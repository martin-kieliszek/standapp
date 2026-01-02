//
//  ExerciseStore.swift
//  StandFit
//
//  Refactored to use StandFitCore services
//

import Foundation
import SwiftUI
import Combine
import StandFitCore

@MainActor
class ExerciseStore: ObservableObject {
    static let shared = ExerciseStore()

    // MARK: - Services

    private let exerciseService: ExerciseService
    internal let reportingService: ReportingService  // Accessible within module for NotificationManager
    private let timelineService: TimelineService

    // MARK: - Published State

    @Published var logs: [ExerciseLog] = []
    @Published var customExercises: [CustomExercise] = []

    // MARK: - Settings (AppStorage)

    @AppStorage("reminderIntervalMinutes") var reminderIntervalMinutes: Int = 30
    @AppStorage("remindersEnabled") var remindersEnabled: Bool = true
    @AppStorage("activeDaysData") private var activeDaysData: Data = Data()
    @AppStorage("startHour") var startHour: Int = 9
    @AppStorage("endHour") var endHour: Int = 17
    @AppStorage("nextScheduledNotificationTime") private var nextScheduledTimeInterval: Double = -1
    @AppStorage("deadResponseEnabled") var deadResponseEnabled: Bool = true
    @AppStorage("deadResponseMinutes") var deadResponseMinutes: Int = 5
    @AppStorage("progressReportSettingsData") private var progressReportSettingsData: Data = Data()

    // MARK: - Constants

    static let deadResponseOptions = [1, 2, 3, 5, 10, 15]

    // MARK: - Computed Properties

    var progressReportSettings: ProgressReportSettings {
        get {
            guard let decoded = try? JSONDecoder().decode(ProgressReportSettings.self, from: progressReportSettingsData) else {
                return ProgressReportSettings()
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                progressReportSettingsData = encoded
            }
        }
    }

    var nextScheduledNotificationTime: Date? {
        get {
            guard nextScheduledTimeInterval >= 0 else {
                return nil
            }
            return Date(timeIntervalSince1970: nextScheduledTimeInterval)
        }
        set {
            nextScheduledTimeInterval = newValue?.timeIntervalSince1970 ?? -1
        }
    }

