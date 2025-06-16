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
        // key ISO8601 date (yyyy-MM-dd)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateKey = formatter.string(from: date)
        
        // target the nested field
        let field = "\(UserStats.CodingKeys.timeStudiedByDate.rawValue).\(dateKey)"
        // increment payload
        let data: [String: Any] = [
            field: FieldValue.increment(Int64(seconds))
        ]
        
        // update
        try await statsDocument(userId: userId).setData(data, merge: true)
    }
}
