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
    
    private func fetchUsername(for userId: String?) async {
        guard let userId else { hostUsername = nil; return }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            hostUsername = user.username ?? "Unknown"
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
                Text((hostUsername ?? (room.hostId ?? "Unknown")) + "'s \nStudy Room 🤓")
                    .font(.body)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                
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
                        if let hostProfileImage {
                            Image(uiImage: hostProfileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        } else {
                            Image("profile_pic1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        }
                        
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 25, height: 25)
                            Text("+4")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .fontWidth(.expanded)
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
