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
    @Published var phase: String = "work" // or "break"
    @Published var isPaused: Bool = true
    @Published var hostId: String? = nil
    @Published var roomTitle: String = "Study Room ☕️"

    
    // make an object to store more
    // Optional: presence map from RTDB (uid -> "online"/"offline")
    @Published var presence: [String: String] = [:]

    // Internals
    private var roomListener: ListenerRegistration?
    private var ticker: AnyCancellable?
    private var rtdbPresenceHandle: DatabaseHandle?
    private var rtdbPresenceRef: DatabaseReference?

    private var endAt: Date = Date() // authoritative end when running

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
    }

    func stop() {
        setPresenceOffline()
        roomListener?.remove()
        roomListener = nil
        ticker?.cancel()
        ticker = nil
        if let handle = rtdbPresenceHandle { rtdbPresenceRef?.removeObserver(withHandle: handle) }
        rtdbPresenceHandle = nil
        rtdbPresenceRef = nil
        // Don't stop ServerClock.shared globally (shared across views)
    }

    deinit { stop() }

    // MARK: Firestore listening
    private func listenToRoom() {
        roomListener = StudyRoomManager.shared.listen(roomId: roomId) { [weak self] room in
            guard let self = self, let room = room else { return }
            self.hostId = room.hostId
            self.applyTimer(room.timer)
            Task { @MainActor in
                self.setRoomTitle(room.title)
            }
        }
    }

    private func applyTimer(_ timer: TimerState?) {
        guard let timer = timer else { return }
        let serverNow = ServerClock.shared.now

        phase = timer.phase ?? "work"
        isPaused = timer.isPaused ?? true

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
                startTicker()
                tick() // immediate UI update
            }
        }
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
}

