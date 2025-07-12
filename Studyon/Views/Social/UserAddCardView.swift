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
    var body: some View {
        HStack {
            // profile pic
            
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
                }
            } label: {
                ZStack {
                    HStack {
                        Text("ADD")
                            .font(.caption2)
                            .fontWidth(.expanded)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width:70, height: 30)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
        //.background(Color.gray.opacity(0.1))
    }
}

#Preview {
    UserAddCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"), viewModel: SocialViewModel())
}
