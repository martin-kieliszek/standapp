//
//  AchievementTemplateEngine.swift
//  StandFitCore
//
//  Converts AchievementTemplates into concrete Achievement objects
//  Handles template regeneration and exercise deletion
//

import Foundation

/// Engine for generating achievements from user-created templates
public struct AchievementTemplateEngine {

    public init() {}

    /// Generate all achievements from active templates
    public func generateAchievements(
        from templates: [AchievementTemplate],
        customExercises: [CustomExercise],
        exerciseLogs: [ExerciseLog],
        existingUnlockDates: [String: Date] = [:]  // Preserve unlock dates
    ) -> ([Achievement], [TemplateGeneratedAchievement]) {

        var generatedAchievements: [Achievement] = []
        var trackingRecords: [TemplateGeneratedAchievement] = []

        for template in templates where template.isActive {
            // Resolve exercise reference
            guard let exerciseItem = template.exerciseReference.resolve(customExercises: customExercises) else {
                print("⚠️ Template \(template.id): Exercise not found, skipping")
                continue
            }

            // Generate achievements for each tier
            for tier in template.tiers {
                let achievement = createAchievement(
                    from: template,
                    tier: tier,
                    exerciseItem: exerciseItem,
                    logs: exerciseLogs,
                    existingUnlockDates: existingUnlockDates  // Pass through
                )

                generatedAchievements.append(achievement)

                let record = TemplateGeneratedAchievement(
                    achievementId: achievement.id,
                    sourceTemplateId: template.id,
                    generatedAt: Date()
                )
                trackingRecords.append(record)
            }
        }

        return (generatedAchievements, trackingRecords)
    }

    /// Create a single achievement from template and tier
    private func createAchievement(
        from template: AchievementTemplate,
        tier: AchievementTemplateTier,
        exerciseItem: ExerciseItem,
        logs: [ExerciseLog],
        existingUnlockDates: [String: Date]
    ) -> Achievement {

        let achievementId = "\(template.id.uuidString)_\(tier.id.uuidString)"

        // Use template name with tier label if provided, otherwise template name + tier
        let displayName: String
        if let customLabel = tier.label, !customLabel.isEmpty {
            displayName = "\(template.name) - \(customLabel)"
        } else if template.tiers.count > 1 {
            // Multiple tiers: include tier name for clarity
            displayName = "\(template.name) (\(tier.tier.rawValue))"
        } else {
            // Single tier: just use template name
            displayName = template.name
        }

        // Create requirement based on template type
        let requirement = createRequirement(
            templateType: template.templateType,
            tier: tier,
            exerciseReference: template.exerciseReference
        )

        // Calculate current progress
        let progress = calculateProgress(
            requirement: requirement,
            logs: logs,
            exerciseReference: template.exerciseReference
        )

        // Preserve existing unlock date if already unlocked, otherwise calculate if newly unlocked
        let unlockedAt: Date?
        if let existingDate = existingUnlockDates[achievementId] {
            // Use preserved unlock date from previous generation
            unlockedAt = existingDate
        } else if progress >= tier.target {
            // Newly unlocked - calculate unlock date
            unlockedAt = findUnlockDate(requirement: requirement, logs: logs, target: tier.target)
        } else {
            // Not yet unlocked
            unlockedAt = nil
        }

        return Achievement(
            id: achievementId,
            name: displayName,
            description: generateDescription(template: template, tier: tier, exerciseItem: exerciseItem),
            icon: tier.icon ?? template.templateType.icon,
            category: .template,  // UX16: All template achievements use template category
            tier: tier.tier,
            requirement: requirement,
            unlockedAt: unlockedAt,
            progress: progress
        )
    }

    /// Create requirement from template type and tier
    private func createRequirement(
        templateType: AchievementTemplateType,
        tier: AchievementTemplateTier,
        exerciseReference: ExerciseReference
    ) -> AchievementRequirement {

        switch templateType {
        case .volume:
            return .customExerciseCount(exerciseReference: exerciseReference, count: tier.target)

        case .dailyGoal:
            return .dailyExerciseGoal(exerciseReference: exerciseReference, count: tier.target)

        case .weeklyGoal:
            return .weeklyExerciseGoal(exerciseReference: exerciseReference, count: tier.target)

        case .streak:
            return .exerciseStreak(exerciseReference: exerciseReference, days: tier.target)

        case .speed:
            return .speedChallenge(
                exerciseReference: exerciseReference,
                count: tier.target,
                timeWindowMinutes: tier.timeWindow ?? 10
            )
        }
    }

