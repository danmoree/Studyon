//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  HomeAll.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/30/25.
//

import SwiftUI
import FirebaseAuth


struct HomeWidgetsViews: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TodayTasks: View {
    @EnvironmentObject var tasksVM: TasksViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    @State var showingAddTaskSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let todayTasks = tasksVM.sortedTasksByDueDate().filter {
                if let dueDate = $0.dueDate {
                    return Calendar.current.isDateInToday(dueDate) && ($0.completed ?? false) == false
                }
                return false
            }
            
            HStack {
                Text("Today")
                    .fontWidth(.expanded)
                    .foregroundColor(.black)
                Text(String(todayTasks.count))
                    .fontWidth(.expanded)
                    .fontWeight(.thin)
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.8))
                
                Spacer()
                
                Button {
                    print("Add task")
                    showingAddTaskSheet = true
                    
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 5)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(todayTasks) { task in
                    Button(action: {
                        // mark as complete
                        Task {
                            guard let userId = Auth.auth().currentUser?.uid else { return }
                            let newCompletedValue = !(task.completed ?? false)
                            do {
                                try await TaskManager.shared.updateTaskCompletion(for: userId , taskId: task.taskId, isCompleted: newCompletedValue)
                                tasksVM.fetchTasks(for: userId)
                            } catch {
                                print("Error updating task completion:", error.localizedDescription)
                            }
                        }
                        
                    }) {
                        Label(
                            task.title ?? "NULL",
                            systemImage: task.completed ?? false ? "checkmark.square.fill" : "square"
                        )
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                }
            }
            .font(.caption)
            .fontWidth(.expanded)
            .fontWeight(.light)
        }
        .task {
            print("task in widget")
            if let userId = userVM.user?.userId {
                 tasksVM.fetchTasks(for: userId)
            }
        }
        .onChange(of: userVM.user?.userId) { newUserId in
            if let userId = newUserId {
                tasksVM.fetchTasks(for: userId)
            }
        }
        .padding(.top, 4)
        .padding(.trailing, 4)
        .padding()
        .frame(width: 170, height: 170, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        //.shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 10)
        .sheet(isPresented: $showingAddTaskSheet, onDismiss: {
            Task {
                if let userId = userVM.user?.userId {
                    tasksVM.fetchTasks(for: userId)
                }
            }
           
        }) {
            TaskAddView(showingAddTaskSheet: $showingAddTaskSheet, viewModel: tasksVM)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
        }
        
    }
       
}

struct TimeSpentCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time Spent")
                    .fontWidth(.expanded)
                    .foregroundColor(.white)
                
                Spacer()
                
            }
            
            HStack {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 8, height: 60)
                            Capsule()
                                .fill(Color(red: 105/255, green: 169/255, blue: 98/255))
                                .frame(width: 8, height: CGFloat.random(in: 20...60))
                        }
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)
            .padding(.top)
            .padding(.trailing)
        }
        .padding(.top, -30)
        .padding(.trailing, -12)
        .padding()
        .frame(width: 170, height: 170)
        .background(Color(.systemGray))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ActiveRoomsPreviewView: View {
    var body: some View {
        
        VStack(alignment: .leading) {

            VStack {
                HStack {
                    Text("Brady’s Study Room")
                        .foregroundColor(.white)
                        .fontWidth(.expanded)
                        .fontWeight(.medium)
                    
                    Spacer()
                 
                }
                
                HStack {
                    HStack(spacing: -12) {
                        ForEach(0..<3) { index in
                            Image("profile_pic\(index + 1)")// Replace with actual image names or URLs
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            
                            
                        }
                        
                        
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            Text("+4")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                        }
                        
                        
                    }
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    
                    Spacer()
                    Button("Join") {
                        // join room logic
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .fontWidth(.expanded)
                    .fontWeight(.bold)
                }
    
                
               
                
                HStack {
                    VStack {
                        Text("Start")
                        Text("9:00")
                    }
                    .foregroundColor(.white)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("34 mins left")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 250, height: 10)
                            Capsule()
                                .frame(width: 200, height: 10)
                        }
                    }
                    Spacer()
                   
                    
                    VStack(alignment: .leading) {
                        Text("End")
                        Text("11:30")
                    }
                    .foregroundColor(.white)
                    
                }
                .font(.caption)
            }
            .padding()
            .background(Color(red: 105/255, green: 169/255, blue: 98/255)) // dark green
            .cornerRadius(16)
            
        }
        .fontWidth(.expanded)
    }
}

struct StudiedTimeTodayView: View {
    let studiedTimeToday: TimeInterval
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time Studied")
                    .fontWidth(.expanded)
                    .foregroundColor(.black)
                
                Spacer()
            }
            Text("Today")
                .foregroundColor(.black)
            Text("\(studiedTimeToday / 60, specifier: "%.0f") Minutes")
                .foregroundColor(.black)
                .font(.title)
            
            
        }
        .padding(.top, -30)
        .padding(.trailing, -12)
        .padding()
        .frame(width: 170, height: 170)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 10)
    }
}

struct QuickStartStudyRoomView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Quick Study ⏳")
                        .fontWidth(.expanded)
                        .foregroundColor(.black)
                    Spacer()
                }
                
                // blocks
                HStack {
                    
                    // block 1
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text("⚡️")
                        }
                        
                        
                        HStack {
                            Text("Focus\nSprint")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWidth(.expanded)
                                .fontWeight(.light)
                        }
                        
                        
                        
                        HStack {
                            Text("15m")
                                .font(.title)
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 10)
                    
                    Spacer()
                    
                    // block 2
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text("🎯")
                        }
                        
                        
                        HStack {
                            Text("Deep\nWork")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWidth(.expanded)
                                .fontWeight(.light)
                        }
                        
                        
                        
                        HStack {
                            Text("25m")
                                .font(.title)
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 10)
                    
                    Spacer()
                    
                    // block 3
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text("🧠")
                        }
                        
                        
                        HStack {
                            Text("Power\nBlock")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWidth(.expanded)
                                .fontWeight(.light)
                        }
                        
                        
                        
                        HStack {
                            Text("50m")
                                .font(.title)
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 10)
                    
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                
            }
            //.padding(.top, -30)
            .padding()
            .frame(width: geometry.size.width, height: 170)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 10)
        }
    }
}

#Preview {
    //TodayTasks()
    //    .environmentObject(TasksViewModel())
    //    .environmentObject(ProfileViewModel())
    //TimeSpentCard()
    //ActiveRoomsPreviewView()
    StudiedTimeTodayView(studiedTimeToday: 123)
    QuickStartStudyRoomView()
    
}

