//
//  InvitesInboxView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/2/26.
//

import SwiftUI

struct InvitesInboxView: View {
    @Binding var showInboxView: Bool
    var body: some View {
        VStack {
            VStack {
                // Title
                HStack {
                    Text("Room invites 👨‍🏫")
                        .font(.title)
                        .bold()
                        .fontWidth(.expanded)
                    Spacer()
                    
                    Button {
                        showInboxView = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                        
                    }
                    
                }
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        RoomInvitationCardView()
                        Divider()
//                        RoomInvitationCardView()
//                        Divider()
//                        RoomInvitationCardView()
                    }
                    .padding(.vertical, 8)
                }
                
            }
            .padding(.horizontal, 23)
            .padding(.top, 20)
            
        }
    }
}

#Preview {
    InvitesInboxView(showInboxView: .constant(true))
}
