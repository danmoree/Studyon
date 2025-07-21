//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  PomodoroAttributes.swift
//  PomodoroWidgetExtension
//
//  Created by Daniel Moreno on 7/20/25.
//

import Foundation
import ActivityKit

struct PomodoroAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: TimeInterval
        var isRunning: Bool
    }

    var sessionTitle: String
}
