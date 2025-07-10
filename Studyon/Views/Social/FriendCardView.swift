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
    var body: some View {
        HStack {
            // profile pic, online/offline
            
            ZStack {
                Image("profile_pic1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.leading, 10)
                Circle()
                    .fill(Color.green)
                    .frame(width: 15, height: 15)
                    .padding(.leading, 35)
                    .padding(.top, 35)
            }
            
            
            // username, message
            VStack(alignment: .leading) {
                Text(user.username ?? "User")
                    .font(.title3)
                    .bold()
                Text("In a room")
            }
            .fontWidth(.expanded)
            
            Spacer()
            // dm button
            
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 40, height: 54)
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Color.white)
                    .font(.title3)
               
            }
        }
        .padding(.horizontal, 23)
        .frame(width: .infinity, height: 100)
        //.background(Color.gray.opacity(0.1))
    }
}

#Preview {
    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"))
}
