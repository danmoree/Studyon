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
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUserLoggedIn = Auth.auth().currentUser != nil
    @StateObject private var userVM = ProfileViewModel()
    @State private var userID: String? = Auth.auth().currentUser?.uid
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        Group {
            if let uid = userID, isUserLoggedIn {
                ZStack {
                    Color("background").ignoresSafeArea()
                    MainTabView(isUserLoggedIn: $isUserLoggedIn)
                        .task {
                            try? await userVM.loadCurrentUser()
                            if userVM.profileImage == nil {
                                await userVM.loadProfileImage()
                            }
                        }
                        .environmentObject(userVM)
                        .environmentObject(settingsVM)
                }
            } else {
                AuthView(onLoginSuccess: {
                    self.userID = Auth.auth().currentUser?.uid
                    self.isUserLoggedIn = true
                })
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                Task {
                    if let uid = userID {
                        try await UserManager.shared.setStatusOnline(userId: uid)
                    }
                }
            case .inactive, .background:
                Task {
                    if let uid = userID {
                        try await UserManager.shared.setStatusOffline(userId: uid)
                    }
                }
            
            @unknown default:
                break
            }
            
        }
    }
}

extension Color {
    static let softWhite = Color(red: 245/255, green: 245/255, blue: 245/255)
}

#Preview {
    ContentView()
}
