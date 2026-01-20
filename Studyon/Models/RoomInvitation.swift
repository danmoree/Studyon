//
//  RoomInvitation.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/19/26.
//

import Foundation
import FirebaseFirestore

// MARK: - RoomInvite (Canonical source in rooms/{roomId}/invites/{uid})
struct RoomInvite: Identifiable, Codable {
    let inviteId: String
    let roomId: String
    let invitedBy: String
    let status: String
    let invitedAt: Date
    let respondedAt: Date?

    var id: String { inviteId }

    enum CodingKeys: String, CodingKey {
        case inviteId = "invite_id"
        case roomId = "room_id"
        case invitedBy = "invited_by"
        case status = "status"
        case invitedAt = "invited_at"
        case respondedAt = "responded_at"
    }

    init(inviteId: String, roomId: String, invitedBy: String, status: String, invitedAt: Date, respondedAt: Date?) {
        self.inviteId = inviteId
        self.roomId = roomId
        self.invitedBy = invitedBy
        self.status = status
        self.invitedAt = invitedAt
        self.respondedAt = respondedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inviteId = try container.decode(String.self, forKey: .inviteId)
        roomId = try container.decode(String.self, forKey: .roomId)
        invitedBy = try container.decode(String.self, forKey: .invitedBy)
        status = try container.decode(String.self, forKey: .status)
        invitedAt = try container.decode(Timestamp.self, forKey: .invitedAt).dateValue()
        respondedAt = try container.decodeIfPresent(Timestamp.self, forKey: .respondedAt)?.dateValue()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inviteId, forKey: .inviteId)
        try container.encode(roomId, forKey: .roomId)
        try container.encode(invitedBy, forKey: .invitedBy)
        try container.encode(status, forKey: .status)
        try container.encode(Timestamp(date: invitedAt), forKey: .invitedAt)
        if let respondedAt = respondedAt {
            try container.encode(Timestamp(date: respondedAt), forKey: .respondedAt)
        }
    }
}

// MARK: - RoomLink (User inbox index at users/{uid}/roomLinks/{roomId})
struct RoomLink: Identifiable, Codable {
    let roomId: String
    let userId: String
    let status: String
    let invitedBy: String
    let roomTitle: String?
    let roomDescription: String?
    let hostName: String?
    let startTime: Date?
    let endTime: Date?
    let activeUntil: Date?
    let invitedAt: Date

    var id: String { roomId }

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case userId = "user_id"
        case status = "status"
        case invitedBy = "invited_by"
        case roomTitle = "room_title"
        case roomDescription = "room_description"
        case hostName = "host_name"
        case startTime = "start_time"
        case endTime = "end_time"
        case activeUntil = "active_until"
        case invitedAt = "invited_at"
    }

    init(roomId: String, userId: String, status: String, invitedBy: String, roomTitle: String?, roomDescription: String?, hostName: String?, startTime: Date?, endTime: Date?, activeUntil: Date?, invitedAt: Date) {
        self.roomId = roomId
        self.userId = userId
        self.status = status
        self.invitedBy = invitedBy
        self.roomTitle = roomTitle
        self.roomDescription = roomDescription
        self.hostName = hostName
        self.startTime = startTime
        self.endTime = endTime
        self.activeUntil = activeUntil
        self.invitedAt = invitedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roomId = try container.decode(String.self, forKey: .roomId)
        userId = try container.decode(String.self, forKey: .userId)
        status = try container.decode(String.self, forKey: .status)
        invitedBy = try container.decode(String.self, forKey: .invitedBy)
        roomTitle = try container.decodeIfPresent(String.self, forKey: .roomTitle)
        roomDescription = try container.decodeIfPresent(String.self, forKey: .roomDescription)
        hostName = try container.decodeIfPresent(String.self, forKey: .hostName)
        startTime = try container.decodeIfPresent(Timestamp.self, forKey: .startTime)?.dateValue()
        endTime = try container.decodeIfPresent(Timestamp.self, forKey: .endTime)?.dateValue()
        activeUntil = try container.decodeIfPresent(Timestamp.self, forKey: .activeUntil)?.dateValue()
        invitedAt = try container.decode(Timestamp.self, forKey: .invitedAt).dateValue()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roomId, forKey: .roomId)
        try container.encode(userId, forKey: .userId)
        try container.encode(status, forKey: .status)
        try container.encode(invitedBy, forKey: .invitedBy)
        try container.encodeIfPresent(roomTitle, forKey: .roomTitle)
        try container.encodeIfPresent(roomDescription, forKey: .roomDescription)
        try container.encodeIfPresent(hostName, forKey: .hostName)
        if let startTime = startTime {
            try container.encode(Timestamp(date: startTime), forKey: .startTime)
        }
        if let endTime = endTime {
            try container.encode(Timestamp(date: endTime), forKey: .endTime)
        }
        if let activeUntil = activeUntil {
            try container.encode(Timestamp(date: activeUntil), forKey: .activeUntil)
        }
        try container.encode(Timestamp(date: invitedAt), forKey: .invitedAt)
    }
}

// MARK: - RoomMembership (Embedded in room document)
struct RoomMembership: Codable {
    let uid: String
    let status: String
    let joinedAt: Date?

    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case status = "status"
        case joinedAt = "joined_at"
    }

    init(uid: String, status: String, joinedAt: Date?) {
        self.uid = uid
        self.status = status
        self.joinedAt = joinedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        status = try container.decode(String.self, forKey: .status)
        joinedAt = try container.decodeIfPresent(Timestamp.self, forKey: .joinedAt)?.dateValue()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(status, forKey: .status)
        if let joinedAt = joinedAt {
            try container.encode(Timestamp(date: joinedAt), forKey: .joinedAt)
        }
    }
}
