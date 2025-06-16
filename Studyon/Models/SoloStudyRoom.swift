//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
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
