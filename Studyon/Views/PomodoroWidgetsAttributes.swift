//
//  PomodoroWidgetsAttributes.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/20/25.
//

import Foundation
import ActivityKit

struct PomodoroWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var timeRemaining: TimeInterval
        var isBreak: Bool
        var isPaused: Bool
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
