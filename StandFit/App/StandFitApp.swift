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
    static let showProgressReport = Notification.Name("showProgressReport")
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
        
        return true
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

        // ✅ Reschedule next notification immediately when this one is delivered
        // This ensures timer always keeps running regardless of user interaction
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
            alert.addAction(UIAlertAction(title: "Log Exercise", style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showExercisePicker, object: nil)
                }
            })
            
            // Snooze button
            alert.addAction(UIAlertAction(title: "Snooze 5 min", style: .default) { _ in
                NotificationManager.shared.scheduleReminderWithSchedule(store: ExerciseStore.shared)
                NotificationManager.shared.playClickHaptic()
            })
        } else if categoryIdentifier == NotificationType.progressReport.categoryIdentifier {
            // View Details button
            alert.addAction(UIAlertAction(title: "View Details", style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showProgressReport, object: nil)
                }
            })
        } else if categoryIdentifier == NotificationType.achievementUnlocked.categoryIdentifier {
            // View Achievements button
            alert.addAction(UIAlertAction(title: "View All", style: .default) { _ in
                NotificationManager.shared.playClickHaptic()
                // Navigate to achievements (or just dismiss for now)
            })
        }
        
        // Always add dismiss button
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
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

        // User responded - cancel any pending follow-up
        notificationManager.cancelFollowUpReminder()

        switch response.actionIdentifier {
        case "LOG_EXERCISE":
            // User tapped "Log Exercise" - show exercise picker immediately
            notificationManager.playClickHaptic()
            // Post notification to show exercise picker (slight delay to ensure view is ready)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }

        case "SNOOZE":
            // User tapped "Snooze" - reschedule for next interval
            notificationManager.scheduleReminderWithSchedule(store: store)
            notificationManager.playClickHaptic()

        case "VIEW_REPORT":
            // User tapped "View Details" on progress report
            notificationManager.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showProgressReport, object: nil)
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself - open exercise picker and reschedule
            notificationManager.playClickHaptic()
            notificationManager.scheduleReminderWithSchedule(store: store)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }

        default:
            break
        }
    }
}
