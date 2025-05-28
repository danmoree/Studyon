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
    case completed = "Completed"
}
