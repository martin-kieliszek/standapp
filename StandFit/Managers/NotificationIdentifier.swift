//
//  NotificationIdentifier.swift
//  StandFit iOS
//
//  Centralized identifier management for all notification types.
//  Ensures unique identifiers for batch scheduling and proper slot allocation.
//

import Foundation

/// Centralized identifier management for all notification types
enum NotificationIdentifier {

    // MARK: - Prefixes & Constants

    /// Prefix for exercise reminder notifications (batch scheduled)
    static let exercisePrefix = "exercise_"

    /// Prefix for snooze reminder notifications
    static let snoozePrefix = "snooze_"

    /// Single identifier for dead response (only one at a time)
    static let deadResponse = "dead_response"

    /// Single identifier for progress report (repeating)
    static let progressReport = "progress_report"

    /// Prefix for achievement notifications
    static let achievementPrefix = "achievement_"

    // MARK: - Slot Allocation Constants

    /// Maximum exercise reminders to schedule (reserves slots for other types)
    /// Total iOS limit: 64
    /// Reserved: 1 snooze + 1 dead response + 1 progress report + 3 achievements = 6
    /// Available for exercise: 58
    static let maxExerciseReminders = 58

    /// Refill queue when exercise reminder count drops below this threshold
    static let refillThreshold = 30

    /// Maximum days to schedule ahead
    static let maxDaysAhead = 7

    // MARK: - Date Formatter

    /// Thread-safe date formatter for identifier generation
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Identifier Generators

    /// Generate unique identifier for an exercise reminder at a specific time
    /// Format: "exercise_YYYYMMDD_HHMM"
    static func exerciseReminder(for date: Date) -> String {
        return "\(exercisePrefix)\(dateFormatter.string(from: date))"
    }

    /// Generate unique identifier for a snooze reminder at a specific time
    /// Format: "snooze_YYYYMMDD_HHMM"
    static func snoozeReminder(for date: Date) -> String {
        return "\(snoozePrefix)\(dateFormatter.string(from: date))"
    }

    /// Generate identifier for an achievement notification
    /// Format: "achievement_<achievementId>"
    static func achievement(id: String) -> String {
        return "\(achievementPrefix)\(id)"
    }

    // MARK: - Identifier Type Checks

    /// Check if identifier is for an exercise reminder
    static func isExerciseReminder(_ identifier: String) -> Bool {
        return identifier.hasPrefix(exercisePrefix)
    }

    /// Check if identifier is for a snooze reminder
    static func isSnoozeReminder(_ identifier: String) -> Bool {
        return identifier.hasPrefix(snoozePrefix)
    }

    /// Check if identifier is for an achievement notification
    static func isAchievement(_ identifier: String) -> Bool {
        return identifier.hasPrefix(achievementPrefix)
    }

    /// Check if identifier is for dead response
    static func isDeadResponse(_ identifier: String) -> Bool {
        return identifier == deadResponse
    }

    /// Check if identifier is for progress report
    static func isProgressReport(_ identifier: String) -> Bool {
        return identifier == progressReport
    }

    /// Check if identifier is for any exercise-related notification (exercise, snooze, or dead response)
    static func isExerciseRelated(_ identifier: String) -> Bool {
        return isExerciseReminder(identifier) ||
               isSnoozeReminder(identifier) ||
               isDeadResponse(identifier)
    }

    // MARK: - Date Extraction

    /// Extract the scheduled date from an identifier (works for exercise and snooze)
    /// Returns nil if identifier format doesn't contain a parseable date
    static func date(from identifier: String) -> Date? {
        let prefixes = [exercisePrefix, snoozePrefix]
        for prefix in prefixes {
            if identifier.hasPrefix(prefix) {
                let dateString = String(identifier.dropFirst(prefix.count))
                return dateFormatter.date(from: dateString)
            }
        }
        return nil
    }

    // MARK: - Debug Helpers

    /// Get a human-readable description of an identifier
    static func description(for identifier: String) -> String {
        if isExerciseReminder(identifier) {
            if let date = date(from: identifier) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, h:mm a"
                return "Exercise reminder at \(displayFormatter.string(from: date))"
            }
            return "Exercise reminder (unknown time)"
        } else if isSnoozeReminder(identifier) {
            if let date = date(from: identifier) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                return "Snooze reminder at \(displayFormatter.string(from: date))"
            }
            return "Snooze reminder (unknown time)"
        } else if isDeadResponse(identifier) {
            return "Dead response follow-up"
        } else if isProgressReport(identifier) {
            return "Progress report"
        } else if isAchievement(identifier) {
            let achievementId = String(identifier.dropFirst(achievementPrefix.count))
            return "Achievement: \(achievementId)"
        }
        return "Unknown notification: \(identifier)"
    }
}