    /// Calculate current progress for requirement
    private func calculateProgress(
        requirement: AchievementRequirement,
        logs: [ExerciseLog],
        exerciseReference: ExerciseReference
    ) -> Int {
        let exerciseLogs = filterLogs(logs: logs, for: exerciseReference)

        switch requirement {
        case .customExerciseCount:
            return exerciseLogs.reduce(0) { $0 + $1.count }

        case .dailyExerciseGoal:
            return calculateBestDailyCount(logs: exerciseLogs)

        case .weeklyExerciseGoal:
            return calculateBestWeeklyCount(logs: exerciseLogs)

        case .exerciseStreak:
            return calculateCurrentStreak(logs: exerciseLogs)

        case .speedChallenge(_, _, let timeWindow):
            return calculateBestSpeedRun(logs: exerciseLogs, timeWindow: timeWindow)

        default:
            return 0
        }
    }

    /// Generate achievement description
    private func generateDescription(
        template: AchievementTemplate,
        tier: AchievementTemplateTier,
        exerciseItem: ExerciseItem
    ) -> String {
        switch template.templateType {
        case .volume:
            return "Complete \(tier.target) total \(exerciseItem.name.lowercased())"
        case .dailyGoal:
            return "Complete \(tier.target) \(exerciseItem.name.lowercased()) in a single day"
        case .weeklyGoal:
            return "Complete \(tier.target) \(exerciseItem.name.lowercased()) in one week"
        case .streak:
            return "Log \(exerciseItem.name.lowercased()) for \(tier.target) consecutive days"
        case .speed:
            let timeWindow = tier.timeWindow ?? 10
            return "Complete \(tier.target) \(exerciseItem.name.lowercased()) in \(timeWindow) minutes"
        }
    }

    /// Find the date when achievement was unlocked
    private func findUnlockDate(
        requirement: AchievementRequirement,
        logs: [ExerciseLog],
        target: Int
    ) -> Date? {
        // For simplicity, return the timestamp of the log that pushed progress to target
        // In a real implementation, this would need more sophisticated tracking
        guard !logs.isEmpty else { return nil }
        return logs.last?.timestamp ?? Date()
    }

    // MARK: - Helper Methods

    private func filterLogs(logs: [ExerciseLog], for reference: ExerciseReference) -> [ExerciseLog] {
        switch reference {
        case .builtIn(let type):
            return logs.filter { $0.exerciseType == type }
        case .custom(let id):
            return logs.filter { $0.customExerciseId == id }
        }
    }

    private func calculateBestDailyCount(logs: [ExerciseLog]) -> Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: logs) {
            calendar.startOfDay(for: $0.timestamp)
        }

        var best = 0
        for (_, dayLogs) in grouped {
            let dayTotal = dayLogs.reduce(0) { $0 + $1.count }
            best = max(best, dayTotal)
        }
        return best
    }

    private func calculateBestWeeklyCount(logs: [ExerciseLog]) -> Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: logs) {
            calendar.dateInterval(of: .weekOfYear, for: $0.timestamp)?.start ?? $0.timestamp
        }

        var best = 0
        for (_, weekLogs) in grouped {
            let weekTotal = weekLogs.reduce(0) { $0 + $1.count }
            best = max(best, weekTotal)
        }
        return best
    }

    private func calculateCurrentStreak(logs: [ExerciseLog]) -> Int {
        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        let maxIterations = 1000

        for _ in 0..<maxIterations {
            let dayLogs = logs.filter { calendar.isDate($0.timestamp, inSameDayAs: checkDate) }
            guard !dayLogs.isEmpty else { break }

            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    private func calculateBestSpeedRun(logs: [ExerciseLog], timeWindow: Int) -> Int {
        let sortedLogs = logs.sorted { $0.timestamp < $1.timestamp }
        var bestCount = 0

        for i in 0..<sortedLogs.count {
            let windowStart = sortedLogs[i].timestamp
            let windowEnd = windowStart.addingTimeInterval(TimeInterval(timeWindow * 60))
            let windowLogs = sortedLogs.filter { $0.timestamp >= windowStart && $0.timestamp < windowEnd }
            let windowTotal = windowLogs.reduce(0) { $0 + $1.count }
            bestCount = max(bestCount, windowTotal)
        }

        return bestCount
    }
}
