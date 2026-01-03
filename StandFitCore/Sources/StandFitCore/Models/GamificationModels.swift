//
//  GamificationModels.swift
//  StandFitCore
//
//  Gamification system data models supporting achievements, streaks, levels, and challenges
//  Designed for extensibility and future feature additions
//

import Foundation

// MARK: - Achievement System

/// Represents an unlockable achievement with progress tracking
public struct Achievement: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String  // SF Symbol name
    public let category: AchievementCategory
    public let tier: AchievementTier
    public let requirement: AchievementRequirement
    public var unlockedAt: Date?
    public var progress: Int  // Current progress toward requirement

    public var isUnlocked: Bool { unlockedAt != nil }

    /// Calculate progress percentage (0.0 to 1.0)
    public var progressPercent: Double {
        let target = requirement.targetValue
        guard target > 0 else { return isUnlocked ? 1.0 : 0.0 }
        return min(Double(progress) / Double(target), 1.0)
    }

    /// Get the target value from the requirement
    public var targetValue: Int {
        requirement.targetValue
    }

    public init(
        id: String,
        name: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        tier: AchievementTier,
        requirement: AchievementRequirement,
        unlockedAt: Date? = nil,
        progress: Int = 0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.tier = tier
        self.requirement = requirement
        self.unlockedAt = unlockedAt
        self.progress = progress
    }

    public static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

/// Categories for organizing achievements
public enum AchievementCategory: String, Codable, CaseIterable, Identifiable {
    case milestone = "Milestone"
    case consistency = "Consistency"
    case volume = "Volume"
    case variety = "Variety"
    case challenge = "Challenge"
    case social = "Social"
    case template = "Custom Templates"  // UX16: User-created achievements

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .milestone: return "flag.fill"
        case .consistency: return "flame.fill"
        case .volume: return "chart.bar.fill"
        case .variety: return "circle.hexagongrid.fill"
        case .challenge: return "trophy.fill"
        case .social: return "person.2.fill"
        case .template: return "star.square.on.square.fill"
        }
    }
}

/// Tiers for achievement rarity/difficulty
public enum AchievementTier: String, Codable, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"

    public var sortOrder: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 1
        case .gold: return 2
        case .platinum: return 3
        }
    }
}

/// Defines what needs to be accomplished to unlock an achievement
public enum AchievementRequirement: Codable, Equatable {
    case totalSessions(Int)            // Total exercise SESSIONS (log entries) across all types
    case exerciseVolume(String, Int)   // Total REPS/SECONDS for specific exercise type
    case streak(Int)                   // Maintain streak for N days
    case unique(Int)                   // Unique exercise types in one day
    case timeWindow(hour: Int, comparison: TimeComparison, count: Int)  // Exercise sessions before/after specific hour
    case dailyGoal(Int)                // Complete N exercise sessions in one day

    // Template-based requirements (UX16)
    case customExerciseCount(exerciseReference: ExerciseReference, count: Int)  // Total count for specific exercise (built-in or custom)
    case dailyExerciseGoal(exerciseReference: ExerciseReference, count: Int)    // Specific exercise count in one day
    case weeklyExerciseGoal(exerciseReference: ExerciseReference, count: Int)   // Specific exercise count in one week
    case exerciseStreak(exerciseReference: ExerciseReference, days: Int)        // Consecutive days with specific exercise
    case speedChallenge(exerciseReference: ExerciseReference, count: Int, timeWindowMinutes: Int)  // N reps in M minutes

    public enum TimeComparison: String, Codable {
        case before
        case after
    }

    /// Get the target value for progress calculation
    public var targetValue: Int {
        switch self {
        case .totalSessions(let count): return count
        case .exerciseVolume(_, let count): return count
        case .streak(let days): return days
        case .unique(let count): return count
        case .timeWindow(_, _, let count): return count
        case .dailyGoal(let count): return count
        case .customExerciseCount(_, let count): return count
        case .dailyExerciseGoal(_, let count): return count
        case .weeklyExerciseGoal(_, let count): return count
        case .exerciseStreak(_, let days): return days
        case .speedChallenge(_, let count, _): return count
        }
    }
    
    // MARK: - Backward Compatibility
    
