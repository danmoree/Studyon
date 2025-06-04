//
//  StudyRoomsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI

struct StudyRoomsView: View {
    @State private var selectedFilter: StudyRoomsFilter = .all
    @State private var showCreateRoomSheet = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Study Rooms 📚")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        showCreateRoomSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.black)
                        
                    }
                }
                
            }
            .fontWidth(.expanded)
            .padding(.horizontal, 23)
            .padding(.top, 20)
        }
        
        
        // Segmented Control - Top tab bar
        HStack {
            StudyRoomsSegmentedControl(selectedFilter: $selectedFilter)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        
        ScrollView {
            VStack(spacing: 24) {
                switch selectedFilter {
                case .all:
                    
                    VStack {
                        HStack {
                            Text("Active Rooms")
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .font(.title3)
                                .padding(.leading, 5)
                        Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            
                        }
                    }
                case .inProgress:
                    VStack {
                        HStack {
                            Text("Active Rooms")
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .font(.title3)
                                .padding(.leading, 5)
                        Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            
                        }
                    }
                case .upcoming:
                    VStack {
                        HStack {
                            Text("Upcoming Rooms")
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .font(.title3)
                                .padding(.leading, 5)
                        Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            
                        }
                    }
                    
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    StudyRoomsView()
}
