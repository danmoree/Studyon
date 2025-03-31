//
//  MainTabView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .tasks:
                    //TasksView()
                    Text("Tasks")
                case .rooms:
                    //StudyRoomsView()
                    Text("Rooms")
                case .home:
                    //HomeView()
                    //Text("Home")
                    HomeParentView()
                case .social:
                    //SocialFeedView()
                    Text("Social")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            TabBarView(selectedTab: $selectedTab)
                .padding(.bottom, 25)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainTabView()
}
