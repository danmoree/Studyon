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
    let dayStreak: Int?
    let totalTimeStudied: TimeInterval // fancy named double
    var timeStudiedByDate: [String: TimeInterval]?
    let lastStudyDate: Date?
    var sessionCountByDate: [String: Int]?
    let longestSession: TimeInterval?
    
    init(
        xp: Int = 0,
        dayStreak: Int = 0,
        totalTimeStudied: TimeInterval = 0,
        timeStudiedByDate: [String: TimeInterval]? = [:],
        lastStudyDate: Date? = nil,
        sessionCountByDate: [String: Int]? = [:],
        longestSession: TimeInterval = 0
    ) {
        self.xp = xp
        self.dayStreak = dayStreak
        self.totalTimeStudied = totalTimeStudied
        self.timeStudiedByDate = timeStudiedByDate
        self.lastStudyDate = lastStudyDate
        self.sessionCountByDate = sessionCountByDate
        self.longestSession = longestSession
    }
    
    enum CodingKeys: String, CodingKey {
        case xp = "xp"
        case dayStreak = "day_streak"
        case totalTimeStudied = "total_time_studied"
        case timeStudiedByDate = "time_studied_by_date"
        case lastStudyDate = "last_study_date"
        case sessionCountByDate = "session_count_by_date"
        case longestSession = "longest_session"
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
}
