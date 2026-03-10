//
//  NameSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/7/25.
//

import SwiftUI

struct NameSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Full name", text: $fullName)
                    .onChange(of: fullName) { newValue in
                        fullName = InputValidator.sanitiseFullName(newValue)
                    }
            }
            Text("2–\(InputValidator.fullNameMax) characters. Letters, spaces, hyphens and apostrophes only.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        .onAppear {
            if let name = userVM.user?.fullName {
                fullName = name
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    if let error = InputValidator.validateFullName(fullName) {
                        alertMessage = error
                        showAlert = true
                        return
                    }
                    Task {
                        do {
                            try await settingsVM.changeName(name: fullName.trimmingCharacters(in: .whitespaces))
                            try await userVM.loadCurrentUser()
                            dismiss()
                        } catch {
                            if let settingsError = error as? SettingsError {
                                switch settingsError {
                                case .invalidInput(let reason):
                                    alertMessage = reason
                                default:
                                    alertMessage = settingsError.localizedDescription
                                }
                            } else {
                                alertMessage = "Failed to change name: \(error.localizedDescription)"
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
    NameSettingsView(settingsVM: SettingsViewModel())
        .environmentObject(ProfileViewModel())
}
