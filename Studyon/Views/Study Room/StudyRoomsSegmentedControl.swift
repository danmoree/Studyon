//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyRoomsSegmentedControlView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI

struct StudyRoomsSegmentedControl: View {
    @Binding var selectedFilter: StudyRoomsFilter
    @Environment(\.colorScheme) var colorScheme
    
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
    StudyRoomsSegmentedControl(selectedFilter: .constant(.all))
}
