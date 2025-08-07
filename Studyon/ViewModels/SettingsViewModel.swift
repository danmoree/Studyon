//
//  SettingsViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/5/25.
//

import Foundation
import FirebaseAuth


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
    
    var appVersion: String {
        SettingsService.shared.appVersion
    }
}
