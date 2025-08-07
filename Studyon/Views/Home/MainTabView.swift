//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  MainTabView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var selectedTab: Tab = .home
    @State private var hideTabBar = false
    @StateObject private var tasksVM = TasksViewModel()
    @StateObject private var socialVM = SocialViewModel()
    @EnvironmentObject var settingsVM:  SettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                
                if colorScheme == .light {
                    AnimatedCloudsView()
                }
                
                switch selectedTab {
                case .tasks:
                    TasksView(isUserLoggedIn: $isUserLoggedIn)
                        .environmentObject(tasksVM)
                    
                case .rooms:
                    StudyRoomsView(isUserLoggedIn: $isUserLoggedIn, hideTabBar: $hideTabBar)
                    //Text("Studyrooms")
                case .home:
                    HomeParentView(isUserLoggedIn: $isUserLoggedIn)
                        .environmentObject(tasksVM)
                        .environmentObject(socialVM)
                        .environmentObject(settingsVM)
                case .social:
                   SocialView(viewModel: socialVM)
                }
                
                if !hideTabBar {
                    TabBarView(selectedTab: $selectedTab)
                        .padding(.bottom, 25)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
           
            
        }
        .onAppear {
            Task {
                await socialVM.fetchFriends()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainTabView(isUserLoggedIn: .constant(true))
        .environmentObject(ProfileViewModel())
}
