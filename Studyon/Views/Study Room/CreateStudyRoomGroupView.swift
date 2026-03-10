//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  CreateStudyRoomGroupView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/13/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateStudyRoomGroupView: View {
    @Binding var showCreateStudyRoomGroup: Bool
    @State private var pomDuration: Int = 25 * 60
    @State private var pomBreakDuration: Int = 5 * 60
    @State private var newGroupRoom: GroupStudyRoom? = nil
    @State private var title: String = ""
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var isPrivate: Bool = false // false always for now
    // if private then need to open detailed room view, so user can send out invites
    @State var openRoomDetailedView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var socialVM: SocialViewModel
    
    @State var loadingRoom: Bool = false
    @State private var showInviteFriends: Bool = false
    @State private var selectedFriendIds: Set<String> = []
    @State private var titleError: String? = nil

    private func createRoomAndInviteFriends() async {
        let newRoomId = Firestore.firestore().collection("rooms").document().documentID
        let userId = Auth.auth().currentUser?.uid ?? ""
        let createdAt = FieldValue.serverTimestamp()
        let start = startDate ?? Date()
        let end = endDate ?? (start.addingTimeInterval(3600))
        let activeUntil = end
        let roomData: [String: Any] = [
            GroupStudyRoom.CodingKeys.roomId.rawValue: newRoomId,
            GroupStudyRoom.CodingKeys.hostId.rawValue: userId,
            GroupStudyRoom.CodingKeys.createdAt.rawValue: createdAt,
            GroupStudyRoom.CodingKeys.title.rawValue: title.isEmpty ? "Untitled Group Room" : title,
            GroupStudyRoom.CodingKeys.isPrivate.rawValue: isPrivate,
            GroupStudyRoom.CodingKeys.pomodoroLength.rawValue: pomDuration,
            GroupStudyRoom.CodingKeys.breakLength.rawValue: pomBreakDuration,
            GroupStudyRoom.CodingKeys.startTime.rawValue: start,
            GroupStudyRoom.CodingKeys.endTime.rawValue: end,
            GroupStudyRoom.CodingKeys.memberIds.rawValue: [userId]
        ]

        do {
            // Create room first
            try await Firestore.firestore().collection("rooms").document(newRoomId).setData(roomData)
            print("Room created successfully with ID: \(newRoomId)")

            // Create RoomLink for the host so they can see their own room
            let hostUser = try? await UserManager.shared.getUser(userId: userId)
            let hostName = hostUser?.fullName ?? "Unknown"

            let hostRoomLink = RoomLink(
                roomId: newRoomId,
                userId: userId,
                status: "accepted",
                invitedBy: userId,
                roomTitle: title.isEmpty ? "Untitled Group Room" : title,
                roomDescription: nil,
                hostName: hostName,
                startTime: start,
                endTime: end,
                activeUntil: activeUntil,
                invitedAt: Date()
            )

            let hostLinkData = try Firestore.Encoder().encode(hostRoomLink)
            try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("roomLinks")
                .document(newRoomId)
                .setData(hostLinkData)

            print("Host RoomLink created")

            // Then send invites if any friends selected
            if !selectedFriendIds.isEmpty {
                try await RoomInvitationManager.shared.inviteUsers(
                    roomId: newRoomId,
                    userIds: Array(selectedFriendIds)
                )
                print("Invitations sent to \(selectedFriendIds.count) friends")
            }
        } catch {
            print("Error creating room or sending invites: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title bar
                HStack {
                    Text("Create room! 🌎")
                        .font(.title)
                        .fontWeight(.heavy)
                        .fontWidth(.expanded)
                    
                    Spacer()
                    
                    Button {
                        showCreateStudyRoomGroup = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title TextField
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Title")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                Spacer()
                                Text("\(title.count)/\(InputValidator.roomTitleMax)")
                                    .font(.caption)
                                    .foregroundStyle(title.count > InputValidator.roomTitleMax - 10 ? .orange : .secondary)
                            }
                            CustomTextField2(
                                text: Binding(
                                    get: { title },
                                    set: { newValue in
                                        title = InputValidator.sanitiseTitle(newValue, maxLength: InputValidator.roomTitleMax)
                                        titleError = nil
                                    }
                                ),
                                hint: "Biology exam lock in"
                            )
                            if let error = titleError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Pomodoro Duration Slider
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pomodoro Duration: \(pomDuration / 60) min")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)
                            Slider(value: Binding(
                                get: { Double(pomDuration) / 60 },
                                set: { newValue in pomDuration = Int(newValue) * 60}
                            ), in: 1...30, step: 1)
                            .accentColor(colorScheme == .light ? .black : .white)
                        }
                        .padding(.horizontal)
                        
                        // Pomodoro Break Duration Slider
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Break Duration: \(pomBreakDuration / 60) min")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)
                            Slider(value: Binding(
                                get: { Double(pomBreakDuration) / 60 },
                                set: { pomBreakDuration = Int($0 * 60) }
                            ), in: 1...10, step: 1)
                            .accentColor(colorScheme == .light ? .black : .white)
                        }
                        .padding(.horizontal)
                        
                        // Start DatePicker
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Start Date")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                DatePicker(
                                    "Select start date",
                                    selection: Binding(
                                        get: { startDate ?? Date() },
                                        set: { startDate = $0 }
                                    ),
                                    in: Date()...(Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        
                        // End DatePicker
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("End Date")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                let minEndDate = startDate ?? Date()
                                let maxEndDate = Calendar.current.date(byAdding: .hour, value: 10, to: minEndDate) ?? minEndDate.addingTimeInterval(3600)
                                DatePicker(
                                    "Select end date",
                                    selection: Binding(
                                        get: { endDate ?? minEndDate },
                                        set: { endDate = $0 }
                                    ),
                                    in: minEndDate...maxEndDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        
                        // Show invited friends and invite
                        HStack {
                            Button {
                                showInviteFriends = true
                            } label: {
                                HStack {
                                    Text("Invite Friends")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                        .fontWidth(.expanded)
                                    if !selectedFriendIds.isEmpty {
                                        Text("(\(selectedFriendIds.count))")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(colorScheme == .light ? .white : .black)
                                            .fontWidth(.expanded)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Private Toggle, false for now
//                    VStack(alignment: .leading, spacing: 6) {
//                        Toggle(isOn: $isPrivate) {
//                            Text("Private Room")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .fontWidth(.expanded)
//                        }
//                    }
                        .padding(.horizontal)
                        
                        // Create Button
                        Button {
                            if let error = InputValidator.validateRoomTitle(title) {
                                titleError = error
                                return
                            }
                            Task {
                                loadingRoom = true
                                title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                                await createRoomAndInviteFriends()
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                showCreateStudyRoomGroup = false
                                loadingRoom = false
                            }
                        } label: {
                            if loadingRoom {
                                ProgressView()
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                                    .fontWidth(.expanded)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(title.isEmpty ? Color.gray.opacity(0.5) : Color.primary)
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Create")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                                    .fontWidth(.expanded)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(title.isEmpty ? Color.gray.opacity(0.5) : Color.primary)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(title.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding(.horizontal, 1)
            .padding(.top, 20)
            .navigationDestination(isPresented: $showInviteFriends) {
                SelectFriendsView(selectedFriendIds: $selectedFriendIds)
            }
        }
        .fullScreenCover(item: $newGroupRoom) { groupRoom in
            VStack {
                Text("Group Room Created")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                    .padding()
                Text("Room title: \(groupRoom.title)")
                    .font(.title3)
                Button("Dismiss") {
                    newGroupRoom = nil
                }
                .font(.headline)
                .padding()
            }
        }
    }
}

#Preview {
    CreateStudyRoomGroupView(showCreateStudyRoomGroup: .constant(true))
}

