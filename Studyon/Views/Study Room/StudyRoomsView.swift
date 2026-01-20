//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyRoomsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct StudyRoomsView: View {
    @State private var selectedFilter: StudyRoomsFilter = .all
    @State private var showCreateRoomSheet = false
    @State private var showInbox = false
    @Binding var isUserLoggedIn: Bool
    @Binding var hideTabBar: Bool
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var roomInboxVM = RoomInboxViewModel()

    @State private var showJoinSheet = false
    @State private var selectedRoomId: String? = nil
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color("background").ignoresSafeArea()
                    if colorScheme == .light {
                        AnimatedCloudsView()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Study Rooms 📚")
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Button {
                                    showInbox = true
                                } label: {
                                    Image(systemName: "tray.circle.fill")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.primary)
                                    
                                }
                                
                                Button {
                                    showCreateRoomSheet = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                            
                        }
                        .fontWidth(.expanded)
                        .padding(.horizontal, 23)
                        .padding(.top, 20)
                        
                        
                        
                        // Segmented Control - Top tab bar
                        HStack {
                            StudyRoomsSegmentedControl(selectedFilter: $selectedFilter)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        ScrollView {
                            VStack(spacing: 24) {
                                switch selectedFilter {
                                case .all:
                                    
                                    VStack {
                                        VStack {
                                            HStack {
                                                Text("Active Rooms!")
                                                    .fontWeight(.bold)
                                                    .fontWidth(.expanded)
                                                    .font(.title3)
                                                    .padding(.leading, 5)
                                                Spacer()
                                            }

                                            if roomInboxVM.activeRooms.isEmpty {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(.systemGray6))
                                                    .frame(height: 100)
                                                    .overlay(
                                                        Text("No active rooms right now 🔇")
                                                            .fontWidth(.expanded)
                                                            .foregroundColor(.secondary)
                                                            .font(.headline)
                                                    )
                                                    .padding(.horizontal, 5)
                                            } else {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 25) {
                                                        ForEach(roomInboxVM.activeRooms) { room in
                                                            if let startTime = room.startTime, Date() >= startTime {
                                                                NavigationLink {
                                                                    GroupStudyRoomViewNew(
                                                                        roomId: room.roomId,
                                                                        currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                                                                        isHost: room.hostId == Auth.auth().currentUser?.uid,
                                                                        pomoDuration: room.pomodoroLength,
                                                                        breakDuration: room.breakLength
                                                                    )
                                                                } label: {
                                                                    StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                                }
                                                            } else {
                                                                StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                            }
                                                        }
                                                    }
                                                }
                                                .scrollClipDisabled()
                                            }
                                        }
                                        .padding(.bottom, 29)
                                        
                                        
                                        VStack {
                                            HStack {
                                                Text("Upcoming Rooms")
                                                    .fontWeight(.bold)
                                                    .fontWidth(.expanded)
                                                    .font(.title3)
                                                    .padding(.leading, 5)
                                                Spacer()
                                            }
                                            
                                            if roomInboxVM.upcomingRooms.count == 0 {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(.systemGray6))
                                                    .frame(height: 100)
                                                    .overlay(
                                                        Text("Invited rooms appear here 👩‍🎓")
                                                            .fontWidth(.expanded)
                                                            .foregroundColor(.secondary)
                                                            .font(.headline)
                                                    )
                                                    .padding(.horizontal, 5)
                                            } else {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 25) {
                                                        ForEach(roomInboxVM.upcomingRooms) { room in
                                                            if let startTime = room.startTime, Date() >= startTime {
                                                                NavigationLink {
                                                                    GroupStudyRoomViewNew(
                                                                        roomId: room.roomId,
                                                                        currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                                                                        isHost: room.hostId == Auth.auth().currentUser?.uid,
                                                                        pomoDuration: room.pomodoroLength,
                                                                        breakDuration: room.breakLength
                                                                    )
                                                                } label: {
                                                                    StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                                }
                                                            } else {
                                                                StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                            }
                                                        }
                                                    }
                                                    .padding(.horizontal, 0)
                                                }
                                                .scrollClipDisabled()
                                            }
                                            
                                        }
                                    }
                                case .inProgress:
                                    VStack {
                                        HStack {
                                            Text("Active Rooms")
                                                .fontWeight(.bold)
                                                .fontWidth(.expanded)
                                                .font(.title3)
                                                .padding(.leading, 5)
                                            Spacer()
                                        }
                                        
                                        VStack(spacing: 0) {
                                            
                                        }
                                    }
                                case .upcoming:
                                    VStack {
                                        HStack {
                                            Text("Upcoming Rooms")
                                                .fontWeight(.bold)
                                                .fontWidth(.expanded)
                                                .font(.title3)
                                                .padding(.leading, 5)
                                            Spacer()
                                        }
                                        
                                        VStack(spacing: 0) {
                                            
                                        }
                                    }
                                    
                                }
                            }
                            .padding()
                        }
                        .padding(.bottom, 25)
                    }
                }
            }
            .ignoresSafeArea()
            .background(Color.clear)
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateRoomSheet) {
                CreateStudyRoomView(showCreateStudyRoom: $showCreateRoomSheet)
                    .presentationDetents([.height(340)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showInbox) {
                InvitesInboxView(showInboxView: $showInbox)
                    .presentationDetents([.height(600)])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                roomInboxVM.startListening()
            }
            .onDisappear {
                roomInboxVM.stopListening()
            }
        }
        
        
    }
}


#Preview {
    StudyRoomsView(isUserLoggedIn: .constant(true), hideTabBar: .constant(true))
        .environmentObject(ProfileViewModel())
}

