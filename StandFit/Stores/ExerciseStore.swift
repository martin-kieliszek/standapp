//
//  ExerciseStore.swift
//  StandFit iOS
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
    private let subscriptionManager = SubscriptionManager.shared
    public let localizationManager = LocalizationManager.shared

    // MARK: - Published State

    @Published var logs: [ExerciseLog] = []
    @Published var customExercises: [CustomExercise] = []
    
    // MARK: - Subscription Convenience
    
    var isPremium: Bool {
        subscriptionManager.isPremium
    }
    
    var entitlements: FeatureEntitlement {
        subscriptionManager.entitlements
    }
    
    var canCreateCustomExercise: Bool {
        customExercises.count < entitlements.customExerciseLimit
    }

    // MARK: - Settings (AppStorage)

    // Legacy settings (kept for migration)
    @AppStorage("reminderIntervalMinutes") private var legacyReminderIntervalMinutes: Int = 30
    @AppStorage("activeDaysData") private var legacyActiveDaysData: Data = Data()
    @AppStorage("startHour") private var legacyStartHour: Int = 9
    @AppStorage("endHour") private var legacyEndHour: Int = 17
    @AppStorage("deadResponseEnabled") private var legacyDeadResponseEnabled: Bool = true
    @AppStorage("deadResponseMinutes") private var legacyDeadResponseMinutes: Int = 5
    
    // New profile-based system
    @AppStorage("scheduleProfiles") private var scheduleProfilesData: Data = Data()
    @AppStorage("activeProfileId") private var activeProfileIdString: String = ""
    @AppStorage("hasMigratedToProfiles") private var hasMigratedToProfiles: Bool = false
    
    // General settings (not profile-specific)
    @AppStorage("remindersEnabled") var remindersEnabled: Bool = true
    @AppStorage("nextScheduledNotificationTime") private var nextScheduledTimeInterval: Double = -1
    @AppStorage("progressReportSettingsData") private var progressReportSettingsData: Data = Data()

    // MARK: - Constants

    static let deadResponseOptions = [1, 2, 3, 5, 10, 15]
    
    // MARK: - Profile Management
    
    @Published var scheduleProfiles: [ScheduleProfile] = []
    @Published var activeProfile: ScheduleProfile?
    
    // Computed properties for backward compatibility and ease of use
    var reminderIntervalMinutes: Int {
        get {
            activeProfile?.fallbackInterval ?? legacyReminderIntervalMinutes
        }
        set {
            if var profile = activeProfile {
                profile.fallbackInterval = newValue
                updateProfile(profile)
            } else {
                legacyReminderIntervalMinutes = newValue
            }
        }
    }
    
    var activeDays: Set<Int> {
        get {
            activeProfile?.activeDays ?? legacyActiveDays
        }
        set {
            if var profile = activeProfile {
                // Update all days to match new active days set
                // Clear existing schedules
                for day in 1...7 {
                    if newValue.contains(day) && !profile.activeDays.contains(day) {
                        // Day was added - create a simple schedule for it
                        let block = TimeBlock(
                            startHour: startHour,
                            startMinute: 0,
                            endHour: endHour,
                            endMinute: 0,
                            intervalMinutes: reminderIntervalMinutes
                        )
                        profile.dailySchedules[day] = DailySchedule(
                            enabled: true,
                            scheduleType: .timeBlocks([block])
                        )
                    } else if !newValue.contains(day) && profile.activeDays.contains(day) {
                        // Day was removed - disable it
                        if var daySchedule = profile.dailySchedules[day] {
                            daySchedule.enabled = false
                            profile.dailySchedules[day] = daySchedule
                        }
                    }
                }
                updateProfile(profile)
            } else {
                if let encoded = try? JSONEncoder().encode(newValue) {
                    legacyActiveDaysData = encoded
                }
            }
        }
    }
    
    var startHour: Int {
        get {
            // For simple cases, return the earliest start hour from active profile
            guard let profile = activeProfile else { return legacyStartHour }
            let allBlocks = profile.dailySchedules.values.compactMap { $0.timeBlocks }.flatMap { $0 }
            return allBlocks.map(\.startHour).min() ?? legacyStartHour
        }
        set {
            if var profile = activeProfile {
                // Update all time blocks to use new start hour
                for (day, var schedule) in profile.dailySchedules {
                    if case .timeBlocks(var blocks) = schedule.scheduleType {
                        for i in 0..<blocks.count {
                            blocks[i].startHour = newValue
                        }
                        schedule.scheduleType = .timeBlocks(blocks)
                        profile.dailySchedules[day] = schedule
                    }
                }
                updateProfile(profile)
            } else {
                legacyStartHour = newValue
            }
        }
    }
    
    var endHour: Int {
        get {
            // For simple cases, return the latest end hour from active profile
            guard let profile = activeProfile else { return legacyEndHour }
            let allBlocks = profile.dailySchedules.values.compactMap { $0.timeBlocks }.flatMap { $0 }
            return allBlocks.map(\.endHour).max() ?? legacyEndHour
        }
        set {
            if var profile = activeProfile {
                // Update all time blocks to use new end hour
                for (day, var schedule) in profile.dailySchedules {
                    if case .timeBlocks(var blocks) = schedule.scheduleType {
                        for i in 0..<blocks.count {
                            blocks[i].endHour = newValue
                        }
                        schedule.scheduleType = .timeBlocks(blocks)
                        profile.dailySchedules[day] = schedule
                    }
                }
                updateProfile(profile)
            } else {
                legacyEndHour = newValue
            }
        }
    }
    
    var deadResponseEnabled: Bool {
        get {
            activeProfile?.deadResponseEnabled ?? legacyDeadResponseEnabled
        }
        set {
            if var profile = activeProfile {
                profile.deadResponseEnabled = newValue
                updateProfile(profile)
            } else {
                legacyDeadResponseEnabled = newValue
            }
        }
    }
    
    var deadResponseMinutes: Int {
        get {
            activeProfile?.deadResponseMinutes ?? legacyDeadResponseMinutes
        }
        set {
            if var profile = activeProfile {
                profile.deadResponseMinutes = newValue
                updateProfile(profile)
            } else {
                legacyDeadResponseMinutes = newValue
            }
        }
    }
    
    private var legacyActiveDays: Set<Int> {
        if let decoded = try? JSONDecoder().decode(Set<Int>.self, from: legacyActiveDaysData) {
            return decoded
        }
        return [2, 3, 4, 5, 6]
    }


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
        
        // Load and migrate to profile system
        loadProfiles()
        if !hasMigratedToProfiles {
            migrateToProfileSystem()
        }
    }
    
    // MARK: - Profile Management Methods
    
    private func loadProfiles() {
        guard !scheduleProfilesData.isEmpty else {
            scheduleProfiles = []
            activeProfile = nil
            return
        }
        
        if let decoded = try? JSONDecoder().decode([ScheduleProfile].self, from: scheduleProfilesData) {
            scheduleProfiles = decoded
            
            // Load active profile
            if let profileId = UUID(uuidString: activeProfileIdString),
               let profile = scheduleProfiles.first(where: { $0.id == profileId }) {
                activeProfile = profile
            } else if let firstProfile = scheduleProfiles.first {
                // Fallback to first profile
                activeProfile = firstProfile
                activeProfileIdString = firstProfile.id.uuidString
            }
        }
    }
    
    private func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(scheduleProfiles) {
            scheduleProfilesData = encoded
        }
    }
    
    func migrateToProfileSystem() {
        guard scheduleProfiles.isEmpty else { return }
        
        print("📅 Migrating to profile system...")
        
        // Create default profile from legacy settings
        var defaultProfile = ScheduleProfile(
            name: "Default",
            createdDate: Date(),
            fallbackInterval: legacyReminderIntervalMinutes,
            deadResponseEnabled: legacyDeadResponseEnabled,
            deadResponseMinutes: legacyDeadResponseMinutes
        )
        
        // Convert legacy active days to daily schedules
        for day in legacyActiveDays {
            let timeBlock = TimeBlock(
                name: nil,
                startHour: legacyStartHour,
                startMinute: 0,
                endHour: legacyEndHour,
                endMinute: 0,
                intervalMinutes: legacyReminderIntervalMinutes
            )
            
            defaultProfile.dailySchedules[day] = DailySchedule(
                enabled: true,
                scheduleType: .timeBlocks([timeBlock])
            )
        }
        
        scheduleProfiles = [defaultProfile]
        activeProfile = defaultProfile
        activeProfileIdString = defaultProfile.id.uuidString
        
        saveProfiles()
        hasMigratedToProfiles = true
        
        print("✅ Migration complete. Created default profile with \(defaultProfile.activeDays.count) active days")
    }
    
    func createProfile(name: String, basedOn template: ScheduleTemplate? = nil) -> ScheduleProfile {
        let profile: ScheduleProfile
        
        if let template = template {
            var newProfile = template.profile
            newProfile.name = name
            profile = newProfile
        } else {
            // Create empty profile
            profile = ScheduleProfile(name: name)
        }
        
        scheduleProfiles.append(profile)
        saveProfiles()
        
        return profile
    }
    
    func updateProfile(_ profile: ScheduleProfile) {
        if let index = scheduleProfiles.firstIndex(where: { $0.id == profile.id }) {
            scheduleProfiles[index] = profile
            
            // Update active profile if it's the one being edited
            if activeProfile?.id == profile.id {
                activeProfile = profile
                activeProfileIdString = profile.id.uuidString
                
                // Reschedule notifications with updated profile
                updateAllNotificationSchedules(reason: "Updated profile '\(profile.name)'")
            }
            
            saveProfiles()
        }
    }
    
    func deleteProfile(_ profile: ScheduleProfile) {
        scheduleProfiles.removeAll { $0.id == profile.id }
        
        // If deleting active profile, switch to first available
        if activeProfile?.id == profile.id {
            activeProfile = scheduleProfiles.first
            activeProfileIdString = scheduleProfiles.first?.id.uuidString ?? ""
        }
        
        saveProfiles()
    }
    
    func switchToProfile(_ profile: ScheduleProfile) {
        guard scheduleProfiles.contains(where: { $0.id == profile.id }) else { return }
        
        var updatedProfile = profile
        updatedProfile.lastUsedDate = Date()
        updateProfile(updatedProfile)
        
        activeProfile = updatedProfile
        activeProfileIdString = updatedProfile.id.uuidString
        
        // Reschedule notifications with new profile
        updateAllNotificationSchedules(reason: "Switched to profile '\(profile.name)'")
    }
    
    func duplicateProfile(_ profile: ScheduleProfile, newName: String) -> ScheduleProfile {
        var newProfile = profile
        newProfile.name = newName
        newProfile.createdDate = Date()
        newProfile.lastUsedDate = nil
        
        scheduleProfiles.append(newProfile)
        saveProfiles()
        
        return newProfile
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
    
    /// Get the 3 most recently logged exercises (by unique exercise type/id)
    var recentExercises: [ExerciseItem] {
        var seenExerciseIds = Set<String>()
        var recentItems: [ExerciseItem] = []
        
        // Sort logs by timestamp descending (most recent first) and iterate
        let sortedLogs = logs.sorted { $0.timestamp > $1.timestamp }
        
        for log in sortedLogs {
            let exerciseId: String
            let item: ExerciseItem?
            
            if let type = log.exerciseType {
                exerciseId = "builtin_\(type.id)"
                item = ExerciseItem(builtIn: type)
            } else if let customId = log.customExerciseId,
                      let customEx = customExercise(byId: customId) {
                exerciseId = "custom_\(customId.uuidString)"
                item = ExerciseItem(custom: customEx)
            } else {
                continue // Skip invalid logs
            }
            
            // Add if we haven't seen this exercise yet
            if !seenExerciseIds.contains(exerciseId), let exerciseItem = item {
                seenExerciseIds.insert(exerciseId)
                recentItems.append(exerciseItem)
                
                if recentItems.count >= 3 {
                    break
                }
            }
        }
        
        print("🎯 Returning \(recentItems.count) recent exercises")
        return recentItems
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
