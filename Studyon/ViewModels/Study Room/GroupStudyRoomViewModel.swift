//
//  GroupStudyRoomViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/11/25.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import ActivityKit
import WidgetKit

// MARK: - ServerClock
/// Keeps device time aligned with Firebase server time for sub-second sync across clients.
final class ServerClock: ObservableObject {
    static let shared = ServerClock()
    @Published private(set) var offsetMS: Double = 0
    private var ref: DatabaseReference?

    private init() {}

    func start() {
        let r = Database.database().reference(withPath: ".info/serverTimeOffset")
        ref = r
        r.observe(.value) { snap in
            self.offsetMS = (snap.value as? Double) ?? 0
        }
    }

    func stop() {
        ref?.removeAllObservers()
        ref = nil
    }

    var now: Date { Date().addingTimeInterval(offsetMS / 1000.0) }
}

// MARK: - GroupStudyRoomViewModel
final class GroupStudyRoomViewModel: ObservableObject {
    // Inputs
    private let roomId: String
    private let currentUserId: String
    private let isHost: Bool

    // Outputs (bind these to UI)
    @Published var remainingSeconds: Int = 0
    @Published var phase: String = "break" // or "work"
    @Published var isPaused: Bool = true
    @Published var hostId: String? = nil
    @Published var roomTitle: String = "Study Room ☕️"
    @Published private(set) var pomodoroLengthSec: Int = 25 * 60
    @Published private(set) var breakLengthSec: Int = 5 * 60


    // make an object to store more
    // Optional: presence map from RTDB (uid -> "online"/"offline")
    @Published var presence: [String: String] = [:]

    // XP tracking
    private var workSessionStart: Date?
    @Published var totalWorkTimeInSession: TimeInterval = 0
    private let statsManager = UserStatsManager.shared

    // Live Activity
    private var liveActivity: Activity<PomodoroWidgetAttributes>?

    // App Blocking
    private let appBlockingManager = AppBlockingManager.shared

    // Background Task Manager
    private let backgroundTaskManager = BackgroundTaskManager.shared

    // Session summary tracking
    @Published var showSessionSummary = false
    @Published var totalXPGained: Int = 0
    @Published var oldXP: Int = 0
    @Published var newXP: Int = 0

    // Internals
    private var roomListener: ListenerRegistration?
    private var ticker: AnyCancellable?
    private var rtdbPresenceHandle: DatabaseHandle?
    private var rtdbPresenceRef: DatabaseReference?

    private var endAt: Date = Date() // authoritative end when running
    private var sessionStartDate: Date? // Track start date for Live Activity

    init(roomId: String, currentUserId: String, isHost: Bool) {
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.isHost = isHost
    }

    // MARK: Lifecycle
    func start() {
        ServerClock.shared.start()
        listenToRoom()
        observePresence()
        setPresenceOnline()
        Task { await loadRoomTitle() }
        startLiveActivity()
        // Start blocking apps when joining the room
        appBlockingManager.startBlocking()
        // Start background task to prevent iOS from killing the app
        backgroundTaskManager.startBackgroundTask()
    }

    func stop(showSummary: Bool = true) {
        // Award XP before cleaning up
        awardXPForSession()

        setPresenceOffline()
        roomListener?.remove()
        roomListener = nil
        ticker?.cancel()
        ticker = nil
        if let handle = rtdbPresenceHandle { rtdbPresenceRef?.removeObserver(withHandle: handle) }
        rtdbPresenceHandle = nil
        rtdbPresenceRef = nil
        endLiveActivity()
        // Stop blocking apps when leaving the room
        appBlockingManager.stopBlocking()
        // End background task when session ends
        backgroundTaskManager.endBackgroundTask()
        // Don't stop ServerClock.shared globally (shared across views)

        // Prepare session summary if requested and there was study time
        if showSummary && totalXPGained > 0 {
            prepareSessionSummary()
        }
    }

    deinit { stop(showSummary: false) }

    // MARK: Firestore listening
    private func listenToRoom() {
        roomListener = StudyRoomManager.shared.listen(roomId: roomId) { [weak self] room in
            guard let self = self, let room = room else { return }
            self.hostId = room.hostId
            // Update configured durations from room (fallback to defaults if missing)
            self.pomodoroLengthSec = room.pomodoroLength
            self.breakLengthSec = room.breakLength
            self.applyTimer(room.timer)
            Task { @MainActor in
                self.setRoomTitle(room.title)
            }
        }
    }

    private func applyTimer(_ timer: TimerState?) {
        guard let timer = timer else { return }
        let serverNow = ServerClock.shared.now

        let previousPhase = phase
        let previousPaused = isPaused

        phase = timer.phase ?? "work"
        isPaused = timer.isPaused ?? true

        // Track work session changes
        handlePhaseChange(previousPhase: previousPhase, previousPaused: previousPaused)

        if isPaused {
            // Paused: show remaining if available and stop ticking
            ticker?.cancel()
            if let rem = timer.remainingSec { remainingSeconds = max(0, rem) }
            else if let started = timer.startedAt, let duration = timer.durationSec {
                let elapsed = Int(max(0, serverNow.timeIntervalSince(started)))
                remainingSeconds = max(0, (duration - elapsed))
            }
        } else {
            // Running: compute endAt from startedAt + duration
            if let started = timer.startedAt, let duration = timer.durationSec {
                endAt = started.addingTimeInterval(TimeInterval(duration))
                sessionStartDate = started
                startTicker()
                tick() // immediate UI update
            }
        }

        // Update Live Activity whenever timer state changes
        updateLiveActivity()
    }

