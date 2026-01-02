import Foundation

/// A complete schedule profile with all settings
public struct ScheduleProfile: Codable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var createdDate: Date
    public var lastUsedDate: Date?
    
    // Global fallback settings
    public var fallbackInterval: Int
    public var deadResponseEnabled: Bool
    public var deadResponseMinutes: Int
    
    // Per-day schedules (1=Sunday, 2=Monday, ..., 7=Saturday in Calendar.current)
    public var dailySchedules: [Int: DailySchedule]
    
    public init(
        id: UUID = UUID(),
        name: String,
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        fallbackInterval: Int = 30,
        deadResponseEnabled: Bool = true,
        deadResponseMinutes: Int = 30,
        dailySchedules: [Int: DailySchedule] = [:]
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.fallbackInterval = fallbackInterval
        self.deadResponseEnabled = deadResponseEnabled
        self.deadResponseMinutes = deadResponseMinutes
        self.dailySchedules = dailySchedules
    }
    
    /// Get active days (weekdays where schedule is enabled)
    public var activeDays: Set<Int> {
        Set(dailySchedules.filter { $0.value.enabled }.keys)
    }
    
    /// Get schedule for a specific weekday
    public func schedule(for weekday: Int) -> DailySchedule? {
        return dailySchedules[weekday]
    }
    
    /// Check if a specific day is enabled
    public func isEnabled(weekday: Int) -> Bool {
        return dailySchedules[weekday]?.enabled ?? false
    }
    
    /// Estimated total reminders per week
    public var estimatedWeeklyReminderCount: Int {
        return dailySchedules.values.reduce(0) { 
            $0 + $1.estimatedReminderCount(fallbackInterval: fallbackInterval)
        }
    }
    
    /// Estimated daily average
    public var estimatedDailyAverage: Int {
        let enabledDays = activeDays.count
        guard enabledDays > 0 else { return 0 }
        return estimatedWeeklyReminderCount / enabledDays
    }
    
    /// Get a summary description of this profile
    public var summaryDescription: String {
        let enabledDays = activeDays.count
        if enabledDays == 0 {
            return "No active days"
        } else if enabledDays == 7 {
            return "Every day, \(estimatedDailyAverage) reminders/day"
        } else {
            let dayNames = activeDays.sorted().map { weekday in
                let formatter = DateFormatter()
                return formatter.shortWeekdaySymbols[weekday - 1]
            }.joined(separator: ", ")
            return "\(dayNames), \(estimatedDailyAverage) reminders/day"
        }
    }
}
