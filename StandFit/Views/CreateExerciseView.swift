//
//  CreateExerciseView.swift
//  StandFit iOS
//
//  iOS-optimized view for creating/editing custom exercises
//

import SwiftUI
import StandFitCore

/// View for creating or editing a custom exercise, adapted for iOS layout
struct CreateExerciseView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    /// If editing an existing exercise, pass it here
    var existingExercise: CustomExercise?

    @State private var name: String
    @State private var icon: String
    @State private var unitType: ExerciseUnitType
    @State private var defaultCount: Int
    @State private var showingDeleteConfirmation = false
    @State private var showPaywall = false
    @State private var previousUnitType: ExerciseUnitType

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
            _previousUnitType = State(initialValue: exercise.unitType)
        } else {
            _name = State(initialValue: "")
            _icon = State(initialValue: "figure.stand")
            _unitType = State(initialValue: .reps)
            _defaultCount = State(initialValue: 10)
            _previousUnitType = State(initialValue: .reps)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Preview text showing what the default will look like
    private var defaultPreview: String {
        unitType.toDisplayValue(defaultCount).description + unitType.unitLabelShort
    }

    var body: some View {
        Form {
            // Premium check for custom exercise limit
            if !isEditing && !store.canCreateCustomExercise {
                Section {
                    PremiumPrompt(
                        feature: "Create unlimited custom exercises",
                        icon: "lock.fill",
                        onUpgrade: {
                            showPaywall = true
                        }
                    )
                }
            } else {
                // Name Input Section
                Section("Name") {
                    TextField("Exercise name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                // Icon Selection
                Section("Icon") {
                    IconPickerButton(selectedIcon: $icon)
                }

                // Unit Type Selection
                Section("Measurement") {
                    Picker("Measured In", selection: $unitType) {
                        ForEach(ExerciseUnitType.allCases) {
                            type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: unitType) { newValue in
                        // Convert the current count when switching unit types
                        let oldValue = previousUnitType
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
                        previousUnitType = newValue
                    }
                    
                    Text(unitTypeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Default Count
            Section("Default Count") {
                HStack {
                    Button {
                        let currentDisplay = unitType.toDisplayValue(defaultCount)
                        if currentDisplay > 1 {
                            defaultCount = unitType.toStorageValue(currentDisplay - stepAmount)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)

                    Spacer()

                    Text("\(unitType.toDisplayValue(defaultCount))")
                        .font(.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .frame(minWidth: 60)

                    Spacer()

                    Button {
                        let currentDisplay = unitType.toDisplayValue(defaultCount)
                        defaultCount = unitType.toStorageValue(currentDisplay + stepAmount)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.green)
                }
                .padding(.vertical, 8)
                
                Text("This is the starting value when logging")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            // Preview
            Section("Preview") {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(name.isEmpty ? "Exercise Name" : name)
                            .font(.headline)
                        Text(defaultPreview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Save/Delete Buttons
            Section {
                Button {
                    saveExercise()
                } label: {
                    Label("\(isEditing ? "Update" : "Create") Exercise", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!isValid)

                if isEditing {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Exercise", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Exercise" : "New Exercise")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .confirmationDialog(
            "Delete Exercise?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the exercise. Your logged data will be kept.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: SubscriptionManager.shared)
        }
    }

    // MARK: - Helpers

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
            builtInSection
            customSection
        }
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
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

    @ViewBuilder
    private var builtInSection: some View {
        Section {
            ForEach(ExerciseType.allCases) { exercise in
                builtInExerciseRow(exercise)
            }
        } header: {
            Text("Built-in")
        }
    }

    private func builtInExerciseRow(_ exercise: ExerciseType) -> some View {
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

    private var customSection: some View {
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
