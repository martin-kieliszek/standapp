//
//  NotificationQueueManager.swift
//  StandFit iOS
//
//  Core batch scheduling logic for reliable notifications.
//  Pre-schedules up to 58 exercise reminders to ensure notifications fire
//  even when the app isn't running.
//

import Foundation
import UserNotifications
import Combine
import StandFitCore

/// Manages the notification queue with batch scheduling for reliability
class NotificationQueueManager: ObservableObject {
    static let shared = NotificationQueueManager()

    // MARK: - Published State

    /// Number of exercise reminders currently pending
    @Published private(set) var pendingExerciseCount: Int = 0

    /// Last time the queue was validated
    @Published private(set) var lastValidationTime: Date?

    /// Indicates if a queue operation is in progress
    @Published private(set) var isProcessing: Bool = false

    // MARK: - Private Properties

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Public API

    /// Ensure the notification queue is properly populated.
    /// Call this on app launch, foreground, and background refresh.
    /// This is a non-destructive operation - it only adds missing notifications.
    func ensureNotificationQueue(store: ExerciseStore) async {
        guard store.remindersEnabled else {
            print("📵 Reminders disabled - skipping queue validation")
            return
        }

        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        let pendingRequests = await center.pendingNotificationRequests()

        // Count only exercise reminders
        let exerciseReminders = pendingRequests.filter {
            NotificationIdentifier.isExerciseReminder($0.identifier)
        }

        let currentCount = exerciseReminders.count

        await MainActor.run {
            pendingExerciseCount = currentCount
            lastValidationTime = Date()
        }

        print("📊 Queue validation: \(currentCount) exercise reminders pending")

        // Check if we need to refill
        if currentCount < NotificationIdentifier.refillThreshold {
            print("⚠️ Below threshold (\(NotificationIdentifier.refillThreshold)) - refilling queue")
            await refillQueue(
                store: store,
                existingReminders: exerciseReminders,
                targetCount: NotificationIdentifier.maxExerciseReminders
            )
        } else {
            print("✅ Queue is healthy (\(currentCount)/\(NotificationIdentifier.maxExerciseReminders))")
        }
    }

    /// Rebuild the entire notification queue from scratch.
    /// Call this when schedule profile changes or reminders are re-enabled.
    /// This cancels all exercise-related notifications and reschedules.
    func rebuildNotificationQueue(store: ExerciseStore) async {
        guard store.remindersEnabled else {
            print("📵 Reminders disabled - clearing queue instead of rebuilding")
            await clearExerciseRelatedNotifications()
            return
        }

        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        print("🔄 Rebuilding notification queue...")

        // 1. Cancel all exercise-related notifications (but NOT progress report)
        await clearExerciseRelatedNotifications()

        // 2. Calculate new reminder times based on current profile
        let reminderTimes = calculateUpcomingReminderTimes(
            store: store,
            from: Date(),
            maxCount: NotificationIdentifier.maxExerciseReminders
        )

        // 3. Schedule the new batch
        if !reminderTimes.isEmpty {
            await scheduleExerciseReminderBatch(times: reminderTimes)
        }

        await MainActor.run {
            pendingExerciseCount = reminderTimes.count
            lastValidationTime = Date()
        }

        print("✅ Queue rebuilt with \(reminderTimes.count) exercise reminders")
    }

