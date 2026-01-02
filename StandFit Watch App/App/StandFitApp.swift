//
//  StandFitApp.swift
//  StandFit Watch App
//
//  Created by Marty Kieliszek on 31/12/2025.
//

import SwiftUI
import UserNotifications

@main
struct StandFit_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self

        // Request notification permissions
        Task {
            do {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                DispatchQueue.main.async {
                    NotificationManager.shared.setupNotificationCategories()
                    // Ensure all notifications are scheduled on app launch
                    ExerciseStore.shared.updateAllNotificationSchedules(reason: "App launch")
                }
            } catch {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        NotificationManager.shared.playReminderHaptic()

        // Record that this notification was actually fired (for timeline tracking)
        NotificationFiredLog.shared.recordNotificationFired()

        // Schedule a follow-up in case user doesn't respond (dead response reset)
        NotificationManager.shared.scheduleFollowUpReminder(store: ExerciseStore.shared)

        return [.banner, .sound]
    }
    
    // Handle notification action responses
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
            // User tapped the notification itself - schedule next reminder
            notificationManager.scheduleReminderWithSchedule(store: store)
            notificationManager.playClickHaptic()

        default:
            break
        }
    }
    
}
