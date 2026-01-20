//
//  InvitesInboxView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/2/26.
//

import SwiftUI

struct InvitesInboxView: View {
    @Binding var showInboxView: Bool
    @StateObject private var viewModel = RoomInboxViewModel()

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

                if viewModel.pendingInvites.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No pending invites")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.pendingInvites) { invite in
                                RoomInvitationCardView(roomLink: invite, viewModel: viewModel)
                                if invite.id != viewModel.pendingInvites.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

            }
            .padding(.horizontal, 23)
            .padding(.top, 20)

        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

#Preview {
    InvitesInboxView(showInboxView: .constant(true))
}
