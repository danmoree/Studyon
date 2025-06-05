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

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .tasks:
                    TasksView(isUserLoggedIn: $isUserLoggedIn)
                    
                case .rooms:
                    StudyRoomsView(isUserLoggedIn: $isUserLoggedIn, hideTabBar: $hideTabBar)
                    //Text("Studyrooms")
                case .home:
                    HomeParentView(isUserLoggedIn: $isUserLoggedIn)
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
