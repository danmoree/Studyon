//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  HomeWidgetsViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/13/25.
//

import Foundation
@MainActor
final class HomeWidgetsViewModel: ObservableObject {
    @Published var xp: Int = UserDefaults.standard.integer(forKey: "cachedXP") {
        didSet {
            UserDefaults.standard.set(xp, forKey: "cachedXP")
        }
    }
    @Published var dayStreak: Int = UserDefaults.standard.integer(forKey: "cachedDayStreak") {
        didSet {
            UserDefaults.standard.set(dayStreak, forKey: "cachedDayStreak")
        }
    }
    @Published var secondsStudiedToday: TimeInterval = UserDefaults.standard.double(forKey: "cachedSecondsStudiedToday") {
        didSet {
            UserDefaults.standard.set(secondsStudiedToday, forKey: "cachedSecondsStudiedToday")
        }
    }
    @Published var userStats: UserStats? = nil

    private let statsManager = UserStatsManager.shared
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()
    
    init() {
        if let cachedStats = UserStats.loadFromCache() {
            xp = cachedStats.xp ?? 0
            dayStreak = cachedStats.dayStreak ?? 0
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = .current
            let dateKey = df.string(from: Date())
            secondsStudiedToday = cachedStats.timeStudiedByDate?[dateKey] ?? 0
            userStats = cachedStats
        }
    }
    
    func loadAllStats(for userId: String) async {
        do {
            let stats = try await statsManager.fetchStats(userId: userId)
            // core counters
            xp = stats.xp ?? 0
            dayStreak = stats.dayStreak ?? 0

            // today’s time
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = .current
            let dateKey = df.string(from: Date())
            secondsStudiedToday = stats.timeStudiedByDate?[dateKey] ?? 0
         
            self.userStats = stats
            
            UserStats.cache(stats)
            
            print("Fetched map:", stats.timeStudiedByDate as Any)
            //print("Looking up:", key)
            print("xp:", xp)
            // … pull any other fields …
        } catch {
            print("Failed loading home stats:", error)
            // leave defaults or show an error state
        }
    }
    
    func getLevel(from xp: Int) -> String {
        switch xp {
        case 0..<100:
            return "🐥 LVL 1"
        case 100..<300:
            return "🍎 LVL 2"
        case 300..<600:
            return "🤓 LVL 3"
        case 600..<1000:
            return "🎒 LVL 4"
        case 1000..<1500:
            return "📚 LVL 5"
        case 1500..<2100:
            return "✏️ LVL 6"
        case 2100..<2800:
            return "👨‍🎓 LVL 7"
        case 2800..<3600:
            return "🧠 LVL 8"
        case 3600..<4500:
            return "🧠 LVL 9"
        default:
            return "🧠 LVL Legend"
        }
    }
    
}
