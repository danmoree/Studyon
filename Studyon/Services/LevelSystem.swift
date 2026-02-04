//
//  Created by Daniel Moreno on 2026
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  LevelSystem.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/1/26.
//

import Foundation

struct LevelInfo {
    let level: Int
    let emoji: String
    let xpRequired: Int
    let xpForNextLevel: Int

    var displayName: String {
        "\(emoji) LVL \(level)"
    }

    var progressToNextLevel: Double {
        guard xpForNextLevel > xpRequired else { return 1.0 }
        return Double(xpRequired) / Double(xpForNextLevel)
    }
}

final class LevelSystem {
    static let shared = LevelSystem()

    private init() {}

    // Level thresholds matching HomeWidgetsViewModel
    private let levelThresholds: [(xp: Int, emoji: String)] = [
        (0, "🐥"),      // LVL 1
        (100, "🍎"),    // LVL 2
        (300, "🤓"),    // LVL 3
        (600, "🎒"),    // LVL 4
        (1000, "📚"),   // LVL 5
        (1500, "✏️"),   // LVL 6
        (2100, "👨‍🎓"),   // LVL 7
        (2800, "🧠"),   // LVL 8
        (3600, "🧠"),   // LVL 9
        (4500, "🧠")    // LVL Legend
    ]

    /// Get level info for a given XP amount
    func getLevelInfo(xp: Int) -> LevelInfo {
        var currentLevel = 1
        var currentThreshold = 0
        var nextThreshold = 100
        var emoji = "🐥"

        for (index, threshold) in levelThresholds.enumerated() {
            if xp >= threshold.xp {
                currentLevel = index + 1
                currentThreshold = threshold.xp
                emoji = threshold.emoji

                // Get next threshold
                if index + 1 < levelThresholds.count {
                    nextThreshold = levelThresholds[index + 1].xp
                } else {
                    // Max level reached
                    nextThreshold = threshold.xp
                }
            } else {
                break
            }
        }

        return LevelInfo(
            level: currentLevel,
            emoji: emoji,
            xpRequired: xp - currentThreshold,
            xpForNextLevel: nextThreshold - currentThreshold
        )
    }

    /// Get level number only
    func getLevel(xp: Int) -> Int {
        return getLevelInfo(xp: xp).level
    }

    /// Get display name (emoji + level)
    func getLevelDisplayName(xp: Int) -> String {
        return getLevelInfo(xp: xp).displayName
    }

    /// Check if XP gain causes level up
    func didLevelUp(oldXP: Int, newXP: Int) -> Bool {
        let oldLevel = getLevel(xp: oldXP)
        let newLevel = getLevel(xp: newXP)
        return newLevel > oldLevel
    }

    /// Get the new level after XP gain (if leveled up)
    func getNewLevelIfLeveledUp(oldXP: Int, newXP: Int) -> LevelInfo? {
        if didLevelUp(oldXP: oldXP, newXP: newXP) {
            return getLevelInfo(xp: newXP)
        }
        return nil
    }
}
