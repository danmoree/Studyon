//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  FriendCardView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/10/25.
//

import SwiftUI

struct FriendCardView: View {
    let user: DBUser
    @State private var showSheet = false
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileImage: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        HStack {
            Button(action: { showSheet = true }) {
                HStack {
                    // profile pic, online/offline
                    
                    ZStack {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 45, height: 45)
                                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .stroke(colorScheme == .light ? Color.black : Color.gray, lineWidth: 1.5)
                                                            )
                        } else if isLoadingImage {
                            ProgressView()
                                                            .scaledToFill()
                                                            .frame(width: 45, height: 45)
                                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .stroke(colorScheme == .light ? Color.black : Color.gray, lineWidth: 1.5)
                                                            )
                        } else {
                            Image("default_profile_pic")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(colorScheme == .light ? Color.black : Color.gray, lineWidth: 1.5)
                                )
                        }
                       
                        
                        Circle()
                            .fill(user.isOnline == true ? Color.green : Color.gray)
                            .frame(width: 15, height: 15)
                            .padding(.leading, 30)
                            .padding(.top, 35)
                    }
                    .onAppear {
                        if let cachedImage = viewModel.loadCachedFriendProfileImage(for: user.userId) {
                            profileImage = cachedImage
                        } else {
                            isLoadingImage = true
                            Task {
                                if let loaded = await try? UserManager.shared.fetchProfileImageWithDiskCache(for: user) {
                                    await MainActor.run {
                                        profileImage = loaded
                                        viewModel.cacheFriendProfileImage(loaded, for: user.userId)
                                        isLoadingImage = false
                                    }
                                } else {
                                    await MainActor.run {
                                        isLoadingImage = false
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    // username, message
                    VStack(alignment: .leading) {
                        Text(user.username ?? "User")
                            .font(.body)
                            .bold()
                        Text(user.isOnline == true ? "Online" : "Offline")
                            .font(.caption)
                    }
                    .fontWidth(.expanded)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            // dm button
            
//            ZStack {
//                Circle()
//                    .fill(Color.green)
//                    .frame(width: 35, height: 35)
//                Image(systemName: "paperplane.fill")
//                    .foregroundStyle(Color.white)
//                    .font(.subheadline)
//               
//            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
        //.background(Color.gray.opacity(0.1))
        .sheet(isPresented: $showSheet) {
            FriendFullSheetView(user: user, showFriendSheet: $showSheet, socialVM: viewModel)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"), viewModel: SocialViewModel())
        .environmentObject(SocialViewModel())
}
