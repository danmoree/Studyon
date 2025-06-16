//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  CustomTaskView.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI
import FirebaseAuth

struct CustomTaskView: View {
    @State private var completedState: Bool
    
    let taskId: String
    let title: String
    let dueDate: Date
    let priority: String
    let isCompleted: Bool
    
    @ObservedObject var viewModel: TasksViewModel

    init(taskId: String, title: String, dueDate: Date, isCompleted: Bool, priority: String, viewModel: TasksViewModel) {
        self.taskId = taskId
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self._completedState = State(initialValue: isCompleted)
        self.viewModel = viewModel
    }
    
    private var formattedDueDate: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: dueDate)

        if dueDay == today {
            return "Today"
        } else if dueDay == calendar.date(byAdding: .day, value: 1, to: today) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: dueDate)
        }
    }
    
    private var priorityColor: Color {
        switch priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .blue
        default: return .white
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                
                // Flag background
                RoundedRectangle(cornerRadius: 16)
                    .fill(completedState ? Color.gray.opacity(0.4) : (priority.lowercased() == "none" || priority.isEmpty ? Color.gray : priorityColor.opacity(0.3)))
                    .frame(width: completedState ? geometry.size.width : geometry.size.width - 16, height: 60)
                if !completedState {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray))
                            .frame(width: geometry.size.width - 45, height: 60)
                        Spacer(minLength: 0)
                    }
                }
             

              

                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Button {
                                
                                completedState.toggle()
                                Task {
                                    guard let userId = Auth.auth().currentUser?.uid else { return }
                                    
                                    do {
                                        try await TaskManager.shared.updateTaskCompletion(for: userId , taskId: taskId, isCompleted: completedState)
                                            viewModel.fetchTasks(for: userId)
                                    } catch {
                                        print("Error updating task completion:", error.localizedDescription)
                                    }
                                }
                                
                            } label: {
                                Image(systemName: completedState ? "checkmark.square" : "square")
                                    .foregroundColor(.white)
                            }

                            
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.white)
                        }

                        Text(formattedDueDate)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 26)
                    }
                    Spacer()

                    Image(systemName: "flag.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(completedState ? Color.white : priorityColor)
                        .padding(.trailing, 14)
                }
                .fontWidth(.expanded)
                .padding(.leading)
            }
            //.padding(.horizontal, 8)
        }
        .frame(height: 70)
    }
}



#Preview {
    CustomTaskView(taskId: "preview-task-id", title: "Finish ch3", dueDate: Date().addingTimeInterval(86400), isCompleted: true, priority: "low", viewModel: TasksViewModel())
}
