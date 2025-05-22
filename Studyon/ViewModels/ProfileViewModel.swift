//
//  ProfileViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/20/25.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)
        await MainActor.run {
            self.user = fetchedUser
        }
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        // update user and fetch
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            let refreshedUser = try await UserManager.shared.getUser(userId: user.userId)
            await MainActor.run {
                self.user = refreshedUser
            }
        }
        
    }
    
    
}
