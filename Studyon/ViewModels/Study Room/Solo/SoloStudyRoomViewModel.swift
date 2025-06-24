//
//  SoloStudyRoomViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/9/25.
//

import Foundation
import Combine
import FirebaseAuth

final class SoloStudyRoomViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var isPaused: Bool = false
    @Published var isOnBreak: Bool = false
    @Published var autoStart: Bool = false // auto start countdown

    private var timer: AnyCancellable?
    private var sessionStart: Date?
    private var sessionEnd: Date?
    let studyRoom: SoloStudyRoom
    private let statsManager = UserStatsManager.shared

    init(studyRoom: SoloStudyRoom) {
        self.studyRoom = studyRoom
        self.remainingTime = studyRoom.pomDurationSec
        sessionStart = Date() // start time
        sessionEnd = sessionStart!.addingTimeInterval(TimeInterval(studyRoom.pomDurationSec)) // pom sesh should end at this time
        startTimer()
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
                } else {
                    isPaused = true
                    sessionStart = nil
                    sessionEnd = nil
                }
            } else {
                // Break ended
                if autoStart {
                    isOnBreak = false
                    sessionStart = Date()
                    sessionEnd = Date().addingTimeInterval(TimeInterval(studyRoom.pomDurationSec))
                    remainingTime = studyRoom.pomDurationSec
                    startTimer()
                } else {
                    isPaused = true
                    sessionStart = nil
                    sessionEnd = nil
                }
            }
        }
    }

    
    func pauseToggle() {
        if !isOnBreak && remainingTime > 0 && !isPaused {
            recordWorkSession()
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

        isPaused.toggle()
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
        Task {
            do {
                try await statsManager.recordStudyTime(userId: userId, date: Date(), seconds: seconds)
                try await statsManager.incrementXP(userId: userId, by: 20)
            } catch {
                print("Failed to record study time:", error)
            }
        }
    }

    
    
    deinit {
        timer?.cancel()
    }
}
