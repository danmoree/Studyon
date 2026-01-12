//
//  RoomInvitationCardView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/2/26.
//

import SwiftUI

struct RoomInvitationCardView: View {
    var body: some View {
        VStack {
            HStack {
                // Host profile pic
                Image("default_profile_pic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                    .padding(.leading, 2)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    Text("Dan’s Biology Study Sesh")
                        .fontWidth(.expanded)
                        .fontWeight(.medium)
                        .font(.callout)
                    Text("Hosted by @danmoreee")
                        .font(.caption)
                    Text("Fri, Jan 2")
                        .font(.caption)
                    Text("6:30 PM - 8:30 PM")
                        .font(.caption)
                }
                .fontWidth(.expanded)
                
                Spacer()
            }
            
            HStack {
                Button {
                    
                } label: {
                    ZStack {
                        HStack {
                            Text("Accept")
                                .font(.caption2)
                                .fontWidth(.expanded)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 1)
                    .frame(width:71, height: 30)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                }
                Button {
                    
                } label: {
                    ZStack {
                        HStack {
                            Text("Decline")
                                .font(.caption2)
                                .fontWidth(.expanded)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 1)
                    .frame(width:71, height: 30)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                }
                Spacer()
            }
        }
    }
}

#Preview {
    RoomInvitationCardView()
}
