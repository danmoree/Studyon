//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  TabBarView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack {
                        ZStack {
                            if selectedTab == tab {
                                Circle()
                                    .fill(colorScheme == .light ? Color.white : Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .matchedGeometryEffect(id: "background", in: animation)
                            }

                            Image(systemName: tab.iconName)
                                .font(.system(size: 22))
                                .foregroundColor(
                                    selectedTab == tab
                                        ? (colorScheme == .light ? .black : .white)
                                        : .gray
                                )
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(Color("background"))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .background(Color.clear)
        .padding(.horizontal)
        .ignoresSafeArea(edges: .bottom)
    }
}

enum Tab: CaseIterable {
    case tasks,social,home,rooms

    var iconName: String {
        switch self {
        case .tasks: return "checkmark.square"
        case .social: return "person.3.fill"
        case .home: return "house.fill"
        case .rooms: return "lamp.desk"
        }
    }
}
#Preview {
    TabBarView(selectedTab: .constant(.home))
}
