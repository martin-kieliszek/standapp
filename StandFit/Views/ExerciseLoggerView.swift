//
//  ExerciseLoggerView.swift
//  StandFit iOS
//
//  Enhanced exercise logger with modern, engaging design
//

import SwiftUI
import StandFitCore

struct ExerciseLoggerView: View {
    @ObservedObject var store: ExerciseStore
    let exerciseItem: ExerciseItem

    @Environment(\.dismiss) private var dismiss
    @State private var count: Int
    @State private var showSuccessAnimation = false

    private let notificationManager = NotificationManager.shared

    /// Initialize with a unified ExerciseItem (handles both built-in and custom)
    init(store: ExerciseStore, exerciseItem: ExerciseItem) {
        self.store = store
        self.exerciseItem = exerciseItem
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
            ZStack {
                // Animated gradient background based on exercise color
                LinearGradient(
                    colors: [
                        ExerciseColorPalette.color(for: exerciseItem).opacity(0.08),
                        Color.white,
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Exercise Header with Icon
                        exerciseHeader

                        // Count Display Card
                        countDisplayCard

                        // Controls Section
                        VStack(spacing: 24) {
                            // Main +/- buttons
                            adjustmentButtons

                            // Quick add buttons
                            quickAddButtons
                        }

                        // Save button (prominent)
                        saveButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(LocalizedString.ExerciseLogger.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if showSuccessAnimation {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Exercise Header

    private var exerciseHeader: some View {
        VStack(spacing: 16) {
            // Icon with gradient circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ExerciseColorPalette.color(for: exerciseItem),
                                ExerciseColorPalette.color(for: exerciseItem).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: ExerciseColorPalette.color(for: exerciseItem).opacity(0.4), radius: 12, x: 0, y: 6)

                Image(systemName: exerciseItem.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }

            // Exercise name
            Text(exerciseItem.name)
                .font(.title)
                .fontWeight(.bold)

            Text(LocalizedString.ExerciseLogger.adjustCountInstruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Count Display Card

    private var countDisplayCard: some View {
        VStack(spacing: 12) {
            // Large count number
            Text("\(count)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ExerciseColorPalette.color(for: exerciseItem),
                            ExerciseColorPalette.color(for: exerciseItem).opacity(0.7)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())

            // Unit label
            Text(exerciseItem.unitType.unitLabel)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            ExerciseColorPalette.color(for: exerciseItem).opacity(0.2),
                            ExerciseColorPalette.color(for: exerciseItem).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }

    // MARK: - Adjustment Buttons

    private var adjustmentButtons: some View {
        HStack(spacing: 32) {
            // Minus button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if count > stepAmount {
                        count -= stepAmount
                        notificationManager.playClickHaptic()
                    } else if count > 1 {
                        count = 1
                        notificationManager.playClickHaptic()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: "minus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Plus button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    count += stepAmount
                    notificationManager.playClickHaptic()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Add Buttons

    private var quickAddButtons: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text(LocalizedString.ExerciseLogger.quickAddHeader)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(quickIncrements, id: \.self) { increment in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            count += increment
                            notificationManager.playClickHaptic()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.caption)
                            Text("\(increment)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ExerciseColorPalette.color(for: exerciseItem).opacity(0.1))
                        )
                        .foregroundStyle(ExerciseColorPalette.color(for: exerciseItem))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(ExerciseColorPalette.color(for: exerciseItem).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveExercise()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                Text(LocalizedString.ExerciseLogger.saveButton(count: count, unit: exerciseItem.unitType.unitLabel))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                ExerciseColorPalette.color(for: exerciseItem),
                                ExerciseColorPalette.color(for: exerciseItem).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: ExerciseColorPalette.color(for: exerciseItem).opacity(0.4), radius: 12, x: 0, y: 6)
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showSuccessAnimation ? 1.0 : 0.5)
                .opacity(showSuccessAnimation ? 1.0 : 0.0)

                VStack(spacing: 8) {
                    Text(LocalizedString.ExerciseLogger.loggedSuccess)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(LocalizedString.ExerciseLogger.loggedSuccessDetail(count: count, unit: exerciseItem.unitType.unitLabel, exerciseName: exerciseItem.name))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(showSuccessAnimation ? 1.0 : 0.0)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .shadow(radius: 20)
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

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
        case .reps: return [5, 10, 20]
        case .seconds: return [15, 30, 60]
        case .minutes: return [5, 10, 15]
        }
    }

    private func saveExercise() {
        // Convert display value to storage value (e.g., minutes → seconds)
        let storageCount = exerciseItem.unitType.toStorageValue(count)
        store.logExercise(item: exerciseItem, count: storageCount)

        // Show success animation
        withAnimation(.spring(response: 0.5)) {
            showSuccessAnimation = true
        }

        notificationManager.playSuccessHaptic()

        // Reschedule the next reminder
        if store.remindersEnabled {
            notificationManager.scheduleReminderWithSchedule(store: store)
        }

        // Dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
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
