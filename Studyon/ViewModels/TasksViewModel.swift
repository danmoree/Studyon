//
//  TasksViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/29/25.
//

import Foundation
import FirebaseFirestore

final class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchTasks(for userId: String) {
        isLoading = true
        TaskManager.shared.fetchTasks(for: userId) { [weak self] fetchedTasks, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.tasks = []
                } else {
                    self?.errorMessage = nil
                    self?.tasks = fetchedTasks ?? []
                }
            }
        }
    }
}
