//
//  NotificationManager.swift
//  StandFit iOS
//
//  iOS notification and haptic manager (adapts from WatchOS version)
//

import Foundation
import UserNotifications
import UIKit
import Combine
import StandFitCore

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let logExerciseActionID = "LOG_EXERCISE"
    private let snoozeActionID = "SNOOZE"
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var lastNotificationError: (type: NotificationType, error: Error)?
    
    private init() {
        setupNotificationCategories()
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Notification authorization failed: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Notification Categories (for action buttons)
       
    func setupNotificationCategories() {
        let logAction = UNNotificationAction(
            identifier: logExerciseActionID, title: LocalizedString.Notifications.actionLogExercise, options: .foreground)

        let snoozeAction = UNNotificationAction(identifier: snoozeActionID, title: LocalizedString.Notifications.actionSnooze5Min, options: [])

        let viewReportAction = UNNotificationAction(
            identifier: "VIEW_REPORT", title: LocalizedString.Notifications.actionViewDetails, options: [.foreground])

        let viewAchievementsAction = UNNotificationAction(
            identifier: "VIEW_ACHIEVEMENTS", title: LocalizedString.Notifications.actionViewAll, options: [.foreground])

        let exerciseCategory = UNNotificationCategory(
            identifier: NotificationType.exerciseReminder.categoryIdentifier,
            actions: [logAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        let reportCategory = UNNotificationCategory(
            identifier: NotificationType.progressReport.categoryIdentifier,
            actions: [viewReportAction],
            intentIdentifiers: [],
            options: []
        )

        let achievementCategory = UNNotificationCategory(
            identifier: NotificationType.achievementUnlocked.categoryIdentifier,
            actions: [viewAchievementsAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([exerciseCategory, reportCategory, achievementCategory])
        
        #if DEBUG
        print("✅ Registered 3 notification categories:")
        print("   - \(NotificationType.exerciseReminder.categoryIdentifier) with 2 actions")
        print("   - \(NotificationType.progressReport.categoryIdentifier) with 1 action")
        print("   - \(NotificationType.achievementUnlocked.categoryIdentifier) with 1 action")
        #endif
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                NotificationType.exerciseReminder.rawValue,
                NotificationType.deadResponseReminder.rawValue,
                NotificationType.progressReport.rawValue
            ]
        )
    }

    func cancelFollowUpReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationType.deadResponseReminder.rawValue]
        )
    }
    
    func cancelProgressReport() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationType.progressReport.rawValue]
        )
    }

    /// Schedule a follow-up reminder for dead response reset.
    /// This fires if the user doesn't respond to the main notification.
    func scheduleFollowUpReminder(store: ExerciseStore) {
        guard store.deadResponseEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.stillThereTitle
        content.body = LocalizedString.Notifications.missedReminderBody
        content.sound = .default
        content.categoryIdentifier = NotificationType.deadResponseReminder.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(store.deadResponseMinutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: NotificationType.deadResponseReminder.rawValue,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule follow-up: \(error)")
            } else {
                print("Scheduled follow-up reminder for \(store.deadResponseMinutes) minutes")
            }
        }
    }
    
    /// Get the next scheduled reminder time
    func getNextReminderTime() async -> Date? {
        let requests = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()

        guard let request = requests.first(where: { $0.identifier == NotificationType.exerciseReminder.rawValue }),
              let trigger = request.trigger as? UNTimeIntervalNotificationTrigger
        else {
            return nil
        }

        return trigger.nextTriggerDate()
    }
     
    
    // MARK: - Haptic Feedback (iOS-specific using UIDevice)
    func playReminderHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func playSuccessHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func playClickHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func playDirectionUpHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Scheduling
    
    func debugPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("=== Pending Notifications ===")
            for request in requests {
                print("ID: \(request.identifier)")
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  Fires in: \(trigger.timeInterval) seconds")
                    print("  Next date: \(trigger.nextTriggerDate() ?? Date())")
                }
            }
            if requests.isEmpty {
                print("  (none scheduled)")
            }
        }
    }
    
    func scheduleReminderWithSchedule(store: ExerciseStore) {
        // Cancel any existing (including follow-ups)
        cancelAllReminders()

        // Find next valid time using profile system
        guard let nextTime = calculateNextReminderTime(store: store, from: Date()) else {
            print("No valid reminder time found in the next week")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.timeToMoveTitle
        content.body = LocalizedString.Notifications.standUpExerciseBody
        content.sound = .default
        content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

        let interval = nextTime.timeIntervalSince(Date())
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(interval, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: NotificationType.exerciseReminder.rawValue,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Scheduled reminder for \(nextTime)")
                DispatchQueue.main.async {
                    store.nextScheduledNotificationTime = nextTime
                }
            }
        }
    }
    
    // MARK: - Advanced Scheduling with Profile System
    
    /// Calculate next reminder time using the active profile's schedule
    func calculateNextReminderTime(store: ExerciseStore, from date: Date) -> Date? {
        guard let profile = store.activeProfile else {
            // Fallback to legacy system if no profile
            return store.nextValidReminderDate(afterMinutes: store.reminderIntervalMinutes)
        }
        
        let calendar = Calendar.current
        var candidateTime = date
        
        // Try up to 7 days ahead
        for _ in 0..<(7 * 24 * 60) {
            let weekday = calendar.component(.weekday, from: candidateTime)
            let hour = calendar.component(.hour, from: candidateTime)
            let minute = calendar.component(.minute, from: candidateTime)
            let currentMinutes = hour * 60 + minute
            
            guard let daySchedule = profile.dailySchedules[weekday],
                  daySchedule.enabled else {
                // Skip to next day at midnight
                candidateTime = calendar.nextDate(
                    after: candidateTime,
                    matching: DateComponents(hour: 0, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? candidateTime.addingTimeInterval(86400)
                continue
            }
            
            switch daySchedule.scheduleType {
            case .timeBlocks(let blocks):
                // Find matching time block
                if let matchingBlock = blocks.first(where: { $0.contains(minutes: currentMinutes) }) {
                    // We're in a block - calculate next time within this block
                    return calculateNextTimeInBlock(
                        block: matchingBlock,
                        from: candidateTime,
                        profile: profile,
                        store: store
                    )
                } else {
                    // Not in a block - jump to next block start
                    if let nextBlock = blocks.first(where: { $0.startMinutes > currentMinutes }) {
                        // Jump to start of next block today
                        candidateTime = calendar.date(
                            bySettingHour: nextBlock.startHour,
                            minute: nextBlock.startMinute,
                            second: 0,
                            of: candidateTime
                        ) ?? candidateTime
                    } else {
                        // No more blocks today, move to next day
                        candidateTime = calendar.nextDate(
                            after: candidateTime,
                            matching: DateComponents(hour: 0, minute: 0),
                            matchingPolicy: .nextTime
                        ) ?? candidateTime.addingTimeInterval(86400)
                    }
                }
                
            case .fixedTimes(let reminders):
                // Find next fixed time
                if let nextReminder = reminders.first(where: { $0.totalMinutes > currentMinutes }) {
                    return calendar.date(
                        bySettingHour: nextReminder.hour,
                        minute: nextReminder.minute,
                        second: 0,
                        of: candidateTime
                    )
                } else {
                    // No more fixed times today, move to next day
                    candidateTime = calendar.nextDate(
                        after: candidateTime,
                        matching: DateComponents(hour: 0, minute: 0),
                        matchingPolicy: .nextTime
                    ) ?? candidateTime.addingTimeInterval(86400)
                }
                
            case .useFallback:
                // Use global fallback interval
                return candidateTime.addingTimeInterval(
                    TimeInterval(profile.fallbackInterval * 60)
                )
            }
        }
        
        return nil // No valid time found in next week
    }
    
    private func calculateNextTimeInBlock(
        block: TimeBlock,
        from date: Date,
        profile: ScheduleProfile,
        store: ExerciseStore
    ) -> Date {
        var interval = block.intervalMinutes
        
        // Apply randomization if enabled
        if let randomRange = block.randomizationRange {
            let randomOffset = Int.random(in: -randomRange...randomRange)
            interval = max(1, interval + randomOffset)
        }
        
        let nextTime = date.addingTimeInterval(TimeInterval(interval * 60))
        
        // Check if next time is still within this block
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: nextTime)
        let minute = calendar.component(.minute, from: nextTime)
        let totalMinutes = hour * 60 + minute
        
        if totalMinutes >= block.endMinutes {
            // Would exceed block - return nil to trigger jump to next block
            return calculateNextReminderTime(store: store, from: nextTime) ?? nextTime
        }
        
        return nextTime
    }

    
    // MARK: - Progress Report Notifications
    
    /// Schedule a progress report notification at configured frequency and time
    func scheduleProgressReport(store: ExerciseStore, precachedStats: ReportStats? = nil) {
        guard store.progressReportSettings.enabled else { return }

        // Get stats for today/this week
        let period: ReportPeriod = store.progressReportSettings.frequency == .daily ? .today : .weekStarting(Date())
        let stats = precachedStats ?? store.reportingService.getStats(
            for: period,
            logs: store.logs,
            customExercises: store.customExercises
        )

        // Get previous period stats for comparison
        let previousPeriod: ReportPeriod = store.progressReportSettings.frequency == .daily ? .yesterday : .weekStarting(Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        let previousStats = store.reportingService.getStats(
            for: previousPeriod,
            logs: store.logs,
            customExercises: store.customExercises
        )

        // Generate content
        let content = ReportNotificationContent.generate(
            stats: stats,
            frequency: store.progressReportSettings.frequency,
            previousStats: previousStats
        )

        // Build UNMutableNotificationContent
        let unContent = UNMutableNotificationContent()
        unContent.title = content.title
        unContent.body = content.body
        unContent.sound = .default
        unContent.categoryIdentifier = NotificationType.progressReport.categoryIdentifier

        if let badge = content.badge {
            unContent.title = "\(badge) \(content.title)"
        }

        // Use calendar-based trigger for automatic repetition
        var components = DateComponents()
        components.hour = store.progressReportSettings.hour
        components.minute = store.progressReportSettings.minute

        // For weekly reports, set weekday to Sunday (1 in Calendar.Component.weekday)
        if store.progressReportSettings.frequency == .weekly {
            components.weekday = 1  // Sunday
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true  // ✅ FIXED - automatically repeats daily/weekly
        )

        let request = UNNotificationRequest(
            identifier: NotificationType.progressReport.rawValue,
            content: unContent,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.lastNotificationError = (.progressReport, error)
                    print("⚠️ Failed to schedule progress report: \(error)")
                } else {
                    self?.lastNotificationError = nil
                    let frequency = store.progressReportSettings.frequency.displayName
                    let time = String(format: "%d:%02d", store.progressReportSettings.hour, store.progressReportSettings.minute)
                    print("✅ Scheduled \(frequency.lowercased()) progress report at \(time)")
                }
            }
        }
    }
    
    // MARK: - Achievement Notifications

    /// Send a notification when an achievement is unlocked
    func sendAchievementNotification(achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.achievementUnlockedWithTrophy
        content.body = "\(achievement.name) - \(achievement.description)"
        content.sound = .default
        content.categoryIdentifier = NotificationType.achievementUnlocked.categoryIdentifier

        // Immediate trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(NotificationType.achievementUnlocked.rawValue)_\(achievement.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send achievement notification: \(error)")
            } else {
                print("✅ Achievement notification sent: \(achievement.name)")
            }
        }
    }

    #if DEBUG
    /// Debug utilities for testing notification scheduling
    func triggerProgressReportNow() {
        let content = UNMutableNotificationContent()
        content.title = "Progress Report (TEST)"
        content.body = "This is a test notification fired immediately"
        content.sound = .default
        content.categoryIdentifier = NotificationType.progressReport.categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationType.progressReport.rawValue + "_debug",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Failed to trigger test notification: \(error)")
            } else {
                print("DEBUG: Test progress report scheduled")
            }
        }
    }
    
    func listScheduledNotifications() -> [UNNotificationRequest] {
        var result: [UNNotificationRequest] = []
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            result = requests
            print("=== Scheduled Notifications ===")
            for request in requests {
                print("ID: \(request.identifier)")
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  Fires in: \(trigger.timeInterval) seconds")
                }
            }
            if requests.isEmpty {
                print("  (none scheduled)")
            }
        }
        return result
    }
    #endif
    
}
