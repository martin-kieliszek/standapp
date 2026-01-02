import Foundation

/// A time block with specific reminder settings for a portion of the day
public struct TimeBlock: Codable, Identifiable, Hashable {
    public let id: UUID
    public var name: String?
    public var startHour: Int
    public var startMinute: Int
    public var endHour: Int
    public var endMinute: Int
    public var intervalMinutes: Int
    public var randomizationRange: Int?
    public var icon: String?
    public var notificationStyle: NotificationStyle
    
    public init(
        id: UUID = UUID(),
        name: String? = nil,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        intervalMinutes: Int,
        randomizationRange: Int? = nil,
        icon: String? = nil,
        notificationStyle: NotificationStyle = .standard
    ) {
        self.id = id
        self.name = name
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.intervalMinutes = intervalMinutes
        self.randomizationRange = randomizationRange
        self.icon = icon
        self.notificationStyle = notificationStyle
    }
    
    public enum NotificationStyle: String, Codable {
        case standard
        case gentle
        case urgent
    }
    
    /// Total minutes from midnight for start time
    public var startMinutes: Int {
        startHour * 60 + startMinute
    }
    
    /// Total minutes from midnight for end time
    public var endMinutes: Int {
        endHour * 60 + endMinute
    }
    
    /// Check if a given time (in minutes from midnight) falls within this block
    public func contains(minutes: Int) -> Bool {
        return minutes >= startMinutes && minutes < endMinutes
    }
    
    /// Check if this time block overlaps with another
    public func overlaps(with other: TimeBlock) -> Bool {
        return !(self.endMinutes <= other.startMinutes || self.startMinutes >= other.endMinutes)
    }
    
    /// Duration of the time block in minutes
    public var durationMinutes: Int {
        return endMinutes - startMinutes
    }
    
    /// Estimated number of reminders in this block
    public var estimatedReminderCount: Int {
        return max(0, durationMinutes / intervalMinutes)
    }
}
