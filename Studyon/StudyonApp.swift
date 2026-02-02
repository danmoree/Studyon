//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyonApp.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/13/25.
//

import SwiftUI
import FirebaseCore

@main
struct StudyonApp: App {
    // Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var settingsVM = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsVM)
                .preferredColorScheme(settingsVM.selectedTheme.colorScheme)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase!")
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // App moved to background - background task is already running if needed
        print("App entered background - background task active: \(BackgroundTaskManager.shared.isBackgroundTaskActive)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // App returning to foreground
        print("App entering foreground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Ensure app blocking is stopped when app terminates
        AppBlockingManager.shared.stopBlocking()
        // End any background tasks
        BackgroundTaskManager.shared.endBackgroundTask()
        print("App terminating - cleaned up app blocking and background tasks")
    }
}
