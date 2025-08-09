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
import UIKit

final class SocialViewModel: ObservableObject {
    @Published var searchResults: [DBUser] = []
    @Published var pendingRequestSenders: [DBUser] = []
    @Published var friends: [DBUser] = []
    @Published var friendRequestError: String? = nil
    @Published var declineFriendRequestError: String? = nil
    @Published var acceptFriendRequestError: String? = nil
    @Published var unfriendError: String? = nil
    @Published var friendStats: UserStats? = nil
    @Published var userStats: UserStats? = nil
    @Published var friendIds: [String] = []
    @Published var user: DBUser? = nil
    @Published var profileImage: UIImage? = nil
    
    func loadFriendStats(for userId: String) async {
        do {
            let stats = try await UserStatsManager.shared.fetchStats(userId: userId)
            await MainActor.run {
                self.friendStats = stats
            }
        } catch {
            print("Failed loading friend stats:", error)
            // leave defaults or show an error state
        }
    }
    
    /// Returns the total hours studied for the current user, or 0 if not available.

    var totalHoursStudied: Double {
        guard let timeStudiedByDate = friendStats?.timeStudiedByDate else { return 0 }
        let totalSeconds = timeStudiedByDate.values.reduce(0, +)
        return totalSeconds / 3600.0
    }
    
    var friendSecondsStudiedToday: Double {
        guard let timeStudiedByDate = friendStats?.timeStudiedByDate else { return 0 }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current
        let dateKey = df.string(from: Date())
        return timeStudiedByDate[dateKey] ?? 0
    }
    
    
    func loadUsersByUsername(username: String) async throws {
        let users = try await UserManager.shared.fetchUsersByExactUsername(username.lowercased())
        let usersPrefix = try await UserManager.shared.fetchUsersByUsernamePrefix(username.lowercased())

        // If you want to combine and remove duplicates:
        let allUsers = Array(Set(users + usersPrefix))
        let filteredUsers = allUsers.filter { user in
            user.userId != Auth.auth().currentUser?.uid && !friendIds.contains(user.userId)
            
        }
        // Update the published property on the main thread
        await MainActor.run {
            self.searchResults = filteredUsers
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
            self.friendIds = friendIds
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
    
    func unfriend(userId: String) async {
        do {
            try await FriendshipManager.shared.unfriend(userId: userId)
            await fetchFriends()
            await MainActor.run {
                self.unfriendError = nil
            }
        } catch {
            await MainActor.run {
                self.unfriendError = error.localizedDescription
            }
        }
    }
    
    func loadProfileImage() async {
        guard let user = self.user else { return }
        do {
            let image = try await UserManager.shared.fetchProfileImageWithDiskCache(for: user)
            await MainActor.run {
                self.profileImage = image ?? UIImage(systemName: "person.crop.circle")
            }
        } catch {
            // On error, set the default SF Symbol
            await MainActor.run {
                self.profileImage = UIImage(systemName: "person.crop.circle")
            }
        }
    }
}
