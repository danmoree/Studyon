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
    
    @Binding var needsProfileSetup: Bool
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
            
            CustomTextField(text: $username, hint: "Choose a Username", leadingIcon: Image(systemName: "at"))
                .autocapitalization(.none)
            
            Text("Date of Birth")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Image(systemName: "calendar")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(width: 40, alignment: .leading)
                
                DatePicker("", selection: $birthDate, displayedComponents: .date)
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
            }
            
            
            Button {
                let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                let age = ageComponents.year ?? 0

                guard age >= 13 else {
                    errorMessage = "You must be at least 13 years old."
                    return
                }
                errorMessage = nil
                
                
                Task {
                    do {
                        try await UserManager.shared.updateUserProfileInfo(
                            userId: userID,
                            fullName: fullName,
                            username: username,
                            dateOfBirth: birthDate
                        )
                        
                        // Optional: refresh profile
                        try await userVM.loadCurrentUser()
                        
                        needsProfileSetup = false
                        
                        
                    } catch {
                        errorMessage = "Failed to save profile: \(error.localizedDescription)"
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
            .disabled(fullName.isEmpty || username.isEmpty)
            
        }
        .padding()
    }
}

 
 

#Preview {
    ProfileSetupView(userID: "sdfasdga", needsProfileSetup: .constant(true))
}
