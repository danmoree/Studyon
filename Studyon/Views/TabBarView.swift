//
//  TabBarView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                            .background(
                                Circle()
                                    .fill(selectedTab == tab ? Color.white : Color.clear)
                                    .frame(width: 40, height: 40)
                            )
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .padding(.horizontal)
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
