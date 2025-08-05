//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  TaskManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/29/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct UTask: Identifiable, Codable, Equatable {
    var taskId: String
    let title: String?
    let description: String?
    let createdAt: Date?
    let dueDate: Date?
    let completed: Bool?
    let priority: String
    let tag: String?
    
    var id: String { taskId }
    
    
    init(
        taskId: String,
        title: String,
        description: String? = nil,
        createdAt: Date,
        dueDate: Date,
        completed: Bool,
        priority: String,
        tag: String? = nil
    ) {
        self.taskId = taskId
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.completed = completed
        self.priority = priority
        self.tag = tag
    }
    
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case title = "title"
        case description = "description"
        case createdAt = "created_at"
        case dueDate = "due_date"
        case completed = "completed"
        case priority = "priority"
        case tag = "tag"
    }
    
    // get from firestore
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.taskId = try container.decodeIfPresent(String.self, forKey: .taskId) ?? ""
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.priority = try container.decode(String.self, forKey: .priority)
        self.tag = try container.decodeIfPresent(String.self, forKey: .tag)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.taskId, forKey: .taskId)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
        try container.encodeIfPresent(self.dueDate, forKey: .dueDate)
        try container.encodeIfPresent(self.completed, forKey: .completed)
        try container.encodeIfPresent(self.priority, forKey: .priority)
        try container.encodeIfPresent(self.tag, forKey: .tag)
        
    }
}

final class TaskManager {
    
    static let shared = TaskManager()

    private let userCollection = Firestore.firestore().collection("users")
    // /users/{userId}/tasks
    private func tasksCollection(for userId: String) -> CollectionReference {
        userCollection.document(userId).collection("tasks")
    }
    
    // /users/{userId}/tasks/{taskId}
    private func taskDocument(userId: String, taskId: String) -> DocumentReference {
        tasksCollection(for: userId).document(taskId)
    }
    
    
    
    
    
    func addTask(for userId: String, task: UTask) async throws {
        let newDocRef = tasksCollection(for: userId).document()
        var data = try Firestore.Encoder().encode(task)
        data["task_id"] = newDocRef.documentID
        try await newDocRef.setData(data)
    }

    
    
    func updateTask(for userId: String, task: UTask) async throws {
        let data = try Firestore.Encoder().encode(task)
        try await taskDocument(userId: userId, taskId: task.taskId).updateData(data)
    }
    
    func updateTaskCompletion(for userId: String, taskId: String, isCompleted: Bool) async throws {
        try await taskDocument(userId: userId, taskId: taskId).updateData([
            "completed": isCompleted
        ])
    }
    

    
    func deleteTask(for userId: String, taskId: String) async throws {
        try await taskDocument(userId: userId, taskId: taskId).delete()
    }
    
    func fetchTasks(for userId: String) async throws -> [UTask] {
        let snapshot = try await tasksCollection(for: userId).getDocuments()
        
        var tasks: [UTask] = []
        
        for doc in snapshot.documents {
            if let task = try? doc.data(as: UTask.self) {
                tasks.append(task)
            }
        }
        return tasks
    }
    
  
    
}
