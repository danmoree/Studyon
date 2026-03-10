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
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: username) { newValue in
                        username = InputValidator.sanitiseUsername(newValue)
                    }
            }
            Text("3–\(InputValidator.usernameMax) characters. Lowercase letters, numbers and underscores only. Cannot start or end with an underscore.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        .onAppear {
            if let userUsername = userVM.user?.username {
                username = userUsername
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    if let error = InputValidator.validateUsername(username) {
                        alertMessage = error
                        showAlert = true
                        return
                    }
                    Task {
                        do {
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
