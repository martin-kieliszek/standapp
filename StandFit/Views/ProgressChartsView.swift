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
                Text(LocalizedString.Progress.activityTitle)
                    .font(.headline)
                    .fontWeight(.semibold)

                Chart(chartData) { point in
                    // Show stacked bars for each exercise type
                    // Note: Only hours with data will show bars (better readability than 24 empty bars)
                    if period == .today {
                        // For today view, use hour as numeric x-axis value
                        if point.breakdown.isEmpty {
                            // Show invisible placeholder to maintain x-axis continuity
                            BarMark(
                                x: .value("Hour", point.hourValue ?? 0),
                                y: .value("Count", 0)
                            )
                            .opacity(0)
                        } else {
                            ForEach(point.breakdown, id: \.exerciseId) { item in
                                BarMark(
                                    x: .value("Hour", point.hourValue ?? 0),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(item.color)
                            }
                        }
                    } else {
                        // For week/month views, use string labels
                        if point.breakdown.isEmpty {
                            BarMark(
                                x: .value("Day", point.label),
                                y: .value("Count", 0)
                            )
                            .opacity(0)
                        } else {
                            ForEach(point.breakdown, id: \.exerciseId) { item in
                                BarMark(
                                    x: .value("Day", point.label),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(item.color)
                            }
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    if period == .today {
                        // For hourly view with numeric x-axis
                        AxisMarks(position: .bottom, values: [0, 4, 8, 12, 16, 20]) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let hour = value.as(Int.self) {
                                    Text(hourLabelFormatted(hour))
                                        .font(.system(size: 10))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    } else {
                        // For daily/weekly view, show all labels
                        AxisMarks(position: .bottom) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let label = value.as(String.self) {
                                    Text(label)
                                        .font(.caption2)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(value.as(Int.self) ?? 0)")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                    }
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
            // Show hourly breakdown for today (00:00 to 23:00)
            var points: [ChartDataPoint] = []
            let todayStart = calendar.startOfDay(for: now)

            for hour in 0..<24 {
                guard let hourStart = calendar.date(byAdding: .hour, value: hour, to: todayStart),
                      let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) else { continue }

                let hourLogs = store.logs.filter { $0.timestamp >= hourStart && $0.timestamp < hourEnd }
                let breakdown = calculateBreakdown(for: hourLogs)

                // Format hour label (12am, 1am, 2am... 11am, 12pm, 1pm... 11pm)
                let hourLabel = hourLabelFormatted(hour)
                points.append(ChartDataPoint(label: hourLabel, breakdown: breakdown, date: hourStart, hourValue: hour))
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
                points.append(ChartDataPoint(label: dayLabel(weekday), breakdown: breakdown, date: date, hourValue: nil))
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

                points.append(ChartDataPoint(label: LocalizedString.Progress.weekNumber(weekOffset + 1), breakdown: breakdown, date: weekStartDay, hourValue: nil))
            }

            return points

        default:
            return []
        }
    }

    private func calculateBreakdown(for logs: [ExerciseLog]) -> [ExerciseChartItem] {
        // Group logs by exercise
        var exerciseAmounts: [String: (item: ExerciseItem, amount: Int)] = [:]

        for log in logs {
            // Convert log to ExerciseItem (skip if deleted)
            guard let item = toExerciseItem(log) else { continue }
            let key = item.id
            let amount = volumeAmount(for: item.unitType, storedValue: log.count)

            if let existing = exerciseAmounts[key] {
                exerciseAmounts[key] = (existing.item, existing.amount + amount)
            } else {
                exerciseAmounts[key] = (item, amount)
            }
        }

        // Convert to chart items with assigned colors
        return exerciseAmounts.map { key, value in
            ExerciseChartItem(
                exerciseId: key,
                exerciseName: value.item.name,
                count: value.amount,
                color: ExerciseColorPalette.color(for: value.item)
            )
        }.sorted { $0.count > $1.count } // Sort by amount for consistent stacking
    }

    private func volumeAmount(for unitType: ExerciseUnitType, storedValue: Int) -> Int {
        if unitType.isTimeBased {
            return minutesRoundedUp(fromSeconds: storedValue)
        }
        return storedValue
    }

    private func minutesRoundedUp(fromSeconds seconds: Int) -> Int {
        guard seconds > 0 else { return 0 }
        return Int(ceil(Double(seconds) / 60.0))
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
        switch weekday {
        case 1: return LocalizedString.Progress.daySunday
        case 2: return LocalizedString.Progress.dayMonday
        case 3: return LocalizedString.Progress.dayTuesday
        case 4: return LocalizedString.Progress.dayWednesday
        case 5: return LocalizedString.Progress.dayThursday
        case 6: return LocalizedString.Progress.dayFriday
        case 7: return LocalizedString.Progress.daySaturday
        default: return ""
        }
    }

    private func hourLabelFormatted(_ hour: Int) -> String {
        // Return compact hour labels: 12a, 1a, 2a... 12p, 1p, 2p...
        if hour == 0 {
            return "12a"
        } else if hour < 12 {
            return "\(hour)a"
        } else if hour == 12 {
            return "12p"
        } else {
            return "\(hour - 12)p"
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let breakdown: [ExerciseChartItem]
    let date: Date
    let hourValue: Int?
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

    private var sortedByVolume: [ExerciseBreakdown] {
        breakdown.sorted { volumeAmount(for: $0) > volumeAmount(for: $1) }
    }

    private var totalVolume: Int {
        sortedByVolume.reduce(0) { $0 + volumeAmount(for: $1) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedString.Progress.breakdownTitle)
                .font(.headline)
                .fontWeight(.semibold)

            if breakdown.isEmpty {
                Text(LocalizedString.Progress.noActivityLogged)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(sortedByVolume, id: \.exercise.id) { item in
                        let (value, unitLabel) = volumeDisplay(for: item)
                        let pct = totalVolume > 0 ? Double(value) / Double(totalVolume) : 0
                        ExerciseBreakdownRow(
                            name: item.exercise.name,
                            value: value,
                            unitLabel: unitLabel,
                            percentage: pct,
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

    private func volumeAmount(for item: ExerciseBreakdown) -> Int {
        if item.exercise.unitType.isTimeBased {
            return minutesRoundedUp(fromSeconds: item.totalAmount)
        }
        return item.totalAmount
    }

    private func volumeDisplay(for item: ExerciseBreakdown) -> (value: Int, unitLabel: String) {
        if item.exercise.unitType.isTimeBased {
            return (minutesRoundedUp(fromSeconds: item.totalAmount), LocalizedString.ExerciseUnitTypeName.minutesLabel)
        }
        return (item.totalAmount, item.exercise.unitType.unitLabel)
    }

    private func minutesRoundedUp(fromSeconds seconds: Int) -> Int {
        guard seconds > 0 else { return 0 }
        return Int(ceil(Double(seconds) / 60.0))
    }
}

struct ExerciseBreakdownRow: View {
    let name: String
    let value: Int
    let unitLabel: String
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

            Text("\(value) \(unitLabel)")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(minWidth: 64, alignment: .trailing)
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
