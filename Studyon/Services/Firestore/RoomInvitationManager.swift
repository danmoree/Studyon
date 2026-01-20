//
//  RoomInvitationManager.swift
//  Studyon
//
//  Created by Claude on 1/19/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum RoomInvitationError: Error, LocalizedError {
    case userNotLoggedIn
    case roomNotFound
    case alreadyInvited
    case notInvited
    case batchLimitExceeded
    case invalidStatus

    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "You must be logged in to manage invitations."
        case .roomNotFound:
            return "Room not found."
        case .alreadyInvited:
            return "User has already been invited."
        case .notInvited:
            return "No invitation found."
        case .batchLimitExceeded:
            return "Cannot invite more than 165 users at once."
        case .invalidStatus:
            return "Invalid invitation status."
        }
    }
}

final class RoomInvitationManager {
    static let shared = RoomInvitationManager()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - References
    private func roomRef(_ roomId: String) -> DocumentReference {
        db.collection("rooms").document(roomId)
    }

    private func inviteRef(_ roomId: String, _ uid: String) -> DocumentReference {
        roomRef(roomId).collection("invites").document(uid)
    }

    private func roomLinkRef(_ uid: String, _ roomId: String) -> DocumentReference {
        db.collection("users").document(uid).collection("roomLinks").document(roomId)
    }

    // MARK: - Workflow A: Invite Friends (Fan-out with WriteBatch)
    /// Invites multiple users to a room using atomic WriteBatch
    /// Handles: Room doc update + N × (invite doc + roomLink doc)
    /// Limit: 500 operations per batch (165 invites max)
    func inviteUsers(roomId: String, userIds: [String]) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        // Firestore batch limit is 500 operations
        // Each invite = 2 operations (invite doc + roomLink doc) + 1 shared room update
        // Conservative limit: 165 invites (165 * 2 = 330 ops + 1 room update = 331 ops)
        guard userIds.count <= 165 else {
            throw RoomInvitationError.batchLimitExceeded
        }

        // 1. Fetch room data for denormalization
        let roomSnap = try await roomRef(roomId).getDocument()
        guard let room = try? roomSnap.data(as: GroupStudyRoom.self) else {
            throw RoomInvitationError.roomNotFound
        }

        // 2. Fetch host name for display
        let hostUser = try? await UserManager.shared.getUser(userId: currentUserId)
        let hostName = hostUser?.fullName ?? "Unknown"

        let now = Date()
        let activeUntil = room.endTime ?? room.startTime?.addingTimeInterval(24 * 3600) ?? now.addingTimeInterval(24 * 3600)

        // 3. Create WriteBatch for atomic fan-out
        let batch = db.batch()

        for uid in userIds {
            // 3a. Create canonical invite doc
            let invite = RoomInvite(
                inviteId: uid,
                roomId: roomId,
                invitedBy: currentUserId,
                status: "invited",
                invitedAt: now,
                respondedAt: nil
            )
            let inviteData = try Firestore.Encoder().encode(invite)
            batch.setData(inviteData, forDocument: inviteRef(roomId, uid))

            print("Creating invite for user \(uid) in room \(roomId)")

            // 3b. Create user inbox RoomLink
            let roomLink = RoomLink(
                roomId: roomId,
                userId: uid,
                status: "invited",
                invitedBy: currentUserId,
                roomTitle: room.title,
                roomDescription: room.description,
                hostName: hostName,
                startTime: room.startTime,
                endTime: room.endTime,
                activeUntil: activeUntil,
                invitedAt: now
            )
            let linkData = try Firestore.Encoder().encode(roomLink)
            batch.setData(linkData, forDocument: roomLinkRef(uid, roomId))

            print("Creating roomLink at: users/\(uid)/roomLinks/\(roomId)")
            print("RoomLink data: \(linkData)")
        }

        // 4. Update room memberIds array (add invited users)
        batch.updateData([
            "member_ids": FieldValue.arrayUnion(userIds)
        ], forDocument: roomRef(roomId))

