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
    
    var body: some View {
        HStack {
            Button(action: { showSheet = true }) {
                HStack {
                    // profile pic, online/offline
                    
                    ZStack {
                        Image("profile_pic1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 1.5)
                            )
                            
                        Circle()
                            .fill(user.isOnline == true ? Color.green : Color.gray)
                            .frame(width: 15, height: 15)
                            .padding(.leading, 30)
                            .padding(.top, 35)
                    }
                    
                    
                    // username, message
                    VStack(alignment: .leading) {
                        Text(user.username ?? "User")
                            .font(.body)
                            .bold()
                        Text("In a room")
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

