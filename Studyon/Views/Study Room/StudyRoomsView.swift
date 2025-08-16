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
    @Binding var isUserLoggedIn: Bool
    @Binding var hideTabBar: Bool
    //@State private var selectedRoom: StudyRoom? = nil
    @Environment(\.colorScheme) var colorScheme
    
    @State private var activeRooms: [GroupStudyRoom] = []
    @State private var upcomingRooms: [GroupStudyRoom] = []
    @State private var activeRoomsListener: ListenerRegistration? = nil
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
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 25) {
                                                    ForEach(activeRooms) { room in
                                                        NavigationLink {
                                                            GroupStudyRoomView(
                                                                roomId: room.roomId,
                                                                currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                                                                isHost: room.hostId == Auth.auth().currentUser?.uid
                                                            )
                                                        } label: {
                                                            StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                        }
                                                    }
                                                }
                                            }
                                            .scrollClipDisabled()
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
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 25) {
                                                    ForEach(upcomingRooms) { room in
                                                        NavigationLink {
                                                            GroupStudyRoomView(
                                                                roomId: room.roomId,
                                                                currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                                                                isHost: room.hostId == Auth.auth().currentUser?.uid
                                                            )
                                                        } label: {
                                                            StudyRoomCard(hideTabBar: $hideTabBar, room: room)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 0)
                                            }
                                            .scrollClipDisabled()
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
            .onAppear {
                activeRoomsListener = StudyRoomManager.shared.listenActiveRooms { rooms in
                    self.activeRooms = rooms
                }
                StudyRoomManager.shared.fetchRoomsStartingSoon { rooms in
                    self.upcomingRooms = rooms
                }
            }
            .onDisappear {
                activeRoomsListener?.remove()
                activeRoomsListener = nil
            }
        }
        
        
    }
}


#Preview {
    StudyRoomsView(isUserLoggedIn: .constant(true), hideTabBar: .constant(true))
        .environmentObject(ProfileViewModel())
}

private struct ActiveRoomCard: View {
    let room: GroupStudyRoom
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(room.title ?? "Untitled Room")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                PhaseTag(phase: room.timer?.phase ?? "work")
            }
            HStack(spacing: 6) {
                Image(systemName: "person.2")
                Text("\(room.memberIds?.count ?? 1)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct PhaseTag: View {
    let phase: String
    var body: some View {
        Text(phase == "break" ? "Break" : "Work")
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(phase == "break" ? Color.blue.opacity(0.15) : Color.green.opacity(0.15), in: Capsule())
    }
}
