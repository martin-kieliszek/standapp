//
//  StandFitApp.swift
//  StandFit iOS
//
//  iOS app entry point with notification handling
//

import SwiftUI
import UserNotifications
import StandFitCore

@main
struct StandFitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Notification Names (shared with ContentView)

extension Notification.Name {
    static let showExercisePicker = Notification.Name("showExercisePicker")
    static let showWeeklyInsights = Notification.Name("showWeeklyInsights")
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up notification center delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = self

        // ✅ CRITICAL: Setup notification categories BEFORE requesting permissions
        // This ensures actions are available for any notifications
        NotificationManager.shared.setupNotificationCategories()
        print("✅ Notification categories registered on app launch")

        // Request notification permissions
        Task {
            do {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                DispatchQueue.main.async {
                    // Ensure all notifications are scheduled on app launch
                    ExerciseStore.shared.updateAllNotificationSchedules(reason: "App launch")
                }
            } catch {
                print("Notification authorization error: \(error)")
            }
        }
        
        // Request Focus Status authorization (iOS 15+)
        if #available(iOS 15.0, *) {
            FocusStatusManager.shared.requestAuthorization()
        }
        
        // ✅ Monitor app lifecycle to ensure notifications stay scheduled
        setupAppLifecycleMonitoring()
        
        return true
    }
    
    /// Monitor app entering foreground to ensure notification chain stays active
    private func setupAppLifecycleMonitoring() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.ensureNotificationChainActive()
        }
    }
    
    /// Check if there's a pending exercise reminder notification, schedule one if missing
    private func ensureNotificationChainActive() {
        Task {
            let center = UNUserNotificationCenter.current()
            let pendingRequests = await center.pendingNotificationRequests()
            
            // Check if there's a pending exercise reminder
            let hasExerciseReminder = pendingRequests.contains { request in
                request.identifier == NotificationType.exerciseReminder.rawValue
            }
            
            if !hasExerciseReminder {
                print("⚠️ No exercise reminder scheduled - scheduling one now")
                NotificationManager.shared.scheduleReminderWithSchedule(store: ExerciseStore.shared)
            } else {
                print("✅ Exercise reminder is scheduled")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        NotificationManager.shared.playReminderHaptic()

        // Record that this notification was actually fired (for timeline tracking)
        NotificationFiredLog.shared.recordNotificationFired()

        // Schedule a follow-up in case user doesn't respond (dead response reset)
        NotificationManager.shared.scheduleFollowUpReminder(store: ExerciseStore.shared)

        // ✅ When notification fires, schedule next one using normal schedule
        // This applies whether it was a regular notification or a snoozed one
        if notification.request.content.categoryIdentifier == NotificationType.exerciseReminder.categoryIdentifier {
            NotificationManager.shared.scheduleReminderWithSchedule(store: ExerciseStore.shared)
        }

        // Show alert with action buttons for better UX (iOS banners hide actions)
        await showNotificationAlert(for: notification)

        return [.banner, .sound, .badge]
    }
    
    /// Show an alert dialog with action buttons for notifications in foreground
    private func showNotificationAlert(for notification: UNNotification) async {
        let content = notification.request.content
        let categoryIdentifier = content.categoryIdentifier
        
        // Create alert controller
        let alert = UIAlertController(
            title: content.title,
            message: content.body,
            preferredStyle: .alert
        )
        
        // Add actions based on category
        if categoryIdentifier == NotificationType.exerciseReminder.categoryIdentifier {
            // Log Exercise button
            alert.addAction(UIAlertAction(title: LocalizedString.Notifications.actionLogExercise, style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showExercisePicker, object: nil)
                }
            })
            
            // Snooze button
            alert.addAction(UIAlertAction(title: LocalizedString.Notifications.actionSnooze5Min, style: .default) { _ in
                NotificationManager.shared.snoozeReminder(seconds: 300, store: ExerciseStore.shared)
                NotificationManager.shared.playClickHaptic()
            })
        } else if categoryIdentifier == NotificationType.progressReport.categoryIdentifier {
            // View Details button
            alert.addAction(UIAlertAction(title: LocalizedString.Notifications.actionViewDetails, style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showWeeklyInsights, object: nil)
                }
            })
        } else if categoryIdentifier == NotificationType.achievementUnlocked.categoryIdentifier {
            // View Achievements button
            alert.addAction(UIAlertAction(title: LocalizedString.Notifications.actionViewAll, style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                // Navigate to achievements (or just dismiss for now)
            })
        }
        
        // Always add dismiss button
        alert.addAction(UIAlertAction(title: LocalizedString.Notifications.actionDismiss, style: .cancel))
        
        // Present on main window
        await MainActor.run {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
    
    /// Handle notification action responses (taps and button actions)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let notificationManager = NotificationManager.shared
        let store = ExerciseStore.shared

        // Record that this notification was delivered (for background notifications)
        // This captures the timestamp when user interacted with it
        NotificationFiredLog.shared.recordNotificationFired()

        // User responded - cancel any pending follow-up
        notificationManager.cancelFollowUpReminder()
        
        // ✅ CRITICAL: Schedule next notification regardless of which action was taken
        // This ensures notification chain continues even if user dismisses/ignores
        // Only do this for exercise reminders (not progress reports or achievements)
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        if categoryIdentifier == NotificationType.exerciseReminder.categoryIdentifier {
            // Don't schedule if user snoozed (snooze handles its own scheduling)
            if response.actionIdentifier != "SNOOZE" {
                notificationManager.scheduleReminderWithSchedule(store: store)
            }
        }

        switch response.actionIdentifier {
        case "LOG_EXERCISE":
            // User tapped "Log Exercise" - show exercise picker immediately
            notificationManager.playClickHaptic()
            // Post notification to show exercise picker (slight delay to ensure view is ready)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }

        case "SNOOZE":
            // User tapped "Snooze" - schedule notification in 5 minutes (300 seconds)
            // Note: Snooze handles its own scheduling, so we skip the auto-schedule above
            notificationManager.snoozeReminder(seconds: 300, store: store)
            notificationManager.playClickHaptic()

        case "VIEW_REPORT":
            // User tapped "View Details" on progress report
            notificationManager.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showWeeklyInsights, object: nil)
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself - open exercise picker
            // (Next notification already scheduled above)
            notificationManager.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }

        default:
            // User dismissed notification or other action
            // (Next notification already scheduled above)
            break
        }
    }
}
