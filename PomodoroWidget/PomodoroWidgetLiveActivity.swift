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
            HStack {
                
                Image("onStudy_app_icon_transSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    

                
                VStack(alignment: .leading) {
                    // timer
                    if context.state.isPaused {
                        Text(timeString(from: context.state.timeRemaining))
                            .font(.title)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                            
                    } else {
                        Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                            .font(.title)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                    }
                    
                    
                    Text(context.state.isBreak ? "Break" : "Focus")
                        .padding(.leading, 5)
                        .fontWidth(.expanded)
                }
                .activitySystemActionForegroundColor(Color.black)
                
                Spacer()
            }
            .padding(.leading)

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
                    }
                }
            } compactLeading: {
                Image("onStudy_app_icon_transSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
            } compactTrailing: {
                    if context.state.isPaused {
                        Text(timeString(from: context.state.timeRemaining))
                            .font(.body)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                    } else {
                        Text(timerInterval: Date()...Date().addingTimeInterval(context.state.timeRemaining), countsDown: true)
                            .font(.body)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                }
            } minimal: {
                VStack {
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
        PomodoroWidgetAttributes.ContentState(timeRemaining: 900, isBreak: false, isPaused: false)
     }
     
     fileprivate static var starEyes: PomodoroWidgetAttributes.ContentState {
         PomodoroWidgetAttributes.ContentState(timeRemaining: 300, isBreak: true, isPaused: false)
     }
}

#Preview("Notification", as: .content, using: PomodoroWidgetAttributes.preview) {
   PomodoroWidgetLiveActivity()
} contentStates: {
    PomodoroWidgetAttributes.ContentState.smiley
    PomodoroWidgetAttributes.ContentState.starEyes
}

