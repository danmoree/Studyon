//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  AuthenticationView.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/28/25.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
    
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
//    func createUser(email: String, password: String ) async throws {
//        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
//        let user = DBUser(userId: authDataResult.user.uid, email: authDataResult.user.email, photoUrl: authDataResult.user.photoURL?.absoluteString, dateCreated: Date())
//        
//        try await UserManager.shared.createNewUser(user: user)
//    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // New signIn method for returning users
        func signIn(email: String, password: String) async throws -> AuthDataResultModel {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        }
    
    func signOut() throws {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "cachedDayStreak")
        UserDefaults.standard.removeObject(forKey: "cachedXP")
        UserDefaults.standard.removeObject(forKey: "cachedSecondsStudiedToday")
        UserStats.clearCache()
        DBUser.clearCachedFullName()
        
    }
}
