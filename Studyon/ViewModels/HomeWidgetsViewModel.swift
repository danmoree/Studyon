//
//  HomeWidgetsViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/13/25.
//

import Foundation
@MainActor
final class HomeWidgetsViewModel: ObservableObject {
    @Published var xp: Int = 0
    @Published var dayStreak : Int = 0
    @Published var secondsStudiedToday: TimeInterval = 0
    
    private let statsManager = UserStatsManager.shared
      private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
      }()
    
    func loadAllStats(for userId: String) async {
        do {
          let stats = try await statsManager.fetchStats(userId: userId)
          // core counters
          xp = stats.xp ?? 0
          dayStreak = stats.dayStreak ?? 0

          // today’s time
          // let key = isoFormatter.string(from: Date())
          // secondsStudiedToday = stats.timeStudiedByDate?[key] ?? 0
         
            print("Fetched map:", stats.timeStudiedByDate as Any)
            //print("Looking up:", key)
            print("xp:", xp)
          // … pull any other fields …
        } catch {
          print("Failed loading home stats:", error)
          // leave defaults or show an error state
        }
      }
    
}
