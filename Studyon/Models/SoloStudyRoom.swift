//
//  SoloRoomManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/7/25.
//

import Foundation

struct SoloStudyRoom: Identifiable {
    let id: UUID = UUID()
    let createAt: Date
    
    // pomo
    var pomIsRunning: Bool
    var pomDurationSec: Int // in seconds
    var pomBreakDurationSec: Int
}
