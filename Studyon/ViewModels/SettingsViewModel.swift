//
//  SettingsViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/5/25.
//

import Foundation
import FirebaseAuth
import UIKit

class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            SettingsService.shared.saveTheme(selectedTheme)
        }
    }
    
    init() {
        self.selectedTheme = SettingsService.shared.loadTheme()
    }
    
    var currentUserUID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func changeUsername(username: String) async throws {
        guard let uid = currentUserUID else {
            throw NSError(domain: "SettingsViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        try await SettingsService.shared.changeUsername(username: username, userId: uid)
    }
    
    func changeName(name: String) async throws {
        guard let uid = currentUserUID else {
            throw NSError(domain: "SettingsViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        try await SettingsService.shared.changeName(name: name, userId: uid)
    }
    
    func changeProfilePic(imageData: Data) async throws {
        try await SettingsService.shared.changeProfilePic(imageData: imageData)
    }
    
    var appVersion: String {
        SettingsService.shared.appVersion
    }
    
    func updateDailyStudyGoal(amount: TimeInterval) async throws {
        guard let uid = currentUserUID else {
            throw NSError(domain: "SettingsViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        try await UserManager.shared.updateUserDailyStudyGoal(userId: uid, goal: amount)
    }

    /// Removes the cached image for the given profile photo URL, forcing image reload from network next time.
    func removeImageCache(for photoUrl: String) {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let hashedFileName = "\(photoUrl.hashValue).jpg"
        let cacheFileURL = cacheDirectory.appendingPathComponent(hashedFileName)
        if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            try? FileManager.default.removeItem(at: cacheFileURL)
        }
    }
}