    private enum CodingKeys: String, CodingKey {
        case type
        case value1
        case value2
        case value3
        case comparison
        case exerciseReference
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        // Handle legacy cases
        case "totalExercises":
            let count = try container.decode(Int.self, forKey: .value1)
            self = .totalSessions(count)
        case "specificExercise":
            let name = try container.decode(String.self, forKey: .value1)
            let count = try container.decode(Int.self, forKey: .value2)
            self = .exerciseVolume(name, count)
        // Handle current cases
        case "totalSessions":
            let count = try container.decode(Int.self, forKey: .value1)
            self = .totalSessions(count)
        case "exerciseVolume":
            let name = try container.decode(String.self, forKey: .value1)
            let count = try container.decode(Int.self, forKey: .value2)
            self = .exerciseVolume(name, count)
        case "streak":
            let days = try container.decode(Int.self, forKey: .value1)
            self = .streak(days)
        case "unique":
            let count = try container.decode(Int.self, forKey: .value1)
            self = .unique(count)
        case "timeWindow":
            let hour = try container.decode(Int.self, forKey: .value1)
            let comparison = try container.decode(TimeComparison.self, forKey: .comparison)
            let count = try container.decode(Int.self, forKey: .value2)
            self = .timeWindow(hour: hour, comparison: comparison, count: count)
        case "dailyGoal":
            let count = try container.decode(Int.self, forKey: .value1)
            self = .dailyGoal(count)
        // Template-based cases
        case "customExerciseCount":
            let reference = try container.decode(ExerciseReference.self, forKey: .exerciseReference)
            let count = try container.decode(Int.self, forKey: .value1)
            self = .customExerciseCount(exerciseReference: reference, count: count)
        case "dailyExerciseGoal":
            let reference = try container.decode(ExerciseReference.self, forKey: .exerciseReference)
            let count = try container.decode(Int.self, forKey: .value1)
            self = .dailyExerciseGoal(exerciseReference: reference, count: count)
        case "weeklyExerciseGoal":
            let reference = try container.decode(ExerciseReference.self, forKey: .exerciseReference)
            let count = try container.decode(Int.self, forKey: .value1)
            self = .weeklyExerciseGoal(exerciseReference: reference, count: count)
        case "exerciseStreak":
            let reference = try container.decode(ExerciseReference.self, forKey: .exerciseReference)
            let days = try container.decode(Int.self, forKey: .value1)
            self = .exerciseStreak(exerciseReference: reference, days: days)
        case "speedChallenge":
            let reference = try container.decode(ExerciseReference.self, forKey: .exerciseReference)
            let count = try container.decode(Int.self, forKey: .value1)
            let timeWindow = try container.decode(Int.self, forKey: .value2)
            self = .speedChallenge(exerciseReference: reference, count: count, timeWindowMinutes: timeWindow)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown requirement type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .totalSessions(let count):
            try container.encode("totalSessions", forKey: .type)
            try container.encode(count, forKey: .value1)
        case .exerciseVolume(let name, let count):
            try container.encode("exerciseVolume", forKey: .type)
            try container.encode(name, forKey: .value1)
            try container.encode(count, forKey: .value2)
        case .streak(let days):
            try container.encode("streak", forKey: .type)
            try container.encode(days, forKey: .value1)
        case .unique(let count):
            try container.encode("unique", forKey: .type)
            try container.encode(count, forKey: .value1)
        case .timeWindow(let hour, let comparison, let count):
            try container.encode("timeWindow", forKey: .type)
            try container.encode(hour, forKey: .value1)
            try container.encode(comparison, forKey: .comparison)
            try container.encode(count, forKey: .value2)
        case .dailyGoal(let count):
            try container.encode("dailyGoal", forKey: .type)
            try container.encode(count, forKey: .value1)
        // Template-based cases
        case .customExerciseCount(let reference, let count):
            try container.encode("customExerciseCount", forKey: .type)
            try container.encode(reference, forKey: .exerciseReference)
            try container.encode(count, forKey: .value1)
        case .dailyExerciseGoal(let reference, let count):
            try container.encode("dailyExerciseGoal", forKey: .type)
            try container.encode(reference, forKey: .exerciseReference)
            try container.encode(count, forKey: .value1)
        case .weeklyExerciseGoal(let reference, let count):
            try container.encode("weeklyExerciseGoal", forKey: .type)
            try container.encode(reference, forKey: .exerciseReference)
            try container.encode(count, forKey: .value1)
        case .exerciseStreak(let reference, let days):
            try container.encode("exerciseStreak", forKey: .type)
            try container.encode(reference, forKey: .exerciseReference)
            try container.encode(days, forKey: .value1)
        case .speedChallenge(let reference, let count, let timeWindow):
            try container.encode("speedChallenge", forKey: .type)
            try container.encode(reference, forKey: .exerciseReference)
            try container.encode(count, forKey: .value1)
            try container.encode(timeWindow, forKey: .value2)
        }
    }
}

