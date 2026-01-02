//
//  GamificationService.swift
//  StandFitCore
//
//  Platform-agnostic gamification business logic
//

import Foundation

/// Service for gamification state management
public class GamificationService {
    private let persistence: PersistenceProvider
    private static let gamificationKey = "gamification_data"

    public init(persistence: PersistenceProvider) {
        self.persistence = persistence
    }

    // MARK: - Data Model

    public struct GamificationData: Codable {
        public var achievements: [Achievement]
        public var streak: StreakData
        public var levelProgress: LevelProgress
        public var activeChallenges: [Challenge]

        public init(
            achievements: [Achievement] = [],
            streak: StreakData = StreakData(),
            levelProgress: LevelProgress = LevelProgress(),
            activeChallenges: [Challenge] = []
        ) {
            self.achievements = achievements
            self.streak = streak
            self.levelProgress = levelProgress
            self.activeChallenges = activeChallenges
        }
    }

    // MARK: - Persistence

    public func loadData() throws -> GamificationData {
        guard let data: GamificationData = try persistence.load(forKey: Self.gamificationKey, as: GamificationData.self) else {
            // First launch - return default with initialized achievements
            return GamificationData(achievements: AchievementDefinitions.all)
        }
        return data
    }

    public func saveData(_ data: GamificationData) throws {
        try persistence.save(data, forKey: Self.gamificationKey)
    }

    // MARK: - Event Processing

    public struct EventProcessingResult {
        public let newlyUnlockedAchievements: [Achievement]
        public let leveledUp: Bool
        public let newLevel: Int?

        public init(newlyUnlockedAchievements: [Achievement] = [], leveledUp: Bool = false, newLevel: Int? = nil) {
            self.newlyUnlockedAchievements = newlyUnlockedAchievements
            self.leveledUp = leveledUp
            self.newLevel = newLevel
        }
    }

    /// Process a gamification event and return updated data + results
    public func processEvent(
        _ event: GamificationEvent,
        currentData: GamificationData,
        logs: [ExerciseLog],
        customExercises: [CustomExercise]
    ) -> (updatedData: GamificationData, result: EventProcessingResult) {
        var data = currentData
        var result = EventProcessingResult()

        switch event {
        case .exerciseLogged(let exerciseId, let count, let timestamp):
            // Update streak
            data.streak.recordActivity(on: timestamp)

            // Award XP
            let xpEarned = LevelSystem.xpPerExercise * count
            let xpStreakBonus = LevelSystem.xpPerStreak * data.streak.currentStreak
            let oldLevel = data.levelProgress.currentLevel
            data.levelProgress.addXP(xpEarned + xpStreakBonus)
            let newLevel = data.levelProgress.currentLevel

            // Check for level up
            if newLevel > oldLevel {
                result = EventProcessingResult(leveledUp: true, newLevel: newLevel)
            }

            // Update achievement progress
            let (updatedAchievements, newlyUnlocked) = checkAchievements(
                achievements: data.achievements,
                logs: logs,
                customExercises: customExercises,
                gamificationData: data,
                timestamp: timestamp
            )
            data.achievements = updatedAchievements

            // Award XP for unlocked achievements
            for _ in newlyUnlocked {
                data.levelProgress.addXP(LevelSystem.xpPerAchievement)
            }

            result = EventProcessingResult(
                newlyUnlockedAchievements: newlyUnlocked,
                leveledUp: result.leveledUp,
                newLevel: result.newLevel
            )

            // Update active challenges
            data.activeChallenges = updateChallenges(
                challenges: data.activeChallenges,
                exerciseId: exerciseId,
                count: count,
                timestamp: timestamp
            )

        case .reminderResponded(let timestamp):
            // Could track reminder response streaks in future
            break

        case .dayCompleted(let date):
            // End-of-day processing
            data.streak.recordActivity(on: date)

        case .achievementUnlocked(let achievementId):
            // Award XP for achievement
            data.levelProgress.addXP(LevelSystem.xpPerAchievement)

        case .levelUp(let newLevel):
            // Level up celebration
            break

        case .challengeCompleted(let challengeId):
            if let challenge = data.activeChallenges.first(where: { $0.id == challengeId }) {
                data.levelProgress.addXP(challenge.xpReward)
            }
        }

        return (data, result)
    }

    // MARK: - Achievement Checking

    private func checkAchievements(
        achievements: [Achievement],
        logs: [ExerciseLog],
        customExercises: [CustomExercise],
        gamificationData: GamificationData,
        timestamp: Date
    ) -> (updated: [Achievement], newlyUnlocked: [Achievement]) {
        var updated = achievements
        var newlyUnlocked: [Achievement] = []

        for i in 0..<updated.count {
            // Skip already unlocked
            guard updated[i].unlockedAt == nil else { continue }

            let engine = AchievementEngine(achievement: updated[i])
            let (progress, unlocked) = engine.evaluate(
                logs: logs,
                customExercises: customExercises,
                gamificationData: gamificationData,
                timestamp: timestamp
            )

            updated[i].progress = progress

            if unlocked {
                updated[i].unlockedAt = Date()
                newlyUnlocked.append(updated[i])
            }
        }

        return (updated, newlyUnlocked)
    }