    // MARK: Room Metadata
    @MainActor
    private func setRoomTitle(_ title: String?) {
        let trimmed = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.roomTitle = trimmed.isEmpty ? "Study Room ☕️" : trimmed
    }

    /// Loads the room title from Firestore and publishes it.
    func loadRoomTitle() async {
        do {
            if let room = try? await StudyRoomManager.shared.getRoom(roomId: roomId) {
                await MainActor.run { self.setRoomTitle(room.title) }
            } else {
                await MainActor.run { self.setRoomTitle(nil) }
            }
        }
    }

    // MARK: Ticker
    private func startTicker() {
        ticker?.cancel()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        let now = ServerClock.shared.now
        let secs = max(0, Int(endAt.timeIntervalSince(now)))
        if secs != remainingSeconds { remainingSeconds = secs }
    }

    // MARK: Host controls
    func startWork(durationSec: Int) async {
        guard isHost else { return }
        do { try await StudyRoomManager.shared.startWork(roomId: roomId, durationSec: durationSec) } catch {
            print("startWork error: \(error)")
        }
    }

    func startBreak(durationSec: Int) async {
        guard isHost else { return }
        do { try await StudyRoomManager.shared.startBreak(roomId: roomId, durationSec: durationSec) } catch {
            print("startBreak error: \(error)")
        }
    }

    func pause() async {
        guard isHost else { return }
        let now = ServerClock.shared.now
        let rem = max(0, Int(endAt.timeIntervalSince(now)))
        do { try await StudyRoomManager.shared.pause(roomId: roomId, remainingSec: rem) } catch {
            print("pause error: \(error)")
        }
    }

    func resume() async {
        guard isHost else { return }
        do { try await StudyRoomManager.shared.resume(roomId: roomId) } catch {
            print("resume error: \(error)")
        }
    }

    // MARK: Presence (RTDB)
    /// Observes presence under /status/{roomId}
    /// Uses the Firebase real time database instead of the regular firebase db
    private func observePresence() {
        let ref = Database.database().reference(withPath: "status/\(roomId)")
        rtdbPresenceRef = ref
        rtdbPresenceHandle = ref.observe(.value) { [weak self] snap in
            var map: [String: String] = [:]
            for child in snap.children {
                if let c = child as? DataSnapshot,
                   let dict = c.value as? [String: Any],
                   let state = dict["state"] as? String {
                    map[c.key] = state
                }
            }
            self?.presence = map
        }
    }
    
    private func setPresenceOnline() {
        let userRef = Database.database().reference(withPath: "status/\(roomId)/\(currentUserId)")
        userRef.setValue(["state": "online"])
        userRef.onDisconnectSetValue(["state": "offline"])
    }

    private func setPresenceOffline() {
        let userRef = Database.database().reference(withPath: "status/\(roomId)/\(currentUserId)")
        userRef.setValue(["state": "offline"])
        userRef.cancelDisconnectOperations()
    }

    // MARK: App Lifecycle Handling
    /// Called when app becomes active - ensures presence is set to online
    func restorePresence() {
        let userRef = Database.database().reference(withPath: "status/\(roomId)/\(currentUserId)")
        userRef.setValue(["state": "online"])
        // Re-establish onDisconnect handler in case connection was reset
        userRef.onDisconnectSetValue(["state": "offline"])
    }

    /// Called when app goes to background - maintains presence but prepares for potential disconnect
    func prepareForBackground() {
        // Keep the user online - Firebase will handle actual disconnection if needed
        // The onDisconnect handler will automatically set offline if connection drops
        // We don't explicitly set to offline here because the user is still "in" the room
    }

    // MARK: XP Tracking
    private func handlePhaseChange(previousPhase: String, previousPaused: Bool) {
        // Starting a work session (not paused, work phase)
        if phase == "work" && !isPaused && (previousPhase != "work" || previousPaused) {
            startWorkSession()
        }

        // Ending a work session (switching to break, pausing, or leaving work phase)
        if previousPhase == "work" && !previousPaused && (phase != "work" || isPaused) {
            endWorkSession()
        }
    }

    private func startWorkSession() {
        workSessionStart = Date()
        print("GroupStudyRoom: Started work session tracking")
    }

    private func endWorkSession() {
        guard let start = workSessionStart else { return }
        let workTime = Date().timeIntervalSince(start)
        totalWorkTimeInSession += workTime
        workSessionStart = nil
        print("GroupStudyRoom: Ended work session. Duration: \(Int(workTime))s. Total: \(Int(totalWorkTimeInSession))s")
    }

