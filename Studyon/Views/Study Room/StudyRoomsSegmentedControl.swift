//
//  StudyRoomsSegmentedControlView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI

struct StudyRoomsSegmentedControl: View {
    @Binding var selectedFilter: StudyRoomsFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StudyRoomsFilter.allCases, id: \.self) { filter in
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
    StudyRoomsSegmentedControl(selectedFilter: .constant(.all))
}