// MARK: - Streak System

/// Tracks consecutive days of activity with protection mechanisms
public struct StreakData: Codable {
    public var currentStreak: Int
    public var longestStreak: Int
    public var lastActiveDate: Date?
    public var streakFreezesAvailable: Int  // Grace period tokens (max 2)
    public var restDay: Int?  // Weekday (1-7) that doesn't break streak

    public init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDate: Date? = nil,
        streakFreezesAvailable: Int = 0,
        restDay: Int? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.streakFreezesAvailable = streakFreezesAvailable
        self.restDay = restDay
    }

    /// Record activity and update streak
    public mutating func recordActivity(on date: Date = Date()) {
        let calendar = Calendar.current

        guard let lastDate = lastActiveDate else {
            // First activity ever
            currentStreak = 1
            longestStreak = 1
            lastActiveDate = date
            return
        }

        // Check if already counted today
        if calendar.isDate(date, inSameDayAs: lastDate) {
            return
        }

        let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: date)).day ?? 0

        if daysDiff == 1 {
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)

            // Award freeze token every 7 days (max 2)
            if currentStreak % 7 == 0 && streakFreezesAvailable < 2 {
                streakFreezesAvailable += 1
            }
        } else if daysDiff == 2 && streakFreezesAvailable > 0 {
            // Missed one day but have a freeze
            streakFreezesAvailable -= 1
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysDiff > 1 {
            // Check if the missed day was the designated rest day
            let missedDate = calendar.date(byAdding: .day, value: 1, to: lastDate)!
            let missedWeekday = calendar.component(.weekday, from: missedDate)

            if restDay == missedWeekday && daysDiff == 2 {
                // Missed rest day, streak continues
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // Streak broken
                currentStreak = 1
            }
        }

        lastActiveDate = date
    }

    /// Check if streak is at risk (no activity today yet)
    public func isAtRisk() -> Bool {
        guard let lastDate = lastActiveDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActiveDay = calendar.startOfDay(for: lastDate)

        return !calendar.isDate(lastActiveDay, inSameDayAs: today) && currentStreak > 0
    }
}

/// Different types of streaks to track
public enum StreakType: String, Codable, CaseIterable {
    case dailyActive = "Daily Active"
    case reminderResponse = "Reminder Response"
    case weeklyGoal = "Weekly Goal"

    public var icon: String {
        switch self {
        case .dailyActive: return "flame.fill"
        case .reminderResponse: return "bell.badge.fill"
        case .weeklyGoal: return "calendar.badge.checkmark"
        }
    }
}

// MARK: - Level & XP System

/// Experience points and leveling system for long-term progression
public struct LevelProgress: Codable {
    public var totalXP: Int

    public init(totalXP: Int = 0) {
        self.totalXP = totalXP
    }

    /// Current level based on total XP
    public var currentLevel: Int {
        LevelSystem.levelFor(xp: totalXP)
    }

    /// XP needed for next level
    public var xpForNextLevel: (current: Int, needed: Int) {
        LevelSystem.xpForNextLevel(currentXP: totalXP)
    }

    /// Progress to next level (0.0 to 1.0)
    public var levelProgressPercent: Double {
        let (current, needed) = xpForNextLevel
        guard needed > 0 else { return 0.0 }
        return Double(current) / Double(needed)
    }

    public mutating func addXP(_ amount: Int) {
        totalXP += amount
    }
}

/// Static XP award values and level calculation
public struct LevelSystem {
    public static let xpPerExercise = 10
    public static let xpPerStreak = 5  // Bonus XP per day of current streak
    public static let xpPerAchievement = 50

