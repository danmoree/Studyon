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

final class SocialViewModel: ObservableObject {
    @Published var searchResults: [DBUser] = []
    
    func loadUsersByUsername(username: String) async throws {
        // You can choose which match to use: exact, prefix, or both combined.
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
}