    /// Clear all exercise-related notifications (exercise, snooze, dead response)
    /// Does NOT clear progress report or achievement notifications.
    func clearExerciseRelatedNotifications() async {
        let pendingRequests = await center.pendingNotificationRequests()

        let exerciseRelatedIds = pendingRequests
            .map(\.identifier)
            .filter { NotificationIdentifier.isExerciseRelated($0) }

        if !exerciseRelatedIds.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: exerciseRelatedIds)
            print("🗑️ Cleared \(exerciseRelatedIds.count) exercise-related notifications")
        }

        await MainActor.run {
            pendingExerciseCount = 0
        }
    }

    /// Get debug information about the current queue state
    func getQueueDebugInfo() async -> QueueDebugInfo {
        let pendingRequests = await center.pendingNotificationRequests()

        let exerciseReminders = pendingRequests.filter {
            NotificationIdentifier.isExerciseReminder($0.identifier)
        }

        let snoozeReminders = pendingRequests.filter {
            NotificationIdentifier.isSnoozeReminder($0.identifier)
        }

        let hasDeadResponse = pendingRequests.contains {
            NotificationIdentifier.isDeadResponse($0.identifier)
        }

        let hasProgressReport = pendingRequests.contains {
            NotificationIdentifier.isProgressReport($0.identifier)
        }

        // Get next 5 exercise reminder times
        let upcomingTimes = exerciseReminders
            .compactMap { request -> Date? in
                NotificationIdentifier.date(from: request.identifier)
            }
            .sorted()
            .prefix(5)

        // Get the furthest scheduled time
        let furthestTime = exerciseReminders
            .compactMap { NotificationIdentifier.date(from: $0.identifier) }
            .max()

        return QueueDebugInfo(
            totalPending: pendingRequests.count,
            exerciseReminderCount: exerciseReminders.count,
            snoozeReminderCount: snoozeReminders.count,
            hasDeadResponse: hasDeadResponse,
            hasProgressReport: hasProgressReport,
            nextFiveReminderTimes: Array(upcomingTimes),
            furthestScheduledTime: furthestTime,
            lastValidationTime: lastValidationTime
        )
    }

    // MARK: - Private Methods

    /// Refill the queue with additional notifications
    private func refillQueue(
        store: ExerciseStore,
        existingReminders: [UNNotificationRequest],
        targetCount: Int
    ) async {
        // Find the latest scheduled time to continue from there
        let existingTimes = Set(existingReminders.compactMap {
            NotificationIdentifier.date(from: $0.identifier)
        })

        let latestScheduledTime = existingTimes.max() ?? Date()
        let slotsNeeded = targetCount - existingReminders.count

        guard slotsNeeded > 0 else { return }

        // Calculate new times starting after the latest existing one
        let newTimes = calculateUpcomingReminderTimes(
            store: store,
            from: latestScheduledTime.addingTimeInterval(60),
            maxCount: slotsNeeded,
            excludingTimes: existingTimes
        )

        if !newTimes.isEmpty {
            await scheduleExerciseReminderBatch(times: newTimes)

            await MainActor.run {
                pendingExerciseCount = existingReminders.count + newTimes.count
            }

            print("✅ Added \(newTimes.count) notifications, total now: \(existingReminders.count + newTimes.count)")
        } else {
            print("ℹ️ No additional times available to schedule (profile may have limited hours/days)")
        }
    }

    /// Calculate upcoming reminder times based on the current schedule profile
    func calculateUpcomingReminderTimes(
        store: ExerciseStore,
        from startDate: Date = Date(),
        maxCount: Int = NotificationIdentifier.maxExerciseReminders,
        excludingTimes: Set<Date> = []
    ) -> [Date] {
        var reminderTimes: [Date] = []
        var currentDate = startDate
        let maxEndDate = startDate.addingTimeInterval(
            TimeInterval(NotificationIdentifier.maxDaysAhead * 24 * 60 * 60)
        )

        // Safety limit to prevent infinite loops
        var iterations = 0
        let maxIterations = maxCount * 100

        while reminderTimes.count < maxCount && iterations < maxIterations {
            iterations += 1

            guard let nextTime = calculateNextReminderTime(store: store, from: currentDate) else {
                break // No more valid times based on profile
            }

            // Don't go beyond max days ahead
            if nextTime > maxEndDate {
                break
            }

            // Skip if this time is already scheduled
            // Round to minute for comparison
            let roundedTime = Calendar.current.date(
                bySetting: .second, value: 0, of: nextTime
            ) ?? nextTime

            if !excludingTimes.contains(roundedTime) {
                reminderTimes.append(roundedTime)
            }

            // Move past this time for next iteration
            currentDate = nextTime.addingTimeInterval(60)
        }

        return reminderTimes
    }

    /// Calculate next reminder time using the active profile's schedule
    /// This is a copy of NotificationManager's logic to avoid circular dependency
    private func calculateNextReminderTime(store: ExerciseStore, from date: Date) -> Date? {
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
                    var interval = matchingBlock.intervalMinutes

                    // Apply randomization if enabled
                    if let randomRange = matchingBlock.randomizationRange {
                        let randomOffset = Int.random(in: -randomRange...randomRange)
                        interval = max(1, interval + randomOffset)
                    }

                    let nextTime = candidateTime.addingTimeInterval(TimeInterval(interval * 60))

                    // Check if next time is still within this block
                    let nextHour = calendar.component(.hour, from: nextTime)
                    let nextMinute = calendar.component(.minute, from: nextTime)
                    let nextTotalMinutes = nextHour * 60 + nextMinute

                    if nextTotalMinutes < matchingBlock.endMinutes {
                        return nextTime
                    } else {
                        // Would exceed block - find next block or next day
                        candidateTime = calendar.date(
                            bySettingHour: matchingBlock.endHour,
                            minute: matchingBlock.endMinute,
                            second: 0,
                            of: candidateTime
                        ) ?? candidateTime.addingTimeInterval(3600)
                    }
                } else {
                    // Not in a block - jump to next block start
                    if let nextBlock = blocks.sorted(by: { $0.startMinutes < $1.startMinutes })
                        .first(where: { $0.startMinutes > currentMinutes }) {
                        // Jump to start of next block today
                        return calendar.date(
                            bySettingHour: nextBlock.startHour,
                            minute: nextBlock.startMinute,
                            second: 0,
                            of: candidateTime
                        )
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
                let sortedReminders = reminders.sorted { $0.totalMinutes < $1.totalMinutes }
                if let nextReminder = sortedReminders.first(where: { $0.totalMinutes > currentMinutes }) {
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

    /// Schedule a batch of exercise reminder notifications
    private func scheduleExerciseReminderBatch(times: [Date]) async {
        let content = UNMutableNotificationContent()
        content.title = LocalizedString.Notifications.timeToMoveTitle
        content.body = LocalizedString.Notifications.standUpExerciseBody
        content.sound = .default
        content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

        var scheduledCount = 0

        for time in times {
            let identifier = NotificationIdentifier.exerciseReminder(for: time)
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: time
            )
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
                scheduledCount += 1
            } catch {
                print("❌ Failed to schedule notification for \(time): \(error)")
            }
        }

        #if DEBUG
        if scheduledCount > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let firstTime = times.first.map { formatter.string(from: $0) } ?? "?"
            let lastTime = times.last.map { formatter.string(from: $0) } ?? "?"
            print("✅ Scheduled \(scheduledCount) exercise reminders from \(firstTime) to \(lastTime)")
        }
        #endif
    }
}

