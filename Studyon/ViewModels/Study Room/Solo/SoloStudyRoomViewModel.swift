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

    private var timer: AnyCancellable?
    let studyRoom: SoloStudyRoom

    init(studyRoom: SoloStudyRoom) {
        self.studyRoom = studyRoom
        self.remainingTime = studyRoom.pomDurationSec
        startTimer()
    }

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
            remainingTime -= 1
        } else if !isOnBreak {
            isOnBreak = true
            remainingTime = studyRoom.pomBreakDurationSec
        } else {
            timer?.cancel()
        }
    }

    func pauseToggle() {
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
