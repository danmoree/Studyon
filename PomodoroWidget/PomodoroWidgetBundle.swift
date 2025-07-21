//
//  PomodoroWidgetBundle.swift
//  PomodoroWidget
//
//  Created by Daniel Moreno on 7/20/25.
//

import WidgetKit
import SwiftUI

@main
struct PomodoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomodoroWidget()
        PomodoroWidgetControl()
        PomodoroWidgetLiveActivity()
    }
}
