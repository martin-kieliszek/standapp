//
//  AchievementsView.swift
//  StandFit
//
//  Main view for displaying achievements with filtering and progress tracking
//

import SwiftUI
import StandFitCore

struct AchievementsView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @State private var selectedCategory: AchievementCategory?

    var body: some View {
        List {
            // Summary Section
            summarySection

            // Category Filter
            categoryFilterSection

            // Unlocked Achievements
            if !filteredUnlockedAchievements.isEmpty {
                Section {
                    ForEach(filteredUnlockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, showProgress: false)
                    }
                } header: {
                    Text("Unlocked (\(filteredUnlockedAchievements.count))")
                }
            }

            // In Progress Achievements
            if !filteredInProgressAchievements.isEmpty {
                Section {
                    ForEach(filteredInProgressAchievements) { achievement in
                        AchievementRow(achievement: achievement, showProgress: true)
                    }
                } header: {
                    Text("In Progress (\(filteredInProgressAchievements.count))")
                }
            }

            // Locked Achievements
            if !filteredLockedAchievements.isEmpty {
                Section {
                    ForEach(filteredLockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, isLocked: true)
                    }
                } header: {
                    Text("Locked (\(filteredLockedAchievements.count))")
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(unlockedCount)/\(totalCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Achievements")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Tier breakdown
            HStack(spacing: 6) {
                tierBadge(.platinum)
                tierBadge(.gold)
                tierBadge(.silver)
                tierBadge(.bronze)
            }
        }
        .padding(.vertical, 4)
    }

    private func tierBadge(_ tier: AchievementTier) -> some View {
        let unlocked = gamificationStore.achievementCount(tier: tier, unlocked: true)
        let total = gamificationStore.achievements.filter { $0.tier == tier }.count

        return HStack(spacing: 2) {
            Circle()
                .fill(tier.color)
                .frame(width: 8, height: 8)
            Text("\(unlocked)/\(total)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Category Filter Section

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                categoryPill(nil, label: "All")
                ForEach(AchievementCategory.allCases) { category in
                    categoryPill(category, label: category.rawValue)
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }

    private func categoryPill(_ category: AchievementCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 4) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.caption2)
                }
                Text(label)
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filtered Achievements

    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return gamificationStore.achievements.filter { $0.category == category }
        }
        return gamificationStore.achievements
    }

    private var filteredUnlockedAchievements: [Achievement] {
        filteredAchievements
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? Date.distantPast) > ($1.unlockedAt ?? Date.distantPast) }
    }

    private var filteredInProgressAchievements: [Achievement] {
        filteredAchievements
            .filter { !$0.isUnlocked && $0.progress > 0 }
            .sorted { $0.progressPercent > $1.progressPercent }
    }

    private var filteredLockedAchievements: [Achievement] {
        filteredAchievements
            .filter { !$0.isUnlocked && $0.progress == 0 }
            .sorted { $0.tier.sortOrder < $1.tier.sortOrder }
    }

    // MARK: - Computed Properties

    private var unlockedCount: Int {
        gamificationStore.unlockedAchievements.count
    }

    private var totalCount: Int {
        gamificationStore.achievements.count
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: Achievement
    var showProgress: Bool = false
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: achievement.icon)
                .font(.title3)
                .foregroundStyle(isLocked ? .gray : achievement.tier.color)
                .frame(width: 28)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(achievement.name)
                        .font(.caption)
                        .fontWeight(achievement.isUnlocked ? .semibold : .regular)
                        .foregroundStyle(isLocked ? .secondary : .primary)

                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                if showProgress {
                    // Progress bar for in-progress achievements
                    ProgressView(value: achievement.progressPercent)
                        .tint(achievement.tier.color)

                    Text("\(achievement.progress)/\(achievement.targetValue) (\(Int(achievement.progressPercent * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text(achievement.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Tier badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(achievement.tier.color.opacity(0.3))
                        .frame(width: 6, height: 6)
                    Text(achievement.tier.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if achievement.isUnlocked, let unlockedAt = achievement.unlockedAt {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(unlockedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Achievement Unlocked Toast

/// Toast view shown when an achievement is unlocked
struct AchievementUnlockedToast: View {
    let achievement: Achievement
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.system(size: 36))
                .foregroundStyle(achievement.tier.color)

            Text("Achievement Unlocked!")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(achievement.name)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Button {
                isPresented = false
            } label: {
                Text("Awesome!")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(achievement.tier.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AchievementsView(
            gamificationStore: GamificationStore.shared,
            exerciseStore: ExerciseStore.shared
        )
    }
}
