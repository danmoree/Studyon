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

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
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
                case .social:
                    //SocialFeedView()
                    Text("Social")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !hideTabBar {
                TabBarView(selectedTab: $selectedTab)
                    .padding(.bottom, 25)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainTabView(isUserLoggedIn: .constant(true))
        .environmentObject(ProfileViewModel())
}
