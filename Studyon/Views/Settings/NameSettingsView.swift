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
                //NavigationLink("Change Password", destination: ChangePasswordView())
            }
            Text("Your name must be fewer than 30 characters.")
            
        }
        
        .onAppear {
            if let name = userVM.user?.fullName {
                fullName = name
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    Task {
                        do {
                            if fullName.count >= 30 || fullName.count == 0 {
                                alertMessage = "Name must be between 1 and 30 characters."
                                showAlert = true
                                return
                            }
                            try await settingsVM.changeName(name: fullName)
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
