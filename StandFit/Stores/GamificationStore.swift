//
//  GamificationStore.swift
//  StandFit iOS
//
//  Refactored to use StandFitCore services
//

import Foundation
import SwiftUI
import Combine
import StandFitCore

// NotificationManager is defined in the iOS app
private let notificationManager = NotificationManager.shared

@MainActor
class GamificationStore: ObservableObject {
    static let shared = GamificationStore()

    // MARK: - Services

    private let gamificationService: GamificationService

    // MARK: - Published State

    @Published var achievements: [Achievement] = []
    @Published var streak: StreakData = StreakData()
    @Published var levelProgress: LevelProgress = LevelProgress()
    @Published var activeChallenges: [Challenge] = []
    @Published var recentlyUnlockedAchievements: [Achievement] = []  // For showing notifications

    // MARK: - Initialization

    init() {
        let persistence = try! JSONFilePersistence()
        self.gamificationService = GamificationService(persistence: persistence)

        // Load data from service
        loadData()
    }

    private func loadData() {
        do {
            let data = try gamificationService.loadData()
            self.achievements = data.achievements
            self.streak = data.streak
            self.levelProgress = data.levelProgress
            self.activeChallenges = data.activeChallenges
        } catch {
            // Critical error loading data - log but preserve what we can
            print("⚠️ Error loading gamification data: \(error). Starting fresh.")
            // GamificationService.loadData() already returns initialized data on first launch,
            // so if we're here, it's a real error. Start with defaults.
            let defaultData = GamificationService.GamificationData(
                achievements: AchievementDefinitions.all,
                streak: StreakData(),
                levelProgress: LevelProgress(),
                activeChallenges: []
            )
            self.achievements = defaultData.achievements
            self.streak = defaultData.streak
            self.levelProgress = defaultData.levelProgress
            self.activeChallenges = defaultData.activeChallenges
            
            // Save the default data to create the file
            try? gamificationService.saveData(defaultData)
        }
    }

    private func saveData() {
        let data = GamificationService.GamificationData(
            achievements: achievements,
            streak: streak,
            levelProgress: levelProgress,
            activeChallenges: activeChallenges
        )

        try? gamificationService.saveData(data)
    }

    // MARK: - Event Processing

    /// Process a gamification event and update state accordingly
    func processEvent(_ event: GamificationEvent, exerciseStore: ExerciseStore) {
        // Only process achievements for premium users
        guard exerciseStore.isPremium else { return }
        
        let currentData = GamificationService.GamificationData(
            achievements: achievements,
            streak: streak,
            levelProgress: levelProgress,
            activeChallenges: activeChallenges
        )

        let (updatedData, result) = gamificationService.processEvent(
            event,
            currentData: currentData,
            logs: exerciseStore.logs,
            customExercises: exerciseStore.customExercises
        )

        // Update published state
        self.achievements = updatedData.achievements
        self.streak = updatedData.streak
        self.levelProgress = updatedData.levelProgress
        self.activeChallenges = updatedData.activeChallenges

        // Handle newly unlocked achievements
        if !result.newlyUnlockedAchievements.isEmpty {
            recentlyUnlockedAchievements.append(contentsOf: result.newlyUnlockedAchievements)

            // Send push notifications for each unlocked achievement
            for achievement in result.newlyUnlockedAchievements {
                notificationManager.sendAchievementNotification(achievement: achievement)
            }
        }

        // Handle level up
        if result.leveledUp, let newLevel = result.newLevel {
            print("🎉 Level up! Now level \(newLevel)")
            // Could show notification or celebration
        }

        // Save updated data
        saveData()
    }

    /// Clear recently unlocked achievements (after showing notifications)
    func clearRecentUnlocks() {
        recentlyUnlockedAchievements.removeAll()
    }

    // MARK: - Challenge Management

