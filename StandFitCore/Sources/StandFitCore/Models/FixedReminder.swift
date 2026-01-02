import Foundation

/// A fixed-time reminder that fires at a specific time each day
public struct FixedReminder: Codable, Identifiable, Hashable {
    public let id: UUID
    public var hour: Int
    public var minute: Int
    public var label: String?
    public var smartSpacing: Bool
    
    public init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        label: String? = nil,
        smartSpacing: Bool = false
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.label = label
        self.smartSpacing = smartSpacing
    }
    
    /// Total minutes from midnight
    public var totalMinutes: Int {
        hour * 60 + minute
    }
    
    /// Formatted time string (e.g., "9:00 AM")
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        
        return "\(hour):\(String(format: "%02d", minute))"
    }
}
