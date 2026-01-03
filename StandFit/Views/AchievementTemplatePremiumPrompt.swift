//
//  AchievementTemplatePremiumPrompt.swift
//  StandFit
//
//  Premium paywall for achievement templates (UX16)
//

import SwiftUI

struct AchievementTemplatePremiumPrompt: View {
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Hero icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "star.square.on.square.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 20)

            // Title
            VStack(spacing: 8) {
                Text("Create Custom Achievement Templates")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Design personalized achievements for your custom exercises")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Feature benefits
            VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                    icon: "target",
                    color: .purple,
                    text: "Set your own achievement targets and goals"
                )

                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue,
                    text: "Track progress automatically as you exercise"
                )

                BenefitRow(
                    icon: "sparkles",
                    color: .pink,
                    text: "Choose from 5 template types: Volume, Daily, Weekly, Streak, and Speed"
                )

                BenefitRow(
                    icon: "infinity",
                    color: .orange,
                    text: "Create unlimited templates with Premium"
                )
            }
            .padding(.horizontal)

            Spacer()

            // CTA
            VStack(spacing: 12) {
                Button {
                    onUpgrade()
                } label: {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text("14-day free trial • Cancel anytime")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Supporting Views

private struct BenefitRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

#Preview {
    AchievementTemplatePremiumPrompt {
        print("Upgrade tapped")
    }
}
