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
    
    @State private var fullName    = ""
    @State private var username    = ""
    @State private var birthDate   = Date()
    @State private var errorMessage: String?
    
    @EnvironmentObject var userVM: ProfileViewModel
    @Environment(\.presentationMode) var presentation
    
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
    ProfileSetupView(userID: "sdfasdga")
}
