//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  SettingsService.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/4/25.
//

import Foundation
import Firebase

enum SettingsError: LocalizedError {
    case invalidInput(String)
    case updateFailed
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        case .updateFailed:
            return "Failed to update settings."
        case .networkError:
            return "Network connection failed."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}

class SettingsService {
    static let shared = SettingsService()
    private init() {}
    
    // user profile settings that write to firebase
    func changeName(name: String, userId: String) async throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SettingsError.invalidInput("Name cannot be empty.")
        }

        do {
            // Example Firebase Firestore update
            try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .updateData(["name": name])
        } catch let error as URLError {
            throw SettingsError.networkError
        } catch {
            throw SettingsError.updateFailed
        }
    }
    
    func changeUsername(username: String, userId: String) async throws {
        
    }
    
    func changeEmail(email: String, userId: String) async throws {
        
    }
    
    func changePassword(password: String, userId: String) async throws {
        
    }
    
    func changePhoto(photo: Data, userId: String) async throws {
        // not sure if photo is type Data
        // need to compress before uploading
    }
    
    
    
}
