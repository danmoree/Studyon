//
//  InputValidator.swift
//  Studyon
//
//  Created by Daniel Moreno on 2026
//  © 2025 Daniel Moreno. All rights reserved.
//

import Foundation

enum InputValidator {

    // MARK: - Character limits
    static let usernameMin   = 3
    static let usernameMax   = 20
    static let fullNameMax   = 50
    static let taskTitleMax  = 100
    static let roomTitleMax  = 60
    static let passwordMin   = 8

    // MARK: - Username
    // Allowed: lowercase a-z, 0-9, underscore. No spaces, no leading/trailing underscore.
    static let usernameRegex = #"^[a-z0-9][a-z0-9_]{1,18}[a-z0-9]$|^[a-z0-9]{1,3}$"#

    /// Sanitises username on every keystroke: lowercase, strip invalid chars, cap length.
    static func sanitiseUsername(_ raw: String) -> String {
        let lowered  = raw.lowercased()
        let filtered = lowered.filter { $0.isLetter || $0.isNumber || $0 == "_" }
        return String(filtered.prefix(usernameMax))
    }

    /// Returns a user-facing error string, or nil when the username is valid.
    static func validateUsername(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty                     { return "Username cannot be empty." }
        if trimmed.count < usernameMin         { return "Username must be at least \(usernameMin) characters." }
        if trimmed.count > usernameMax         { return "Username must be \(usernameMax) characters or fewer." }
        if trimmed.hasPrefix("_")              { return "Username cannot start with an underscore." }
        if trimmed.hasSuffix("_")              { return "Username cannot end with an underscore." }
        if trimmed.contains("__")              { return "Username cannot contain consecutive underscores." }
        let allowed = CharacterSet.lowercaseLetters.union(.decimalDigits).union(CharacterSet(charactersIn: "_"))
        if trimmed.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return "Username can only contain lowercase letters, numbers, and underscores."
        }
        return nil
    }

    // MARK: - Full Name
    /// Sanitises full name on every keystroke: strip leading spaces, cap length.
    static func sanitiseFullName(_ raw: String) -> String {
        // Allow letters (any language), spaces, hyphens, apostrophes
        let filtered = raw.filter { $0.isLetter || $0.isWhitespace || $0 == "-" || $0 == "'" }
        return String(filtered.prefix(fullNameMax))
    }

    /// Returns a user-facing error string, or nil when valid.
    static func validateFullName(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty          { return "Name cannot be empty." }
        if trimmed.count < 2        { return "Name must be at least 2 characters." }
        if trimmed.count > fullNameMax { return "Name must be \(fullNameMax) characters or fewer." }
        if !trimmed.contains(where: { $0.isLetter }) {
            return "Name must contain at least one letter."
        }
        return nil
    }

    // MARK: - Email
    static func validateEmail(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Email cannot be empty." }
        // Basic sanity check — Firebase validates the full format server-side
        let parts = trimmed.split(separator: "@")
        if parts.count != 2 || (parts.last?.contains(".") == false) {
            return "Please enter a valid email address."
        }
        return nil
    }

    // MARK: - Password
    static func validatePassword(_ value: String) -> String? {
        if value.isEmpty          { return "Password cannot be empty." }
        if value.count < passwordMin { return "Password must be at least \(passwordMin) characters." }
        return nil
    }

    // MARK: - Task title
    static func sanitiseTitle(_ raw: String, maxLength: Int = taskTitleMax) -> String {
        // Strip control characters
        let filtered = raw.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
        let clean = String(String.UnicodeScalarView(filtered))
        return String(clean.prefix(maxLength))
    }

    static func validateTaskTitle(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty          { return "Task title cannot be empty." }
        if trimmed.count > taskTitleMax { return "Task title must be \(taskTitleMax) characters or fewer." }
        return nil
    }

    // MARK: - Room title
    static func validateRoomTitle(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty           { return "Room title cannot be empty." }
        if trimmed.count > roomTitleMax { return "Room title must be \(roomTitleMax) characters or fewer." }
        return nil
    }
}
