//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  NotificationsManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/23/25.
//

import Foundation
import UserNotifications

class NotificationsManager {
    static let shared = NotificationsManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications denied")
            }
        }
    }
    
    
    func schedulePomodoroNotification(duration: TimeInterval, sessionType: String) {
        let content = UNMutableNotificationContent()
        content.title = sessionType == "Break" ? "Break Over " : "Pomodoro Complete! ⏱️"
        content.body = sessionType == "Break" ? "Time to focus again" : "Rest your mind and eyes"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_done", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling failed: \(error)")
            }
        }
    }
    
    func cancelPomodoroNotification() {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro_done"])
        }
    
}