    /// Calculate level from total XP (exponential curve)
    public static func levelFor(xp: Int) -> Int {
        var level = 1
        var threshold = 0
        var increment = 100

        while xp >= threshold + increment {
            level += 1
            threshold += increment
            increment = Int(Double(increment) * 1.2)  // 20% increase per level
        }

        return level
    }

    /// Calculate XP progress within current level
    public static func xpForNextLevel(currentXP: Int) -> (current: Int, needed: Int) {
        let level = levelFor(xp: currentXP)
        var threshold = 0
        var increment = 100

        for _ in 1..<level {
            threshold += increment
            increment = Int(Double(increment) * 1.2)
        }

        let currentProgress = currentXP - threshold
        return (currentProgress, increment)
    }
}

// MARK: - Challenge System

/// Time-limited goals for short-term engagement
public struct Challenge: Identifiable, Codable {
    public let id: UUID
    public let type: ChallengeType
    public let target: Int
    public var progress: Int
    public let expiresAt: Date
    public let xpReward: Int

    public var isComplete: Bool { progress >= target }
    public var isExpired: Bool { Date() > expiresAt }
    public var isActive: Bool { !isComplete && !isExpired }

    public var progressPercent: Double {
        guard target > 0 else { return 0.0 }
        return min(Double(progress) / Double(target), 1.0)
    }

    public init(type: ChallengeType, target: Int, expiresAt: Date, xpReward: Int = 25) {
        self.id = UUID()
        self.type = type
        self.target = target
        self.progress = 0
        self.expiresAt = expiresAt
        self.xpReward = xpReward
    }
}

/// Types of challenges available
public enum ChallengeType: String, Codable {
    case dailyExercises = "Daily Exercises"
    case specificExercise = "Specific Exercise"
    case varietyChallenge = "Variety Challenge"
    case streakProtect = "Streak Protect"
    case earlyBird = "Early Bird"

    public var icon: String {
        switch self {
        case .dailyExercises: return "figure.run"
        case .specificExercise: return "target"
        case .varietyChallenge: return "shuffle"
        case .streakProtect: return "shield.fill"
        case .earlyBird: return "sunrise.fill"
        }
    }

    public var description: String {
        switch self {
        case .dailyExercises: return "Complete exercises today"
        case .specificExercise: return "Complete specific exercise"
        case .varietyChallenge: return "Try different exercises"
        case .streakProtect: return "Maintain your streak"
        case .earlyBird: return "Exercise before 8 AM"
        }
    }
}

// MARK: - Gamification Events

/// Events that trigger gamification updates
public enum GamificationEvent {
    case exerciseLogged(exerciseId: String, count: Int, timestamp: Date)
    case reminderResponded(timestamp: Date)
    case dayCompleted(date: Date)
    case achievementUnlocked(achievementId: String)
    case levelUp(newLevel: Int)
    case challengeCompleted(challengeId: UUID)
}

// MARK: - Achievement Definitions

