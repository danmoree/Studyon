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
    
    var body: some View {
        
        Group {
            if isUserLoggedIn {
                if needsProfileSetup, let uid = userID {
                    ProfileSetupView(userID: uid)
                } else {
                    MainTabView(isUserLoggedIn: $isUserLoggedIn)
                        .task {
                            try? await userVM.loadCurrentUser()
                        }
                        .environmentObject(userVM)
                }
            } else {
                AuthView(onLoginSuccess: {
                    self.userID = Auth.auth().currentUser?.uid
                    self.checkProfile()
                    self.isUserLoggedIn = true
                })
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
        }
    }
}

#Preview {
    ContentView()
}
