//
//  ProgressChartsView.swift
//  StandFit iOS
//
//  Charts and breakdown visualization for exercise progress
//

import SwiftUI
import Charts
import StandFitCore

struct ProgressChartsView: View {
    let period: ReportPeriod
    @ObservedObject var store: ExerciseStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Activity chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.headline)
                    .fontWeight(.semibold)

                Chart(chartData) { point in
                    ForEach(point.breakdown, id: \.exerciseId) { item in
                        BarMark(
                            x: .value("Day", point.label),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(item.color)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .today:
            // Show last 7 days in chronological order (oldest to newest)
            var points: [ChartDataPoint] = []

            for daysAgo in (0..<7).reversed() {
                guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: date)
                guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

                let dayLogs = store.logs.filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
                let breakdown = calculateBreakdown(for: dayLogs)

                let weekday = calendar.component(.weekday, from: date)
                points.append(ChartDataPoint(label: dayLabel(weekday), breakdown: breakdown, date: date))
            }

            return points

        case .weekStarting(let start):
            // Show each day of week in order (Sunday to Saturday)
            var points: [ChartDataPoint] = []
            let safeStart = calendar.startOfDay(for: start)

            for dayOffset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: safeStart) else { continue }
                let dayStart = calendar.startOfDay(for: date)
                guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

                let dayLogs = store.logs.filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
                let breakdown = calculateBreakdown(for: dayLogs)

                let weekday = calendar.component(.weekday, from: date)
                points.append(ChartDataPoint(label: dayLabel(weekday), breakdown: breakdown, date: date))
            }

            return points

        case .monthStarting(let start):
            // Show weekly totals for the month (4 weeks)
            var points: [ChartDataPoint] = []
            let safeStart = calendar.startOfDay(for: start)

            for weekOffset in 0..<4 {
                guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: safeStart) else { continue }
                let weekStartDay = calendar.startOfDay(for: weekStart)
                guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStartDay) else { continue }

                let weekLogs = store.logs.filter { $0.timestamp >= weekStartDay && $0.timestamp < weekEnd }
                let breakdown = calculateBreakdown(for: weekLogs)

                points.append(ChartDataPoint(label: "W\(weekOffset + 1)", breakdown: breakdown, date: weekStartDay))
            }

            return points

        default:
            return []
        }
    }

    private func calculateBreakdown(for logs: [ExerciseLog]) -> [ExerciseChartItem] {
        // Group logs by exercise
        var exerciseCounts: [String: (item: ExerciseItem, count: Int)] = [:]

        for log in logs {
            // Convert log to ExerciseItem (skip if deleted)
            guard let item = toExerciseItem(log) else { continue }
            let key = item.id

            if let existing = exerciseCounts[key] {
                exerciseCounts[key] = (existing.item, existing.count + log.count)
            } else {
                exerciseCounts[key] = (item, log.count)
            }
        }

        // Convert to chart items with assigned colors
        return exerciseCounts.map { key, value in
            ExerciseChartItem(
                exerciseId: key,
                exerciseName: value.item.name,
                count: value.count,
                color: ExerciseColorPalette.color(for: value.item)
            )
        }.sorted { $0.count > $1.count } // Sort by count for consistent stacking
    }

    private func toExerciseItem(_ log: ExerciseLog) -> ExerciseItem? {
        if let exerciseType = log.exerciseType {
            return ExerciseItem(builtIn: exerciseType)
        } else if let customId = log.customExerciseId,
                  let customExercise = store.customExercises.first(where: { $0.id == customId }) {
            return ExerciseItem(custom: customExercise)
        } else {
            // Skip deleted custom exercises
            return nil
        }
    }

    private func dayLabel(_ weekday: Int) -> String {
        ["", "S", "M", "T", "W", "T", "F", "S"][weekday]
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let breakdown: [ExerciseChartItem]
    let date: Date
}

struct ExerciseChartItem: Identifiable {
    let id = UUID()
    let exerciseId: String
    let exerciseName: String
    let count: Int
    let color: Color
}

// MARK: - Exercise Breakdown View

struct ExerciseBreakdownView: View {
    let breakdown: [ExerciseBreakdown]
    let period: ReportPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            if breakdown.isEmpty {
                Text("No activity logged")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(breakdown, id: \.exercise.id) { item in
                        ExerciseBreakdownRow(
                            name: item.exercise.name,
                            count: item.count,
                            percentage: item.percentage,
                            color: exerciseColor(item.exercise)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    private func exerciseColor(_ item: ExerciseItem) -> Color {
        return ExerciseColorPalette.color(for: item)
    }
}

struct ExerciseBreakdownRow: View {
    let name: String
    let count: Int
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(name)
                .font(.body)
                .lineLimit(1)

            Spacer()

            // Percentage bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray3))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 50 * percentage, height: 6)
            }
            .frame(width: 50)

            Text("\(count)")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    VStack {
        ProgressChartsView(period: .today, store: ExerciseStore.shared)
        ExerciseBreakdownView(breakdown: [], period: .today)
    }
    .padding()
}
