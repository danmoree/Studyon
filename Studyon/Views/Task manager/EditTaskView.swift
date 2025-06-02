//
//  EditTaskView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/2/25.
//

import SwiftUI
import FirebaseAuth

struct EditTaskView: View {
    @State private var title: String
    @State private var dueDate: Date
    @State private var includeTime: Bool
    @State private var priority: String
    
    @State private var showPriorityOptions = false
    
    var task: UTask
    
    @Binding var isShowingEditSheet: Bool
    
    @ObservedObject var viewModel: TasksViewModel
    
    init(task: UTask, isShowingEditSheet: Binding<Bool>, viewModel: TasksViewModel) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _includeTime = State(initialValue: task.dueDate != nil)
        _priority = State(initialValue: task.priority ?? "None")
        self._isShowingEditSheet = isShowingEditSheet
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        
        VStack {
            VStack {
                // Title
                HStack {
                    Text("Edit Task 📆")
                        .font(.title)
                        .bold()
                        .fontWidth(.expanded)
                    Spacer()
                    
                    Button {
                        isShowingEditSheet = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                        
                    }
                    
                }
                
            }
            .padding(.horizontal, 23)
            .padding(.top, 20)
        }
        
        ScrollView {
            VStack {
                CustomTextField(text: $title, hint: "What would you like to do?", leadingIcon: Image(systemName: "list.clipboard.fill"), isPassword: false)
                
                
                
                HStack(spacing: 0) {
                    Image(systemName: "calendar")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(width: 40, alignment: .leading)
                    
                    DatePicker(
                        "",
                        selection: $dueDate,
                        displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                    )
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.1))
                }
                
                Toggle("Include Time", isOn: $includeTime)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                
                HStack {
                    Button {
                        showPriorityOptions.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "flag.fill")
                            Text("Set Priority")
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    
                    Spacer()
                }
                if showPriorityOptions {
                    HStack(spacing: 10) {
                        ForEach(["None", "Low", "Medium", "High"], id: \.self) { level in
                            Text(level)
                                .font(.subheadline)
                                .fontWeight(priority == level ? .bold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    priority == level
                                    ? (
                                        level == "Low" ? Color.blue :
                                            level == "Medium" ? Color.orange :
                                            level == "High" ? Color.red :
                                            Color.gray
                                    )
                                    : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(priority == level ? .white : .black)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    priority = level
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                }
                
                Button {
                    Task {
                        guard let userId = Auth.auth().currentUser?.uid else { return }
                        
                        let updatedTask = UTask(taskId: task.taskId, title: title, createdAt: task.createdAt ?? Date(), dueDate: dueDate, completed: task.completed ?? false, priority: priority)
                        
                        do {
                            try await TaskManager.shared.updateTask(for: userId, task: updatedTask)
                            await viewModel.fetchTasks(for: userId)
                            isShowingEditSheet = false // dismiss sheet
                        } catch {
                            print("Failed to update task:", error.localizedDescription)
                        }
                        
                    }
                } label: {
                    Text("Update")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background {
                            Capsule().fill(.black)
                        }
                }
                
            }
            
            .padding()
        }
    }
}

#Preview {
    EditTaskView(
        task: UTask(taskId: "sampleId", title: "Sample Task", createdAt: Date(), dueDate: Date(), completed: false, priority: "Medium"),
        isShowingEditSheet: .constant(true),
        viewModel: TasksViewModel()
    )
}

