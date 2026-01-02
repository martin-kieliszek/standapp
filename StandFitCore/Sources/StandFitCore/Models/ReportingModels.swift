//
//  ReportingModels.swift
//  StandFitCore
//
//  Progress reporting and notification models
//

import Foundation

// MARK: - Notification Type Registry

public enum NotificationType: String {
    case exerciseReminder = "stand_reminder"
    case deadResponseReminder = "stand_reminder_followup"
    case progressReport = "progress_report"
    case achievementUnlocked = "achievement_unlocked"

    public var categoryIdentifier: String {
        switch self {
        case .exerciseReminder, .deadResponseReminder:
            return "STAND_REMINDER"
        case .progressReport:
            return "PROGRESS_REPORT"
        case .achievementUnlocked:
            return "ACHIEVEMENT_UNLOCKED"
        }
    }

    public var requiresRepeat: Bool {
        switch self {
        case .exerciseReminder: return true
        case .deadResponseReminder: return false
        case .progressReport: return true
        case .achievementUnlocked: return false
        }
    }
}

// MARK: - Report Period

public enum ReportPeriod: Hashable {
    case today
    case yesterday
    case weekStarting(Date)
    case monthStarting(Date)
    case year(Int)

    public var startDate: Date {
         let calendar = Calendar.current
         switch self {
         case .today:
             return calendar.startOfDay(for: Date())
         case .yesterday:
             let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date().addingTimeInterval(-86400)
             return calendar.startOfDay(for: yesterday)
         case .weekStarting(let date):
             return calendar.startOfDay(for: date)
         case .monthStarting(let date):
             return calendar.startOfDay(for: date)
         case .year(let year):
             return calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
         }
     }

    public var endDate: Date {
        let calendar = Calendar.current
        switch self {
        case .today:
            return calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate.addingTimeInterval(86400)
        case .yesterday:
            return calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate.addingTimeInterval(86400)
        case .weekStarting:
            return calendar.date(byAdding: .day, value: 7, to: startDate) ?? startDate.addingTimeInterval(86400 * 7)
        case .monthStarting:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate.addingTimeInterval(86400 * 30)
        case .year(let year):
            return calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? startDate.addingTimeInterval(86400 * 365)
        }
    }

    public var displayName: String {
        let calendar = Calendar.current
        switch self {
        case .today:
            return "Today"
        case .yesterday:
            return "Yesterday"
        case .weekStarting(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "Week of \(formatter.string(from: date))"
        case .monthStarting(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        case .year(let year):
            return String(year)
        }
    }
}

// MARK: - Report Stats

public struct ReportStats {
    public let totalCount: Int
    public let periodStart: Date
    public let periodEnd: Date
    public let breakdown: [ExerciseBreakdown]
    public let comparisonToPrevious: Double?  // Percentage change, e.g., 0.15 = 15%
    public let streak: Int?

    public init(
        totalCount: Int,
        periodStart: Date,
        periodEnd: Date,
        breakdown: [ExerciseBreakdown],
        comparisonToPrevious: Double? = nil,
        streak: Int? = nil
    ) {
        self.totalCount = totalCount
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.breakdown = breakdown
        self.comparisonToPrevious = comparisonToPrevious
        self.streak = streak
    }
}

public struct ExerciseBreakdown {
    public let exercise: ExerciseItem
    public let count: Int
    public let percentage: Double  // 0.0 to 1.0

    public init(exercise: ExerciseItem, count: Int, percentage: Double) {
        self.exercise = exercise
        self.count = count
        self.percentage = percentage
    }
}

// MARK: - Report Notification Content

public struct ReportNotificationContent {
    public let title: String
    public let body: String
    public let badge: String?

    public init(title: String, body: String, badge: String? = nil) {
        self.title = title
        self.body = body
        self.badge = badge
    }

    public static func generate(
        stats: ReportStats,
        frequency: ReportFrequency,
        previousStats: ReportStats? = nil
    ) -> ReportNotificationContent {
        var bodyParts: [String] = []

        // Main stat with formatting
        let timeframeText = timeframeLabel(for: frequency)
        bodyParts.append("You logged \(stats.totalCount) exercise\(stats.totalCount == 1 ? "" : "s") \(timeframeText)")

        // Comparison to previous period
        if let previous = previousStats, let percentChange = stats.comparisonToPrevious {
            let arrow = percentChange >= 0 ? "↑" : "↓"
            let percent = abs(Int(percentChange * 100))
            bodyParts.append("\(arrow)\(percent)% vs last \(timeframeText.lowercased())")
        }

        // Streak indicator
        if let streak = stats.streak, streak > 0 {
            bodyParts.append("🔥 \(streak)-day streak!")
        }

        let body = bodyParts.joined(separator: " • ")
        let badge = determineBadge(stats: stats)

        return ReportNotificationContent(
            title: "Progress Report",
            body: body,
            badge: badge
        )
    }

    private static func timeframeLabel(for frequency: ReportFrequency) -> String {
        switch frequency {
        case .daily:
            return "today"
        case .weekly:
            return "this week"
        }
    }

    private static func determineBadge(stats: ReportStats) -> String? {
        if stats.totalCount > 100 { return "🎯" }
        if stats.streak ?? 0 > 10 { return "🔥" }
        if stats.comparisonToPrevious ?? 0 > 0.2 { return "💪" }
        return nil
    }
}

// MARK: - Progress Report Settings

public struct ProgressReportSettings: Codable, Equatable {
    public var enabled: Bool
    public var frequency: ReportFrequency
    public var hour: Int
    public var minute: Int
    public var lastReportDate: Date?

    // Future extensibility
    public var includeStreak: Bool
    public var includeComparison: Bool

    public init(
        enabled: Bool = true,
        frequency: ReportFrequency = .daily,
        hour: Int = 20,
        minute: Int = 0,
        lastReportDate: Date? = nil,
        includeStreak: Bool = true,
        includeComparison: Bool = true
    ) {
        self.enabled = enabled
        self.frequency = frequency
        self.hour = hour
        self.minute = minute
        self.lastReportDate = lastReportDate
        self.includeStreak = includeStreak
        self.includeComparison = includeComparison
    }
}

public enum ReportFrequency: String, Codable, CaseIterable {
    case daily
    case weekly

    public var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }

    /// Calculate next scheduled date for this frequency
    public func nextScheduledDate(baseDate: Date = Date(), atHour hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current

        switch self {
        case .daily:
            return calendar.nextDate(
                after: baseDate,
                matching: DateComponents(hour: hour, minute: minute),
                matchingPolicy: .nextTime
            ) ?? baseDate.addingTimeInterval(3600)

        case .weekly:
            // Sunday = 1 in Calendar.Component.weekday
            return calendar.nextDate(
                after: baseDate,
                matching: DateComponents(hour: hour, minute: minute, weekday: 1),
                matchingPolicy: .nextTime
            ) ?? baseDate.addingTimeInterval(3600 * 24)
        }
    }

    /// Check if enough time has passed since last report
    public func shouldScheduleNewReport(lastReportDate: Date?) -> Bool {
        guard let lastDate = lastReportDate else { return true }
        let calendar = Calendar.current

        switch self {
        case .daily:
            return !calendar.isDate(lastDate, inSameDayAs: Date())
        case .weekly:
            let daysSince = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            return daysSince >= 7
        }
    }
}
