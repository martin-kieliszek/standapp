//
//  AchievementShareView.swift
//  StandFit iOS
//
//  Beautiful shareable image template for achievement unlocks
//

import SwiftUI
import StandFitCore

/// View designed to be rendered as a 1080x1080 shareable image for achievement unlocks
struct AchievementShareView: View {
    let achievement: Achievement

    var body: some View {
        ZStack {
            // Background gradient based on achievement tier
            LinearGradient(
                colors: [
                    achievement.tier.color.opacity(0.2),
                    achievement.tier.color.opacity(0.05),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 50) {
                Spacer()

                // Achievement icon (large, centered)
                ZStack {
                    Circle()
                        .fill(achievement.tier.color.opacity(0.15))
                        .frame(width: 320, height: 320)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 160))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [achievement.tier.color, achievement.tier.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: achievement.tier.color.opacity(0.3), radius: 30)

                // Achievement info
                VStack(spacing: 20) {
                    Text(LocalizedString.Share.achievementUnlocked)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(achievement.name)
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)

                    Text(achievement.description)
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 60)
                }

                // Tier badge
                HStack(spacing: 14) {
                    Image(systemName: achievement.tier.icon)
                        .font(.system(size: 28))
                    Text(achievement.tier.displayName)
                        .font(.system(size: 30, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(achievement.tier.color)
                        .shadow(color: achievement.tier.color.opacity(0.4), radius: 10)
                )

                Spacer()

                // StandFit branding footer
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 36))
                        Text(LocalizedString.General.appName)
                            .font(.system(size: 38, weight: .bold))
                    }
                    .foregroundStyle(.primary)

                    Text(LocalizedString.Share.appTagline)
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 70)
            }
            .padding(.horizontal, 60)
        }
    }
}

#Preview {
    // Preview with a sample achievement
    let sampleAchievement = Achievement(
        id: "first_steps",
        name: "First Steps",
        description: "Complete your first exercise",
        icon: "figure.walk",
        category: .milestone,
        tier: .bronze,
        requirement: .totalSessions(1),
        unlockedAt: Date(),
        progress: 1
    )

    AchievementShareView(achievement: sampleAchievement)
        .frame(width: 1080, height: 1080)
}