// MARK: - Debug Info Structure

/// Debug information about the notification queue state
struct QueueDebugInfo {
    let totalPending: Int
    let exerciseReminderCount: Int
    let snoozeReminderCount: Int
    let hasDeadResponse: Bool
    let hasProgressReport: Bool
    let nextFiveReminderTimes: [Date]
    let furthestScheduledTime: Date?
    let lastValidationTime: Date?

    var description: String {
        var lines: [String] = []
        lines.append("=== Notification Queue Status ===")
        lines.append("Total pending: \(totalPending)/64")
        lines.append("Exercise reminders: \(exerciseReminderCount)/\(NotificationIdentifier.maxExerciseReminders)")
        lines.append("Snooze reminders: \(snoozeReminderCount)")
        lines.append("Dead response: \(hasDeadResponse ? "scheduled" : "none")")
        lines.append("Progress report: \(hasProgressReport ? "scheduled" : "none")")

        if !nextFiveReminderTimes.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "E MMM d, h:mm a"
            lines.append("Next reminders:")
            for time in nextFiveReminderTimes {
                lines.append("  - \(formatter.string(from: time))")
            }
        }

        if let furthest = furthestScheduledTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "E MMM d, h:mm a"
            let daysAhead = Calendar.current.dateComponents([.day], from: Date(), to: furthest).day ?? 0
            lines.append("Furthest scheduled: \(formatter.string(from: furthest)) (\(daysAhead) days ahead)")
        }

        if let lastValidation = lastValidationTime {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            lines.append("Last validation: \(formatter.localizedString(for: lastValidation, relativeTo: Date()))")
        }

        return lines.joined(separator: "\n")
    }
}
