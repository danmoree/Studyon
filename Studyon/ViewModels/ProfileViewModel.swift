//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  ProfileViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/20/25.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    // basicly on login
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        // day streak check
        try await UserStatsManager.shared.checkAndUpdateLoginStreak(userId: fetchedUser.userId)
        try await UserManager.shared.setStatusOnline(userId: fetchedUser.userId)
        
        await MainActor.run {
            self.user = fetchedUser
            DBUser.cacheFullName(fetchedUser.fullName)
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
    
    func updateDailyStudyGoal(amount: TimeInterval) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.updateUserDailyStudyGoal(userId: user.userId, goal: amount)
            let refreshedUser = try await UserManager.shared.getUser(userId: user.userId)
            await MainActor.run {
                self.user = refreshedUser
            }
        }
        
    }
    
    func signOut() async throws {
        guard let user = user else { return }
        try await UserManager.shared.setStatusOffline(userId: user.userId)
        try AuthenticationManager.shared.signOut()
        await MainActor.run {
            self.user = nil
        }
    }
    
    
}
