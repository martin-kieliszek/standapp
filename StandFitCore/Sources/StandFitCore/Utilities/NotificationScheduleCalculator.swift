//
//  NotificationScheduleCalculator.swift
//  StandFitCore
//
//  Calculates theoretical notification schedule based on user settings
//

import Foundation

/// Calculates theoretical notification schedule based on user settings
/// Used to infer when notifications should have fired for timeline visualization
public struct NotificationScheduleCalculator {
    public let intervalMinutes: Int
    public let activeHours: (start: Int, end: Int)
    public let activeDays: Set<Int>

    public init(intervalMinutes: Int, activeHours: (start: Int, end: Int), activeDays: Set<Int>) {
        self.intervalMinutes = intervalMinutes
        self.activeHours = activeHours
        self.activeDays = activeDays
    }

    /// Generate all scheduled notification times for a given day
    public func scheduledTimes(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)

        // Check if this day is active
        let weekday = calendar.component(.weekday, from: date)
        guard activeDays.contains(weekday) else { return [] }

        var scheduledTimes: [Date] = []

        // Generate times within active hours
        var currentMinute = activeHours.start * 60 // Convert to minutes since midnight

        while currentMinute <= activeHours.end * 60 {
            let hour = currentMinute / 60
            let minute = currentMinute % 60

            var components = DateComponents()
            components.year = calendar.component(.year, from: date)
            components.month = calendar.component(.month, from: date)
            components.day = calendar.component(.day, from: date)
            components.hour = hour
            components.minute = minute

            if let scheduledTime = calendar.date(from: components) {
                scheduledTimes.append(scheduledTime)
            }

            currentMinute += intervalMinutes
        }

        return scheduledTimes
    }

    /// Get today's scheduled notification times (only past times)
    public var todaysScheduledTimes: [Date] {
        let now = Date()
        return scheduledTimes(for: now).filter { $0 <= now }
    }

    /// Get scheduled times for a date range
    public func scheduledTimes(from startDate: Date, to endDate: Date) -> [Date] {
        let calendar = Calendar.current
        var allTimes: [Date] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        while currentDate <= endDay {
            allTimes.append(contentsOf: scheduledTimes(for: currentDate))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Filter to only times within the actual range
        return allTimes.filter { $0 >= startDate && $0 <= endDate }
    }
}