    /// Call this when the user leaves the room to award XP for all accumulated work time
    func awardXPForSession() {
        // End any active work session first
        if phase == "work" && !isPaused {
            endWorkSession()
        }

        guard totalWorkTimeInSession > 0 else {
            print("GroupStudyRoom: No work time to award XP for")
            return
        }

        // Capture the time value before resetting (to avoid race conditions)
        let workTime = totalWorkTimeInSession
        let minutes = Int(workTime / 60)
        let baseXP = minutes // 1 XP per minute
        let groupBonus = 20 // Bonus XP for studying in a group room
        let totalXP = baseXP + groupBonus

        // Store for session summary
        totalXPGained = totalXP

        // Reset immediately to prevent double-awarding
        totalWorkTimeInSession = 0

        guard baseXP > 0 else {
            print("GroupStudyRoom: Work time less than 1 minute, no XP awarded")
            return
        }

        Task {
            do {
                try await statsManager.recordStudyTime(userId: currentUserId, date: Date(), seconds: workTime)
                try await statsManager.incrementXP(userId: currentUserId, by: totalXP)
                print("GroupStudyRoom: Awarded \(totalXP) XP (\(baseXP) from time + \(groupBonus) group bonus) for \(Int(workTime))s of work time")
            } catch {
                print("GroupStudyRoom: Failed to award XP: \(error)")
            }
        }
    }

    /// Prepare and show session summary
    func prepareSessionSummary() {
        Task {
            do {
                // Fetch current XP to calculate old/new
                let stats = try await statsManager.fetchStats(userId: currentUserId)
                let currentXP = stats.xp ?? 0

                await MainActor.run {
                    self.newXP = currentXP
                    self.oldXP = currentXP - totalXPGained
                    self.showSessionSummary = true
                }
            } catch {
                print("Failed to fetch stats for summary:", error)
            }
        }
    }

    // MARK: Utils
    func formattedRemaining() -> String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    /// Fetches the user's profile picture URL from Firestore, if available.
    func profilePhotoURL(for userId: String) async throws -> URL? {
        let user = try await UserManager.shared.getUser(userId: userId)
        guard let urlString = user.photoUrl, let url = URL(string: urlString) else { return nil }
        return url
    }
    
    // Cache for names
    @Published private(set) var userNames: [String: String] = [:] // uid -> display name
    
    // Synchronous accessor that triggers fetch if needed
    func name(for uid: String) -> String? {
        if let cached = userNames[uid], !cached.isEmpty {
            return cached
        } else {
            Task { await fetchNameIfNeeded(for: uid) }
            return nil
        }
    }
    
    // Fetch and cache if missing
    @MainActor
    func fetchNameIfNeeded(for uid: String) async {
        if userNames[uid] != nil { return }
        do {
            let name = try await UserManager.shared.fetchDisplayName(for: uid)
            userNames[uid] = name
        } catch {
            // Store a fallback so we don't refetch constantly
            userNames[uid] = uid
        }
    }
    
    // Optional: Prefetch for all current presence UIDs
    @MainActor
    func prefetchNamesForCurrentPresence() async {
        let uids = Array(presence.keys)
        await withTaskGroup(of: Void.self) { group in
            for uid in uids {
                group.addTask { [weak self] in
                    await self?.fetchNameIfNeeded(for: uid)
                }
            }
        }
    }

    // MARK: Live Activity
    func startLiveActivity() {
        let attributes = PomodoroWidgetAttributes(name: roomTitle)
        let totalDuration = phase == "break" ? breakLengthSec : pomodoroLengthSec
        let now = Date()
        let startDate = sessionStartDate ?? now
        let endDate = endAt

        let contentState = PomodoroWidgetAttributes.ContentState(
            timeRemaining: TimeInterval(remainingSeconds),
            isBreak: phase == "break",
            isPaused: isPaused,
            totalDuration: TimeInterval(totalDuration),
            startDate: startDate,
            endDate: endDate
        )
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        do {
            liveActivity = try Activity<PomodoroWidgetAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateLiveActivity() {
        guard let liveActivity else { return }
        let totalDuration = phase == "break" ? breakLengthSec : pomodoroLengthSec
        let now = Date()
        let startDate: Date
        let endDate: Date

        if isPaused {
            endDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
            startDate = endDate.addingTimeInterval(-TimeInterval(totalDuration))
        } else {
            startDate = sessionStartDate ?? now
            endDate = self.endAt
        }

        let contentState = PomodoroWidgetAttributes.ContentState(
            timeRemaining: TimeInterval(remainingSeconds),
            isBreak: phase == "break",
            isPaused: isPaused,
            totalDuration: TimeInterval(totalDuration),
            startDate: startDate,
            endDate: endDate
        )
        Task {
            await liveActivity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }

    func endLiveActivity() {
        guard let liveActivity else { return }
        let finalState = PomodoroWidgetAttributes.ContentState(
            timeRemaining: 0,
            isBreak: false,
            isPaused: false,
            totalDuration: 0,
            startDate: sessionStartDate ?? Date(),
            endDate: endAt
        )
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await liveActivity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
}

