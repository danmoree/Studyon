//
//  InviteFriendsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/18/26.
//

import SwiftUI

struct InviteFriendsView: View {
    @EnvironmentObject var socialVM: SocialViewModel
    let roomId: String
    @State private var invitedUserIds: Set<String> = []
    @State private var isInviting: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        content
            .navigationTitle("Invite Friends")
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if socialVM.friends.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "person.2.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("No friends yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Add or follow friends to invite them to your room.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                Section(header: Text("All Friends")) {
                    ForEach(socialVM.friends, id: \.userId) { (friend: DBUser) in
                        HStack {
                            if let urlString = friend.photoUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 36, height: 36)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image("default_profile_pic")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                    @unknown default:
                                        Image("default_profile_pic")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                    }
                                }
                            } else {
                                Image("default_profile_pic")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            }
                            
                            Text(friend.fullName ?? "NULL")

                            Spacer()

                            if invitedUserIds.contains(friend.userId) {
                                // Show checkmark if invited
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if isInviting {
                                ProgressView()
                            } else {
                                Button("Invite") {
                                    Task {
                                        await inviteFriend(friend.userId)
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Invite Action
    private func inviteFriend(_ userId: String) async {
        isInviting = true
        do {
            try await RoomInvitationManager.shared.inviteUsers(roomId: roomId, userIds: [userId])
            await MainActor.run {
                invitedUserIds.insert(userId)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        isInviting = false
    }
}

#Preview {
    let viewModel = SocialViewModel()
    viewModel.friends = [
        DBUser(userId: "1", photoUrl: nil, fullName: "John Smith"),
        DBUser(userId: "2", photoUrl: nil, fullName: "Sarah Johnson"),
        DBUser(userId: "3", photoUrl: nil, fullName: "Mike Chen")
    ] as [DBUser]

    return InviteFriendsView(roomId: "preview-room-id")
        .environmentObject(viewModel)
}
