//
//  Created by Daniel Moreno on 2026
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  BackgroundTaskManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/1/26.
//

import UIKit
import Foundation

/// Manages background tasks to keep the app alive during study sessions
final class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    @Published private(set) var isBackgroundTaskActive = false

    private init() {}

    /// Start a background task to keep the app alive during study sessions
    /// This tells iOS not to terminate the app while in the background
    func startBackgroundTask() {
        // Don't start a new task if one is already running
        guard backgroundTaskID == .invalid else {
            print("BackgroundTask: Already running")
            return
        }

        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "StudySessionBackgroundTask") { [weak self] in
            // This expiration handler is called if iOS needs to terminate the task
            // We should clean up and end the task properly
            print("BackgroundTask: Expiring, cleaning up")
            self?.endBackgroundTask()
        }

        if backgroundTaskID != .invalid {
            isBackgroundTaskActive = true
            print("BackgroundTask: Started (ID: \(backgroundTaskID.rawValue))")

            // Schedule a timer to periodically renew the background task
            // This helps keep the app alive for longer periods
            scheduleBackgroundTaskRenewal()
        } else {
            print("BackgroundTask: Failed to start")
        }
    }

    /// End the background task
    func endBackgroundTask() {
        guard backgroundTaskID != .invalid else {
            return
        }

        print("BackgroundTask: Ending (ID: \(backgroundTaskID.rawValue))")
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
        isBackgroundTaskActive = false
    }

    /// Schedule periodic renewal of the background task
    /// This helps extend the background execution time
    private func scheduleBackgroundTaskRenewal() {
        // Renew the task every 2 minutes to keep it alive
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) { [weak self] in
            guard let self = self, self.backgroundTaskID != .invalid else {
                return
            }

            // End the current task and immediately start a new one
            let oldTaskID = self.backgroundTaskID
            self.backgroundTaskID = .invalid

            // Start new background task
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "StudySessionBackgroundTask") { [weak self] in
                print("BackgroundTask: Expiring during renewal, cleaning up")
                self?.endBackgroundTask()
            }

            // End the old task
            UIApplication.shared.endBackgroundTask(oldTaskID)

            if self.backgroundTaskID != .invalid {
                print("BackgroundTask: Renewed (Old ID: \(oldTaskID.rawValue), New ID: \(self.backgroundTaskID.rawValue))")
                // Schedule next renewal
                self.scheduleBackgroundTaskRenewal()
            } else {
                print("BackgroundTask: Renewal failed")
                self.isBackgroundTaskActive = false
            }
        }
    }
}
