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

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .milestone: return "flag.fill"
        case .consistency: return "flame.fill"
        case .volume: return "chart.bar.fill"
        case .variety: return "circle.hexagongrid.fill"
        case .challenge: return "trophy.fill"
        case .social: return "person.2.fill"
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
    case totalExercises(Int)           // Total exercise count across all types
    case specificExercise(String, Int) // Specific exercise type, target count
    case streak(Int)                   // Maintain streak for N days
    case unique(Int)                   // Unique exercise types in one day
    case timeWindow(hour: Int, comparison: TimeComparison, count: Int)  // Exercise before/after specific hour
    case dailyGoal(Int)                // Complete N exercises in one day

    public enum TimeComparison: String, Codable {
        case before
        case after
    }

    /// Get the target value for progress calculation
    public var targetValue: Int {
        switch self {
        case .totalExercises(let count): return count
        case .specificExercise(_, let count): return count
        case .streak(let days): return days
        case .unique(let count): return count
        case .timeWindow(_, _, let count): return count
        case .dailyGoal(let count): return count
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
        // MARK: Milestones
        Achievement(
            id: "first_exercise",
            name: "First Steps",
            description: "Log your first exercise",
            icon: "figure.walk",
            category: .milestone,
            tier: .bronze,
            requirement: .totalExercises(1),
            progress: 0
        ),
        Achievement(
            id: "ten_exercises",
            name: "Getting Started",
            description: "Log 10 total exercises",
            icon: "10.circle.fill",
            category: .milestone,
            tier: .bronze,
            requirement: .totalExercises(10),
            progress: 0
        ),
        Achievement(
            id: "century",
            name: "Century Club",
            description: "Log 100 total exercises",
            icon: "100.circle.fill",
            category: .milestone,
            tier: .silver,
            requirement: .totalExercises(100),
            progress: 0
        ),
        Achievement(
            id: "five_hundred",
            name: "Dedicated",
            description: "Log 500 total exercises",
            icon: "star.fill",
            category: .milestone,
            tier: .gold,
            requirement: .totalExercises(500),
            progress: 0
        ),
        Achievement(
            id: "thousand",
            name: "The Grind",
            description: "Log 1,000 total exercises",
            icon: "star.circle.fill",
            category: .milestone,
            tier: .platinum,
            requirement: .totalExercises(1000),
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
            description: "Do all exercise types in one day",
            icon: "circle.hexagongrid.fill",
            category: .variety,
            tier: .bronze,
            requirement: .unique(4),
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

        // MARK: Volume (Built-in exercises)
        Achievement(
            id: "pushup_100",
            name: "Pushup Pro",
            description: "Complete 100 lifetime pushups",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .bronze,
            requirement: .specificExercise("Pushups", 100),
            progress: 0
        ),
        Achievement(
            id: "pushup_500",
            name: "Pushup Expert",
            description: "Complete 500 lifetime pushups",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .silver,
            requirement: .specificExercise("Pushups", 500),
            progress: 0
        ),
        Achievement(
            id: "pushup_1000",
            name: "Pushup Master",
            description: "Complete 1,000 lifetime pushups",
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .gold,
            requirement: .specificExercise("Pushups", 1000),
            progress: 0
        ),
        Achievement(
            id: "squat_100",
            name: "Squat Pro",
            description: "Complete 100 lifetime squats",
            icon: "figure.stand",
            category: .volume,
            tier: .bronze,
            requirement: .specificExercise("Squats", 100),
            progress: 0
        ),
        Achievement(
            id: "squat_500",
            name: "Squat Expert",
            description: "Complete 500 lifetime squats",
            icon: "figure.stand",
            category: .volume,
            tier: .silver,
            requirement: .specificExercise("Squats", 500),
            progress: 0
        ),
        Achievement(
            id: "squat_1000",
            name: "Squat Master",
            description: "Complete 1,000 lifetime squats",
            icon: "figure.stand",
            category: .volume,
            tier: .gold,
            requirement: .specificExercise("Squats", 1000),
            progress: 0
        ),
    ]
}
