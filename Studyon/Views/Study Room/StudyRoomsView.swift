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

struct StudyRoomsView: View {
    @State private var selectedFilter: StudyRoomsFilter = .all
    @State private var showCreateRoomSheet = false
    @Binding var isUserLoggedIn: Bool
    @Binding var hideTabBar: Bool
    //@State private var selectedRoom: StudyRoom? = nil
    @Environment(\.colorScheme) var colorScheme
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
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "CS 471 Study", startTime: "11:00 AM", endTime: "1:00 PM", creatorUsername: "danmore", pomoDuration: 1800, pomoBreakDuration: 600, studyRoom: selectedRoom ?? nil)
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "Geo Study", startTime: "12:00 PM", endTime: "2:00 PM", creatorUsername: "emalynn", pomoDuration: 2700, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "Diff eq study", startTime: "6:00 PM", endTime: "9:00 PM", creatorUsername: "Brader", pomoDuration: 1800, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
                                                    
                                                }
                                                .padding(.horizontal, 0)
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
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "CS 471 Study", startTime: "11:00 AM", endTime: "1:00 PM", creatorUsername: "danmore", pomoDuration: 1800, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "Geo Study", startTime: "12:00 PM", endTime: "2:00 PM", creatorUsername: "emalynn", pomoDuration: 2700, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
//                                                    StudyRoomCard(hideTabBar: $hideTabBar, title: "Diff eq study", startTime: "6:00 PM", endTime: "9:00 PM", creatorUsername: "Brader", pomoDuration: 1800, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
//                                                    
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
        }
        
        
    }
}


#Preview {
    StudyRoomsView(isUserLoggedIn: .constant(true), hideTabBar: .constant(true))
        .environmentObject(ProfileViewModel())
}
