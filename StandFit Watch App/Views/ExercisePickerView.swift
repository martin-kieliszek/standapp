//
//  ExercisePickerView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/01/2026.
//

import SwiftUI
import StandFitCore

/// A reusable exercise picker grid that can be embedded in ContentView
/// or presented full-screen when launched from a notification.
/// Now supports both built-in and custom exercises via ExerciseItem.
struct ExercisePickerView: View {
    @ObservedObject var store: ExerciseStore = ExerciseStore.shared
    let onSelect: (ExerciseItem) -> Void

    private let notificationManager = NotificationManager.shared

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(store.allExercises) { item in
                ExercisePickerButton(item: item) {
                    notificationManager.playClickHaptic()
                    onSelect(item)
                }
            }
        }
    }
}

/// Individual exercise button for the picker grid
struct ExercisePickerButton: View {
    let item: ExerciseItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.title3)
                Text(item.name)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(item.isBuiltIn ? .green : .blue)
    }
}

/// Full-screen exercise picker presented when launched from notification.
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
                        .font(.headline)
                        .padding(.top, 8)

                    ExercisePickerView(store: store) { item in
                        selectedExerciseItem = item
                    }
                    .padding(.horizontal, 8)
                }
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
