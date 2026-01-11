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

        // Dead response category uses same actions as exercise reminder
        let deadResponseCategory = UNNotificationCategory(
            identifier: NotificationType.deadResponseReminder.categoryIdentifier,
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

        UNUserNotificationCenter.current().setNotificationCategories([exerciseCategory, deadResponseCategory, reportCategory, achievementCategory])
        
        #if DEBUG
        print("✅ Registered 4 notification categories:")
        print("   - \(NotificationType.exerciseReminder.categoryIdentifier) with 2 actions")
        print("   - \(NotificationType.deadResponseReminder.categoryIdentifier) with 2 actions")
        print("   - \(NotificationType.progressReport.categoryIdentifier) with 1 action")
        print("   - \(NotificationType.achievementUnlocked.categoryIdentifier) with 1 action")
        #endif
    }
    
    /// Cancel all exercise-related reminders (exercise queue, snooze, dead response)
    /// Does NOT cancel progress reports - use cancelProgressReport() for that
    func cancelAllExerciseReminders() {
        Task {
            await NotificationQueueManager.shared.clearExerciseRelatedNotifications()
        }
    }

    /// Cancel only the dead response follow-up reminder
    func cancelFollowUpReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.deadResponse]
        )
    }

    /// Cancel only snooze reminders
    func cancelSnoozeReminders() {
        Task {
            let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            let snoozeIds = requests
                .map(\.identifier)
                .filter { NotificationIdentifier.isSnoozeReminder($0) }
            if !snoozeIds.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: snoozeIds)
            }
        }
    }

    /// Cancel progress report notification
    func cancelProgressReport() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.progressReport]
        )
    }
    
    /// Snooze the reminder for a specified number of seconds from now.
    /// This schedules a snooze notification using a reserved slot.
    /// The main exercise reminder queue remains intact - the next scheduled reminder will still fire.
    func snoozeReminder(seconds: Int, store: ExerciseStore) {
        // Cancel any pending follow-up (user explicitly snoozed)
        cancelFollowUpReminder()

        // Cancel any existing snooze reminder (only one snooze at a time)
        cancelSnoozeReminders()

        let snoozeTime = Date().addingTimeInterval(TimeInterval(seconds))

        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.timeToMoveTitle
        content.body = LocalizedString.Notifications.standUpExerciseBody
        content.sound = .default
        content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

        // Use time interval trigger for precise snooze timing
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )

        // Use snooze-specific identifier (doesn't overwrite exercise queue)
        let identifier = NotificationIdentifier.snoozeReminder(for: snoozeTime)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule snooze: \(error)")
            } else {
                print("✅ Snoozed reminder for \(seconds) seconds (will fire at \(snoozeTime))")
                print("   Snooze ID: \(identifier)")
                DispatchQueue.main.async {
                    store.nextScheduledNotificationTime = snoozeTime
                }
            }
        }
    }

    /// Extend the current timer by adding time to the next scheduled notification.
    /// This cancels the next scheduled notification and reschedules it later.
    func extendTimer(bySeconds seconds: Int, store: ExerciseStore) {
        Task {
            // Get the current next reminder time
            guard let currentNextTime = await getNextReminderTime() else {
                // No scheduled notification - fall back to snooze from now
                snoozeReminder(seconds: seconds, store: store)
                return
            }

            // Calculate new time by adding to the current scheduled time
            let newTime = currentNextTime.addingTimeInterval(TimeInterval(seconds))

            // Cancel the current next notification (could be exercise or snooze)
            await cancelNextScheduledNotification()

            // Schedule a new snooze notification at the extended time
            let content = UNMutableNotificationContent()
            content.title = LocalizedString.Notifications.timeToMoveTitle
            content.body = LocalizedString.Notifications.standUpExerciseBody
            content.sound = .default
            content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

            let identifier = NotificationIdentifier.snoozeReminder(for: newTime)
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: newTime
                ),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await UNUserNotificationCenter.current().add(request)
                print("✅ Extended timer by \(seconds)s: \(currentNextTime) → \(newTime)")
                await MainActor.run {
                    store.nextScheduledNotificationTime = newTime
                }
            } catch {
                print("❌ Failed to extend timer: \(error)")
            }
        }
    }

    /// Cancel the next scheduled notification (whether exercise or snooze)
    private func cancelNextScheduledNotification() async {
        guard let nextTime = await getNextReminderTime() else { return }

        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()

        // Find the notification that matches the next time
        for request in requests {
            if let date = NotificationIdentifier.date(from: request.identifier),
               abs(date.timeIntervalSince(nextTime)) < 60 { // Within 1 minute
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: [request.identifier]
                )
                print("🗑️ Cancelled next notification: \(request.identifier)")
                return
            }
        }
    }

    /// Schedule a follow-up reminder for dead response reset.
    /// This fires if the user doesn't respond to the main notification.
    /// Uses a single reserved slot (NotificationIdentifier.deadResponse).
    func scheduleFollowUpReminder(store: ExerciseStore) {
        guard store.deadResponseEnabled else { return }

        // Cancel any existing dead response first (only one at a time)
        cancelFollowUpReminder()

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
            identifier: NotificationIdentifier.deadResponse,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule follow-up: \(error)")
            } else {
                print("⏰ Scheduled dead response follow-up for \(store.deadResponseMinutes) minutes")
            }
        }
    }
    
    /// Get the next scheduled reminder time (from exercise queue or snooze)
    func getNextReminderTime() async -> Date? {
        let requests = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()

        // Find all exercise and snooze reminder times
        var upcomingTimes: [Date] = []

        for request in requests {
            let identifier = request.identifier

            // Check for batch-scheduled exercise reminders
            if NotificationIdentifier.isExerciseReminder(identifier) {
                if let date = NotificationIdentifier.date(from: identifier) {
                    upcomingTimes.append(date)
                }
            }
            // Check for snooze reminders
            else if NotificationIdentifier.isSnoozeReminder(identifier) {
                if let date = NotificationIdentifier.date(from: identifier) {
                    upcomingTimes.append(date)
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                          let triggerDate = trigger.nextTriggerDate() {
                    upcomingTimes.append(triggerDate)
                }
            }
        }

        // Return the soonest upcoming time
        return upcomingTimes.filter { $0 > Date() }.min()
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
    
    func playXPGainHaptic() {
        // Double tap for XP gain celebration
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred(intensity: 0.8)
        }
    }
    
    // MARK: - Scheduling

    /// Debug: Print all pending notifications with detailed info
    func debugPendingNotifications() {
        Task {
            let debugInfo = await NotificationQueueManager.shared.getQueueDebugInfo()
            print(debugInfo.description)
        }
    }

    /// Ensure the notification queue is properly populated.
    /// Call this on app launch, foreground, and when settings change.
    /// This is the primary method for managing exercise reminders.
    func ensureNotificationQueue(store: ExerciseStore) {
        Task {
            await NotificationQueueManager.shared.ensureNotificationQueue(store: store)

            // Update the next scheduled time in store
            if let nextTime = await getNextReminderTime() {
                await MainActor.run {
                    store.nextScheduledNotificationTime = nextTime
                }
            }
        }
    }

    /// Rebuild the entire notification queue from scratch.
    /// Call this when schedule profile changes or reminders are re-enabled.
    func rebuildNotificationQueue(store: ExerciseStore) {
        Task {
            await NotificationQueueManager.shared.rebuildNotificationQueue(store: store)

            // Update the next scheduled time in store
            if let nextTime = await getNextReminderTime() {
                await MainActor.run {
                    store.nextScheduledNotificationTime = nextTime
                }
            }
        }
    }

    /// @available(*, deprecated, message: "Use ensureNotificationQueue() or rebuildNotificationQueue() instead")
    /// Legacy single-notification scheduling - kept for backward compatibility during transition
    func scheduleReminderWithSchedule(store: ExerciseStore) {
        // Redirect to the new queue-based system
        ensureNotificationQueue(store: store)
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
            components.weekday = 1  // Sunday (1 = Sunday in Calendar.Component.weekday)
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true  // Automatically repeats daily (if only hour/minute) or weekly (if weekday set)
        )

        #if DEBUG
        print("📅 Progress report trigger created:")
        print("   - Frequency: \(store.progressReportSettings.frequency.displayName)")
        print("   - Components: hour=\(components.hour ?? -1), minute=\(components.minute ?? -1), weekday=\(components.weekday ?? -1)")
        print("   - Next trigger: \(trigger.nextTriggerDate() ?? Date())")
        #endif

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.progressReport,
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
            identifier: NotificationIdentifier.achievement(id: achievement.id),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send achievement notification: \(error)")
            } else {
                print("🏆 Achievement notification sent: \(achievement.name)")
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
            identifier: "\(NotificationIdentifier.progressReport)_debug",
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

    /// Trigger an exercise reminder immediately for testing
    func triggerExerciseReminderNow() {
        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.timeToMoveTitle
        content.body = "This is a test notification"
        content.sound = .default
        content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = NotificationIdentifier.exerciseReminder(for: Date())

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Failed to trigger test exercise reminder: \(error)")
            } else {
                print("DEBUG: Test exercise reminder scheduled with ID: \(identifier)")
            }
        }
    }

    /// List all scheduled notifications with detailed info
    func listScheduledNotifications() async -> [UNNotificationRequest] {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()

        print("=== Scheduled Notifications (\(requests.count) total) ===")

        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM d, h:mm a"

        for request in requests {
            let identifier = request.identifier
            let description = NotificationIdentifier.description(for: identifier)

            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextDate = calendarTrigger.nextTriggerDate() {
                print("  \(description) → \(formatter.string(from: nextDate))")
            } else if let intervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                      let nextDate = intervalTrigger.nextTriggerDate() {
                print("  \(description) → \(formatter.string(from: nextDate))")
            } else if let date = NotificationIdentifier.date(from: identifier) {
                print("  \(description) → \(formatter.string(from: date))")
            } else {
                print("  \(description)")
            }
        }

        if requests.isEmpty {
            print("  (none scheduled)")
        }

        return requests
    }

    /// Get queue debug info asynchronously
    func getQueueDebugInfo() async -> QueueDebugInfo {
        return await NotificationQueueManager.shared.getQueueDebugInfo()
    }
    #endif
    
}
