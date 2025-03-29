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
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .matchedGeometryEffect(id: "background", in: animation)
                            }

                            Image(systemName: tab.iconName)
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == tab ? .black : .gray)
                        }
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
