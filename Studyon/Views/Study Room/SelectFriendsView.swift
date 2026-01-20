//
//  SelectFriendsView.swift
//  Studyon
//
//  Created by Claude on 1/19/26.
//

import SwiftUI

struct SelectFriendsView: View {
    @EnvironmentObject var socialVM: SocialViewModel
    @Binding var selectedFriendIds: Set<String>

    var body: some View {
        content
            .navigationTitle("Select Friends")
            .navigationBarTitleDisplayMode(.inline)
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

                            Text(friend.fullName ?? "Unknown")

                            Spacer()

                            // Checkmark if selected
                            if selectedFriendIds.contains(friend.userId) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.gray)
                                    .font(.title2)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(friend.userId)
                        }
                    }
                }
            }
        }
    }

    private func toggleSelection(_ userId: String) {
        if selectedFriendIds.contains(userId) {
            selectedFriendIds.remove(userId)
        } else {
            selectedFriendIds.insert(userId)
        }
    }
}

#Preview {
    let viewModel = SocialViewModel()
    viewModel.friends = [
        DBUser(userId: "1", photoUrl: nil, fullName: "John Smith"),
        DBUser(userId: "2", photoUrl: nil, fullName: "Sarah Johnson"),
        DBUser(userId: "3", photoUrl: nil, fullName: "Mike Chen")
    ] as [DBUser]

    return SelectFriendsView(selectedFriendIds: .constant(["1"]))
        .environmentObject(viewModel)
}
