//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  PageIntro.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/15/25.
//

import Foundation

struct PageIntro: Identifiable, Hashable {
    var id: UUID = .init()
    var introAssetImage: String
    var title: String
    var subTitile: String
    var displayAction: Bool = false
}

var pageIntros: [PageIntro] = [
    // Page 1: Solo Study Sessions
    .init(
        introAssetImage: "timer",
        title: "Focus with Pomodoro",
        subTitile: "Track your study time and earn XP with customizable work and break sessions",
        displayAction: false
    ),

    // Page 2: Group Study Rooms
    .init(
        introAssetImage: "person.3.fill",
        title: "Study Together",
        subTitile: "Join friends in real-time synchronized study rooms with shared timers and presence tracking",
        displayAction: false
    ),

    // Page 3: App Blocking
    .init(
        introAssetImage: "hand.raised.fill",
        title: "Stay Focused",
        subTitile: "Block distracting apps during study sessions. Choose your exceptions and let Studyon handle the rest",
        displayAction: false
    ),

    // Page 4: Progress & Achievements
    .init(
        introAssetImage: "chart.line.uptrend.xyaxis",
        title: "Track Your Growth",
        subTitile: "Earn XP, level up, maintain your study streak, and see your progress over time",
        displayAction: false
    ),

    // Page 5: Authentication
    .init(
        introAssetImage: "person.crop.circle.fill",
        title: "Let's Get Started",
        subTitile: "Sign up using your email!",
        displayAction: true
    )
]
