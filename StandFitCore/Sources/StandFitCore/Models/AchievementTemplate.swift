//
//  AchievementTemplate.swift
//  StandFitCore
//
//  User-created templates for generating custom achievements
//  Premium-only feature
//

import Foundation

// MARK: - AchievementTemplate

/// User-created template for generating custom achievements
public struct AchievementTemplate: Identifiable, Codable, Hashable {
    public let id: UUID

    // Exercise Reference
    public var exerciseReference: ExerciseReference

    // Template Configuration
    public var templateType: AchievementTemplateType
    public var name: String
    public var tiers: [AchievementTemplateTier]

    // Metadata
    public var createdAt: Date
    public var lastModified: Date
    public var isActive: Bool
    public var createdByPremiumUser: Bool

    // Generation Settings
    public var autoGenerateOnExerciseLog: Bool
    public var includeInGlobalAchievements: Bool

    public init(
        id: UUID = UUID(),
        exerciseReference: ExerciseReference,
        templateType: AchievementTemplateType,
        name: String,
        tiers: [AchievementTemplateTier],
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        isActive: Bool = true,
        createdByPremiumUser: Bool = true,
        autoGenerateOnExerciseLog: Bool = true,
        includeInGlobalAchievements: Bool = true
    ) {
        self.id = id
        self.exerciseReference = exerciseReference
        self.templateType = templateType
        self.name = name
        self.tiers = tiers
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.isActive = isActive
        self.createdByPremiumUser = createdByPremiumUser
        self.autoGenerateOnExerciseLog = autoGenerateOnExerciseLog
        self.includeInGlobalAchievements = includeInGlobalAchievements
    }

    /// Summary description for display in UI
    public var summaryDescription: String {
        "\(tiers.count) tiers • \(templateType.rawValue)"
    }
}

// MARK: - ExerciseReference

/// Reference to either a built-in or custom exercise
public enum ExerciseReference: Codable, Hashable {
    case builtIn(ExerciseType)
    case custom(UUID)

    public var displayName: String {
        switch self {
        case .builtIn(let type):
            return type.rawValue
        case .custom:
            return "Custom Exercise"
        }
    }

    /// Resolve to ExerciseItem if possible
    public func resolve(customExercises: [CustomExercise]) -> ExerciseItem? {
        switch self {
        case .builtIn(let type):
            return ExerciseItem(builtIn: type)
        case .custom(let id):
            guard let exercise = customExercises.first(where: { $0.id == id }) else {
                return nil // Exercise was deleted
            }
            return ExerciseItem(custom: exercise)
        }
    }
}

// MARK: - AchievementTemplateType

/// Types of achievement templates available
public enum AchievementTemplateType: String, Codable, CaseIterable, Hashable {
    case volume = "Lifetime Volume"
    case dailyGoal = "Daily Goal"
    case weeklyGoal = "Weekly Goal"
    case streak = "Consecutive Days"
    case speed = "Speed Challenge"

    public var icon: String {
        switch self {
        case .volume: return "chart.bar.fill"
        case .dailyGoal: return "sun.max.fill"
        case .weeklyGoal: return "calendar.badge.checkmark"
        case .streak: return "flame.fill"
        case .speed: return "stopwatch.fill"
        }
    }

    public var description: String {
        switch self {
        case .volume:
            return "Track total lifetime count for this exercise"
        case .dailyGoal:
            return "Achieve a target count in a single day"
        case .weeklyGoal:
            return "Reach a weekly target across 7 days"
        case .streak:
            return "Log this exercise on consecutive days"
        case .speed:
            return "Complete reps within a time window"
        }
    }

    /// Default tier configurations for each template type
    public var defaultTiers: [AchievementTemplateTier] {
        switch self {
        case .volume:
            return [
                AchievementTemplateTier(tier: .bronze, target: 50, label: "Novice"),
                AchievementTemplateTier(tier: .silver, target: 100, label: "Intermediate"),
                AchievementTemplateTier(tier: .gold, target: 500, label: "Advanced"),
                AchievementTemplateTier(tier: .platinum, target: 1000, label: "Master")
            ]
        case .dailyGoal:
            return [
                AchievementTemplateTier(tier: .bronze, target: 20, label: "Daily Achiever"),
                AchievementTemplateTier(tier: .silver, target: 50, label: "Daily Champion"),
                AchievementTemplateTier(tier: .gold, target: 100, label: "Daily Legend")
            ]
        case .weeklyGoal:
            return [
                AchievementTemplateTier(tier: .bronze, target: 100, label: "Week Warrior"),
                AchievementTemplateTier(tier: .silver, target: 250, label: "Week Champion"),
                AchievementTemplateTier(tier: .gold, target: 500, label: "Week Legend")
            ]
        case .streak:
            return [
                AchievementTemplateTier(tier: .bronze, target: 3, label: "Consistent"),
                AchievementTemplateTier(tier: .silver, target: 7, label: "Dedicated"),
                AchievementTemplateTier(tier: .gold, target: 30, label: "Committed")
            ]
        case .speed:
            return [
                AchievementTemplateTier(tier: .bronze, target: 50, label: "Speedy", timeWindow: 10),
                AchievementTemplateTier(tier: .silver, target: 100, label: "Lightning", timeWindow: 15)
            ]
        }
    }

    /// Map template type to achievement category
    public var achievementCategory: AchievementCategory {
        switch self {
        case .volume: return .volume
        case .dailyGoal: return .milestone
        case .weeklyGoal: return .milestone
        case .streak: return .consistency
        case .speed: return .challenge
        }
    }
}

// MARK: - AchievementTemplateTier

/// Configuration for a single tier within a template
public struct AchievementTemplateTier: Identifiable, Codable, Hashable {
    public let id: UUID
    public var tier: AchievementTier
    public var target: Int
    public var label: String?
    public var icon: String?
    public var timeWindow: Int? // For speed achievements: minutes

    public init(
        id: UUID = UUID(),
        tier: AchievementTier,
        target: Int,
        label: String? = nil,
        icon: String? = nil,
        timeWindow: Int? = nil
    ) {
        self.id = id
        self.tier = tier
        self.target = target
        self.label = label
        self.icon = icon
        self.timeWindow = timeWindow
    }
}

// MARK: - TemplateGeneratedAchievement

/// Tracking record for achievements generated from templates
public struct TemplateGeneratedAchievement: Codable, Hashable {
    public let achievementId: String
    public let sourceTemplateId: UUID
    public let generatedAt: Date
    public var lastRegenerated: Date?

    public init(
        achievementId: String,
        sourceTemplateId: UUID,
        generatedAt: Date = Date(),
        lastRegenerated: Date? = nil
    ) {
        self.achievementId = achievementId
        self.sourceTemplateId = sourceTemplateId
        self.generatedAt = generatedAt
        self.lastRegenerated = lastRegenerated
    }
}