        // 5. Commit batch
        try await batch.commit()
        print("Batch committed successfully for \(userIds.count) invitations")
    }

    // MARK: - Workflow B: Query Inbox
    /// Fetch pending invites for current user
    func fetchPendingInvites() async throws -> [RoomLink] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("roomLinks")
            .whereField("status", isEqualTo: "invited")
            .order(by: "invited_at", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: RoomLink.self) }
    }

    /// Listen to pending invites in real-time
    func listenToPendingInvites(onChange: @escaping ([RoomLink]) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("listenToPendingInvites: No user logged in")
            onChange([])
            return nil
        }

        print("listenToPendingInvites: Setting up listener for user \(uid)")

        return db.collection("users")
            .document(uid)
            .collection("roomLinks")
            .whereField("status", isEqualTo: "invited")
            .order(by: "invited_at", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("listenToPendingInvites error: \(error.localizedDescription)")
                    onChange([])
                    return
                }

                guard let snapshot = snapshot else {
                    print("listenToPendingInvites: No snapshot")
                    onChange([])
                    return
                }

                print("listenToPendingInvites: Got \(snapshot.documents.count) documents")

                for doc in snapshot.documents {
                    print("Document data: \(doc.data())")
                }

                let links = snapshot.documents.compactMap { try? $0.data(as: RoomLink.self) }
                print("listenToPendingInvites: Parsed \(links.count) RoomLinks")
                onChange(links)
            }
    }

    // MARK: - Workflow C: Accept Invite
    /// Accept invitation (transactional to prevent race conditions)
    func acceptInvite(roomId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        try await db.runTransaction { [weak self] (transaction, errorPointer) -> Any? in
            guard let self = self else { return nil }

            // 1. Verify invite exists
            let inviteRef = self.inviteRef(roomId, uid)
            let inviteSnap: DocumentSnapshot
            do {
                inviteSnap = try transaction.getDocument(inviteRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard inviteSnap.exists,
                  let invite = try? inviteSnap.data(as: RoomInvite.self),
                  invite.status == "invited" else {
                errorPointer?.pointee = RoomInvitationError.notInvited as NSError
                return nil
            }

            let now = Timestamp(date: Date())

            // 2. Update canonical invite status
            transaction.updateData([
                "status": "accepted",
                "responded_at": now
            ], forDocument: inviteRef)

            // 3. Update user's roomLink status
            transaction.updateData([
                "status": "accepted"
            ], forDocument: self.roomLinkRef(uid, roomId))

            // 4. Add to room's memberIds if not already present
            transaction.updateData([
                "member_ids": FieldValue.arrayUnion([uid])
            ], forDocument: self.roomRef(roomId))

            return nil
        }
    }

    // MARK: - Workflow D: Decline Invite
    /// Decline invitation (updates both docs)
    func declineInvite(roomId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        let now = Timestamp(date: Date())
        let batch = db.batch()

        // Update canonical invite
        batch.updateData([
            "status": "declined",
            "responded_at": now
        ], forDocument: inviteRef(roomId, uid))

        // Update user's roomLink
        batch.updateData([
            "status": "declined"
        ], forDocument: roomLinkRef(uid, roomId))

        // Optionally remove from room memberIds
        batch.updateData([
            "member_ids": FieldValue.arrayRemove([uid])
        ], forDocument: roomRef(roomId))

        try await batch.commit()
    }

    // MARK: - Query Upcoming/Active Rooms
    /// Fetch upcoming rooms (startTime in future, activeUntil > now)
    func fetchUpcomingRooms() async throws -> [RoomLink] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        let now = Date()
        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("roomLinks")
            .whereField("status", isEqualTo: "accepted")
            .whereField("active_until", isGreaterThan: Timestamp(date: now))
            .getDocuments()

        // Sort in memory to avoid needing a composite index
        let links = snapshot.documents.compactMap { try? $0.data(as: RoomLink.self) }
        return links.sorted { ($0.startTime ?? Date.distantPast) < ($1.startTime ?? Date.distantPast) }
    }

    /// Listen to upcoming rooms in real-time
    func listenToUpcomingRooms(onChange: @escaping ([RoomLink]) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("listenToUpcomingRooms: No user logged in")
            onChange([])
            return nil
        }

        print("listenToUpcomingRooms: Setting up listener for user \(uid)")

        let now = Date()
        return db.collection("users")
            .document(uid)
            .collection("roomLinks")
            .whereField("status", isEqualTo: "accepted")
            .whereField("active_until", isGreaterThan: Timestamp(date: now))
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("listenToUpcomingRooms error: \(error.localizedDescription)")
                    onChange([])
                    return
                }

                guard let snapshot = snapshot else {
                    print("listenToUpcomingRooms: No snapshot")
                    onChange([])
                    return
                }

                print("listenToUpcomingRooms: Got \(snapshot.documents.count) documents")

                for doc in snapshot.documents {
                    print("Upcoming room document: \(doc.data())")
                }

                let links = snapshot.documents.compactMap { try? $0.data(as: RoomLink.self) }
                // Sort in memory to avoid needing a composite index
                let sorted = links.sorted { ($0.startTime ?? Date.distantPast) < ($1.startTime ?? Date.distantPast) }
                print("listenToUpcomingRooms: Parsed \(sorted.count) RoomLinks")
                onChange(sorted)
            }
    }

    // MARK: - Cleanup Utilities
    /// Delete old declined/accepted invites (background cleanup)
    func cleanupOldInvites(olderThan days: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw RoomInvitationError.userNotLoggedIn
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("roomLinks")
            .whereField("active_until", isLessThan: Timestamp(date: cutoffDate))
            .getDocuments()

        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }

        try await batch.commit()
    }
}
