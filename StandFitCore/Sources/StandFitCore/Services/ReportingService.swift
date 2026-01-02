//
//  ReportingService.swift
//  StandFitCore
//
//  Platform-agnostic reporting and statistics service
//

import Foundation

/// Unified service for generating statistics across different time periods
/// Shared by progress charts, notifications, and future features
public struct ReportingService {
    public init() {}

    /// Get stats for a specific period
    public func getStats(
        for period: ReportPeriod,
        logs: [ExerciseLog],
        customExercises: [CustomExercise]
    ) -> ReportStats {
        // Early exit if no logs at all
        guard !logs.isEmpty else {
            return emptyStats(for: period)
        }

        let periodLogs = logsForPeriod(period, from: logs)

        // Early exit if no logs for this period
        guard !periodLogs.isEmpty else {
            return emptyStats(for: period)
        }

        let totalCount = periodLogs.reduce(0) { $0 + $1.count }
        let breakdown = exerciseBreakdown(periodLogs, customExercises: customExercises)
        let previousStats = previousPeriodStats(for: period, from: logs, customExercises: customExercises)
        let percentChange = percentageChange(current: totalCount, previous: previousStats?.totalCount)
        let streak = calculateStreak(from: logs)

        return ReportStats(
            totalCount: totalCount,
            periodStart: period.startDate,
            periodEnd: period.endDate,
            breakdown: breakdown,
            comparisonToPrevious: percentChange,
            streak: streak
        )
    }

    private func logsForPeriod(_ period: ReportPeriod, from logs: [ExerciseLog]) -> [ExerciseLog] {
        logs.filter { log in
            log.timestamp >= period.startDate && log.timestamp < period.endDate
        }
    }

    private func exerciseBreakdown(_ logs: [ExerciseLog], customExercises: [CustomExercise]) -> [ExerciseBreakdown] {
        let total = logs.reduce(0) { $0 + $1.count }
        guard total > 0 else { return [] }

        var breakdown: [String: (count: Int, item: ExerciseItem)] = [:]

        for log in logs {
            let item: ExerciseItem

            if let exerciseType = log.exerciseType {
                item = ExerciseItem(builtIn: exerciseType)
            } else if let customId = log.customExerciseId,
                      let custom = customExercises.first(where: { $0.id == customId }) {
                item = ExerciseItem(custom: custom)
            } else {
                // Skip logs for deleted exercises - don't show them in breakdown
                continue
            }

            let key = item.id

            if let existing = breakdown[key] {
                breakdown[key] = (count: existing.count + log.count, item: existing.item)
            } else {
                breakdown[key] = (count: log.count, item: item)
            }
        }

        return breakdown.map { key, value in
            ExerciseBreakdown(
                exercise: value.item,
                count: value.count,
                percentage: Double(value.count) / Double(total)
            )
        }.sorted { $0.count > $1.count }
    }

    private func previousPeriodStats(
        for period: ReportPeriod,
        from logs: [ExerciseLog],
        customExercises: [CustomExercise]
    ) -> ReportStats? {
        let previousPeriod: ReportPeriod?
        let calendar = Calendar.current

        switch period {
        case .today:
            previousPeriod = .yesterday
        case .yesterday:
            return nil  // No previous day before yesterday in context
        case .weekStarting(let date):
            guard let previousWeekStart = calendar.date(byAdding: .day, value: -7, to: date) else {
                return nil  // Safely handle date computation failure
            }
            previousPeriod = .weekStarting(previousWeekStart)
        case .monthStarting(let date):
            guard let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: date) else {
                return nil  // Safely handle date computation failure
            }
            previousPeriod = .monthStarting(previousMonthStart)
        case .year(let year):
            previousPeriod = .year(year - 1)
        }

        guard let previous = previousPeriod else { return nil }
        return getStats(for: previous, logs: logs, customExercises: customExercises)
    }

    private func percentageChange(current: Int, previous: Int?) -> Double? {
        guard let previous = previous, previous > 0 else { return nil }
        return Double(current - previous) / Double(previous)
    }

    private func calculateStreak(from logs: [ExerciseLog]) -> Int? {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        let maxIterations = 1000  // Safety limit to prevent infinite loops
        var iterations = 0

        // Count backwards from today
        while iterations < maxIterations {
            let dayLogs = logs.filter { calendar.isDate($0.timestamp, inSameDayAs: checkDate) }
            guard !dayLogs.isEmpty else { break }

            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate.addingTimeInterval(-86400)
            iterations += 1
        }

        return streak > 0 ? streak : nil
    }

    private func emptyStats(for period: ReportPeriod) -> ReportStats {
        ReportStats(
            totalCount: 0,
            periodStart: period.startDate,
            periodEnd: period.endDate,
            breakdown: [],
            comparisonToPrevious: nil,
            streak: nil
        )
    }
}
