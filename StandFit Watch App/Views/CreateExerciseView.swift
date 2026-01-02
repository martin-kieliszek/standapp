//
//  CreateExerciseView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/01/2026.
//

import SwiftUI
import StandFitCore

/// View for creating or editing a custom exercise
struct CreateExerciseView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    /// If editing an existing exercise, pass it here
    var existingExercise: CustomExercise?

    @State private var name: String
    @State private var icon: String
    @State private var unitType: ExerciseUnitType
    @State private var defaultCount: Int
    @State private var showingSaveConfirmation = false
    @State private var showingDeleteConfirmation = false

    private var isEditing: Bool {
        existingExercise != nil
    }

    init(store: ExerciseStore, existingExercise: CustomExercise? = nil) {
        self.store = store
        self.existingExercise = existingExercise

        // Initialize @State variables from existing exercise or defaults
        if let exercise = existingExercise {
            _name = State(initialValue: exercise.name)
            _icon = State(initialValue: exercise.icon)
            _unitType = State(initialValue: exercise.unitType)
            _defaultCount = State(initialValue: exercise.defaultCount)
        } else {
            _name = State(initialValue: "")
            _icon = State(initialValue: "figure.stand")
            _unitType = State(initialValue: .reps)
            _defaultCount = State(initialValue: 10)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Preview text showing what the default will look like
    private var defaultPreview: String {
        "\(displayCount) \(unitType.unitLabel)"
    }

    /// Display value (converts storage to display for minutes)
    private var displayCount: Int {
        unitType.toDisplayValue(defaultCount)
    }

    /// Set display value (converts display to storage for minutes)
    private func setDisplayCount(_ value: Int) {
        defaultCount = unitType.toStorageValue(value)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Name Input Section
                nameSection

                // Icon Selection
                iconSection

                // Unit Type Selection
                unitTypeSection

                // Default Count
                defaultCountSection

                // Preview
                previewSection

                // Save Button
                Button {
                    saveExercise()
                } label: {
                    Label("Save Exercise", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .disabled(!isValid)

                // Delete Button (only when editing)
                if isEditing {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle(isEditing ? "Edit Exercise" : "New Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete Exercise?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the exercise. Your logged data will be kept.")
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Name")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Exercise name", text: $name)
                .textInputAutocapitalization(.words)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Icon")
                .font(.caption)
                .foregroundStyle(.secondary)

            IconPickerButton(selectedIcon: $icon)
        }
    }

    private var unitTypeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Measured In")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Unit Type", selection: $unitType) {
                ForEach(ExerciseUnitType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
            .onChange(of: unitType) { oldValue, newValue in
                // Convert the current count when switching unit types
                if oldValue.isTimeBased && newValue.isTimeBased {
                    // Converting between time units (seconds ↔ minutes)
                    let currentDisplay = oldValue.toDisplayValue(defaultCount)
                    defaultCount = newValue.toStorageValue(currentDisplay)
                } else if !oldValue.isTimeBased && newValue.isTimeBased {
                    // Switching from reps to time - use sensible default
                    defaultCount = newValue.toStorageValue(newValue == .minutes ? 5 : 30)
                } else if oldValue.isTimeBased && !newValue.isTimeBased {
                    // Switching from time to reps - use sensible default
                    defaultCount = 10
                }
            }

            Text(unitTypeDescription)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var unitTypeDescription: String {
        switch unitType {
        case .reps:
            return "Count repetitions (e.g., 10 pushups)"
        case .seconds:
            return "Count seconds (e.g., 30 second plank)"
        case .minutes:
            return "Count minutes (e.g., 15 minute walk)"
        }
    }

    private var defaultCountSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Default \(unitType.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button {
                    let currentDisplay = displayCount
                    if currentDisplay > 1 {
                        setDisplayCount(currentDisplay - stepAmount)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Text("\(displayCount)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .frame(minWidth: 50)

                Button {
                    let currentDisplay = displayCount
                    setDisplayCount(currentDisplay + stepAmount)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity)

            Text("This is the starting value when logging")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var previewSection: some View {
        VStack(spacing: 8) {
            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name.isEmpty ? "Exercise Name" : name)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(defaultPreview)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Helpers

    private var stepAmount: Int {
        switch unitType {
        case .reps: return 1
        case .seconds: return 5
        case .minutes: return 1
        }
    }

    private func saveExercise() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let existing = existingExercise {
            // Update existing
            var updated = existing
            updated.name = trimmedName
            updated.icon = icon
            updated.unitType = unitType
            updated.defaultCount = defaultCount
            store.updateCustomExercise(updated)
        } else {
            // Create new
            let newExercise = CustomExercise(
                name: trimmedName,
                icon: icon,
                unitType: unitType,
                defaultCount: defaultCount
            )
            store.addCustomExercise(newExercise)
        }

        NotificationManager.shared.playClickHaptic()
        dismiss()
    }

    private func deleteExercise() {
        if let exercise = existingExercise {
            store.deleteCustomExercise(exercise)
        }
        dismiss()
    }
}

/// List view for managing custom exercises (shown in Settings)
struct CustomExerciseListView: View {
    @ObservedObject var store: ExerciseStore
    @State private var showingCreateView = false

    var body: some View {
        List {
            // Built-in exercises (read-only info)
            Section {
                ForEach(ExerciseType.allCases) { exercise in
                    HStack {
                        Image(systemName: exercise.icon)
                            .foregroundStyle(.blue)
                        Text(exercise.rawValue)
                        Spacer()
                        Text("\(exercise.defaultCount)\(exercise.unitType.unitLabelShort)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            } header: {
                Text("Built-in")
            }

            // Custom exercises (editable)
            Section {
                ForEach(store.customExercises) { exercise in
                    NavigationLink {
                        CreateExerciseView(
                            store: store,
                            existingExercise: exercise
                        )
                    } label: {
                        HStack {
                            Image(systemName: exercise.icon)
                                .foregroundStyle(.green)
                            Text(exercise.name)
                            Spacer()
                            Text("\(exercise.defaultCountDisplay)\(exercise.unitType.unitLabelShort)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        store.deleteCustomExercise(store.customExercises[index])
                    }
                }
                .onMove { source, destination in
                    store.moveCustomExercise(from: source, to: destination)
                }

                Button {
                    showingCreateView = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle")
                }
                .foregroundStyle(.green)
            } header: {
                Text("Custom")
            } footer: {
                if store.customExercises.isEmpty {
                    Text("Tap + to create your own exercises")
                }
            }
        }
        .navigationTitle("Exercises")
        .sheet(isPresented: $showingCreateView) {
            NavigationStack {
                CreateExerciseView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingCreateView = false
                            }
                        }
                    }
            }
        }
    }
}

#Preview("Create Exercise") {
    NavigationStack {
        CreateExerciseView(store: ExerciseStore.shared)
    }
}

#Preview("Exercise List") {
    NavigationStack {
        CustomExerciseListView(store: ExerciseStore.shared)
    }
}
