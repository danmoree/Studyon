//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  Friendship.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum FriendshipManagerError: Error, LocalizedError {
    case alreadyRequested
    case userNotLoggedIn

    var errorDescription: String? {
        switch self {
        case .alreadyRequested:
            return "A friend request already exists or you are already friends."
        case .userNotLoggedIn:
            return "You must be logged in to send a friend request."
        }
    }
}

struct Friendship: Identifiable, Codable {
    @DocumentID var id: String?
    
    var user1Id: String
    var user2Id: String
    var status: String  // "pending", "accepted", "blocked"
    var createdAt: Date
    var lastUpdatedAt: Date
    
    var actionBy: String?
    var isFavorite: Bool?
}

enum CodingKeys: String, CodingKey {
    case user1Id = "user1_id"
    case user2Id = "user2_id"
    case status = "status"
    case createdAt = "created_at"
    case lastUpdatedAt = "last_updated_at"
    case actionBy = "action_by"
    case isFavorite = "is_favorite"
}

final class FriendshipManager {
    static let shared = FriendshipManager()
    
    private let friendshipCollection = Firestore.firestore().collection("friendships")
    
    // normalize the id
    func generateFriendshipDocumentID(userAId: String, userBId: String) -> String {
        let sorted = [userAId, userBId].sorted()
        return "\(sorted[0])_\(sorted[1])"
    }
    
    
    func fetchFriendship(userAId: String, userBId: String) async throws -> Friendship? {
        let docID = generateFriendshipDocumentID(userAId: userAId, userBId: userBId)
        let docRef = friendshipCollection.document(docID)
        let snapshot = try await docRef.getDocument()
        return try snapshot.data(as: Friendship.self)
    }
    
    func fetchFriends(for userId: String) async throws -> [Friendship] {
        let query1 = friendshipCollection
            .whereField("user1_id", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
        let query2 = friendshipCollection
            .whereField("user2_id", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")

        let snapshot1 = try await query1.getDocuments()
        let snapshot2 = try await query2.getDocuments()

        let friends1 = snapshot1.documents.compactMap { try? $0.data(as: Friendship.self) }
        let friends2 = snapshot2.documents.compactMap { try? $0.data(as: Friendship.self) }

        return friends1 + friends2
    }
    

    
    func fetchPendingRequestSendersToCurrentUser() async throws -> [DBUser] {
        guard let myUserId = Auth.auth().currentUser?.uid else {
            print("No logged-in user!")
            return []
        }
        let query = friendshipCollection
            .whereField("user2_id", isEqualTo: myUserId)
            .whereField("status", isEqualTo: "pending")
        let snapshot = try await query.getDocuments()
        let friendships = snapshot.documents.compactMap { try? $0.data(as: Friendship.self) }
        let requesterIds = friendships.map { $0.user1Id }
        return try await UserManager.shared.fetchUsers(for: requesterIds)
    }
    
    func createFriendRequest(to userId: String) async throws {
        guard let myUserId = Auth.auth().currentUser?.uid else {
            throw FriendshipManagerError.userNotLoggedIn
        }
        // normalized the id
        let docID = generateFriendshipDocumentID(userAId: myUserId, userBId: userId)
        let docRef = friendshipCollection.document(docID)

        // Check if the friendship already exists
        let snapshot = try await docRef.getDocument()
        if snapshot.exists {
            throw FriendshipManagerError.alreadyRequested
        }

        // The sender is user1, recipient is user2 by convention
        let friendship = Friendship(
            id: docID,
            user1Id: myUserId,
            user2Id: userId,
            status: "pending",
            createdAt: Date(),
            lastUpdatedAt: Date(),
            actionBy: myUserId,
            isFavorite: false
        )
        try await docRef.setData(from: friendship, merge: false)
    }
    
    func acceptFriendRequest(from userId: String) async throws {
        guard let myUserId = Auth.auth().currentUser?.uid else {
            throw FriendshipManagerError.userNotLoggedIn
        }
        let docID = generateFriendshipDocumentID(userAId: userId, userBId: myUserId)
        let docRef = friendshipCollection.document(docID)
        let snapshot = try await docRef.getDocument()
        guard let friendship = try? snapshot.data(as: Friendship.self), friendship.status == "pending", friendship.user2Id == myUserId else {
            throw FriendshipManagerError.alreadyRequested // (reuse error for no request)
        }
        try await docRef.updateData([
            "status": "accepted",
            "last_updated_at": Date(),
            "action_by": myUserId
        ])
    }

    func declineFriendRequest(from userId: String) async throws {
        guard let myUserId = Auth.auth().currentUser?.uid else {
            throw FriendshipManagerError.userNotLoggedIn
        }
        let docID = generateFriendshipDocumentID(userAId: userId, userBId: myUserId)
        let docRef = friendshipCollection.document(docID)
        let snapshot = try await docRef.getDocument()
        guard let friendship = try? snapshot.data(as: Friendship.self), friendship.status == "pending", friendship.user2Id == myUserId else {
            throw FriendshipManagerError.alreadyRequested // (reuse error for no request)
        }
        try await docRef.delete()
    }
    
}
