//
//  NotificationFiredLog.swift
//  StandFit Watch App
//
//  WatchOS-specific wrapper for tracking fired notifications
//

import Foundation
import Combine
import StandFitCore

/// Lightweight storage for tracking when notifications were actually fired today
/// This is ephemeral data - only keeps today's records
class NotificationFiredLog: ObservableObject {
    static let shared = NotificationFiredLog()

    @Published private(set) var todaysFiredNotifications: [Date] = []

    private init() {
        cleanupOldRecords()
    }

    /// Record that a notification was fired at a specific time
    func recordNotificationFired(at timestamp: Date = Date()) {
        todaysFiredNotifications.append(timestamp)
        cleanupOldRecords()
    }

    /// Remove records from previous days to keep storage minimal
    private func cleanupOldRecords() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        todaysFiredNotifications = todaysFiredNotifications.filter { timestamp in
            timestamp >= today
        }
    }

    /// Get all fired notifications as timeline events
    func getTimelineEvents() -> [TimelineEvent] {
        todaysFiredNotifications.map { timestamp in
            TimelineEvent(timestamp: timestamp, type: .notificationFired)
        }
    }

    /// Clear all records (useful for testing or privacy)
    func clearAll() {
        todaysFiredNotifications.removeAll()
    }
}
