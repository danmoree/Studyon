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
    
    var body: some View {
        
        Group {
            if isUserLoggedIn {
                MainTabView(isUserLoggedIn: $isUserLoggedIn)
                    .task {
                        try? await userVM.loadCurrentUser()
                    }
                    .environmentObject(userVM)
                    
            } else {
                AuthView(onLoginSuccess: {
                    self.isUserLoggedIn = true
                })
            }
        }
    
    }
}

#Preview {
    ContentView()
}
