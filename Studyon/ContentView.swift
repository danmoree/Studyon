//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  ContentView.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/13/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn = Auth.auth().currentUser != nil
    @StateObject private var userVM = ProfileViewModel()
    @State private var needsProfileSetup = false
    @State private var userID: String? = Auth.auth().currentUser?.uid
    @State private var hasCheckedProfile = false
    
    var body: some View {
        
        Group {
            if let uid = userID, isUserLoggedIn, hasCheckedProfile {
                if needsProfileSetup {
                    ProfileSetupView(userID: uid, needsProfileSetup: $needsProfileSetup)
                        .environmentObject(userVM)
                } else {
                    MainTabView(isUserLoggedIn: $isUserLoggedIn)
                        .task {
                            try? await userVM.loadCurrentUser()
                        }
                        .environmentObject(userVM)
                }
            } else if isUserLoggedIn && !hasCheckedProfile {
                ProgressView("Loading profile...")
            } else {
                AuthView(onLoginSuccess: {
                    self.userID = Auth.auth().currentUser?.uid
                    self.checkProfileThenLogin()
                })
            }
        }
        .task {
            if isUserLoggedIn && !hasCheckedProfile {
                self.checkProfile()
            }
        }
    
    }
    
    private func checkProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let username = data["username"] as? String,
               !username.isEmpty {
                self.needsProfileSetup = false
            } else {
                self.needsProfileSetup = true
            }
            self.hasCheckedProfile = true
        }
    }
    
    private func checkProfileThenLogin() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let username = data["username"] as? String,
               !username.isEmpty {
                self.needsProfileSetup = false
            } else {
                self.needsProfileSetup = true
            }
            self.hasCheckedProfile = true
            self.isUserLoggedIn = true
        }
    }
}

#Preview {
    ContentView()
}
