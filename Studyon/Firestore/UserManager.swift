//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  UserManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/20/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct DBUser: Codable, Hashable {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let fullName: String?
    let username: String?
    let dateOfBirth: Date?
    let dailyStudyGoal: TimeInterval?
    let usernameLowercased: String?
    
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.fullName = nil
        self.username = nil
        self.dateOfBirth = nil
        self.dailyStudyGoal = nil
        self.usernameLowercased = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        fullName: String? = nil,
        username: String? = nil,
        dateOfBirth: Date? = nil,
        dailyStudyGoal: TimeInterval? = nil,
        usernameLowercased: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.fullName = fullName
        self.username = username
        self.dateOfBirth = dateOfBirth
        self.dailyStudyGoal = dailyStudyGoal
        self.usernameLowercased = usernameLowercased
    }
    
//    func toggleIsPremiumStatus() -> DBUser {
//        let currentValue = isPremium ?? false
//        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated, isPremium: !currentValue)
//    }
    
//    mutating func toggleIsPremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
//
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
        case fullName = "full_name"
        case username = "username"
        case dateOfBirth = "date_of_birth"
        case dailyStudyGoal = "daily_study_goal"
        case usernameLowercased = "username_lowercased"
    }
    
    // download from firestore
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.dailyStudyGoal = try container.decodeIfPresent(TimeInterval.self, forKey: .dailyStudyGoal)
        self.usernameLowercased = try container.decodeIfPresent(String.self, forKey: .usernameLowercased)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.fullName, forKey: .fullName)
        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.dailyStudyGoal, forKey: .dailyStudyGoal)
        try container.encodeIfPresent(self.usernameLowercased, forKey: .usernameLowercased)
    }
    
    static func == (lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.userId == rhs.userId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
 

    
}
final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//    
//    
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "data_created" : Timestamp()
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//        
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        
//        guard let data = snapshot.data(),  let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//       
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["data_created"] as? Date
//        
//        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
//    func updateUserPremiumStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true, encoder: encoder)
//    }
//    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserProfileInfo(userId: String, fullName: String, username: String, dateOfBirth: Date) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.fullName.rawValue: fullName,
            DBUser.CodingKeys.username.rawValue: username,
            DBUser.CodingKeys.usernameLowercased.rawValue: username.lowercased(),
            DBUser.CodingKeys.dateOfBirth.rawValue: Timestamp(date: dateOfBirth)
        ]
        try await userDocument(userId: userId).setData(data, merge: true)
    }
    
    func updateUserDailyStudyGoal(userId: String, goal: TimeInterval) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.dailyStudyGoal.rawValue: goal
        ]
        try await userDocument(userId: userId).setData(data, merge: true)
    }
    
    func checkAvailableUsername(username: String) async throws -> Bool {
        let query = userCollection.whereField("username_lowercased", isEqualTo: username.lowercased()).limit(to: 1)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.isEmpty
    }
    
    // for users list when trying to add a friend
    func fetchUsersByExactUsername(_ username: String) async throws -> [DBUser] {
        let query = userCollection.whereField("username_lowercased", isEqualTo: username)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBUser.self)
        }
    }
    
    // for users list when trying to add a friend
    func fetchUsersByUsernamePrefix(_ prefix: String) async throws -> [DBUser] {
        let query = userCollection
            .order(by: "username_lowercased")
            .start(at: [prefix])
            .end(at: [prefix + "\u{f8ff}"])
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBUser.self)
        }
    }
    
    func fetchUsers(for userIds: [String]) async throws -> [DBUser] {
        guard !userIds.isEmpty else { return [] }
        let chunkSize = 10
        var users: [DBUser] = []
        for chunk in userIds.chunked(into: chunkSize) {
            let query = userCollection.whereField("user_id", in: chunk)
            let snapshot = try await query.getDocuments()
            let batch = snapshot.documents.compactMap { try? $0.data(as: DBUser.self) }
            users.append(contentsOf: batch)
        }
        return users
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
