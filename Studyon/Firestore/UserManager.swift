//
//  UserManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/20/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct DBUser: Codable {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
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
    }
    
    // download from firestore
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
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
}
