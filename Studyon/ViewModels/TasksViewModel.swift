//
//  TasksViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/29/25.
//

import Foundation
import FirebaseFirestore

final class TasksViewModel: ObservableObject {
    @Published var tasks: [UTask] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchTasks(for userId: String) {
        isLoading = true
        Task {
            do {
                let fetchedTasks = try await TaskManager.shared.fetchTasks(for: userId)
                await MainActor.run {
                    self.tasks = fetchedTasks
                    self.errorMessage = nil
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.tasks = []
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
