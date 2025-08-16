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
    
    @State var loadingRoom: Bool = false
    
    private func createRoomInFirestore() {
        let newRoomId = Firestore.firestore().collection("rooms").document().documentID
        let userId = Auth.auth().currentUser?.uid ?? ""
        let createdAt = FieldValue.serverTimestamp()
        let start = startDate ?? Date()
        let end = endDate ?? (start.addingTimeInterval(3600))
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
        Firestore.firestore().collection("rooms").document(newRoomId).setData(roomData) { error in
            if let error = error {
                print("Error creating room: \(error)")
            } else {
                print("Room created successfully with ID: \(newRoomId)")
            }
        }
    }
    
    var body: some View {
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
                        Text("Title")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                        CustomTextField2(text: $title, hint: "Biology exam lock in")
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
                        ), in: 15...60, step: 5)
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
                        loadingRoom = true
                        createRoomInFirestore()
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
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