    /// Generate a new daily challenge
    func generateDailyChallenge() {
        // Remove old challenges
        activeChallenges.removeAll { $0.isExpired || $0.isComplete }

        if let newChallenge = gamificationService.generateDailyChallenge(currentChallenges: activeChallenges) {
            activeChallenges.append(newChallenge)
            saveData()
        }
    }

    // MARK: - Query Methods

    /// Get achievements filtered by category
    func achievements(in category: AchievementCategory?) -> [Achievement] {
        gamificationService.achievements(in: category, from: achievements)
    }

    /// Get unlocked achievements
    var unlockedAchievements: [Achievement] {
        gamificationService.unlockedAchievements(from: achievements)
    }

    /// Get locked achievements
    var lockedAchievements: [Achievement] {
        gamificationService.lockedAchievements(from: achievements)
    }

    /// Get in-progress achievements (started but not completed)
    var inProgressAchievements: [Achievement] {
        gamificationService.inProgressAchievements(from: achievements)
    }

    /// Count achievements by tier
    func achievementCount(tier: AchievementTier, unlocked: Bool) -> Int {
        gamificationService.achievementCount(tier: tier, unlocked: unlocked, from: achievements)
    }

    /// Get current active challenge
    var activeChallenge: Challenge? {
        gamificationService.activeChallenge(from: activeChallenges)
    }

    // MARK: - Streak Management

    /// Reset streak freeze count (for testing or settings)
    func resetStreakFreezes() {
        streak.streakFreezesAvailable = 0
        saveData()
    }

    /// Set rest day for streak protection
    func setRestDay(_ weekday: Int?) {
        streak.restDay = weekday
        saveData()
    }

    // MARK: - Premium Upgrade
    
    /// Recalculate all achievements from scratch using exercise history
    /// Call this when a user upgrades to premium
    func recalculateAchievementsFromHistory(exerciseStore: ExerciseStore) {
        print("🔄 Recalculating achievements from exercise history...")
        
        // Reset achievements to initial state
        achievements = AchievementDefinitions.all
        streak = StreakData()
        levelProgress = LevelProgress()
        activeChallenges = []
        recentlyUnlockedAchievements = []
        
        // Process each log as an event to rebuild achievement state
        let sortedLogs = exerciseStore.logs.sorted { $0.timestamp < $1.timestamp }
        for log in sortedLogs {
            let exerciseId = log.customExerciseId?.uuidString ?? log.exerciseType?.rawValue ?? "unknown"
            let event = GamificationEvent.exerciseLogged(
                exerciseId: exerciseId,
                count: log.count,
                timestamp: log.timestamp
            )
            
            // Process without premium check (internal recalculation)
            let currentData = GamificationService.GamificationData(
                achievements: achievements,
                streak: streak,
                levelProgress: levelProgress,
                activeChallenges: activeChallenges
            )
            
            let (updatedData, result) = gamificationService.processEvent(
                event,
                currentData: currentData,
                logs: exerciseStore.logs,
                customExercises: exerciseStore.customExercises
            )
            
            self.achievements = updatedData.achievements
            self.streak = updatedData.streak
            self.levelProgress = updatedData.levelProgress
            self.activeChallenges = updatedData.activeChallenges
            
            // Collect unlocked achievements but don't notify
            if !result.newlyUnlockedAchievements.isEmpty {
                recentlyUnlockedAchievements.append(contentsOf: result.newlyUnlockedAchievements)
            }
        }
        
        saveData()
        print("✅ Recalculation complete: \(unlockedAchievements.count) achievements unlocked")
    }
    
    // MARK: - Debug & Testing

    /// Reset all gamification data (useful for testing)
    func resetAllData() {
        achievements = AchievementDefinitions.all
        streak = StreakData()
        levelProgress = LevelProgress()
        activeChallenges = []
        recentlyUnlockedAchievements = []
        saveData()
    }

    /// Manually unlock an achievement (for testing)
    func debugUnlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].unlockedAt = Date()
            achievements[index].progress = achievements[index].targetValue
            recentlyUnlockedAchievements.append(achievements[index])
            saveData()
        }
    }
}
