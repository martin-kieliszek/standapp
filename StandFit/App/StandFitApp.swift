//
//  StandFitApp.swift
//  StandFit iOS
//
//  iOS app entry point with notification handling
//

import SwiftUI
import UserNotifications
import BackgroundTasks
import StandFitCore

@main
struct StandFitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var exerciseStore = ExerciseStore.shared
    @State private var showInitialOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showInitialOnboarding) {
                    OnboardingView(store: exerciseStore, isInitialOnboarding: true)
                }
                .onAppear {
                    // Check if user has completed onboarding
                    let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                    if !hasCompletedOnboarding {
                        // Small delay to let the app settle before showing onboarding
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showInitialOnboarding = true
                        }
                    }
                }
        }
    }
}

// MARK: - Notification Names (shared with ContentView)

extension Notification.Name {
    static let showExercisePicker = Notification.Name("showExercisePicker")
    static let showWeeklyInsights = Notification.Name("showWeeklyInsights")
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Background Task Identifiers
    private static let backgroundRefreshIdentifier = "com.standfit.notification-refresh"

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

        // Register background refresh task
        registerBackgroundTasks()

        // Request notification permissions and build initial queue
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    // Build initial notification queue
                    await NotificationQueueManager.shared.ensureNotificationQueue(store: ExerciseStore.shared)
                    print("✅ Initial notification queue built")
                }
            } catch {
                print("❌ Notification authorization error: \(error)")
            }
        }

        // Request Focus Status authorization (iOS 15+)
        if #available(iOS 15.0, *) {
            FocusStatusManager.shared.requestAuthorization()
        }

        // ✅ Monitor app lifecycle to ensure notifications stay scheduled
        setupAppLifecycleMonitoring()

        // Schedule background refresh
        scheduleBackgroundRefresh()

        return true
    }

    // MARK: - Background Tasks

    /// Register background task handlers
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.backgroundRefreshIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
        print("✅ Background refresh task registered")
    }

    /// Handle background refresh - validate and refill notification queue
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        print("🔄 Background refresh started")

        // Set expiration handler
        task.expirationHandler = {
            print("⚠️ Background refresh expired")
            task.setTaskCompleted(success: false)
        }

        // Perform queue validation
        Task {
            await NotificationQueueManager.shared.ensureNotificationQueue(store: ExerciseStore.shared)
            print("✅ Background refresh completed - queue validated")
            task.setTaskCompleted(success: true)

            // Schedule next background refresh
            self.scheduleBackgroundRefresh()
        }
    }

    /// Schedule the next background refresh
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshIdentifier)
        // Request refresh in 4 hours (iOS will decide actual timing)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("📅 Background refresh scheduled for ~4 hours from now")
        } catch {
            print("⚠️ Failed to schedule background refresh: \(error)")
        }
    }
    
    // MARK: - App Lifecycle

    /// Monitor app entering foreground to ensure notification queue stays healthy
    private func setupAppLifecycleMonitoring() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.validateNotificationQueue()
        }
    }

    /// Validate and refill the notification queue when app enters foreground
    private func validateNotificationQueue() {
        print("📱 App entered foreground - validating notification queue")

        Task {
            let store = ExerciseStore.shared

            // Validate and refill exercise reminder queue
            await NotificationQueueManager.shared.ensureNotificationQueue(store: store)

            // Ensure progress report is scheduled
            let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            let hasProgressReport = pendingRequests.contains { request in
                NotificationIdentifier.isProgressReport(request.identifier)
            }

            if !hasProgressReport && store.progressReportSettings.enabled {
                print("⚠️ No progress report scheduled - scheduling one now")
                NotificationManager.shared.scheduleProgressReport(store: store)
            }

            // Update next scheduled time in store
            if let nextTime = await NotificationManager.shared.getNextReminderTime() {
                await MainActor.run {
                    store.nextScheduledNotificationTime = nextTime
                }
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

        let categoryId = notification.request.content.categoryIdentifier
        let identifier = notification.request.identifier

        // Log which notification fired
        print("🔔 Notification fired: \(NotificationIdentifier.description(for: identifier))")

        // For exercise reminders (including snooze) and dead response, schedule follow-up
        // NOTE: We do NOT need to schedule the next reminder - the queue is pre-built!
        if categoryId == NotificationType.exerciseReminder.categoryIdentifier ||
           categoryId == NotificationType.deadResponseReminder.categoryIdentifier {

            // Schedule follow-up in case user doesn't respond (dead response reset)
            NotificationManager.shared.scheduleFollowUpReminder(store: ExerciseStore.shared)
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
        if categoryIdentifier == NotificationType.exerciseReminder.categoryIdentifier ||
           categoryIdentifier == NotificationType.deadResponseReminder.categoryIdentifier {
            // Log Exercise button (same for both exercise reminder and dead response)
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

        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        let identifier = response.notification.request.identifier

        // Log the response
        print("👆 User responded to notification: \(NotificationIdentifier.description(for: identifier))")
        print("   Action: \(response.actionIdentifier)")

        // User responded - cancel any pending follow-up (they're not "dead")
        notificationManager.cancelFollowUpReminder()

        // NOTE: We do NOT need to reschedule - the notification queue is pre-built!
        // The next notification is already scheduled.

        // Handle actions based on action identifier
        switch response.actionIdentifier {
        case "LOG_EXERCISE":
            // User tapped "Log Exercise" - show exercise picker immediately
            notificationManager.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }

        case "SNOOZE":
            // User tapped "Snooze" - schedule snooze notification (uses reserved slot)
            notificationManager.snoozeReminder(seconds: 300, store: store)
            notificationManager.playClickHaptic()

        case "VIEW_REPORT":
            // User tapped "View Details" on progress report
            notificationManager.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showWeeklyInsights, object: nil)
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body itself - route based on category
            notificationManager.playClickHaptic()

            if categoryIdentifier == NotificationType.progressReport.categoryIdentifier {
                // Progress report notification → show weekly insights
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showWeeklyInsights, object: nil)
                }
            } else {
                // Exercise reminder → show exercise picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .showExercisePicker, object: nil)
                }
            }

        default:
            // User dismissed notification or other action
            break
        }
    }
}
