//
//  NotificationManager.swift
//  StandFit
//
//  Created by Marty Kieliszek on 31/12/2025.
//


import Foundation
import UserNotifications
import WatchKit
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
        UNUserNotificationCenter.current().getNotificationSettings{
            settings in DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Notification Categories (for action buttons)
       
    func setupNotificationCategories() {
        let logAction = UNNotificationAction(
            identifier: logExerciseActionID, title: "Log Exercise", options: .foreground)

        let snoozeAction = UNNotificationAction(identifier: snoozeActionID, title: "Snooze 5 min", options: [])

        let viewReportAction = UNNotificationAction(
            identifier: "VIEW_REPORT", title: "View Details", options: [.foreground])

        let viewAchievementsAction = UNNotificationAction(
            identifier: "VIEW_ACHIEVEMENTS", title: "View All", options: [.foreground])

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
        content.title = "Still there?"
        content.body = "You missed the last reminder. Time to move!"
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
     
    
    // MARK: HAPTIC FEEDBACK
    func playReminderHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
    
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    func playDirectionUpHaptic() {
        WKInterfaceDevice.current().play(.directionUp)
    }
    // MARK: - Scheduling
    
//    func scheduleReminder(inMinutes minutes: Int) {
//        cancelAllReminders()
//    
//        let content = UNMutableNotificationContent()
//        content.title = "Time to Move! 🏃"
//        content.body = "Stand up and do some quick exercises"
//        content.sound = .default
//        content.categoryIdentifier = reminderCategoryID
//
//        // Create trigger for N minutes from now
//        let trigger = UNTimeIntervalNotificationTrigger(
//          timeInterval: TimeInterval(minutes * 60),
//          repeats: false
//        )
//
//        // Create the request
//        let request = UNNotificationRequest(
//          identifier: "stand_reminder",
//          content: content,
//          trigger: trigger
//        )
//
//        // Schedule it
//        UNUserNotificationCenter.current().add(request) { error in
//          if let error = error {
//              print("Failed to schedule notification: \(error)")
//          } else {
//              print("Scheduled reminder for \(minutes) minutes from now")
//              self.debugPendingNotifications()  // Add this
//          }
//        }
//    }
    
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

        // Find next valid time
        guard let nextTime = store.nextValidReminderDate(afterMinutes: store.reminderIntervalMinutes) else {
            print("No valid reminder time found in the next week")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "Stand up and do some quick exercises"
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
        
        //Async version that would demand async contagion
//        do {
//            try await UNUserNotificationCenter.current().add(request)
//            print("Scheduled reminder for \(nextTime)")
//            store.nextScheduledNotificationTime = nextTime
//        } catch {
//            print("Failed to schedule notification: \(error)")
//        }
        
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
        content.title = "🏆 Achievement Unlocked!"
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
