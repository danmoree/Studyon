//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StatsManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/11/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct UserStats: Codable {
    let xp: Int?
    var dayStreak: Int?
    let totalTimeStudied: TimeInterval // fancy named double
    var timeStudiedByDate: [String: TimeInterval]?
    let lastStudyDate: Date? // yet to implement
    var sessionCountByDate: [String: Int]? // yet to implement
    let longestSession: TimeInterval? // yet to implement
    var lastLoginDate: Date?
    
    init(
        xp: Int = 0,
        dayStreak: Int = 0,
        totalTimeStudied: TimeInterval = 0,
        timeStudiedByDate: [String: TimeInterval]? = [:],
        lastStudyDate: Date? = nil,
        sessionCountByDate: [String: Int]? = [:],
        longestSession: TimeInterval = 0,
        lastLoginDate: Date? = nil
    ) {
        self.xp = xp
        self.dayStreak = dayStreak
        self.totalTimeStudied = totalTimeStudied
        self.timeStudiedByDate = timeStudiedByDate
        self.lastStudyDate = lastStudyDate
        self.sessionCountByDate = sessionCountByDate
        self.longestSession = longestSession
        self.lastLoginDate = lastLoginDate
    }
    
    enum CodingKeys: String, CodingKey {
        case xp = "xp"
        case dayStreak = "day_streak"
        case totalTimeStudied = "total_time_studied"
        case timeStudiedByDate = "time_studied_by_date"
        case lastStudyDate = "last_study_date"
        case sessionCountByDate = "session_count_by_date"
        case longestSession = "longest_session"
        case lastLoginDate = "last_login_date"
    }
    
    // from firestore
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.xp = try container.decodeIfPresent(Int.self, forKey: .xp)
        self.dayStreak = try container.decodeIfPresent(Int.self, forKey: .dayStreak)
        self.totalTimeStudied = try container.decodeIfPresent(TimeInterval.self, forKey: .totalTimeStudied) ?? 0
        self.timeStudiedByDate = try container.decodeIfPresent([String : TimeInterval].self, forKey: .timeStudiedByDate)
        self.lastStudyDate = try container.decodeIfPresent(Date.self, forKey: .lastStudyDate)
        self.sessionCountByDate = try container.decodeIfPresent([String : Int].self, forKey: .sessionCountByDate)
        self.longestSession = try container.decodeIfPresent(TimeInterval.self, forKey: .longestSession)
        self.lastLoginDate  = try container.decodeIfPresent(Date.self, forKey: .lastLoginDate)
    }
    
   func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(xp, forKey: .xp)
        try container.encode(dayStreak, forKey: .dayStreak)
        try container.encode(totalTimeStudied, forKey: .totalTimeStudied)
        try container.encodeIfPresent(timeStudiedByDate, forKey: .timeStudiedByDate)
        try container.encodeIfPresent(lastStudyDate, forKey: .lastStudyDate)
        try container.encodeIfPresent(sessionCountByDate, forKey: .sessionCountByDate)
        try container.encode(longestSession, forKey: .longestSession)
        try container.encode(lastLoginDate, forKey: .lastLoginDate)
    }
    
    // UserDefaults Caching
    static let userDefaultsKey = "cachedUserStats"

    static func cache(_ stats: UserStats) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stats) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    static func loadFromCache() -> UserStats? {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let stats = try? decoder.decode(UserStats.self, from: data) {
                return stats
            }
        }
        return nil
    }
    
    static func clearCache() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

final class UserStatsManager {
    
    static let shared = UserStatsManager()
    private init() {}
    
    private let statsCollection = Firestore.firestore().collection("users_stats")
    
    private func statsDocument(userId: String) -> DocumentReference {
        statsCollection.document(userId)
    }
    
    func fetchStats(userId: String) async throws -> UserStats {
        try await statsDocument(userId: userId).getDocument(as: UserStats.self)
    }
    
    func setStats(userId: String, stats: UserStats) async throws {
        try statsDocument(userId: userId).setData(from: stats, merge: true)
    }
    
    func incrementXP(userId: String, by points: Int) async throws {
        let data: [String: Any] = [ UserStats.CodingKeys.xp.rawValue: FieldValue.increment(Int64(points)) ]
        try await statsDocument(userId: userId).updateData(data)
    }
    
    func recordStudyTime(userId: String, date: Date, seconds: TimeInterval) async throws {
        // 1) Format the date key (yyyy-MM-dd)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current
        let dateKey = df.string(from: date)
        
        // 2) Paths for mapField and nested entry
        let mapField = UserStats.CodingKeys.timeStudiedByDate.rawValue
        let nestedPath = "\(mapField).\(dateKey)"
        let incrementData: [String: Any] = [
            nestedPath: FieldValue.increment(Int64(seconds))
        ]
        
        do {
            // Try to increment existing day entry
            try await statsDocument(userId: userId).updateData(incrementData)
        } catch {
            // Fallback: first-time write, create the map with this date
            let initialData: [String: Any] = [
                mapField: [ dateKey: seconds ]
            ]
            try await statsDocument(userId: userId).setData(initialData, merge: true)
        }
    }
    
    func checkAndUpdateLoginStreak(userId: String) async throws {
        var stats: UserStats
        do {
            stats = try await fetchStats(userId: userId)
        } catch {
            // If its missing then make it
            let newStats = UserStats()
            try await setStats(userId: userId, stats: newStats)
            stats = newStats
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastLogin = stats.lastLoginDate.map({ calendar.startOfDay(for: $0) }) else {
            // first time login, set today and dayStreak = 1
            stats.lastLoginDate = today
            stats.dayStreak = 1
            try await setStats(userId: userId, stats: stats)
            return
        }

        // already logged in today — do nothing
        if calendar.isDateInToday(lastLogin) {
            return
        }

        if calendar.isDate(today, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: lastLogin)!) {
            stats.dayStreak = (stats.dayStreak ?? 0) + 1
        } else {
            stats.dayStreak = 1
        }

        stats.lastLoginDate = today
        try await setStats(userId: userId, stats: stats)
    }
}
