//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  SocialView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/10/25.
//

import SwiftUI

struct SocialView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Friends 🌎")
                        .font(.title)
                        .fontWidth(.expanded)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            HStack {
                                Image(systemName: "person.fill.badge.plus")
                                Text("ADD")
                                    .font(.caption2)
                                    .fontWidth(.expanded)
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width:90, height: 30)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    }
                }
            }
            .padding(.horizontal, 23)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            ScrollView {
                VStack (spacing: 25) {
                    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"))
                    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"))
                    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"))
                    FriendCardView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"))
                }
                .padding(.top, 10)
            }
            .padding(.bottom, 55)
        }
       
    }
}

#Preview {
    SocialView()
}
