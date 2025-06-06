//
//  Task.swift
//  Studyon
//
//  Created by Daniel Moreno on 5/29/25.
//

import Foundation

struct UserTask: Codable, Identifiable {
    var id: String { UUID().uuidString }
    var title: String
    var isCompleted: Bool = false
    var dueData: Date
    var description: String
    var priority: Int
}
