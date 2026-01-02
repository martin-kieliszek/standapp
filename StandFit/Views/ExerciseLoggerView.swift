//
//  ExerciseLoggerView.swift
//  StandFit iOS
//
//  iOS-optimized exercise logger with larger buttons and display for iPhone
//

import SwiftUI
import StandFitCore

struct ExerciseLoggerView: View {
    @ObservedObject var store: ExerciseStore
    let exerciseItem: ExerciseItem

    @Environment(\.dismiss) private var dismiss
    @State private var count: Int

    private let notificationManager = NotificationManager.shared

    /// Initialize with a unified ExerciseItem (handles both built-in and custom)
    init(store: ExerciseStore, exerciseItem: ExerciseItem) {
        self.store = store
        self.exerciseItem = exerciseItem
        // For display, convert storage value to display value (e.g., seconds → minutes)
        _count = State(initialValue: exerciseItem.unitType.toDisplayValue(exerciseItem.defaultCount))
    }

    /// Convenience initializer for built-in exercise types (backwards compatibility)
    init(store: ExerciseStore, exerciseType: ExerciseType) {
        self.store = store
        self.exerciseItem = ExerciseItem(builtIn: exerciseType)
        _count = State(initialValue: exerciseType.unitType.toDisplayValue(exerciseType.defaultCount))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Exercise icon
                    Image(systemName: exerciseItem.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(ExerciseColorPalette.color(for: exerciseItem))

                    Text(exerciseItem.name)
                        .font(.title)
                        .fontWeight(.bold)

                    // Count display
                    VStack(spacing: 8) {
                        Text("\(count)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        Text(exerciseItem.unitType.unitLabel)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Increment/Decrement buttons (larger for iOS)
                    HStack(spacing: 24) {
                        Button {
                            if count > stepAmount {
                                count -= stepAmount
                                notificationManager.playClickHaptic()
                            } else if count > 1 {
                                count = 1
                                notificationManager.playClickHaptic()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.red)
                        }

                        Spacer()

                        Button {
                            count += stepAmount
                            notificationManager.playClickHaptic()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Quick increment buttons
                    VStack(spacing: 12) {
                        Text("Quick add")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            ForEach(quickIncrements, id: \.self) { increment in
                                Button("+\(increment)") {
                                    count += increment
                                    notificationManager.playClickHaptic()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .buttonStyle(.bordered)
                                .tint(.blue)
                            }
                        }
                    }

                    // Save button
                    Button {
                        saveExercise()
                    } label: {
                        Label("Save Exercise", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    /// Step amount for +/- buttons
    private var stepAmount: Int {
        switch exerciseItem.unitType {
        case .reps: return 1
        case .seconds: return 5
        case .minutes: return 1
        }
    }

    /// Quick increment values based on unit type
    private var quickIncrements: [Int] {
        switch exerciseItem.unitType {
        case .reps: return [5, 10]
        case .seconds: return [15, 30]
        case .minutes: return [5, 10]
        }
    }

    private func saveExercise() {
        // Convert display value to storage value (e.g., minutes → seconds)
        let storageCount = exerciseItem.unitType.toStorageValue(count)
        store.logExercise(item: exerciseItem, count: storageCount)
        notificationManager.playSuccessHaptic()

        // Reschedule the next reminder
        if store.remindersEnabled {
            notificationManager.scheduleReminderWithSchedule(store: store)
        }

        dismiss()
    }
}

#Preview("Built-in Exercise") {
    ExerciseLoggerView(
        store: ExerciseStore.shared,
        exerciseType: .squats
    )
}

#Preview("Seconds Exercise") {
    ExerciseLoggerView(
        store: ExerciseStore.shared,
        exerciseType: .plank
    )
}

#Preview("Custom Exercise - Reps") {
    ExerciseLoggerView(
        store: ExerciseStore.shared,
        exerciseItem: ExerciseItem(custom: CustomExercise(
            name: "Burpees",
            icon: "figure.jumprope",
            unitType: .reps,
            defaultCount: 15
        ))
    )
}

#Preview("Custom Exercise - Minutes") {
    ExerciseLoggerView(
        store: ExerciseStore.shared,
        exerciseItem: ExerciseItem(custom: CustomExercise(
            name: "Walking",
            icon: "figure.walk",
            unitType: .minutes,
            defaultCount: 900  // 15 minutes stored as 900 seconds
        ))
    )
}
