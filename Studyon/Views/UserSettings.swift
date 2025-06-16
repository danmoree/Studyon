//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  UserSettings.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/15/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct UserSettings: View {
    @Binding var isUserLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("User Settings")
                .font(.title)

           
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    isUserLoggedIn = false
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            if let user = viewModel.user {
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
            }
            
       

        }
        .padding()
    }
}

#Preview {
    UserSettings(isUserLoggedIn: .constant(true))
}
