//
//  TasksSegmentedControl.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI

struct TasksSegmentedControl: View {
    @Binding var selectedFilter: TasksFilter
    
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
                                    .fill(selectedFilter == filter ? Color.black : Color(.systemGray5))
                            )
                            .foregroundColor(selectedFilter == filter ? .white : .black)
                    }
                }
            }
            .padding(.horizontal,20)
        }
    }
}

#Preview {
    TasksSegmentedControl(selectedFilter: .constant(.all))
}
