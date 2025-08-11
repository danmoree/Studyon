//
//  UserIncomingReqCardView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/12/25.
//

import SwiftUI

struct UserIncomingReqCardView: View {
    let user: DBUser
    @ObservedObject var viewModel: SocialViewModel
    
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
            // accept button
            
            Button {
                Task {
                    await viewModel.acceptFriendRequest(from: user.userId)
                    await viewModel.fetchFriends()
                }
            } label: {
                ZStack {
                    HStack {
                        Text("Accept")
                            .font(.caption2)
                            .fontWidth(.expanded)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width:80, height: 30)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }
            
            Button {
                Task {
                    await viewModel.declineFriendRequest(from: user.userId)
                }
            } label: {
                ZStack {
                    HStack {
                        Text("Decline")
                            .font(.caption2)
                            .fontWidth(.expanded)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width:81, height: 30)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
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
    }
}

#Preview {
    UserIncomingReqCardView(
        user: DBUser(userId: "test", email: "test@example.com", photoUrl: nil, dateCreated: nil, isPremium: false, fullName: "Daniel M", username: "danmore", dateOfBirth: nil, dailyStudyGoal: nil, usernameLowercased: "danmore"),
        viewModel: SocialViewModel()
    )
}
