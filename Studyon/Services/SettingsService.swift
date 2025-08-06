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
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
// ...



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
    
    let appVersion = "Version 0.1"
    
    private let userCollection = Firestore.firestore().collection("users")
    
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
                .updateData(["full_name": name])
        } catch _ as URLError {
            throw SettingsError.networkError
        } catch {
            throw SettingsError.updateFailed
        }
    }
    
    func changeUsername(username: String, userId: String) async throws {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SettingsError.invalidInput("Username cannot be empty.")
        }
        guard trimmed.count <= 30 else {
            throw SettingsError.invalidInput("Username cannot exceed 30 characters.")
        }

        if try await checkAvailableUsername(username: trimmed) {
            do {
                try await userCollection.document(userId).updateData([
                    "username": trimmed,
                    "username_lowercased": trimmed.lowercased()
                ])
            } catch {
                throw SettingsError.updateFailed
            }
        } else {
            throw SettingsError.invalidInput("Username is already taken.")
        }
    }
    
    func changeEmail(email: String, userId: String) async throws {
        // Update Firebase Auth
        try await Auth.auth().currentUser?.updateEmail(to: email)

        // Update Firestore
        try await userCollection.document(userId).updateData([
            "email": email
        ])
    }
    
    func changePassword(password: String, userId: String) async throws {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SettingsError.invalidInput("Password cannot be empty.")
        }
        guard trimmed.count >= 8 else {
            throw SettingsError.invalidInput("Password must be at least 8 characters.")
        }
        guard let user = Auth.auth().currentUser else {
            throw SettingsError.unknown
        }
        do {
            try await user.updatePassword(to: trimmed)
        } catch _ as URLError {
            throw SettingsError.networkError
        } catch {
            throw SettingsError.updateFailed
        }
    }
    
    
        func changeProfilePic(imageData: Data) async throws {
            // make sure that the viewmodel checks for valid pic, compresses it then upload/save url
            // 1. Get the user ID
            guard let uid = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "ProfilePicService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }
            
            // 2. Create a reference to Firebase Storage
            let storageRef = Storage.storage().reference().child("profile_pics/\(uid).jpg")
            
            // 3. Upload the data
            _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            
            // 4. Get the download URL
            let downloadURL = try await storageRef.downloadURL()
            
            // 5. Save the URL to Firestore
            let userDoc = Firestore.firestore().collection("users").document(uid)
            try await userDoc.updateData(["photo_url": downloadURL.absoluteString])
        }
    
//    func changePhoto(photo: Data, userId: String) async throws {
//        // Attempt to create UIImage from data to check format
//        guard let image = UIImage(data: photo) else {
//            throw SettingsError.invalidInput("Photo data is not a valid image.")
//        }
//        
//        // Compress the image to JPEG data with quality 0.8
//        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
//            throw SettingsError.invalidInput("Failed to convert image to JPEG.")
//        }
//        
//        let storageRef = Storage.storage().reference().child("profile_photos/\(userId).jpg")
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        
//        do {
//            // Upload JPEG data to Firebase Storage
//            _ = try await storageRef.putDataAsync(jpegData, metadata: metadata)
//            
//            // Get download URL for the uploaded image
//            let downloadURL = try await storageRef.downloadURL()
//            
//            // Update Firestore user document with profile photo URL
//            try await userCollection.document(userId).updateData([
//                "profile_photo_url": downloadURL.absoluteString
//            ])
//        } catch _ as URLError {
//            throw SettingsError.networkError
//        } catch {
//            throw SettingsError.updateFailed
//        }
//    }
    
    func checkAvailableUsername(username: String) async throws -> Bool {
        let query = userCollection.whereField("username_lowercased", isEqualTo: username.lowercased()).limit(to: 1)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.isEmpty
    }
    
    
    // Appearance
    // saving to user dafaults
    func saveTheme(_ theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
    
    func loadTheme() -> AppTheme {
        if let raw = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: raw) {
            return theme
        }
        return .system
    }
    
    
    
}

