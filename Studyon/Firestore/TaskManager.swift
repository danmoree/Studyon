//
//  TaskManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/29/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct UTask: Codable {
    let taskId: String
    let title: String?
    let description: String?
    let createdAt: Date?
    let dueDate: Date?
    let completed: Bool?
    let priority: String
    let tag: String?
    
    
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
        self.taskId = try container.decode(String.self, forKey: .taskId)
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

    private func tasksCollection(for userId: String) -> CollectionReference {
        userCollection.document(userId).collection("tasks")
    }
    
    private func taskDocument(userId: String, taskId: String) -> DocumentReference {
        tasksCollection(for: userId).document(taskId)
    }
    
    
    
    
    

    func addTask(for userId: String, task: UTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(task)
            taskDocument(userId: userId, taskId: task.taskId).setData(data, completion: completion)
        } catch {
            completion(error)
        }
    }

    
    
    func updateTask(for userId: String, task: UTask, completion: @escaping (Error?) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(task)
            taskDocument(userId: userId, taskId: task.taskId).updateData(data, completion: completion)
        } catch {
            completion(error)
        }
    }

    
    func deleteTask(for userId: String, taskId: String, completion: @escaping (Error?) -> Void) {
        taskDocument(userId: userId, taskId: taskId).delete(completion: completion)
    }
    
    func fetchTasks(for userId: String, completion: @escaping ([UTask]?, Error?) -> Void) {
        tasksCollection(for: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }
            
            let tasks: [UTask] = documents.compactMap { doc in
                try? doc.data(as: UTask.self)
            }
            
            completion(tasks,nil)
        
        }
    }
    
    
}
