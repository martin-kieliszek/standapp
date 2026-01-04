//
//  WeeklyInsightsView.swift
//  StandFit iOS
//
//  Swipeable weekly insights cards with celebratory progress highlights
//

import SwiftUI
import StandFitCore

struct WeeklyInsightsView: View {
    @ObservedObject var store: ExerciseStore
    @ObservedObject var gamificationStore: GamificationStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    
    private var weekStats: ReportStats? {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let period = ReportPeriod.weekStarting(weekStart)
        return store.reportingService.getStats(
            for: period,
            logs: store.logs,
            customExercises: store.customExercises,
            currentStreak: gamificationStore.streak.currentStreak
        )
    }
    
    private var insightCards: [InsightCard] {
        guard let stats = weekStats else { return [] }
        
        var cards: [InsightCard] = []
        
        // 1. Total Activity (always show)
        cards.append(.totalActivity(count: stats.totalCount, comparison: stats.comparisonToPrevious))
        
        // 2. Top Exercise (if any activity)
        if let topExercise = stats.breakdown.max(by: { $0.count < $1.count }) {
            cards.append(.topExercise(exercise: topExercise))
        }
        
        // 3. Consistency (active days this week)
        let activeDays = calculateActiveDays(period: ReportPeriod.weekStarting(stats.periodStart))
        cards.append(.consistency(activeDays: activeDays))
        
        // 4. Streak (if active)
        if let streak = stats.streak, streak > 0 {
            cards.append(.streak(days: streak))
        }
        
        // 5. New Achievement (if unlocked this week)
        if let newAchievement = findRecentAchievement() {
            cards.append(.newAchievement(achievement: newAchievement))
        }
        
        // 6. Next Milestone (closest to completion)
        if let nextMilestone = findNearestMilestone() {
            cards.append(.nextMilestone(achievement: nextMilestone))
        }
        
        return cards
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(LocalizedString.WeeklyInsights.navigationTitle)
                        .font(.title2)
                        .bold()
                    
                    if let stats = weekStats {
                        Text(formatDateRange(start: stats.periodStart, end: stats.periodEnd))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)
                
                // Swipeable cards
                TabView(selection: $currentPage) {
                    ForEach(Array(insightCards.enumerated()), id: \.offset) { index, card in
                        InsightCardView(card: card)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Page indicator text
                Text(LocalizedString.WeeklyInsights.pageIndicator(current: currentPage + 1, total: insightCards.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.WeeklyInsights.doneButton) { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end.addingTimeInterval(-1))
        return "\(startStr) – \(endStr)"
    }
    
    private func calculateActiveDays(period: ReportPeriod) -> [Bool] {
        let calendar = Calendar.current
        var activeDays: [Bool] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: period.startDate) else {
                activeDays.append(false)
                continue
            }
            
            let hasActivity = store.logs.contains { log in
                calendar.isDate(log.timestamp, inSameDayAs: date)
            }
            activeDays.append(hasActivity)
        }
        
        return activeDays
    }
    
    private func findRecentAchievement() -> Achievement? {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return gamificationStore.achievements.first { achievement in
            if let unlockedAt = achievement.unlockedAt {
                return unlockedAt >= weekAgo
            }
            return false
        }
    }
    
    private func findNearestMilestone() -> Achievement? {
        gamificationStore.achievements
            .filter { !$0.isUnlocked && $0.progressPercent > 0.5 }  // At least 50% progress
            .max(by: { $0.progressPercent < $1.progressPercent })
    }
}

// MARK: - Insight Card Model

enum InsightCard {
    case totalActivity(count: Int, comparison: Double?)
    case topExercise(exercise: ExerciseBreakdown)
    case consistency(activeDays: [Bool])
    case streak(days: Int)
    case newAchievement(achievement: Achievement)
    case nextMilestone(achievement: Achievement)
}

// MARK: - Insight Card View

struct InsightCardView: View {
    let card: InsightCard
    
    var body: some View {
        VStack(spacing: 20) {
            switch card {
            case .totalActivity(let count, let comparison):
                totalActivityCard(count: count, comparison: comparison)
                
            case .topExercise(let exercise):
                topExerciseCard(exercise: exercise)
                
            case .consistency(let activeDays):
                consistencyCard(activeDays: activeDays)
                
            case .streak(let days):
                streakCard(days: days)
                
            case .newAchievement(let achievement):
                newAchievementCard(achievement: achievement)
                
            case .nextMilestone(let achievement):
                nextMilestoneCard(achievement: achievement)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
    
    // MARK: - Card Layouts
    
    @ViewBuilder
    private func totalActivityCard(count: Int, comparison: Double?) -> some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("\(count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(LocalizedString.WeeklyInsights.totalActivitySubtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            if let comparison = comparison, comparison != 0 {
                let change = comparison * 100
                let isPositive = comparison > 0
                let formattedChange = String(format: "%.0f%%", abs(change))
                let prefix = isPositive ? "↗ +" : "↘ "
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    Text(LocalizedString.WeeklyInsights.vsLastWeek(prefix + formattedChange))
                }
                .font(.headline)
                .foregroundStyle(isPositive ? .green : .orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isPositive ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                )
            }
        }
    }
    
