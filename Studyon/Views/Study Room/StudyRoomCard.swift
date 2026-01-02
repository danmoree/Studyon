//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyRoomCard.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

extension DateFormatter {
    static var timeOnly: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
}

struct StudyRoomCard: View {
    @Binding var hideTabBar: Bool
    
//    let title: String
//    let startTime: String
//    let endTime: String
//    let creatorUsername: String
//    let pomoDuration: Int
//    let pomoBreakDuration: Int
    
    let room: GroupStudyRoom
    
    @State private var hostUsername: String? = nil
    @State private var hostProfileImage: UIImage? = nil
    
    // Presence-driven avatars
    @State private var activeMemberIds: [String] = []
    @State private var activeMemberImages: [UIImage?] = []
    @State private var totalActiveCount: Int = 0
    @State private var presenceRef: DatabaseReference? = nil
    @State private var presenceHandle: DatabaseHandle? = nil
    
    private var formattedStartTime: String {
        if let startDate = room.startTime as? Date {
            return DateFormatter.timeOnly.string(from: startDate)
        }
        if let start = room.startTime as? String {
            return start
        }
        return "-"
    }
    private var formattedEndTime: String {
        if let endDate = room.endTime as? Date {
            return DateFormatter.timeOnly.string(from: endDate)
        }
        if let end = room.endTime as? String {
            return end
        }
        return "-"
    }
    private var displayHostName: String {
        let raw = hostUsername ?? (room.hostId ?? "Unknown")
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func fetchUsername(for userId: String?) async {
        guard let userId else { hostUsername = nil; return }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            hostUsername = (user.username ?? "Unknown").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            hostUsername = "Unknown"
        }
    }
    
    private func fetchProfileImage(for userId: String?) async {
        guard let userId else { hostProfileImage = nil; return }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            let image = try await UserManager.shared.fetchProfileImageWithDiskCache(for: user)
            await MainActor.run {
                hostProfileImage = image
            }
        } catch {
            await MainActor.run {
                hostProfileImage = nil
            }
        }
    }
    
    // Observe active members (online) from Realtime Database under status/{roomId}
    private func observeActiveMembers() {
        // Ensure we only attach one observer per card instance
        stopObservingPresence()
        let ref = Database.database().reference(withPath: "status/\(room.roomId)")
        presenceRef = ref
        presenceHandle = ref.observe(.value) { snapshot in
            var onlineIds: [String] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let state = dict["state"] as? String,
                   state == "online" {
                    onlineIds.append(snap.key)
                }
            }
            // Prefer the host first if present, then stable order by uid
            let sortedIds = onlineIds.sorted { a, b in
                if a == room.hostId { return true }
                if b == room.hostId { return false }
                return a < b
            }
            Task {
                await MainActor.run {
                    self.totalActiveCount = onlineIds.count
                    self.activeMemberIds = sortedIds
                }
                await loadActiveMemberImages(for: sortedIds)
            }
        }
    }

    private func stopObservingPresence() {
        if let handle = presenceHandle, let ref = presenceRef {
            ref.removeObserver(withHandle: handle)
        }
        presenceHandle = nil
        presenceRef = nil
    }

    /// Loads up to 4 profile images for the provided user IDs, preserving their order.
    private func loadActiveMemberImages(for ids: [String]) async {
        let topIds = Array(ids.prefix(2))
        guard !topIds.isEmpty else {
            await MainActor.run { self.activeMemberImages = [] }
            return
        }
        do {
            // Fetch user documents in batches
            let users = try await UserManager.shared.fetchUsers(for: topIds)
            // Map userId -> DBUser for quick lookup
            var userById: [String: DBUser] = [:]
            for u in users { userById[u.userId] = u }

            // Concurrently fetch images, keeping association by uid
            var imageById: [String: UIImage] = [:]
            await withTaskGroup(of: (String, UIImage?).self) { group in
                for uid in topIds {
                    if let user = userById[uid] {
                        group.addTask {
                            let image = try? await UserManager.shared.fetchProfileImageWithDiskCache(for: user)
                            return (uid, image)
                        }
                    } else {
                        group.addTask { return (uid, nil) }
                    }
                }
                for await (uid, image) in group {
                    if let image { imageById[uid] = image }
                }
            }

            // Preserve the input order and include nils for users without images so we can show defaults
            let images: [UIImage?] = topIds.map { imageById[$0] }
            await MainActor.run {
                self.activeMemberImages = images
            }
        } catch {
            await MainActor.run { self.activeMemberImages = Array(repeating: nil, count: topIds.count) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                // top description, time
                Text(room.title ?? "No Title")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .fontWeight(.light)
                    .fontWidth(.expanded)
                    .lineLimit(2)            // up to two lines
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 0.5, height: 30)

                Spacer(minLength: 8)

                Text("\(formattedStartTime) - \n\(formattedEndTime)")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .fontWidth(.expanded)
                    .fontWeight(.light)
                    .fixedSize()
            }
            Spacer()
            HStack {
                // creators room title
                Text(displayHostName + "'s \nStudy Room 🤓")
                    .font(.body)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Spacer()
            VStack {
                // bottom description
                HStack {
                    // Pomodoro
                    Text("Pomodoro")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
                HStack {
                    // study time amount
                    Text("Study \(room.pomodoroLength /  60)m")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
                HStack {
                    // break time amount
                    Text("Break \(room.breakLength /  60)m")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                // members pfp
                // join button
                HStack {
                    HStack(spacing: -4) {
                        if activeMemberImages.isEmpty {
                            // Fallback: show host image or default if no active members available
                            if let hostProfileImage {
                                Image(uiImage: hostProfileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                            } else {
                                Image("default_profile_pic")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                            }
                        } else {
                            ForEach(0..<min(activeMemberImages.count, 2), id: \.self) { i in
                                if let img = activeMemberImages[i] {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                } else {
                                    Image("default_profile_pic")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                }
                            }
                            if totalActiveCount > 2 {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 25, height: 25)
                                    Text("+\(totalActiveCount - 2)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .fontWidth(.expanded)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: GroupStudyRoomViewNew(
                        roomId: room.roomId,
                        currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                        isHost: room.hostId == Auth.auth().currentUser?.uid,
                        pomoDuration: room.pomodoroLength,
                        breakDuration: room.breakLength
                    )
                        .onAppear { hideTabBar = true }
                        .onDisappear { hideTabBar = false }
                    ) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.black)
                    }
                    
                    
                    
                }
            }
        }
        .frame(alignment: .top)
        .padding()
        .frame(width: 200.2, height: 284.7)
        .background(Color(red: 183/255, green: 225/255, blue: 147/255))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task {
            await fetchUsername(for: room.hostId)
            await fetchProfileImage(for: room.hostId)
        }
        .onAppear { observeActiveMembers() }
        .onDisappear { stopObservingPresence() }
    }
}

#Preview {
    let demoRoom = GroupStudyRoom(
        roomId: "demo123",
        title: "CS 471 Study",
        description: "Final review session",
        memberIds: ["danmore", "alice", "bob"],
        createdAt: Date(),
        startTime: Date(),
        endTime: Date().addingTimeInterval(7200),
        maxMemberLimit: 10,
        isPrivate: false, hostId: "danmore", timer: nil, pomodoroLength: 1500,
        breakLength: 300
    )
    StudyRoomCard(hideTabBar: .constant(true), room: demoRoom)
}

