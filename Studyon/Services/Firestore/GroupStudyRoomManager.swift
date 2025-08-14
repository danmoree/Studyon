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





struct GroupStudyRoom: Identifiable, Codable {
    var roomId: String
    let title: String?
    let description: String?
    let creatorId: String? // userID
    let memberIds: [String]?
    let createdAt: Date?
    let startTime: Date?
    let endTime: Date?
    let maxMemberLimit: Int?
    let pomodoroLength: Int
    let breakLength: Int
    let isPrivate: Bool?

    // New fields for group sessions
    let hostId: String?
    let timer: TimerState? // Authoritative, shared timer state

    var id: String { roomId }

    init(
        roomId: String,
        title: String?,
        description: String? = nil,
        creatorId: String?,
        memberIds: [String]? = nil,
        createdAt: Date?,
        startTime: Date?,
        endTime: Date?,
        maxMemberLimit: Int? = nil,
        isPrivate: Bool? = true,
        hostId: String? = nil,
        timer: TimerState? = nil,
        pomodoroLength: Int,
        breakLength: Int
    ) {
        self.roomId = roomId
        self.title = title
        self.description = description
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.startTime = startTime
        self.endTime = endTime
        self.maxMemberLimit = maxMemberLimit
        self.isPrivate = isPrivate
        self.hostId = hostId
        self.timer = timer
        self.pomodoroLength = pomodoroLength
        self.breakLength = breakLength
    }

    enum CodingKeys: String, CodingKey {
        case breakLength = "break_length"
        case createdAt = "created_at"
        case creatorId = "creator_id"
        case description = "description"
        case endTime = "end_time"
        case hostId = "host_id"
        case isPrivate = "is_private"
        case maxMemberLimit = "max_member_limit"
        case memberIds = "member_ids"
        case pomodoroLength = "pomodoro_length"
        case roomId = "room_id"
        case startTime = "start_time"
        case timer = "timer"
        case title = "title"
    }
}

/// Shared group Pomodoro timer state stored on the room document
struct TimerState: Codable {
    /// "work" or "break"
    let phase: String?
    /// Whether the timer is paused
    let isPaused: Bool?
    /// Total duration of the current phase (seconds)
    let durationSec: Int?
    /// When running: server-set start time of the current phase
    let startedAt: Date?
    /// Optional convenience – may be omitted; clients can compute endAt = startedAt + durationSec
    let endAt: Date?
    /// If paused, remaining seconds in current phase
    let remainingSec: Int?
    /// Monotonic counter bumped on each state change to bust caches & distinguish rapid writes
    let generation: Int?

    enum CodingKeys: String, CodingKey {
        case phase = "phase"
        case isPaused = "is_paused"
        case durationSec = "duration_sec"
        case startedAt = "started_at"
        case endAt = "end_at"
        case remainingSec = "remaining_sec"
        case generation = "generation"
    }
}

final class StudyRoomManager {
    static let shared = StudyRoomManager()
    private let db = Firestore.firestore()

    private func roomRef(_ roomId: String) -> DocumentReference {
        db.collection("rooms").document(roomId)
    }

    // MARK: - Listening
    /// Listen to a room document and decode into StudyRoom
    @discardableResult
    func listen(roomId: String, onChange: @escaping (GroupStudyRoom?) -> Void) -> ListenerRegistration {
        roomRef(roomId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                onChange(nil)
                return
            }
            do {
                let room = try snapshot.data(as: GroupStudyRoom.self)
                onChange(room)
            } catch {
                print("[StudyRoomManager] decode error: \(error)")
                onChange(nil)
            }
        }
    }

    // MARK: - Queries
    /// Listen to currently active rooms (timer exists and is not paused).
    /// Returns rooms sorted by most recently updated (best-effort using Firestore snapshot order).
    @discardableResult
    func listenActiveRooms(onChange: @escaping ([GroupStudyRoom]) -> Void) -> ListenerRegistration {
        return db.collection("rooms")
            .whereField("timer.is_paused", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    onChange([])
                    return
                }
                let rooms: [GroupStudyRoom] = snapshot.documents.compactMap { doc in
                    do { return try doc.data(as: GroupStudyRoom.self) } catch { return nil }
                }
                onChange(rooms)
            }
    }

    // MARK: - Timer commands (host only)
    /// Start a work phase
    func startWork(roomId: String, durationSec: Int) async throws {
        try await roomRef(roomId).updateData([
            "timer.phase": "work",
            "timer.is_paused": false,
            "timer.duration_sec": durationSec,
            "timer.remaining_sec": FieldValue.delete(),
            "timer.started_at": FieldValue.serverTimestamp(),
            "timer.generation": FieldValue.increment(Int64(1))
        ])
    }

    /// Start a break phase
    func startBreak(roomId: String, durationSec: Int) async throws {
        try await roomRef(roomId).updateData([
            "timer.phase": "break",
            "timer.is_paused": false,
            "timer.duration_sec": durationSec,
            "timer.remaining_sec": FieldValue.delete(),
            "timer.started_at": FieldValue.serverTimestamp(),
            "timer.generation": FieldValue.increment(Int64(1))
        ])
    }

    /// Pause the timer. Pass the authoritative remaining seconds computed on the client using server clock offset.
    func pause(roomId: String, remainingSec: Int) async throws {
        let timerPatch: [String: Any] = [
            "timer.is_paused": true,
            "timer.remaining_sec": remainingSec,
            "timer.started_at": FieldValue.delete(),
            "timer.generation": FieldValue.increment(Int64(1))
        ]
        try await roomRef(roomId).updateData(timerPatch)
    }

    /// Resume from a paused state. Reads the current remaining_sec in a transaction and restarts using that as duration.
    func resume(roomId: String) async throws {
        try await db.runTransaction { [weak self] (transaction, errorPointer) -> Any? in
            guard let self = self else { return nil }
            let ref = self.roomRef(roomId)
            let snap: DocumentSnapshot
            do { snap = try transaction.getDocument(ref) } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            guard let timer = snap.get("timer") as? [String: Any],
                  let remaining = timer["remaining_sec"] as? Int else {
                return nil
            }
            transaction.updateData([
                "timer.is_paused": false,
                "timer.duration_sec": remaining,
                "timer.remaining_sec": FieldValue.delete(),
                "timer.started_at": FieldValue.serverTimestamp(),
                "timer.generation": FieldValue.increment(Int64(1))
            ], forDocument: ref)
            return nil
        }
    }
}

