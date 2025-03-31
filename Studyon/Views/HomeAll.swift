//
//  HomeAll.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/30/25.
//

import SwiftUI


struct HomeAll: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TodayTasks: View {
    @State var tasks: [UserTask] = [
        UserTask(title: "Study linear", isCompleted: true, dueData: Date(), description: "", priority: 1),
        UserTask(title: "Finish bio hw", isCompleted: false, dueData: Date(), description: "", priority: 2),
        UserTask(title: "Read software ch 4", isCompleted: false, dueData: Date(), description: "", priority: 3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .fontWidth(.expanded)
                    .foregroundColor(.white)
                Text(String(tasks.count))
                    .fontWidth(.expanded)
                    .fontWeight(.thin)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button {
                    print("Add task")
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 5)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(tasks.indices, id: \.self) { index in
                    Button(action: {
                        tasks[index].isCompleted.toggle()
                    }) {
                        Label(
                            tasks[index].title,
                            systemImage: tasks[index].isCompleted ? "checkmark.square.fill" : "square"
                        )
                        .foregroundColor(.white)
                    }
                }
            }
            .font(.caption)
            .fontWidth(.expanded)
            .fontWeight(.light)
        }
        .padding(.top, -30)
        .padding(.trailing, -12)
        .padding()
        .frame(width: 170, height: 170)
        .background(Color(.systemGray))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
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
                                .fill(Color.green)
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
                        .bold()
                    Spacer()
                    Button("Join") {
                        // join room logic
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                HStack {
                    Text("Start 9:00")
                    Spacer()
                    Text("34 mins left")
                    Spacer()
                    Text("End 11:30")
                }
                .font(.caption)
            }
            .padding()
            .background(Color.green.opacity(0.2))
            .cornerRadius(16)
        }
    }
}

#Preview {
    TodayTasks()
    TimeSpentCard()
}
