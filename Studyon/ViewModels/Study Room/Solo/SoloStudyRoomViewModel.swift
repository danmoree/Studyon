//
//  SoloStudyRoomViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/9/25.
//

import Foundation
import Combine
import FirebaseAuth
import ActivityKit
import WidgetKit

final class SoloStudyRoomViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var progress: Double = 0.0 // 0 = top, 1 = bottom
    @Published var isPaused: Bool = false
    @Published var isOnBreak: Bool = false
    @Published var autoStart: Bool = false // auto start countdown

    private var timer: AnyCancellable?
    private var sessionStart: Date?
    private var sessionEnd: Date?
    let studyRoom: SoloStudyRoom
    private let statsManager = UserStatsManager.shared
    private let minRecordableSessionSeconds: TimeInterval = 10 // Threashold for calling recordWorkSession()
    
    private var liveActivity: Activity<PomodoroWidgetAttributes>?

    private static let notificationPermissionKey = "didRequestNotificationPermission"
    
    init(studyRoom: SoloStudyRoom) {
        self.studyRoom = studyRoom
        self.remainingTime = studyRoom.pomDurationSec
        self.progress = 0.0
        sessionStart = Date() // start time
        sessionEnd = sessionStart!.addingTimeInterval(TimeInterval(studyRoom.pomDurationSec)) // pom sesh should end at this time
        startTimer()
        startLiveActivity()
        requestNotificationPermissionIfNeeded()
        NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(studyRoom.pomDurationSec), sessionType: "Pomodoro")
    }
    
    private func requestNotificationPermissionIfNeeded() {
        let key = SoloStudyRoomViewModel.notificationPermissionKey
        if !UserDefaults.standard.bool(forKey: key) {
            NotificationsManager.shared.requestPermission()
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    // combine timer
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard !isPaused, let end = sessionEnd else { return }
        let secondsLeft = Int(max(0, end.timeIntervalSinceNow))
        remainingTime = secondsLeft
        
        let total = isOnBreak ? studyRoom.pomBreakDurationSec : studyRoom.pomDurationSec
        progress = 1.0 - Double(secondsLeft) / Double(total)
        progress = min(max(progress, 0.0), 1.0)

        if secondsLeft == 0 {
            timer?.cancel()
            if !isOnBreak {
                // Work session ended
                recordWorkSession()
                if autoStart {
                    // begin break
                    isOnBreak = true
                    sessionStart = nil
                    sessionEnd = Date().addingTimeInterval(TimeInterval(studyRoom.pomBreakDurationSec))
                    remainingTime = studyRoom.pomBreakDurationSec
                    startTimer()
                    requestNotificationPermissionIfNeeded()
                    NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(studyRoom.pomBreakDurationSec), sessionType: "Break")
                } else {
                    isPaused = true
                    sessionStart = nil
                    sessionEnd = nil
                    requestNotificationPermissionIfNeeded()
                    NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(studyRoom.pomBreakDurationSec), sessionType: "Break")
                }
            } else {
                // Break ended
                if autoStart {
                    isOnBreak = false
                    sessionStart = Date()
                    sessionEnd = Date().addingTimeInterval(TimeInterval(studyRoom.pomDurationSec))
                    remainingTime = studyRoom.pomDurationSec
                    startTimer()
                    requestNotificationPermissionIfNeeded()
                    NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(studyRoom.pomDurationSec), sessionType: "Pomodoro")
                } else {
                    isPaused = true
                    sessionStart = nil
                    sessionEnd = nil
                    requestNotificationPermissionIfNeeded()
                    NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(studyRoom.pomBreakDurationSec), sessionType: "Break")
                }
            }
        }
        //updateLiveActivity()
    }

    
    func pauseToggle() {
        if !isPaused {
            // Pausing: cancel notification
            NotificationsManager.shared.cancelPomodoroNotification()
        }
        
        if isPaused && remainingTime > 0 {
            // Resuming: schedule notification with remaining time
            requestNotificationPermissionIfNeeded()
            let sessionType = isOnBreak ? "Break" : "Pomodoro"
            NotificationsManager.shared.schedulePomodoroNotification(duration: TimeInterval(remainingTime), sessionType: sessionType)
        }
        
        if !isOnBreak && remainingTime > 0 && !isPaused {
            recordWorkSession()
            sessionStart = nil
        }

        if isPaused && remainingTime == 0 && !isOnBreak {
            isOnBreak = true
            sessionStart = Date()
            sessionEnd = Date().addingTimeInterval(TimeInterval(studyRoom.pomBreakDurationSec))
            remainingTime = studyRoom.pomBreakDurationSec
            startTimer()
        }
        else if isPaused && remainingTime == 0 && isOnBreak {
            isOnBreak = false
            sessionStart = Date()
            sessionEnd = Date().addingTimeInterval(TimeInterval(studyRoom.pomDurationSec))
            remainingTime = studyRoom.pomDurationSec
            startTimer()
        }

        // When resuming from pause (playing), reset sessionStart and sessionEnd so new time is counted only
        // This prevents overlapping or repeated study segments from being logged
        if isPaused == true && remainingTime > 0 {
            sessionStart = Date()
            sessionEnd = Date().addingTimeInterval(TimeInterval(remainingTime))
        }

        isPaused.toggle()
        updateLiveActivity()
    }
    

    func timeString() -> String {
        let m = remainingTime / 60
        let s = remainingTime % 60
        return String(format: "%02d:%02d", m, s)
    }

    func recordWorkSession() {
        if isOnBreak { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let start = sessionStart else { return }
        let seconds = Date().timeIntervalSince(start)
        // Prevent spamming pause/play to exploit study session logging
        guard seconds >= minRecordableSessionSeconds else { return }
        Task {
            do {
                try await statsManager.recordStudyTime(userId: userId, date: Date(), seconds: seconds)
                try await statsManager.incrementXP(userId: userId, by: 20)
            } catch {
                print("Failed to record study time:", error)
            }
        }
    }
    
    func startLiveActivity() {
        let attributes = PomodoroWidgetAttributes(name: "Solo Room")
        let totalDuration = isOnBreak ? studyRoom.pomBreakDurationSec : studyRoom.pomDurationSec
        let contentState = PomodoroWidgetAttributes.ContentState(
            timeRemaining: TimeInterval(remainingTime),
            isBreak: isOnBreak,
            isPaused: isPaused,
            totalDuration: TimeInterval(totalDuration),
            startDate: sessionStart ?? Date(),
            endDate: sessionEnd ?? Date()
            
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
        let totalDuration = isOnBreak ? studyRoom.pomBreakDurationSec : studyRoom.pomDurationSec
        let now = Date()
        let startDate: Date
        let endDate: Date
        if isPaused {
            endDate = now.addingTimeInterval(TimeInterval(remainingTime))
            startDate = endDate.addingTimeInterval(-TimeInterval(totalDuration))
        } else {
            startDate = sessionStart ?? now
            endDate = sessionEnd ?? now.addingTimeInterval(TimeInterval(remainingTime))
        }
        let contentState = PomodoroWidgetAttributes.ContentState(
            timeRemaining: TimeInterval(remainingTime),
            isBreak: isOnBreak,
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
            startDate: sessionStart ?? Date(),
            endDate: sessionEnd ?? Date()
        )
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await liveActivity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
    
    deinit {
        timer?.cancel()
    }
}

