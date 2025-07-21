//
//  PomodoroWidgetLiveActivity.swift
//  PomodoroWidget
//
//  Created by Daniel Moreno on 7/20/25.
//

import ActivityKit
import WidgetKit
import SwiftUI


struct PomodoroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
                if context.state.isPaused {
                    Text(timeString(from: context.state.timeRemaining))
                        .font(.title2)
                        .monospacedDigit()
                } else {
                    Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                        .font(.title2)
                        .monospacedDigit()
                }
                Text(context.state.isBreak ? "Break" : "Focus")
                    .font(.headline)
                    .foregroundColor(context.state.isBreak ? .green : .red)
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        if context.state.isPaused {
                            Text(timeString(from: context.state.timeRemaining))
                                .font(.headline)
                                .monospacedDigit()
                        } else {
                            Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                                .font(.headline)
                                .monospacedDigit()
                        }
                        Text(context.state.isBreak ? "Break" : "Focus")
                            .font(.subheadline)
                            .foregroundColor(context.state.isBreak ? .green : .red)
                        Text("Bottom \(context.state.emoji)")
                    }
                }
            } compactLeading: {
                if context.state.isPaused {
                    Text(timeString(from: context.state.timeRemaining))
                        .font(.caption2)
                        .monospacedDigit()
                } else {
                    Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                        .monospacedDigit()
                }
            } compactTrailing: {
                VStack {
                    Text("T \(context.state.emoji)")
                    if context.state.isPaused {
                        Text(timeString(from: context.state.timeRemaining))
                            .font(.caption2)
                            .monospacedDigit()
                    } else {
                        Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            } minimal: {
                VStack {
                    Text(context.state.emoji)
                    if context.state.isPaused {
                        Text(timeString(from: context.state.timeRemaining))
                            .font(.caption2)
                            .monospacedDigit()
                    } else {
                        Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(timeInterval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension PomodoroWidgetAttributes {
    fileprivate static var preview: PomodoroWidgetAttributes {
        PomodoroWidgetAttributes(name: "World")
    }
}

extension PomodoroWidgetAttributes.ContentState {
    fileprivate static var smiley: PomodoroWidgetAttributes.ContentState {
        PomodoroWidgetAttributes.ContentState(emoji: "😀", timeRemaining: 900, isBreak: false, isPaused: false)
     }
     
     fileprivate static var starEyes: PomodoroWidgetAttributes.ContentState {
         PomodoroWidgetAttributes.ContentState(emoji: "🤩", timeRemaining: 300, isBreak: true, isPaused: false)
     }
}

#Preview("Notification", as: .content, using: PomodoroWidgetAttributes.preview) {
   PomodoroWidgetLiveActivity()
} contentStates: {
    PomodoroWidgetAttributes.ContentState.smiley
    PomodoroWidgetAttributes.ContentState.starEyes
}

