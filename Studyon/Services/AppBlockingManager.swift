//
//  Created by Daniel Moreno on 2026
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  AppBlockingManager.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/21/26.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

final class AppBlockingManager: ObservableObject {
    static let shared = AppBlockingManager()

    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore() // Active blocking store
    private let configStore = ManagedSettingsStore(named: ManagedSettingsStore.Name("StudyonAppBlockingConfig")) // Persistent config store for exceptions

    @Published var isAuthorized = false
    @Published var isBlocking = false
    @Published var isEnabled = true // Master toggle for app blocking feature

    // UserDefaults keys
    private let isEnabledKey = "appBlockingEnabled"
    private let hasConfiguredKey = "appBlockingHasConfigured"

    private init() {
        // Check initial authorization status
        switch center.authorizationStatus {
        case .approved:
            isAuthorized = true
        default:
            isAuthorized = false
        }

        // Load enabled state from UserDefaults (default: true)
        isEnabled = UserDefaults.standard.object(forKey: isEnabledKey) as? Bool ?? true

        // CRITICAL: Ensure no shields are active on app launch
        // Clear the active store to ensure apps aren't blocked outside of study sessions
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    /// Toggle app blocking feature on/off
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: isEnabledKey)

        // If disabling, immediately stop any active blocking
        if !enabled && isBlocking {
            stopBlocking()
        }

        print("AppBlocking: Feature \(enabled ? "enabled" : "disabled")")
    }

    /// Clear all app blocking data and reset
    func clearAll() {
        // Stop any active blocking
        stopBlocking()

        // Clear persisted exceptions config
        configStore.shield.applications = nil
        configStore.shield.applicationCategories = nil
        configStore.shield.webDomains = nil

        // Clear configuration flag
        UserDefaults.standard.set(false, forKey: hasConfiguredKey)

        // Reset enabled state
        isEnabled = true
        UserDefaults.standard.set(true, forKey: isEnabledKey)

        print("AppBlocking: Cleared all data")
    }

    /// Request authorization to use Family Controls
    func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
        await MainActor.run {
            isAuthorized = center.authorizationStatus == .approved
        }
    }

    /// Save selected apps as EXCEPTIONS (apps that should NOT be blocked)
    /// These are stored persistently and will survive app restarts
    func saveExceptionApps(_ selection: FamilyActivitySelection) {
        // Save exceptions to config store - these apps will NOT be blocked
        configStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        configStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        configStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        // Mark that user has configured the feature
        UserDefaults.standard.set(true, forKey: hasConfiguredKey)

        print("AppBlocking: Saved exception apps to persistent config")
    }

    /// Check if user has configured exceptions
    func hasConfigured() -> Bool {
        return UserDefaults.standard.bool(forKey: hasConfiguredKey)
    }

    /// Start blocking apps (called when study session starts)
    /// Blocks ALL apps EXCEPT the ones saved as exceptions
    func startBlocking() {
        guard isEnabled else {
            print("AppBlocking: Feature is disabled")
            return
        }

        guard isAuthorized else {
            print("AppBlocking: Not authorized")
            return
        }

        // The Flow app approach: Block all app categories, then specific app tokens become exceptions
        // When you set applicationCategories to .all(), it blocks all apps
        // When you then set specific application tokens, those become EXCEPTIONS to the category rule

        // Step 1: Block all app categories
        if let exceptionApps = configStore.shield.applications, !exceptionApps.isEmpty {
            // If we have exception apps, use .all() to block everything except the specific apps
            store.shield.applicationCategories = .all()
            // Step 2: Set specific apps as exceptions (these will NOT be blocked)
            store.shield.applications = exceptionApps
        } else {
            // No exceptions configured - block everything
            store.shield.applicationCategories = .all()
            store.shield.applications = nil
        }

        // Block all web domains
        store.shield.webDomains = nil

        isBlocking = true
        let exceptionCount = configStore.shield.applications?.count ?? 0
        print("AppBlocking: Started blocking all apps with \(exceptionCount) exceptions")
    }

    /// Stop blocking apps (called when study session ends)
    func stopBlocking() {
        // Clear the active store - this unblocks everything
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        isBlocking = false
        print("AppBlocking: Stopped blocking apps")
    }

    /// Check if any exception apps are configured
    func hasAppsToBlock() -> Bool {
        return hasConfigured()
    }
}
