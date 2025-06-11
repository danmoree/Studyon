//
//  SoloStudyRoomViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/9/25.
//

import Foundation
import Combine

final class SoloStudyRoomViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var isPaused: Bool = false
    @Published var isOnBreak: Bool = false
    @Published var autoStart: Bool = false // auto start countdown

    private var timer: AnyCancellable?
    let studyRoom: SoloStudyRoom

    init(studyRoom: SoloStudyRoom) {
        self.studyRoom = studyRoom
        self.remainingTime = studyRoom.pomDurationSec
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
        guard !isPaused else { return }
        if remainingTime > 0 {
            // Countdown normally
            remainingTime -= 1
        } else {
            // Time reached zero
            if !isOnBreak {
                // Work phase ended
                if autoStart {
                    // Automatically begin break
                    isOnBreak = true
                    remainingTime = studyRoom.pomBreakDurationSec
                } else {
                    // Pause until user starts break
                    isPaused = true
                }
            } else {
                // Break phase ended
                if autoStart {
                    // Automatically begin next work phase
                    isOnBreak = false
                    remainingTime = studyRoom.pomDurationSec
                } else {
                    // Pause until user restarts work
                    isPaused = true
                }
            }
        }
    }

    
    func pauseToggle() {
        // If paused because work just ended
        if isPaused && remainingTime == 0 && !isOnBreak {
            isOnBreak = true
            remainingTime = studyRoom.pomBreakDurationSec
        }
        else if isPaused && remainingTime == 0 && isOnBreak {
            isOnBreak = false
            remainingTime = studyRoom.pomDurationSec
        }
        isPaused.toggle()
    }
    

    func timeString() -> String {
        let m = remainingTime / 60
        let s = remainingTime % 60
        return String(format: "%02d:%02d", m, s)
    }

    deinit {
        timer?.cancel()
    }
}