    // MARK: - Challenge Management

    private func updateChallenges(
        challenges: [Challenge],
        exerciseId: String,
        count: Int,
        timestamp: Date
    ) -> [Challenge] {
        var updated = challenges

        for i in 0..<updated.count {
            guard updated[i].isActive else { continue }

            // Update progress based on challenge type
            switch updated[i].type {
            case .dailyExercises:
                updated[i].progress += 1
            case .specificExercise:
                // Would need to match specific exercise
                break
            case .varietyChallenge:
                // Would track unique exercises
                break
            case .earlyBird:
                let hour = Calendar.current.component(.hour, from: timestamp)
                if hour < 8 {
                    updated[i].progress += 1
                }
            default:
                break
            }
        }

        // Remove expired challenges
        return updated.filter { !$0.isExpired }
    }

    /// Generate a new daily challenge
    public func generateDailyChallenge(currentChallenges: [Challenge]) -> Challenge? {
        // Don't generate if one already exists
        guard currentChallenges.isEmpty else { return nil }

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let endOfDay = Calendar.current.startOfDay(for: tomorrow)

        // Random challenge type
        let challengeTypes: [ChallengeType] = [.dailyExercises, .earlyBird, .varietyChallenge]
        guard let randomType = challengeTypes.randomElement() else { return nil }

        let target: Int
        switch randomType {
        case .dailyExercises: target = Int.random(in: 5...10)
        case .earlyBird: target = 1
        case .varietyChallenge: target = 3
        default: target = 5
        }

        return Challenge(
            type: randomType,
            target: target,
            expiresAt: endOfDay,
            xpReward: 25
        )
    }

    // MARK: - Query Methods

    public func achievements(in category: AchievementCategory?, from achievements: [Achievement]) -> [Achievement] {
        guard let category = category else { return achievements }
        return achievements.filter { $0.category == category }
    }

    public func unlockedAchievements(from achievements: [Achievement]) -> [Achievement] {
        achievements.filter { $0.isUnlocked }
    }

    public func lockedAchievements(from achievements: [Achievement]) -> [Achievement] {
        achievements.filter { !$0.isUnlocked && $0.progress == 0 }
    }

    public func inProgressAchievements(from achievements: [Achievement]) -> [Achievement] {
        achievements.filter { !$0.isUnlocked && $0.progress > 0 }
    }

    public func achievementCount(tier: AchievementTier, unlocked: Bool, from achievements: [Achievement]) -> Int {
        achievements.filter { $0.tier == tier && $0.isUnlocked == unlocked }.count
    }

    public func activeChallenge(from challenges: [Challenge]) -> Challenge? {
        challenges.first { $0.isActive }
    }
}

// MARK: - Achievement Engine

/// Evaluates achievement requirements and calculates progress
public struct AchievementEngine {
    public let achievement: Achievement

    public init(achievement: Achievement) {
        self.achievement = achievement
    }

    /// Evaluate achievement and return (progress, isUnlocked)
    public func evaluate(
        logs: [ExerciseLog],
        customExercises: [CustomExercise],
        gamificationData: GamificationService.GamificationData,
        timestamp: Date = Date()
    ) -> (progress: Int, unlocked: Bool) {
        switch achievement.requirement {
        case .totalExercises(let target):
            let total = logs.reduce(0) { $0 + $1.count }
            return (total, total >= target)

        case .specificExercise(let exerciseName, let target):
            // Count exercises matching the name
            let total = logs.filter { log in
                if let exerciseType = log.exerciseType {
                    return exerciseType.rawValue == exerciseName
                } else if let customId = log.customExerciseId,
                          let customExercise = customExercises.first(where: { $0.id == customId }) {
                    return customExercise.name == exerciseName
                }
                return false
            }.reduce(0) { $0 + $1.count }
            return (total, total >= target)

        case .streak(let target):
            let current = gamificationData.streak.currentStreak
            return (current, current >= target)

        case .unique(let target):
            // Check if user did N unique exercise types in one day (today)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todaysLogs = logs.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }

            var uniqueExercises = Set<String>()
            for log in todaysLogs {
                if let exerciseType = log.exerciseType {
                    uniqueExercises.insert(exerciseType.rawValue)
                } else if let customId = log.customExerciseId {
                    uniqueExercises.insert(customId.uuidString)
                }
            }

            let count = uniqueExercises.count
            return (count, count >= target)

        case .timeWindow(let hour, let comparison, let target):
            // Count exercises logged before/after specific hour
            let count = logs.filter { log in
                let logHour = Calendar.current.component(.hour, from: log.timestamp)
                switch comparison {
                case .before: return logHour < hour
                case .after: return logHour >= hour
                }
            }.count

            return (count, count >= target)

        case .dailyGoal(let target):
            // Check if user completed N exercises in one day (today)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todaysCount = logs.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count

            return (todaysCount, todaysCount >= target)
        }
    }
}
