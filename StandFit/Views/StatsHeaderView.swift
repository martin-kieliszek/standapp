//
//  StatsHeaderView.swift
//  StandFit iOS
//
//  Displays key statistics for a reporting period
//

import SwiftUI
import StandFitCore

struct StatsHeaderView: View {
    let stats: ReportStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Total count
            HStack(alignment: .firstTextBaseline) {
                Text("\(stats.totalCount)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("rep\(stats.totalCount == 1 ? "" : "s")")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // Comparison to previous period
            if let comparison = stats.comparisonToPrevious {
                HStack(spacing: 8) {
                    Image(systemName: comparison >= 0 ? "arrow.up" : "arrow.down")
                        .font(.body)
                        .foregroundStyle(comparison >= 0 ? .green : .orange)

                    Text("\(abs(Int(comparison * 100)))%")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("vs previous period")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            // Streak indicator
            if let streak = stats.streak, streak > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.body)

                    Text("\(streak)-day streak")
                        .font(.headline)

                    if streak >= 7 {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.body)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatsHeaderView(stats: ReportStats(
        totalCount: 42,
        periodStart: Date(),
        periodEnd: Date(),
        breakdown: [],
        comparisonToPrevious: 0.15,
        streak: 7
    ))
    .padding()
}
