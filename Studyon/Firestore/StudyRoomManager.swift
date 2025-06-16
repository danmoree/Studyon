//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyRoomManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/5/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct StudyRoom: Identifiable, Codable {
    var roomId: String
    let title: String?
    let description: String?
    let creatorId: String? // userID
    let memberIds: [String]?
    let createdAt: Date?
    let startTime: Date?
    let endTime: Date?
    let day: Date?
    let maxMemberLimit: Int?
    let isPrivate: Bool?
    let pomIsRunning: Bool?
    let pomDurationSec: Int?
    let pomBreakDurationSec: Int?
    
    var id: String { roomId }
    
    init(roomId: String, title: String?, description: String? = nil, creatorId: String?, memberIds: [String]? = nil, createdAt: Date?, startTime: Date?, endTime: Date?, day: Date?, maxMemberLimit: Int? = nil, isPrivate: Bool? = true, pomIsRunning: Bool?, pomDurationSec: Int?, pomBreakDurationSec: Int?) {
        self.roomId = roomId
        self.title = title
        self.description = description
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.startTime = startTime
        self.endTime = endTime
        self.day = day
        self.maxMemberLimit = maxMemberLimit
        self.isPrivate = isPrivate
        self.pomIsRunning = pomIsRunning
        self.pomDurationSec = pomDurationSec
        self.pomBreakDurationSec = pomBreakDurationSec
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case title = "title"
        case description = "description"
        case creatorId = "creator_id"
        case memberIds = "member_ids"
        case createdAt = "created_at"
        case startTime = "start_time"
        case endTime = "end_time"
        case day = "day"
        case maxMemberLimit = "max_member_limit"
        case isPrivate = "is_private"
        case pomIsRunning = "pom_is_running"
        case pomDurationSec = "pom_duration_sec"
        case pomBreakDurationSec = "pom_break_duration_sec"
    }
    
}