    var activeDays: Set<Int> {
        get {
            if let decoded = try? JSONDecoder().decode(Set<Int>.self, from: activeDaysData) {
                return decoded
            }
            return [2, 3, 4, 5, 6]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                activeDaysData = encoded
            }
        }
    }

    var shouldRemindNow: Bool {
        guard remindersEnabled else { return false }
        let calendar = Calendar.current
        let now = Date()

        let weekday = calendar.component(.weekday, from: now)
        guard activeDays.contains(weekday) else { return false }

        let hour = calendar.component(.hour, from: now)
        guard hour >= startHour && hour <= endHour else { return false }
        return true
    }

    // MARK: - Initialization

    init() {
        // Initialize services with persistence
        let persistence = try! JSONFilePersistence()
        self.exerciseService = ExerciseService(persistence: persistence)
        self.reportingService = ReportingService()
        self.timelineService = TimelineService()

        // Load data from services
        self.logs = (try? exerciseService.loadLogs()) ?? []
        self.customExercises = (try? exerciseService.loadCustomExercises()) ?? []
    }

    // MARK: - Utility Methods

    static func formatInterval(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    func nextValidReminderDate(afterMinutes minutes: Int) -> Date? {
        let calendar = Calendar.current
        var proposedTime = Date().addingTimeInterval(TimeInterval(minutes * 60))

        // Try up to 7 days ahead to find a valid slot
        for _ in 0..<(7 * 24) {
            let weekday = calendar.component(.weekday, from: proposedTime)
            let hour = calendar.component(.hour, from: proposedTime)

            // Check if this time is valid
            if activeDays.contains(weekday) && hour >= startHour && hour < endHour {
                return proposedTime
            }

            // Move to next valid slot
            if !activeDays.contains(weekday) {
                // Skip to next day at startHour
                proposedTime = calendar.nextDate(
                    after: proposedTime,
                    matching: DateComponents(hour: startHour, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? proposedTime.addingTimeInterval(3600)
            } else if hour < startHour {
                // Move to startHour today
                proposedTime = calendar.date(
                    bySettingHour: startHour,
                    minute: 0,
                    second: 0,
                    of: proposedTime
                ) ?? proposedTime
            } else {
                // Past endHour, move to next day's startHour
                proposedTime = calendar.nextDate(
                    after: proposedTime,
                    matching: DateComponents(hour: startHour, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? proposedTime.addingTimeInterval(3600)
            }
        }

        return nil
    }

    // MARK: - All Exercises (Built-in + Custom)

    var allExercises: [ExerciseItem] {
        exerciseService.getAllExercises(customExercises: customExercises)
    }

    func customExercise(byId id: UUID) -> CustomExercise? {
        exerciseService.customExercise(byId: id, in: customExercises)
    }

    // MARK: - Exercise Log CRUD

    func logExercise(type: ExerciseType, count: Int) {
        let log = ExerciseLog(exerciseType: type, count: count)
        try? exerciseService.addLog(log, to: &logs)

        // Trigger gamification event
        let gamificationStore = GamificationStore.shared
        gamificationStore.processEvent(
            .exerciseLogged(exerciseId: type.rawValue, count: count, timestamp: log.timestamp),
            exerciseStore: self
        )
    }

    func logExercise(customExerciseId: UUID, count: Int) {
        let log = ExerciseLog(customExerciseId: customExerciseId, count: count)
        try? exerciseService.addLog(log, to: &logs)

        // Trigger gamification event
        let gamificationStore = GamificationStore.shared
        gamificationStore.processEvent(
            .exerciseLogged(exerciseId: customExerciseId.uuidString, count: count, timestamp: log.timestamp),
            exerciseStore: self
        )
    }

    func logExercise(item: ExerciseItem, count: Int) {
        let log = ExerciseLog(item: item, count: count)
        try? exerciseService.addLog(log, to: &logs)

        // Trigger gamification event
        let gamificationStore = GamificationStore.shared
        let exerciseId = item.isBuiltIn ? (item.builtInType?.rawValue ?? "unknown") : item.id
        gamificationStore.processEvent(
            .exerciseLogged(exerciseId: exerciseId, count: count, timestamp: log.timestamp),
            exerciseStore: self
        )
    }

    func deleteLog(_ log: ExerciseLog) {
        try? exerciseService.deleteLog(log, from: &logs)
    }

    func clearAllLogs() {
        try? exerciseService.clearAllLogs()
        logs = []
    }

    // MARK: - Custom Exercise CRUD

    func addCustomExercise(_ exercise: CustomExercise) {
        try? exerciseService.addCustomExercise(exercise, to: &customExercises)
    }

    func updateCustomExercise(_ exercise: CustomExercise) {
        try? exerciseService.updateCustomExercise(exercise, in: &customExercises)
    }

    func deleteCustomExercise(_ exercise: CustomExercise) {
        try? exerciseService.deleteCustomExercise(exercise, from: &customExercises)
    }

    func moveCustomExercise(from source: IndexSet, to destination: Int) {
        try? exerciseService.moveCustomExercise(from: source, to: destination, in: &customExercises)
    }

    // MARK: - Statistics

    var todaysLogs: [ExerciseLog] {
        exerciseService.todaysLogs(from: logs)
    }

    var todaysSummaries: [ExerciseSummary] {
        exerciseService.todaysSummaries(from: logs)
    }

    var todaysCustomSummaries: [CustomExerciseSummary] {
        exerciseService.todaysCustomSummaries(from: logs, customExercises: customExercises)
    }

    func logsForLastDays(_ days: Int) -> [ExerciseLog] {
        exerciseService.logsForLastDays(days, from: logs)
    }

    // MARK: - Reporting Service Methods

    func getStats(for period: ReportPeriod) -> ReportStats {
        reportingService.getStats(for: period, logs: logs, customExercises: customExercises)
    }

    // MARK: - Timeline Service Methods

    func getTodaysTimeline() -> (notifications: [TimelineEvent], exercises: [TimelineEvent]) {
        let firedNotifications = NotificationFiredLog.shared.todaysFiredNotifications
        let calculator = NotificationScheduleCalculator(
            intervalMinutes: reminderIntervalMinutes,
            activeHours: (startHour, endHour),
            activeDays: activeDays
        )

        return timelineService.getTimeline(
            for: Date(),
            logs: logs,
            customExercises: customExercises,
            firedNotifications: firedNotifications,
            calculator: calculator
        )
    }

    func getTodaysTimelineAnalysis() -> TimelineAnalysis {
        let firedNotifications = NotificationFiredLog.shared.todaysFiredNotifications
        let calculator = NotificationScheduleCalculator(
            intervalMinutes: reminderIntervalMinutes,
            activeHours: (startHour, endHour),
            activeDays: activeDays
        )

        return timelineService.getTimelineAnalysis(
            for: Date(),
            logs: logs,
            customExercises: customExercises,
            firedNotifications: firedNotifications,
            calculator: calculator
        )
    }

    // MARK: - Notification Scheduling Coordination

    func updateAllNotificationSchedules(reason: String = "Settings changed") {
        print("🔔 Rescheduling notifications (\(reason))")

        let notificationManager = NotificationManager.shared
        notificationManager.cancelAllReminders()

        // Reschedule exercise reminders
        if remindersEnabled {
            notificationManager.scheduleReminderWithSchedule(store: self)
        }

        // Reschedule progress reports
        if progressReportSettings.enabled {
            notificationManager.scheduleProgressReport(store: self)
        }
    }
}
