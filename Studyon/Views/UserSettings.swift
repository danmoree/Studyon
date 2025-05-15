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
        }
        .padding()
    }
}

#Preview {
    UserSettings(isUserLoggedIn: .constant(true))
}
