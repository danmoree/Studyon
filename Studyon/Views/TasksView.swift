//
//  TasksView.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI

struct TasksView: View {
    @State private var selectedFilter: TasksFilter = .all
    @State private var showingSettings = false
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var userVM: ProfileViewModel

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Tasks 🗓️")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        
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

            // Segmented Control - Top tab bar
            HStack {
                TasksSegmentedControl(selectedFilter: $selectedFilter)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Scrollable content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedFilter {
                    case .all:
                        
                            VStack {
                                HStack {
                                    Text("4 Tasks")
                                        .fontWeight(.bold)
                                        .fontWidth(.expanded)
                                        .font(.title3)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                                
                                
                                
                                VStack (spacing: 0){
                                    CustomTaskView(title: "Finish ch3", dueDate: Date().addingTimeInterval(0), isCompleted: false, priority: "High")
                                    
                                    CustomTaskView(title: "Finish ch6 quiz insect", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "medium")
                                    
                                    CustomTaskView(title: "Quiz 3 - ML", dueDate: Date().addingTimeInterval(250400), isCompleted: false, priority: "low")
                                    
                                    CustomTaskView(title: "Exam 2 - Geo", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "")
                                    
                                    CustomTaskView(title: "Finish ch3 hw", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "none")
                                }
                                
                               
                                    
                            }
    
                    case .today:
                        Text("Today")
                    case .upcoming:
                        Text("Upcoming")
                    case .completed:
                        Text("Completed")
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    TasksView(isUserLoggedIn: .constant(true))
        .environmentObject(ProfileViewModel())
}
