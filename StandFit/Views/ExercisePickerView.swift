//
//  ExercisePickerView.swift
//  StandFit iOS
//
//  iOS-optimized exercise picker with larger grid layout for iPhone
//

import SwiftUI
import StandFitCore

/// A reusable exercise picker grid optimized for iPhone (3-4 columns)
/// Supports both built-in and custom exercises via ExerciseItem.
struct ExercisePickerView: View {
    @ObservedObject var store: ExerciseStore = ExerciseStore.shared
    let onSelect: (ExerciseItem) -> Void

    private let notificationManager = NotificationManager.shared

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(store.allExercises) { item in
                ExercisePickerButton(item: item) {
                    notificationManager.playClickHaptic()
                    onSelect(item)
                }
            }
        }
    }
}

/// Individual exercise button for the picker grid (iOS-sized)
struct ExercisePickerButton: View {
    let item: ExerciseItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(item.isBuiltIn ? .blue : .green)
                
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
    }
}

/// Full-screen exercise picker presented from main view
/// Shows a title and the exercise grid, then opens the logger.
struct ExercisePickerFullScreenView: View {
    @ObservedObject var store: ExerciseStore
    @Binding var selectedExerciseItem: ExerciseItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("What did you do?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)

                    ExercisePickerView(store: store) { item in
                        selectedExerciseItem = item
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.vertical, 16)
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
            .sheet(item: $selectedExerciseItem) { item in
                ExerciseLoggerView(
                    store: store,
                    exerciseItem: item
                )
            }
        }
    }
}

#Preview("Picker Grid") {
    ExercisePickerView { item in
        print("Selected: \(item.name)")
    }
    .padding()
}

#Preview("Full Screen") {
    ExercisePickerFullScreenView(
        store: ExerciseStore.shared,
        selectedExerciseItem: .constant(nil)
    )
}
