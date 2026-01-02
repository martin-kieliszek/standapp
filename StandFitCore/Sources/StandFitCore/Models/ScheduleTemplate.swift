import Foundation

/// Pre-defined schedule templates for common use cases
public struct ScheduleTemplate: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let profile: ScheduleProfile
    
    public init(id: String, name: String, description: String, icon: String, profile: ScheduleProfile) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.profile = profile
    }
}

public enum ScheduleTemplates {
    /// Built-in template library
    public static let all: [ScheduleTemplate] = [
        officeWorker,
        remoteWorker,
        athleteTraining,
        wellnessRecovery,
        weekendWarrior,
        minimalist,
        everyDay
    ]
    
    /// Office Worker: Mon-Fri 9am-5pm with lunch break
    public static let officeWorker = ScheduleTemplate(
        id: "office-worker",
        name: "Office Worker",
        description: "Mon-Fri work hours with lunch break",
        icon: "briefcase.fill",
        profile: {
            var profile = ScheduleProfile(name: "Office Worker", fallbackInterval: 30)
            
            // Monday through Friday
            for weekday in 2...6 {
                let morningBlock = TimeBlock(
                    name: "Morning",
                    startHour: 9, startMinute: 0,
                    endHour: 12, endMinute: 0,
                    intervalMinutes: 20,
                    icon: "sun.max.fill"
                )
                
                let afternoonBlock = TimeBlock(
                    name: "Afternoon",
                    startHour: 13, startMinute: 0,
                    endHour: 17, endMinute: 0,
                    intervalMinutes: 30,
                    icon: "briefcase.fill"
                )
                
                let eveningBlock = TimeBlock(
                    name: "Evening",
                    startHour: 18, startMinute: 0,
                    endHour: 21, endMinute: 0,
                    intervalMinutes: 60,
                    icon: "moon.fill",
                    notificationStyle: .gentle
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([morningBlock, afternoonBlock, eveningBlock])
                )
            }
            
            return profile
        }()
    )
    
    /// Remote/Flexible Worker
    public static let remoteWorker = ScheduleTemplate(
        id: "remote-worker",
        name: "Remote Worker",
        description: "Flexible schedule for remote work",
        icon: "house.fill",
        profile: {
            var profile = ScheduleProfile(name: "Remote Worker", fallbackInterval: 30)
            
            // Monday through Friday
            for weekday in 2...6 {
                let workBlock = TimeBlock(
                    name: "Work Hours",
                    startHour: 8, startMinute: 0,
                    endHour: 18, endMinute: 0,
                    intervalMinutes: 30,
                    icon: "laptopcomputer"
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([workBlock])
                )
            }
            
            // Weekends - lighter schedule
            for weekday in [1, 7] {
                let weekendBlock = TimeBlock(
                    name: "Weekend",
                    startHour: 10, startMinute: 0,
                    endHour: 16, endMinute: 0,
                    intervalMinutes: 45,
                    icon: "sun.max.fill",
                    notificationStyle: .gentle
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([weekendBlock])
                )
            }
            
            return profile
        }()
    )
    
    /// Athlete/Training Mode
    public static let athleteTraining = ScheduleTemplate(
        id: "athlete-training",
        name: "Training Mode",
        description: "Intensive training schedule",
        icon: "figure.run",
        profile: {
            var profile = ScheduleProfile(name: "Training Mode", fallbackInterval: 15)
            
            // All days - intensive
            for weekday in 1...7 {
                let trainingBlock = TimeBlock(
                    name: "Training",
                    startHour: 6, startMinute: 0,
                    endHour: 20, endMinute: 0,
                    intervalMinutes: 15,
                    icon: "figure.run"
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([trainingBlock])
                )
            }
            
            return profile
        }()
    )
    
    /// Wellness/Recovery Mode
    public static let wellnessRecovery = ScheduleTemplate(
        id: "wellness-recovery",
        name: "Recovery Mode",
        description: "Gentle reminders for rest days",
        icon: "leaf.fill",
        profile: {
            var profile = ScheduleProfile(name: "Recovery Mode", fallbackInterval: 90)
            
            // All days - gentle
            for weekday in 1...7 {
                let recoveryBlock = TimeBlock(
                    name: "Gentle Movement",
                    startHour: 10, startMinute: 0,
                    endHour: 18, endMinute: 0,
                    intervalMinutes: 90,
                    icon: "leaf.fill",
                    notificationStyle: .gentle
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([recoveryBlock])
                )
            }
            
            return profile
        }()
    )
    
    /// Weekend Warrior
    public static let weekendWarrior = ScheduleTemplate(
        id: "weekend-warrior",
        name: "Weekend Warrior",
        description: "Active weekends only",
        icon: "calendar",
        profile: {
            var profile = ScheduleProfile(name: "Weekend Warrior", fallbackInterval: 30)
            
            // Only weekends
            for weekday in [1, 7] {
                let weekendBlock = TimeBlock(
                    name: "Weekend Activity",
                    startHour: 8, startMinute: 0,
                    endHour: 18, endMinute: 0,
                    intervalMinutes: 30,
                    icon: "figure.hiking"
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([weekendBlock])
                )
            }
            
            return profile
        }()
    )
    
    /// Minimalist - Fixed times only
    public static let minimalist = ScheduleTemplate(
        id: "minimalist",
        name: "Minimalist",
        description: "3 reminders per day",
        icon: "minus.circle.fill",
        profile: {
            var profile = ScheduleProfile(name: "Minimalist", fallbackInterval: 240)
            
            // All days - 3 fixed reminders
            for weekday in 1...7 {
                let reminders = [
                    FixedReminder(hour: 9, minute: 0, label: "Morning"),
                    FixedReminder(hour: 13, minute: 0, label: "Afternoon"),
                    FixedReminder(hour: 18, minute: 0, label: "Evening")
                ]
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .fixedTimes(reminders)
                )
            }
            
            return profile
        }()
    )
    
    /// Every Day - Simple consistent schedule
    public static let everyDay = ScheduleTemplate(
        id: "every-day",
        name: "Every Day",
        description: "Consistent daily routine",
        icon: "repeat",
        profile: {
            var profile = ScheduleProfile(name: "Every Day", fallbackInterval: 30)
            
            // All days - same schedule
            for weekday in 1...7 {
                let dailyBlock = TimeBlock(
                    name: "Active Hours",
                    startHour: 9, startMinute: 0,
                    endHour: 21, endMinute: 0,
                    intervalMinutes: 30,
                    icon: "clock.fill"
                )
                
                profile.dailySchedules[weekday] = DailySchedule(
                    enabled: true,
                    scheduleType: .timeBlocks([dailyBlock])
                )
            }
            
            return profile
        }()
    )
}
