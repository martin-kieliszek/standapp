import Foundation

/// Schedule configuration for a single day of the week
public struct DailySchedule: Codable, Hashable {
    public var enabled: Bool
    public var scheduleType: ScheduleType
    
    public init(enabled: Bool = true, scheduleType: ScheduleType = .useFallback) {
        self.enabled = enabled
        self.scheduleType = scheduleType
    }
    
    public enum ScheduleType: Codable, Hashable {
        case timeBlocks([TimeBlock])
        case fixedTimes([FixedReminder])
        case useFallback
    }
    
    /// Get all time blocks if this schedule uses them
    public var timeBlocks: [TimeBlock]? {
        if case .timeBlocks(let blocks) = scheduleType {
            return blocks
        }
        return nil
    }
    
    /// Get all fixed reminders if this schedule uses them
    public var fixedReminders: [FixedReminder]? {
        if case .fixedTimes(let reminders) = scheduleType {
            return reminders
        }
        return nil
    }
    
    /// Estimated total reminders for this day
    public func estimatedReminderCount(fallbackInterval: Int) -> Int {
        guard enabled else { return 0 }
        
        switch scheduleType {
        case .timeBlocks(let blocks):
            return blocks.reduce(0) { $0 + $1.estimatedReminderCount }
        case .fixedTimes(let reminders):
            return reminders.count
        case .useFallback:
            // Assume 16 hour day with fallback interval
            return (16 * 60) / fallbackInterval
        }
    }
}
