//
//  CustomTaskView.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/27/25.
//

import SwiftUI

struct CustomTaskView: View {
    @State private var completedState: Bool
    
    let title: String
    let dueDate: Date
    let priority: String
    let isCompleted: Bool

    init(title: String, dueDate: Date, isCompleted: Bool, priority: String) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self._completedState = State(initialValue: isCompleted)
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
                    .fill(priority.lowercased() == "none" || priority.isEmpty ? Color.gray : priorityColor.opacity(0.3))
                    .frame(width: geometry.size.width - 16, height: 60)
                    
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray))
                        .frame(width: geometry.size.width - 45, height: 60)
                    Spacer(minLength: 0)
                }

              

                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Button {
                                
                                completedState.toggle()
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
                        .foregroundColor(priorityColor)
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
    CustomTaskView(title: "Finish ch3", dueDate: Date().addingTimeInterval(86400), isCompleted: false, priority: "")
}
