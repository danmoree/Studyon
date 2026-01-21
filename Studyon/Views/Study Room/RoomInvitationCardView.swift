//
//  RoomInvitationCardView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/2/26.
//

import SwiftUI

struct RoomInvitationCardView: View {
    let roomLink: RoomLink
    @ObservedObject var viewModel: RoomInboxViewModel
    @State private var isProcessing: Bool = false

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
                    Text(roomLink.roomTitle ?? "Untitled Room")
                        .fontWidth(.expanded)
                        .fontWeight(.medium)
                        .font(.callout)
                    Text("Hosted by \(roomLink.hostName ?? "Unknown")")
                        .font(.caption)
                    if let startTime = roomLink.startTime {
                        Text(formatDate(startTime))
                            .font(.caption)
                    }
                    if let startTime = roomLink.startTime, let endTime = roomLink.endTime {
                        Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                            .font(.caption)
                    }
                }
                .fontWidth(.expanded)
                
                Spacer()
            }
            
            HStack {
                Button {
                    Task {
                        isProcessing = true
                        await viewModel.acceptInvite(roomId: roomLink.roomId)
                        isProcessing = false
                    }
                } label: {
                    ZStack {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            } else {
                                Text("Accept")
                                    .font(.caption2)
                                    .fontWidth(.expanded)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 1)
                    .frame(width:71, height: 30)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                }
                .disabled(isProcessing)

                Button {
                    Task {
                        isProcessing = true
                        await viewModel.declineInvite(roomId: roomLink.roomId)
                        isProcessing = false
                    }
                } label: {
                    ZStack {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            } else {
                                Text("Decline")
                                    .font(.caption2)
                                    .fontWidth(.expanded)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 1)
                    .frame(width:71, height: 30)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                }
                .disabled(isProcessing)
                Spacer()
            }
        }
    }

    // MARK: - Helper Formatters
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    let mockRoomLink = RoomLink(
        roomId: "preview-room",
        userId: "preview-user",
        status: "invited",
        invitedBy: "host-123",
        roomTitle: "Dan's Biology Study Sesh",
        roomDescription: "Let's study chapter 5",
        hostName: "Dan Moreno",
        startTime: Date(),
        endTime: Date().addingTimeInterval(7200),
        activeUntil: Date().addingTimeInterval(7200),
        invitedAt: Date()
    )
    let viewModel = RoomInboxViewModel()

    return RoomInvitationCardView(roomLink: mockRoomLink, viewModel: viewModel)
}
