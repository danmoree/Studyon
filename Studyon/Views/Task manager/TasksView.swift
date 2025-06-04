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
    @State private var showingAddTaskSheet = false
    @State private var selectedTask: UTask? = nil
    @State private var isShowingEditSheet = false
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var userVM: ProfileViewModel
    @StateObject private var tasksVM = TasksViewModel()

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
                        showingAddTaskSheet = true
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
                                    Text("\(tasksVM.tasks.count) Tasks")
                                        .fontWeight(.bold)
                                        .fontWidth(.expanded)
                                        .font(.title3)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                                
                                
                                
                                VStack (spacing: 0){
                                   
                                    //                                    CustomTaskView(title: "Finish ch3 hw", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "none")
                                    
                                    ForEach(tasksVM.sortedTasksByDueDate().reversed()) { task in
                                        if let title = task.title {
                                            CustomTaskView(
                                                taskId: task.taskId,
                                                title: title,
                                                dueDate: task.dueDate ?? Date(),
                                                isCompleted: task.completed ?? false,
                                                priority: task.priority ?? "none",
                                                viewModel: tasksVM
                                            )
                                            .onTapGesture {
                                                selectedTask = task
                                                isShowingEditSheet = true
                                            }
                                        }
                                    }
                                }
                               
                                    
                            }
    
                    case .today:
                        VStack {
                            let todayTasks = tasksVM.sortedTasksByDueDate().filter {
                                if let dueDate = $0.dueDate {
                                    return Calendar.current.isDateInToday(dueDate) && ($0.completed ?? false) == false
                                }
                                return false
                            }
                            HStack {
                                Text("\(todayTasks.count) Tasks")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.title3)
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            
                            
                            
                            VStack (spacing: 0){
                               
                                //                                    CustomTaskView(title: "Finish ch3 hw", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "none")
                                
                                ForEach(todayTasks) { task in
                                    if let title = task.title {
                                        CustomTaskView(
                                            taskId: task.taskId,
                                            title: title,
                                            dueDate: task.dueDate ?? Date(),
                                            isCompleted: task.completed ?? false,
                                            priority: task.priority ?? "none",
                                            viewModel: tasksVM
                                        )
                                        .onTapGesture {
                                            selectedTask = task
                                            isShowingEditSheet = true
                                        }
                                    }
                                }
                            }
                           
                                
                        }
                        
                    case .upcoming:
                        VStack {
                            let upcomingTasks = tasksVM.sortedTasksByDueDate().filter {
                                if let dueDate = $0.dueDate {
                                    return dueDate > Date() && !Calendar.current.isDateInToday(dueDate) && ($0.completed ?? false) == false
                                }
                                return false
                            }
                            HStack {
                                Text("\(upcomingTasks.count) Tasks")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.title3)
                                    .padding(.leading, 5)
                                Spacer()
                            }

                            VStack (spacing: 0){
                                ForEach(upcomingTasks) { task in
                                    if let title = task.title {
                                        CustomTaskView(
                                            taskId: task.taskId,
                                            title: title,
                                            dueDate: task.dueDate ?? Date(),
                                            isCompleted: task.completed ?? false,
                                            priority: task.priority ?? "none",
                                            viewModel: tasksVM
                                        )
                                        .onTapGesture {
                                            selectedTask = task
                                            isShowingEditSheet = true
                                        }
                                    }
                                }
                            }
                        }
                        
                    case .overDue:
                        VStack {
                            let overdueTasks = tasksVM.sortedTasksByDueDate().filter {
                                if let dueDate = $0.dueDate {
                                    return dueDate < Date() && !Calendar.current.isDateInToday(dueDate) && ($0.completed ?? false) == false
                                        
                                }
                                return false
                            }
                            HStack {
                                Text("\(overdueTasks.count) Tasks")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.title3)
                                    .padding(.leading, 5)
                                Spacer()
                            }

                            VStack (spacing: 0){
                                ForEach(overdueTasks) { task in
                                    if let title = task.title {
                                        CustomTaskView(
                                            taskId: task.taskId,
                                            title: title,
                                            dueDate: task.dueDate ?? Date(),
                                            isCompleted: task.completed ?? false,
                                            priority: task.priority ?? "none",
                                            viewModel: tasksVM
                                        )
                                        .onTapGesture {
                                            selectedTask = task
                                            isShowingEditSheet = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                    case .completed:
                        VStack {
                            let completedTasks = tasksVM.sortedTasksByDueDate().filter {
                                if let completed = $0.completed {
                                    return completed
                                }
                                return false
                            }
                            HStack {
                                Text("\(completedTasks.count) Tasks")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.title3)
                                    .padding(.leading, 5)
                                Spacer()
                            }

                            VStack (spacing: 0){
                                ForEach(completedTasks) { task in
                                    if let title = task.title {
                                        CustomTaskView(
                                            taskId: task.taskId,
                                            title: title,
                                            dueDate: task.dueDate ?? Date(),
                                            isCompleted: task.completed ?? false,
                                            priority: task.priority ?? "none",
                                            viewModel: tasksVM
                                        )
                                        .onTapGesture {
                                            selectedTask = task
                                            isShowingEditSheet = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
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
        .task {
            if let userId = userVM.user?.userId {
                 tasksVM.fetchTasks(for: userId)
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            if let task = selectedTask {
                EditTaskView(task: task, isShowingEditSheet: $isShowingEditSheet, viewModel: tasksVM)
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: tasksVM.tasks) { _ in
            print("Tasks updated — UI will reflect changes")
        }
        
    }
}

#Preview {
    TasksView(isUserLoggedIn: .constant(true))
        .environmentObject(ProfileViewModel())
}
