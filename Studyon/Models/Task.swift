//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
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
