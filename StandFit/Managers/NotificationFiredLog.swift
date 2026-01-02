//
//  NotificationFiredLog.swift
//  StandFit iOS
//
//  Tracks when notifications were actually fired with persistent storage
//

import Foundation
import Combine
import StandFitCore

/// Persistent storage for tracking when notifications were actually delivered
/// Records are saved to disk and kept for the current day only
class NotificationFiredLog: ObservableObject {
    static let shared = NotificationFiredLog()

    @Published private(set) var todaysFiredNotifications: [Date] = []

    private let storageKey = "notification_fired_log"
    private let fileManager = FileManager.default
    private var logFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("notification_fired_log.json")
    }

    private init() {
        loadFromDisk()
        cleanupOldRecords()
    }

    /// Record that a notification was fired at a specific time
    func recordNotificationFired(at timestamp: Date = Date()) {
        todaysFiredNotifications.append(timestamp)
        cleanupOldRecords()
        saveToDisk()

        print("📝 Notification fired recorded at \(timestamp.formatted(date: .omitted, time: .standard))")
    }

    /// Remove records from previous days to keep storage minimal
    private func cleanupOldRecords() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let beforeCount = todaysFiredNotifications.count
        todaysFiredNotifications = todaysFiredNotifications.filter { timestamp in
            timestamp >= today
        }

        let afterCount = todaysFiredNotifications.count
        if beforeCount != afterCount {
            print("🧹 Cleaned up \(beforeCount - afterCount) old notification records")
            saveToDisk()
        }
    }

    /// Get all fired notifications as timeline events
    func getTimelineEvents() -> [TimelineEvent] {
        todaysFiredNotifications.map { timestamp in
            TimelineEvent(timestamp: timestamp, type: .notificationFired)
        }
    }

    /// Clear all records (useful for testing or privacy)
    func clearAll() {
        todaysFiredNotifications.removeAll()
        saveToDisk()
        print("🗑️ All notification records cleared")
    }

    // MARK: - Persistence

    private func saveToDisk() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(todaysFiredNotifications)
            try data.write(to: logFileURL, options: .atomic)
            print("💾 Saved \(todaysFiredNotifications.count) notification records to disk")
        } catch {
            print("❌ Failed to save notification log: \(error)")
        }
    }

    private func loadFromDisk() {
        guard fileManager.fileExists(atPath: logFileURL.path) else {
            print("ℹ️ No existing notification log found, starting fresh")
            return
        }

        do {
            let data = try Data(contentsOf: logFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            todaysFiredNotifications = try decoder.decode([Date].self, from: data)
            print("📂 Loaded \(todaysFiredNotifications.count) notification records from disk")
        } catch {
            print("❌ Failed to load notification log: \(error)")
            todaysFiredNotifications = []
        }
    }
}
