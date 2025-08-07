//
//  ProfileSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/6/25.
//

import SwiftUI

struct UsernameSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Username")) {
                TextField("Username", text: $username)
                //NavigationLink("Change Password", destination: ChangePasswordView())
            }
            Text("Your username must be available and fewer than 30 characters.")
            
        }
        
        .onAppear {
            if let userUsername = userVM.user?.username {
                username = userUsername
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    Task {
                        do {
                            if username.count >= 30 || username.count == 0 {
                                alertMessage = "Username must be between 1 and 30 characters."
                                showAlert = true
                                return
                            }
                            try await settingsVM.changeUsername(username: username)
                            try await userVM.loadCurrentUser()
                            dismiss()
                        } catch {
                            if let settingsError = error as? SettingsError {
                                switch settingsError {
                                case .invalidInput(let reason) where reason == "Username is already taken.":
                                    alertMessage = "Username is already taken."
                                case .invalidInput(let reason):
                                    alertMessage = reason
                                default:
                                    alertMessage = settingsError.localizedDescription
                                }
                            } else {
                                alertMessage = "Failed to change username: \(error.localizedDescription)"
                            }
                            showAlert = true
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    UsernameSettingsView(settingsVM: SettingsViewModel())
        .environmentObject(ProfileViewModel())
}
