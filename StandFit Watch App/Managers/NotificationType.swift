//
//  NotificationType.swift
//  StandFit Watch App
//
//  Platform-specific notification type definitions
//

import Foundation

/// Types of notifications used in the app
enum NotificationType: String {
    case exerciseReminder = "exercise_reminder"
    case deadResponseReminder = "dead_response_reminder"
    case progressReport = "progress_report"
    case achievementUnlocked = "achievement_unlocked"

    /// Category identifier for notification actions
    var categoryIdentifier: String {
        switch self {
        case .exerciseReminder:
            return "EXERCISE_REMINDER_CATEGORY"
        case .deadResponseReminder:
            return "DEAD_RESPONSE_CATEGORY"
        case .progressReport:
            return "PROGRESS_REPORT_CATEGORY"
        case .achievementUnlocked:
            return "ACHIEVEMENT_CATEGORY"
        }
    }
}
