//
//  HistoryView.swift
//  StandFit iOS
//
//  Shows exercise history grouped by day with swipe-to-delete
//

import SwiftUI
import StandFitCore

struct HistoryView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if store.logs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text(LocalizedString.UI.noExercisesYet)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(LocalizedString.History.noHistory)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(groupedLogs, id: \.date) { group in
                            Section {
                                ForEach(group.logs, id: \.id) { log in
                                    LogRow(log: log, store: store)
                                }
                                .onDelete { indexSet in
                                    deleteLog(from: group, at: indexSet)
                                }
                            } header: {
                                Text(formatDate(group.date))
                                    .fontWeight(.semibold)
                            } footer: {
                                Text(LocalizedString.Stats.totalExercises(group.totalCount))
                                    .font(.caption2)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(LocalizedString.History.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.General.done) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Group logs by date
    private var groupedLogs: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: store.logs) { log in
            calendar.startOfDay(for: log.timestamp)
        }
        
        return grouped.map { date, logs in
            DayGroup(
                date: date,
                logs: logs.sorted { $0.timestamp > $1.timestamp },
                totalCount: logs.reduce(0) { $0 + $1.count }
            )
        }.sorted { $0.date > $1.date }
    }
    
    private func deleteLog(from group: DayGroup, at indexSet: IndexSet) {
        for index in indexSet {
            let log = group.logs[index]
            store.deleteLog(log)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return LocalizedString.UI.today
        } else if calendar.isDateInYesterday(date) {
            return LocalizedString.History.yesterday
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Supporting Types

struct DayGroup {
    let date: Date
    let logs: [ExerciseLog]
    let totalCount: Int
}

struct LogRow: View {
    let log: ExerciseLog
    let store: ExerciseStore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exerciseIcon)
                .foregroundStyle(exerciseColor)
                .frame(width: 32)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseName)
                    .font(.headline)
                Text(formatTime(log.timestamp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(displayCount)
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }

    // Determine the unit type from the exercise
    private var unitType: ExerciseUnitType {
        if let exerciseType = log.exerciseType {
            return exerciseType.unitType
        } else if let customId = log.customExerciseId,
                  let custom = store.customExercise(byId: customId) {
            return custom.unitType
        }
        return .reps // default fallback
    }

    // Format the count with appropriate units (especially for time-based exercises)
    private var displayCount: String {
        switch unitType {
        case .reps:
            return "\(log.count)"
        case .seconds:
            // Show seconds if < 60, otherwise show as minutes
            if log.count >= 60 {
                let minutes = log.count / 60
                let seconds = log.count % 60
                if seconds > 0 {
                    return "\(minutes)m \(seconds)s"
                } else {
                    return "\(minutes)m"
                }
            } else {
                return "\(log.count)s"
            }
        case .minutes:
            return "\(log.count)m"
        }
    }

    private var exerciseIcon: String {
        if let exerciseType = log.exerciseType {
            return exerciseType.icon
        } else if let customId = log.customExerciseId,
                  let customExercise = store.customExercise(byId: customId) {
            return customExercise.icon
        }
        return "figure.walk" // Fallback icon
    }

    private var exerciseName: String {
        if let exerciseType = log.exerciseType {
            return exerciseType.displayName
        } else if let customId = log.customExerciseId,
                  let customExercise = store.customExercise(byId: customId) {
            return customExercise.name
        }
        return "Unknown Exercise"
    }

    private var exerciseColor: Color {
        if let exerciseType = log.exerciseType {
            return ExerciseColorPalette.color(for: ExerciseItem(builtIn: exerciseType))
        } else if let customId = log.customExerciseId,
                  let custom = store.customExercise(byId: customId) {
            return ExerciseColorPalette.color(for: ExerciseItem(custom: custom))
        }
        return .gray
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView(store: ExerciseStore.shared)
}
