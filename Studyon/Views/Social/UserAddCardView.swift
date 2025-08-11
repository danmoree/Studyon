//
//  UserAddCardView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/12/25.
//

import SwiftUI

struct UserAddCardView: View {
    let user: DBUser
    @ObservedObject var viewModel: SocialViewModel
    @State private var isAdded = false
    @State private var profileImage: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        HStack {
            // profile pic
            
            ZStack {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                } else if isLoadingImage {
                    ProgressView()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                } else {
                    Image("default_profile_pic")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                }
                
                    
            }
            
            
            // first name, username
            VStack(alignment: .leading) {
                Text(user.fullName ?? "Name")
                    .font(.body)
                    .bold()
                Text("@" + (user.username ?? "username"))
                    .font(.caption)
            }
            .fontWidth(.expanded)
            
            Spacer()
            // add button
            
            Button {
                Task {
                    await viewModel.sendFriendRequest(to: user.userId)
                    withAnimation {
                        isAdded = true
                    }
                }
            } label: {
                ZStack {
                    HStack {
                        Text(isAdded ? "Reqested" : "ADD")
                            .font(.caption2)
                            .fontWidth(.expanded)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: isAdded ? 100 : 70, height: 30)
                .background(isAdded ? Color.green : Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeInOut, value: isAdded)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
        .onAppear {
               isLoadingImage = true
               Task {
                   if let loaded = await try? UserManager.shared.fetchProfileImageWithDiskCache(for: user) {
                       await MainActor.run {
                           profileImage = loaded
                       }
                   }
                   await MainActor.run {
                       isLoadingImage = false
                   }
               }
           }
        //.background(Color.gray.opacity(0.1))
    }
}

#Preview {
    UserAddCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"), viewModel: SocialViewModel())
}

