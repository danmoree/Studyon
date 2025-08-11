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
import UIKit

private let lastProfileImageCacheKey = "lastProfileImageOnDisk"

final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil

    @Published private(set) var profileImage: UIImage? = nil

    init() {
        // Try to synchronously load the last cached image if any.
        if let imageData = UserDefaults.standard.data(forKey: lastProfileImageCacheKey),
           let image = UIImage(data: imageData) {
            self.profileImage = image
        }
    }

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
    
    func loadProfileImage() async {
        guard let user = self.user else { return }
        do {
            let image = try await UserManager.shared.fetchProfileImageWithDiskCache(for: user)
            await MainActor.run {
                if let image = image {
                    self.profileImage = image
                    self.cacheProfileImage(image) // Cache for next launch
                } else {
                    self.profileImage = UIImage(systemName: "person.crop.circle")
                }
            }
        } catch {
            // On error, set the default SF Symbol
            await MainActor.run {
                self.profileImage = UIImage(systemName: "person.crop.circle")
            }
        }
    }
    
    private func cacheProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.95) {
            UserDefaults.standard.set(data, forKey: lastProfileImageCacheKey)
        }
    }
    
}
