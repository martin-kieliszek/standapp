//
//  TimelineService.swift
//  StandFitCore
//
//  Service for timeline data generation and analysis
//

import Foundation

/// Service for generating timeline data and analysis
public struct TimelineService {
    public init() {}

    /// Get timeline events for a specific date (notifications + exercises)
    public func getTimeline(
        for date: Date,
        logs: [ExerciseLog],
        customExercises: [CustomExercise],
        firedNotifications: [Date],
        calculator: NotificationScheduleCalculator?
    ) -> (notifications: [TimelineEvent], exercises: [TimelineEvent]) {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return ([], [])
        }

        // Get notification events
        let notificationEvents: [TimelineEvent]
        if !firedNotifications.isEmpty {
            // Use actual fired notifications
            notificationEvents = firedNotifications
                .filter { $0 >= dayStart && $0 < dayEnd }
                .map { TimelineEvent(timestamp: $0, type: .notificationFired) }
        } else if let calc = calculator {
            // Fall back to scheduled times
            let scheduledTimes = calc.scheduledTimes(for: date)
            notificationEvents = scheduledTimes.map { TimelineEvent(timestamp: $0, type: .notificationFired) }
        } else {
            notificationEvents = []
        }

        // Get exercise events
        let dayLogs = logs.filter { log in
            log.timestamp >= dayStart && log.timestamp < dayEnd
        }

        let exerciseEvents = dayLogs.compactMap { log -> TimelineEvent? in
            let item: ExerciseItem
            if let exerciseType = log.exerciseType {
                item = ExerciseItem(builtIn: exerciseType)
            } else if let customId = log.customExerciseId,
                      let customExercise = customExercises.first(where: { $0.id == customId }) {
                item = ExerciseItem(custom: customExercise)
            } else {
                return nil // Skip deleted exercises
            }

            return TimelineEvent(
                timestamp: log.timestamp,
                type: .exerciseLogged(item: item, count: log.count)
            )
        }

        return (notificationEvents, exerciseEvents)
    }

    /// Get timeline analysis with response metrics
    public func getTimelineAnalysis(
        for date: Date,
        logs: [ExerciseLog],
        customExercises: [CustomExercise],
        firedNotifications: [Date],
        calculator: NotificationScheduleCalculator?
    ) -> TimelineAnalysis {
        let (notifications, exercises) = getTimeline(
            for: date,
            logs: logs,
            customExercises: customExercises,
            firedNotifications: firedNotifications,
            calculator: calculator
        )
        return TimelineAnalysis(notifications: notifications, exercises: exercises)
    }
}