/// Predefined achievements available in the app
public struct AchievementDefinitions {
    public static let all: [Achievement] = [
        // MARK: Milestones (Session-based)
        Achievement(
            id: "first_exercise",
            name: "First Steps",
            description: "Log your first exercise",
            icon: "figure.walk",
            category: .milestone,
            tier: .bronze,
            requirement: .totalSessions(1),
            progress: 0
        ),
        Achievement(
            id: "ten_exercises",
            name: "Getting Started",
            description: "Log 10 exercise sessions",
            icon: "10.circle.fill",
            category: .milestone,
            tier: .bronze,
            requirement: .totalSessions(10),
            progress: 0
        ),
        Achievement(
            id: "century",
            name: "Century Club",
            description: "Log 100 exercise sessions",
            icon: "100.circle.fill",
            category: .milestone,
            tier: .silver,
            requirement: .totalSessions(100),
            progress: 0
        ),
        Achievement(
            id: "five_hundred",
            name: "Dedicated",
            description: "Log 500 exercise sessions",
            icon: "star.fill",
            category: .milestone,
            tier: .gold,
            requirement: .totalSessions(500),
            progress: 0
        ),
        Achievement(
            id: "thousand",
            name: "The Grind",
            description: "Log 1,000 exercise sessions",
            icon: "star.circle.fill",
            category: .milestone,
            tier: .platinum,
            requirement: .totalSessions(1000),
            progress: 0
        ),

        // MARK: Consistency
        Achievement(
            id: "week_streak",
            name: "Week Warrior",
            description: "Maintain a 7-day streak",
            icon: "flame.fill",
            category: .consistency,
            tier: .bronze,
            requirement: .streak(7),
            progress: 0
        ),
        Achievement(
            id: "two_week_streak",
            name: "Building Habits",
            description: "Maintain a 14-day streak",
            icon: "flame.fill",
            category: .consistency,
            tier: .silver,
            requirement: .streak(14),
            progress: 0
        ),
        Achievement(
            id: "month_streak",
            name: "Monthly Master",
            description: "Maintain a 30-day streak",
            icon: "flame.circle.fill",
            category: .consistency,
            tier: .gold,
            requirement: .streak(30),
            progress: 0
        ),
        Achievement(
            id: "year_streak",
            name: "Unstoppable",
            description: "Maintain a 365-day streak",
            icon: "crown.fill",
            category: .consistency,
            tier: .platinum,
            requirement: .streak(365),
            progress: 0
        ),

        // MARK: Variety
        Achievement(
            id: "well_rounded",
            name: "Well Rounded",
            description: "Do 5 different exercise types in one day",
            icon: "circle.hexagongrid.fill",
            category: .variety,
            tier: .bronze,
            requirement: .unique(5),
            progress: 0
        ),
        Achievement(
            id: "variety_expert",
            name: "Variety Expert",
            description: "Do all 10 exercise types in one day",
            icon: "star.circle.fill",
            category: .variety,
            tier: .silver,
            requirement: .unique(10),
            progress: 0
        ),

        // MARK: Challenges
        Achievement(
            id: "early_bird",
            name: "Early Bird",
            description: "Log an exercise before 7 AM",
            icon: "sunrise.fill",
            category: .challenge,
            tier: .bronze,
            requirement: .timeWindow(hour: 7, comparison: .before, count: 1),
            progress: 0
        ),
        Achievement(
            id: "night_owl",
            name: "Night Owl",
            description: "Log an exercise after 10 PM",
            icon: "moon.stars.fill",
            category: .challenge,
            tier: .bronze,
            requirement: .timeWindow(hour: 22, comparison: .after, count: 1),
            progress: 0
        ),
        Achievement(
            id: "power_day",
            name: "Power Day",
            description: "Complete 10 exercises in one day",
            icon: "bolt.fill",
            category: .challenge,
            tier: .silver,
            requirement: .dailyGoal(10),
            progress: 0
        ),
        Achievement(
            id: "marathon",
            name: "Marathon",
            description: "Complete 20 exercises in one day",
            icon: "figure.run",
            category: .challenge,
            tier: .gold,
            requirement: .dailyGoal(20),
            progress: 0
        ),

        // MARK: Volume (Built-in exercises - Rep/Duration based)
        Achievement(
            id: "pushup_100",
            name: "Pushup Pro",
            description: "Complete 100 total pushup reps",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Pushups", 100),
            progress: 0
        ),
        Achievement(
            id: "pushup_500",
            name: "Pushup Expert",
            description: "Complete 500 total pushup reps",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Pushups", 500),
            progress: 0
        ),
        Achievement(
            id: "pushup_1000",
            name: "Pushup Master",
            description: "Complete 1,000 total pushup reps",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Pushups", 1000),
            progress: 0
        ),
        Achievement(
            id: "squat_100",
            name: "Squat Pro",
            description: "Complete 100 total squat reps",
            icon: "figure.stand",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Squats", 100),
            progress: 0
        ),
        Achievement(
            id: "squat_500",
            name: "Squat Expert",
            description: "Complete 500 total squat reps",
            icon: "figure.stand",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Squats", 500),
            progress: 0
        ),
        Achievement(
            id: "squat_1000",
            name: "Squat Master",
            description: "Complete 1,000 total squat reps",
            icon: "figure.stand",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Squats", 1000),
            progress: 0
        ),
        Achievement(
            id: "lunge_100",
            name: "Lunge Pro",
            description: "Complete 100 total lunge reps",
            icon: "figure.walk",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Lunges", 100),
            progress: 0
        ),
        Achievement(
            id: "lunge_500",
            name: "Lunge Expert",
            description: "Complete 500 total lunge reps",
            icon: "figure.walk",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Lunges", 500),
            progress: 0
        ),
        Achievement(
            id: "lunge_1000",
            name: "Lunge Master",
            description: "Complete 1,000 total lunge reps",
            icon: "figure.walk",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Lunges", 1000),
            progress: 0
        ),
        Achievement(
            id: "plank_300",
            name: "Plank Beginner",
            description: "Hold plank for 300 total seconds",
            icon: "figure.core.training",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Plank", 300),
            progress: 0
        ),
        Achievement(
            id: "plank_1800",
            name: "Plank Warrior",
            description: "Hold plank for 1,800 total seconds",
            icon: "figure.core.training",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Plank", 1800),
            progress: 0
        ),
        Achievement(
            id: "plank_3600",
            name: "Plank Champion",
            description: "Hold plank for 3,600 total seconds (1 hour)",
            icon: "figure.core.training",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Plank", 3600),
            progress: 0
        ),
        Achievement(
            id: "stretch_600",
            name: "Flexibility Friend",
            description: "Stretch for 600 total seconds",
            icon: "figure.flexibility",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Standing Stretch", 600),
            progress: 0
        ),
        Achievement(
            id: "stretch_3000",
            name: "Stretch Master",
            description: "Stretch for 3,000 total seconds",
            icon: "figure.flexibility",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Standing Stretch", 3000),
            progress: 0
        ),
        Achievement(
            id: "stretch_6000",
            name: "Zen Master",
            description: "Stretch for 6,000 total seconds",
            icon: "figure.flexibility",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Standing Stretch", 6000),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_200",
            name: "Calf Crusher",
            description: "Complete 200 total calf raises",
            icon: "figure.stand",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Calf Raises", 200),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_1000",
            name: "Calf Expert",
            description: "Complete 1,000 total calf raises",
            icon: "figure.stand",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Calf Raises", 1000),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_2000",
            name: "Steel Calves",
            description: "Complete 2,000 total calf raises",
            icon: "figure.stand",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Calf Raises", 2000),
            progress: 0
        ),
        Achievement(
            id: "walk_1000",
            name: "Stepping Up",
            description: "Walk in place 1,000 total steps",
            icon: "figure.walk.motion",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Walk In Place", 1000),
            progress: 0
        ),
        Achievement(
            id: "walk_5000",
            name: "Step Counter",
            description: "Walk in place 5,000 total steps",
            icon: "figure.walk.motion",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Walk In Place", 5000),
            progress: 0
        ),
        Achievement(
            id: "walk_10000",
            name: "Daily Walker",
            description: "Walk in place 10,000 total steps",
            icon: "figure.walk.motion",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Walk In Place", 10000),
            progress: 0
        ),
        Achievement(
            id: "neck_roll_100",
            name: "Neck Relief",
            description: "Complete 100 total neck rolls",
            icon: "figure.mind.and.body",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Neck Rolls", 100),
            progress: 0
        ),
        Achievement(
            id: "neck_roll_500",
            name: "Tension Tamer",
            description: "Complete 500 total neck rolls",
            icon: "figure.mind.and.body",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Neck Rolls", 500),
            progress: 0
        ),
        Achievement(
            id: "shoulder_shrug_200",
            name: "Shoulder Soother",
            description: "Complete 200 total shoulder shrugs",
            icon: "figure.cooldown",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Shoulder Shrugs", 200),
            progress: 0
        ),
        Achievement(
            id: "shoulder_shrug_1000",
            name: "Desk Warrior",
            description: "Complete 1,000 total shoulder shrugs",
            icon: "figure.cooldown",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Shoulder Shrugs", 1000),
            progress: 0
        ),
        Achievement(
            id: "arm_circle_150",
            name: "Circle Starter",
            description: "Complete 150 total arm circles",
            icon: "figure.arms.open",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Arm Circles", 150),
            progress: 0
        ),
        Achievement(
            id: "arm_circle_750",
            name: "Rotation Master",
            description: "Complete 750 total arm circles",
            icon: "figure.arms.open",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Arm Circles", 750),
            progress: 0
        ),
    ]
}
