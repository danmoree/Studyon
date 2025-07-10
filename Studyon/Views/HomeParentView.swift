//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  HomeParentView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI
import FirebaseAuth

struct HomeParentView: View {
    @State private var selectedFilter: HomeFilter = .all
    @State private var showingSettings = false
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var userVM: ProfileViewModel
    @StateObject private var widgetVM =  HomeWidgetsViewModel()
    @EnvironmentObject var tasksVM: TasksViewModel

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundStyle(.black)
                            .frame(width: 60, height: 60)
                    }
                    .sheet(isPresented: $showingSettings) {
                        UserSettings(isUserLoggedIn: $isUserLoggedIn)
                    }

                  
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let user = userVM.user {
                            Text("Hi, \(user.fullName?.split(separator: " ").first.map(String.init) ?? "there") ☕️")
                                .font(.title)
                                .bold()
                        } else {
                            Text("Loading...")
                        }
                        
                            
                        
                        HStack(spacing: 10) {
                            Text("🔥 \(widgetVM.dayStreak) Days")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(20)
                                .font(.footnote)
                            Text(widgetVM.getLevel(from: widgetVM.xp))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(20)
                                .font(.footnote)
                        }
                    }
                  
                        
                }
               
            }
            .fontWidth(.expanded)
            .padding(.horizontal, 23)
            .padding(.top, 20)
            

            // Segmented Control - Top tab bar
           // HStack {
           //     HomeSegmentedControl(selectedFilter: $selectedFilter)
           //}
           // .frame(maxWidth: .infinity, alignment: .leading)

            // Scrollable content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedFilter {
                    case .all:
                        VStack {
                            VStack {
                                HStack {
                                    Text("Today's Focus")
                                        .fontWeight(.bold)
                                        .fontWidth(.expanded)
                                        .font(.title3)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                                
                                HStack {
                                    TodayTasks()
                                        .environmentObject(tasksVM)
                                        .environmentObject(userVM)
                                    Spacer()
                                    StudiedTimeTodayView(studiedTimeToday: widgetVM.secondsStudiedToday)
                                }
                                QuickStartStudyRoomView()
                                    .padding(.vertical, 10)
                                DailyGoalProgressView(studiedTimeToday: widgetVM.secondsStudiedToday, goalAmount: 50 * 60) // min to seconds
                            }
                            .padding(.bottom)
                            
                            // Active rooms sections
//                            HStack {
//                               Text("Active Rooms!!")
//                                    .fontWeight(.bold)
//                                    .fontWidth(.expanded)
//                                    .font(.title3)
//                                    .padding(.leading, 5)
//                                
//                                Spacer()
//                            }
//                            ActiveRoomsPreviewView()
                        }
                       
                        
                    case .todo:
                        //TodoSummaryView()
                        Text("Todo")
                    case .activeRooms:
                        //ActiveRoomsPreviewView()
                        Text("Active rooms")
                    case .friends:
                        Text("Friends")
                    }
                }
                .padding()
            }
            .padding(.bottom, 55)
            .task {
                if let uid = Auth.auth().currentUser?.uid {
                    print("fethcing tasks")
                    await widgetVM.loadAllStats(for: uid)
                }
            }
        }
    }
}

#Preview {
    HomeParentView(isUserLoggedIn: .constant(true))
        .environmentObject(ProfileViewModel())
        .environmentObject(TasksViewModel())
}
