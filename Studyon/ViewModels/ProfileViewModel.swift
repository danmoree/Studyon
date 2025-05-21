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
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
