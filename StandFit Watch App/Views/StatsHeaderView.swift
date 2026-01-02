//
//  StatsHeaderView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/01/2026.
//

import SwiftUI
import StandFitCore

struct StatsHeaderView: View {
    let stats: ReportStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Total count
            HStack(alignment: .firstTextBaseline) {
                Text("\(stats.totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("rep\(stats.totalCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Comparison to previous period
            if let comparison = stats.comparisonToPrevious {
                HStack(spacing: 4) {
                    Image(systemName: comparison >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                        .foregroundStyle(comparison >= 0 ? .green : .orange)

                    Text("\(abs(Int(comparison * 100)))%")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Text("vs previous period")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Streak indicator
            if let streak = stats.streak, streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)

                    Text("\(streak)-day streak")
                        .font(.caption)

                    if streak >= 7 {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
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
}
