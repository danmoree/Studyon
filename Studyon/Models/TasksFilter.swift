//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  HomeFilter.swift
//  Studyon
//
//  Created by Daniel Moreno on 3/28/25.
//

import Foundation

enum TasksFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case upcoming = "Upcoming"
    case overDue = "Overdue"
    case completed = "Completed"
}