    @ViewBuilder
    private func topExerciseCard(exercise: ExerciseBreakdown) -> some View {
        VStack(spacing: 16) {
            Text("🏆")
                .font(.system(size: 60))
            
            Text(exercise.exercise.name)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(LocalizedString.WeeklyInsights.topExerciseSubtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                // Session count
                Text(LocalizedString.WeeklyInsights.timesCount(exercise.count))
                    .font(.title2)
                    .bold()
                
                // Total reps/seconds with proper unit
                let unitText: String = {
                    switch exercise.exercise.unitType {
                    case .reps:
                        return "\(exercise.totalAmount) " + LocalizedString.Units.reps
                    case .seconds:
                        return "\(exercise.totalAmount) " + LocalizedString.Units.seconds
                    case .minutes:
                        return "\(exercise.totalAmount) " + LocalizedString.Units.minutes
                    }
                }()
                
                Text(unitText)
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text(LocalizedString.WeeklyInsights.percentageActivity(String(format: "%.0f%%", exercise.percentage * 100)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private func consistencyCard(activeDays: [Bool]) -> some View {
        let activeCount = activeDays.filter { $0 }.count
        
        VStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 60))
            
            Text(LocalizedString.WeeklyInsights.consistencyDays(activeCount))
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text(LocalizedString.WeeklyInsights.consistencySubtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // Weekly grid
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Text(dayLabel(index))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .fill(activeDays[index] ? Color.green : Color.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: activeDays[index] ? "checkmark" : "")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            )
                    }
                }
            }
            .padding(.top, 8)
            
            if activeCount < 6 {
                Text(LocalizedString.WeeklyInsights.tryForMoreDays(activeCount + 1))
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
            }
        }
    }
    
    @ViewBuilder
    private func streakCard(days: Int) -> some View {
        VStack(spacing: 16) {
            Text("🚀")
                .font(.system(size: 60))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(days)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text(LocalizedString.WeeklyInsights.streakDaySingular)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Text(LocalizedString.WeeklyInsights.streakTitle)
                .font(.title)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical, 8)
            
            Text(streakMessage(days: days))
                .font(.headline)
                .foregroundStyle(.orange)
        }
    }
    
    @ViewBuilder
    private func newAchievementCard(achievement: Achievement) -> some View {
        VStack(spacing: 16) {
            Text("🏅")
                .font(.system(size: 60))
            
            Text(LocalizedString.WeeklyInsights.newBadge)
                .font(.caption)
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.blue))
            
            Text(achievement.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let unlockedAt = achievement.unlockedAt {
                let daysAgo = Calendar.current.dateComponents([.day], from: unlockedAt, to: Date()).day ?? 0
                Text(daysAgo == 0 ? LocalizedString.WeeklyInsights.unlockedToday : LocalizedString.WeeklyInsights.unlockedDaysAgo(daysAgo))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func nextMilestoneCard(achievement: Achievement) -> some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text(LocalizedString.WeeklyInsights.almostThere)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text(achievement.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * achievement.progressPercent, height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(String(format: "%.0f%%", achievement.progressPercent * 100))
                    .font(.headline)
                
                Spacer()
                
                Text(LocalizedString.WeeklyInsights.progressRatio(current: achievement.progress, target: achievement.targetValue))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func dayLabel(_ index: Int) -> String {
        let days = [
            LocalizedString.WeeklyInsights.dayMon,
            LocalizedString.WeeklyInsights.dayTue,
            LocalizedString.WeeklyInsights.dayWed,
            LocalizedString.WeeklyInsights.dayThu,
            LocalizedString.WeeklyInsights.dayFri,
            LocalizedString.WeeklyInsights.daySat,
            LocalizedString.WeeklyInsights.daySun
        ]
        return days[index]
    }
    
    private func streakMessage(days: Int) -> String {
        if days < 3 {
            return LocalizedString.WeeklyInsights.streakMessageShort
        } else if days < 7 {
            return LocalizedString.WeeklyInsights.streakMessageMedium
        } else {
            return LocalizedString.WeeklyInsights.streakMessageLong
        }
    }
}

#Preview {
    WeeklyInsightsView(store: ExerciseStore.shared, gamificationStore: GamificationStore.shared)
}
