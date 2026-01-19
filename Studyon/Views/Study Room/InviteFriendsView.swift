//
//  InviteFriendsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/18/26.
//

import SwiftUI

struct InviteFriendsView: View {
    @EnvironmentObject var socialVM: SocialViewModel
    
    var body: some View {
        content
            .navigationTitle("Invite Friends")
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
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InviteFriendsView()
        .environmentObject(SocialViewModel())
}
