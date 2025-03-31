//
//  HomeParentView.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import SwiftUI

struct HomeParentView: View {
    @State private var selectedFilter: HomeFilter = .all

    var body: some View {
        Spacer()
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hi, Daniel ☕️")
                            .font(.title)
                            .bold()
                            
                        
                        HStack(spacing: 10) {
                            Text("🔥 3 Days")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(20)
                                .font(.footnote)
                            Text("🟢 LVL 12")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(20)
                                .font(.footnote)
                        }
                    }
                  
                        
                }
               
            }
            .fontWidth(.expanded)
            .padding(.horizontal, 23)

            // Segmented Control
            HStack {
                HomeSegmentedControl(selectedFilter: $selectedFilter)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Scrollable content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedFilter {
                    case .all:
                        //SummaryCard()
                        //TimeSpentCard()
                        //ActiveRoomsPreviewView()
                        Text("Summary")
                    case .todo:
                        //TodoSummaryView()
                        Text("Todo")
                    case .activeRooms:
                        //ActiveRoomsPreviewView()
                        Text("Active rooms")
                    case .friends:
                        Text("Friends")
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeParentView()
}
