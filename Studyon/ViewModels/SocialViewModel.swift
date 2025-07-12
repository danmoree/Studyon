//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  SocialViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/11/25.
//

import Foundation
import FirebaseAuth

final class SocialViewModel: ObservableObject {
    @Published var searchResults: [DBUser] = []
    @Published var pendingRequestSenders: [DBUser] = []
    @Published var friends: [DBUser] = []
    @Published var friendRequestError: String? = nil
    @Published var declineFriendRequestError: String? = nil
    @Published var acceptFriendRequestError: String? = nil
    
    func loadUsersByUsername(username: String) async throws {
        let users = try await UserManager.shared.fetchUsersByExactUsername(username.lowercased())
        let usersPrefix = try await UserManager.shared.fetchUsersByUsernamePrefix(username.lowercased())

        // If you want to combine and remove duplicates:
        let allUsers = Array(Set(users + usersPrefix))
        // Update the published property on the main thread
        await MainActor.run {
            self.searchResults = allUsers
        }

        // If you only want prefix results:
        // await MainActor.run {
        //     self.searchResults = usersPrefix
        // }
    }
    
    
    func fetchFriends() async {
        guard let myUserId = Auth.auth().currentUser?.uid else {
            await MainActor.run { self.friends = [] }
            return
        }
        let friendships = try? await FriendshipManager.shared.fetchFriends(for: myUserId)
        let friendIds = friendships?.map { $0.user1Id == myUserId ? $0.user2Id : $0.user1Id } ?? []
        let users = try? await UserManager.shared.fetchUsers(for: friendIds)
        await MainActor.run {
            self.friends = users ?? []
        }
    }
    
    func fetchPendingRequestSenders() async {
        let users = try? await FriendshipManager.shared.fetchPendingRequestSendersToCurrentUser()
        await MainActor.run {
            self.pendingRequestSenders = users ?? []
        }
        print("Fetched pending")
        print(users ?? [])
    }
    
    func sendFriendRequest(to userId: String) async {
        do {
            try await FriendshipManager.shared.createFriendRequest(to: userId)
            // Optionally refresh data, e.g. pending requests or friends, after a successful request
            await fetchPendingRequestSenders()
            await MainActor.run {
                self.friendRequestError = nil
            }
        } catch {
            await MainActor.run {
                self.friendRequestError = error.localizedDescription
            }
        }
    }
    
    func declineFriendRequest(from userId: String) async {
        do {
            try await FriendshipManager.shared.declineFriendRequest(from: userId)
            await fetchPendingRequestSenders()
            await MainActor.run {
                self.declineFriendRequestError = nil
            }
        } catch {
            await MainActor.run {
                self.declineFriendRequestError = error.localizedDescription
            }
        }
    }
    
    func acceptFriendRequest(from userId: String) async {
        do {
            try await FriendshipManager.shared.acceptFriendRequest(from: userId)
            await fetchFriends()
            await fetchPendingRequestSenders()
            await MainActor.run {
                self.acceptFriendRequestError = nil
            }
        } catch {
            await MainActor.run {
                self.acceptFriendRequestError = error.localizedDescription
            }
        }
    }
}

