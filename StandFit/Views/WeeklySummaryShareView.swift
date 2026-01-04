//
//  WeeklySummaryShareView.swift
//  StandFit iOS
//
//  Beautiful shareable image template for weekly progress summary
//

import SwiftUI
import StandFitCore

/// View designed to be rendered as a 1080x1080 shareable image for weekly summaries
struct WeeklySummaryShareView: View {
    let totalCount: Int
    let activeDays: Int
    let topExercise: ExerciseBreakdown?
    let streakDays: Int?
    let dateRange: String

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.1),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 45) {
                Spacer()

                // Header
                VStack(spacing: 16) {
                    Text(LocalizedString.Share.weeklySummary)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(dateRange)
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }

                // Main stats grid
                VStack(spacing: 24) {
                    HStack(spacing: 24) {
                        // Total exercises
                        StatBox(
                            icon: "flame.fill",
                            value: "\(totalCount)",
                            label: LocalizedString.WeeklyInsights.totalActivitySubtitle,
                            color: .orange
                        )

                        // Active days
                        StatBox(
                            icon: "calendar",
                            value: "\(activeDays)/7",
                            label: LocalizedString.WeeklyInsights.consistencySubtitle,
                            color: .green
                        )
                    }

                    // Top exercise (if available)
                    if let topExercise = topExercise {
                        HStack(spacing: 16) {
                            Image(systemName: topExercise.exercise.icon)
                                .font(.system(size: 44))
                                .foregroundStyle(.blue)
                                .frame(width: 60)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(topExercise.exercise.name)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.primary)

                                Text(LocalizedString.WeeklyInsights.topExerciseSubtitle)
                                    .font(.system(size: 22))
                                    .foregroundStyle(.secondary)

                                Text(LocalizedString.WeeklyInsights.timesCount(topExercise.count))
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(.blue)
                            }

                            Spacer()
                        }
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.08))
                        )
                    }

                    // Streak (if available)
                    if let streakDays = streakDays, streakDays > 0 {
                        HStack(spacing: 16) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 60)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(streakDays) \(LocalizedString.WeeklyInsights.streakDaySingular)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.primary)

                                Text(LocalizedString.WeeklyInsights.streakTitle)
                                    .font(.system(size: 22))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.12), .red.opacity(0.08)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                .padding(.horizontal, 40)

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
            .padding(.horizontal, 50)
        }
    }
}

/// Stat box component for weekly summary
private struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(label)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(color.opacity(0.08))
        )
    }
}

#Preview {
    // Preview with sample data
    let sampleExercise = ExerciseItem(builtIn: .pushups)

    let sampleBreakdown = ExerciseBreakdown(
        exercise: sampleExercise,
        count: 15,
        totalAmount: 150,
        percentage: 0.45
    )

    WeeklySummaryShareView(
        totalCount: 42,
        activeDays: 5,
        topExercise: sampleBreakdown,
        streakDays: 12,
        dateRange: "Jan 1 – Jan 7"
    )
    .frame(width: 1080, height: 1080)
}
