//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  TasksSegmentedControl.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI

struct TasksSegmentedControl: View {
    @Binding var selectedFilter: TasksFilter
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TasksFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .fontWidth(.expanded)
                            .fontWeight(.light)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        selectedFilter == filter
                                            ? (colorScheme == .light ? Color.black : Color.white)
                                            : Color(.systemGray5)
                                    )
                            )
                            .foregroundColor(
                                selectedFilter == filter
                                    ? (colorScheme == .light ? .white : .black)
                                    : (colorScheme == .light ? .black : .white)
                            )
                    }
                }
            }
            .padding(.horizontal,20)
        }
    }
}

#Preview {
    ZStack {
        Color("background").ignoresSafeArea()
        TasksSegmentedControl(selectedFilter: .constant(.all))
    }
    
}
