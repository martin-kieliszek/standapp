//
//  TimelineModels.swift
//  StandFitCore
//
//  Timeline event tracking and analysis models
//

import Foundation

// MARK: - Timeline Event Types

/// Represents a point-in-time event on the timeline (notification or exercise)
public struct TimelineEvent: Identifiable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let type: TimelineEventType

    public init(id: UUID = UUID(), timestamp: Date, type: TimelineEventType) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
    }

    /// Time of day in minutes since midnight (0-1439)
    public var minuteOfDay: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: timestamp)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    /// Hour component for grouping (0-23)
    public var hourOfDay: Int {
        Calendar.current.component(.hour, from: timestamp)
    }
}

public enum TimelineEventType: Hashable {
    case notificationFired
    case exerciseLogged(item: ExerciseItem, count: Int)

    public var displayName: String {
        switch self {
        case .notificationFired:
            return "Notification"
        case .exerciseLogged(let item, let count):
            return "\(item.name) (\(count))"
        }
    }

    public var icon: String {
        switch self {
        case .notificationFired:
            return "bell.fill"
        case .exerciseLogged(let item, _):
            return item.icon
        }
    }
}

// MARK: - Timeline Analysis

/// Analyzes the relationship between notifications and exercise logs
public struct TimelineAnalysis {
    public let notifications: [TimelineEvent]
    public let exercises: [TimelineEvent]

    public init(notifications: [TimelineEvent], exercises: [TimelineEvent]) {
        self.notifications = notifications
        self.exercises = exercises
    }

    /// Find exercise logs that occurred within specified minutes after a notification
    public func exercisesResponding(to notification: TimelineEvent, withinMinutes: Int = 5) -> [TimelineEvent] {
        guard case .notificationFired = notification.type else { return [] }

        let cutoffTime = notification.timestamp.addingTimeInterval(TimeInterval(withinMinutes * 60))

        return exercises.filter { exercise in
            exercise.timestamp >= notification.timestamp &&
            exercise.timestamp <= cutoffTime
        }
    }

    /// Calculate average response time (notification → first exercise) in minutes
    public var averageResponseTimeMinutes: Double? {
        let responseTimes = notifications.compactMap { notification -> Double? in
            let responding = exercisesResponding(to: notification)
            guard let firstExercise = responding.first else { return nil }
            return firstExercise.timestamp.timeIntervalSince(notification.timestamp) / 60.0
        }

        guard !responseTimes.isEmpty else { return nil }
        return responseTimes.reduce(0, +) / Double(responseTimes.count)
    }

    /// Percentage of notifications that resulted in exercise logs within 5 minutes
    public var responseRate: Double {
        guard !notifications.isEmpty else { return 0 }

        let respondedCount = notifications.filter { notification in
            !exercisesResponding(to: notification).isEmpty
        }.count

        return Double(respondedCount) / Double(notifications.count)
    }

    /// Find notifications that were not responded to within specified minutes
    public func missedNotifications(withinMinutes: Int = 5) -> [TimelineEvent] {
        notifications.filter { notification in
            exercisesResponding(to: notification, withinMinutes: withinMinutes).isEmpty
        }
    }
}
