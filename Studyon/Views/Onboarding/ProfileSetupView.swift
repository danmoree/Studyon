//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  ProfileSetupView.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileSetupView: View {
    let userID: String
    var onComplete: () -> Void

    @State private var fullName    = ""
    @State private var username    = ""
    @State private var birthDate   = Date()
    @State private var errorMessage: String?

    @EnvironmentObject var userVM: ProfileViewModel
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Text("Almost there!")
                    .font(.title)
                    .fontWidth(.expanded)
                    .fontWeight(.heavy)
                
                Spacer()
            }
            
            GeometryReader { proxy in
                let size = proxy.size
                
                Image("intro_image_2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(30)
                    .frame(width: size.width, height: size.height)
            }

            CustomTextField(text: $fullName, hint: "Full Name", leadingIcon: Image(systemName: "person"))
                .onChange(of: fullName) { newValue in
                    fullName = InputValidator.sanitiseFullName(newValue)
                }

            CustomTextField(text: $username, hint: "Choose a Username", leadingIcon: Image(systemName: "at"))
                .autocapitalization(.none)
                .onChange(of: username) { newValue in
                    username = InputValidator.sanitiseUsername(newValue)
                }

            Text("Usernames: 3–20 chars, lowercase letters, numbers and underscores only.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Date of Birth")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Image(systemName: "calendar")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(width: 40, alignment: .leading)

                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                // Validate name
                if let nameError = InputValidator.validateFullName(fullName) {
                    errorMessage = nameError; return
                }
                // Validate username format
                if let usernameError = InputValidator.validateUsername(username) {
                    errorMessage = usernameError; return
                }
                // Validate age
                let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                guard age >= 13 else {
                    errorMessage = "You must be at least 13 years old."
                    return
                }
                errorMessage = nil

                Task {
                    do {
                        // Check username availability
                        let isAvailable = try await UserManager.shared.checkAvailableUsername(username: username)
                        guard isAvailable else {
                            errorMessage = "This username is already taken."
                            return
                        }

                        // Save the info (trim whitespace before writing to Firestore)
                        try await UserManager.shared.updateUserProfileInfo(
                            userId: userID,
                            fullName: fullName.trimmingCharacters(in: .whitespaces),
                            username: username,
                            dateOfBirth: birthDate
                        )

                        try await userVM.loadCurrentUser()

                        await MainActor.run {
                            onComplete()
                        }
                    } catch {
                        errorMessage = "Failed to save profile: \(error.localizedDescription)"
                        print("Failed to save profile: \(error.localizedDescription)")
                    }
                }

            } label: {
                Text("Study!")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background {
                        Capsule().fill(.black)
                    }
            }
            .frame(maxWidth: .infinity)
            .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty || username.isEmpty)
            
        }
        .padding()
    }
}

 
 

#Preview {
    ProfileSetupView(userID: "sdfasdga", onComplete: {})
}
