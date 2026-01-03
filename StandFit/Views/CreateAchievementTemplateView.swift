//
//  CreateAchievementTemplateView.swift
//  StandFit
//
//  View for creating and editing achievement templates (UX16)
//

import SwiftUI
import StandFitCore

struct CreateAchievementTemplateView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    /// If editing an existing template, pass it here
    var existingTemplate: AchievementTemplate?

    @State private var name: String
    @State private var templateType: AchievementTemplateType
    @State private var selectedExercise: ExerciseItem?
    @State private var tiers: [AchievementTemplateTier]
    @State private var isActive: Bool
    @State private var showingExercisePicker = false

    private var isEditing: Bool {
        existingTemplate != nil
    }

    init(
        gamificationStore: GamificationStore,
        exerciseStore: ExerciseStore,
        existingTemplate: AchievementTemplate? = nil,
        preselectedExercise: ExerciseItem? = nil
    ) {
        self.gamificationStore = gamificationStore
        self.exerciseStore = exerciseStore
        self.existingTemplate = existingTemplate

        if let template = existingTemplate {
            _name = State(initialValue: template.name)
            _templateType = State(initialValue: template.templateType)
            _tiers = State(initialValue: template.tiers)
            _isActive = State(initialValue: template.isActive)

            // Resolve exercise reference
            let resolved = template.exerciseReference.resolve(customExercises: exerciseStore.customExercises)
            _selectedExercise = State(initialValue: resolved)
        } else {
            _name = State(initialValue: "")
            _templateType = State(initialValue: .volume)
            _tiers = State(initialValue: AchievementTemplateType.volume.defaultTiers)
            _isActive = State(initialValue: true)
            _selectedExercise = State(initialValue: preselectedExercise)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedExercise != nil &&
        !tiers.isEmpty &&
        tiers.allSatisfy { $0.target > 0 }
    }

    var body: some View {
        Form {
            // Template Name
            Section(LocalizedString.Templates.templateNameSection) {
                TextField(LocalizedString.Templates.enterName, text: $name)
                    .textInputAutocapitalization(.words)
            }

            // Exercise Selection
            Section(LocalizedString.Templates.exercise) {
                if let exercise = selectedExercise {
                    HStack {
                        Image(systemName: exercise.icon)
                            .foregroundStyle(exercise.isBuiltIn ? .blue : .green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(.subheadline)
                            Text(exercise.isBuiltIn ? LocalizedString.Templates.builtIn : LocalizedString.Templates.custom)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(LocalizedString.Templates.change) {
                            showingExercisePicker = true
                        }
                        .font(.caption)
                    }
                } else {
                    Button {
                        showingExercisePicker = true
                    } label: {
                        Label(LocalizedString.Templates.selectExercise, systemImage: "plus.circle")
                    }
                }
            }

            // Template Type
            Section {
                Picker(LocalizedString.Templates.templateType, selection: $templateType) {
                    ForEach(AchievementTemplateType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: templateType) { newType in
                    // Reset tiers to defaults when type changes
                    tiers = newType.defaultTiers
                }

                Text(templateType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(LocalizedString.Templates.achievementType)
            }

            // Tiers Configuration
            Section {
                ForEach($tiers) { $tier in
                    TierConfigRow(
                        tier: $tier,
                        templateType: templateType,
                        exercise: selectedExercise
                    )
                }

                Button {
                    addTier()
                } label: {
                    Label(LocalizedString.Templates.addTier, systemImage: "plus.circle")
                }
                .disabled(tiers.count >= 4) // Max 4 tiers
            } header: {
                Text(LocalizedString.Templates.achievementTiers)
            } footer: {
                Text(LocalizedString.Templates.tierFooter)
            }

            // Active Toggle
            Section {
                Toggle(LocalizedString.Templates.templateActive, isOn: $isActive)
            } footer: {
                Text(LocalizedString.Templates.inactiveFooter)
            }

            // Save Button
            Section {
                Button {
                    saveTemplate()
                } label: {
                    Label(isEditing ? LocalizedString.Templates.updateTemplate : LocalizedString.Templates.createTemplate, systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(!isValid)
            }
        }
        .navigationTitle(isEditing ? LocalizedString.Templates.editTemplate : LocalizedString.Templates.newTemplate)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(LocalizedString.Templates.cancel) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            NavigationStack {
                ExerciseSelectionList(
                    exerciseStore: exerciseStore,
                    selectedExercise: $selectedExercise,
                    dismiss: {
                        showingExercisePicker = false
                    }
                )
            }
        }
    }

    // MARK: - Actions

    private func addTier() {
        let nextTier: AchievementTier
        if let lastTier = tiers.last?.tier {
            switch lastTier {
            case .bronze: nextTier = .silver
            case .silver: nextTier = .gold
            case .gold: nextTier = .platinum
            case .platinum: return // Can't add more
            }
        } else {
            nextTier = .bronze
        }

        let newTier = AchievementTemplateTier(
            tier: nextTier,
            target: (tiers.last?.target ?? 10) * 2,
            label: nil,
            icon: nil,
            timeWindow: templateType == .speed ? 10 : nil
        )
        tiers.append(newTier)
    }

    private func saveTemplate() {
        guard let exercise = selectedExercise else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // Create exercise reference
        let reference: ExerciseReference
        if exercise.isBuiltIn, let exerciseType = exercise.builtInType {
            reference = .builtIn(exerciseType)
        } else if let custom = exercise.customExercise {
            reference = .custom(custom.id)
        } else {
            return // Invalid exercise
        }

        if let existing = existingTemplate {
            // Update existing template
            var updated = existing
            updated.name = trimmedName
            updated.templateType = templateType
            updated.exerciseReference = reference
            updated.tiers = tiers
            updated.isActive = isActive
            gamificationStore.updateTemplate(updated, exerciseStore: exerciseStore)
        } else {
            // Create new template
            let newTemplate = AchievementTemplate(
                exerciseReference: reference,
                templateType: templateType,
                name: trimmedName,
                tiers: tiers,
                isActive: isActive
            )
            gamificationStore.createTemplate(newTemplate, exerciseStore: exerciseStore)
        }

        NotificationManager.shared.playClickHaptic()
        dismiss()
    }
}

// MARK: - Supporting Views

private struct TierConfigRow: View {
    @Binding var tier: AchievementTemplateTier
    let templateType: AchievementTemplateType
    let exercise: ExerciseItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Tier badge
                Image(systemName: tier.tier.icon)
                    .foregroundStyle(tier.tier.color)

                Text(tier.tier.displayName)
                    .font(.subheadline.weight(.semibold))

                Spacer()
            }

            // Target count
            HStack {
                Text(LocalizedString.Templates.target)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Stepper(value: $tier.target, in: 1...10000, step: stepSize) {
                    Text("\(tier.target) \(targetLabel)")
                        .font(.caption.monospacedDigit())
                }
            }

            // Time window for speed challenges
            if templateType == .speed {
                HStack {
                    Text(LocalizedString.Templates.timeWindow)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Stepper(value: Binding(
                        get: { tier.timeWindow ?? 10 },
                        set: { tier.timeWindow = $0 }
                    ), in: 1...60, step: 5) {
                        Text(LocalizedString.Templates.minutesFormat(tier.timeWindow ?? 10))
                            .font(.caption.monospacedDigit())
                    }
                }
            }

            // Optional label
            TextField(LocalizedString.Templates.labelOptional, text: Binding(
                get: { tier.label ?? "" },
                set: { tier.label = $0.isEmpty ? nil : $0 }
            ))
            .font(.caption)
            .textInputAutocapitalization(.words)
        }
        .padding(.vertical, 4)
    }

    private var stepSize: Int {
        switch templateType {
        case .volume: return 10
        case .dailyGoal: return 5
        case .weeklyGoal: return 10
        case .streak: return 1
        case .speed: return 5
        }
    }

    private var targetLabel: String {
        switch templateType {
        case .volume:
            return exercise?.unitType.unitLabelShort ?? LocalizedString.Units.reps
        case .dailyGoal:
            return LocalizedString.Templates.perDay
        case .weeklyGoal:
            return LocalizedString.Templates.perWeek
        case .streak:
            return tier.target == 1 ? LocalizedString.Templates.daySingular : LocalizedString.Templates.daysPlural
        case .speed:
            return exercise?.unitType.unitLabelShort ?? LocalizedString.Units.reps
        }
    }
}

private struct ExerciseSelectionList: View {
    @ObservedObject var exerciseStore: ExerciseStore
    @Binding var selectedExercise: ExerciseItem?
    let dismiss: () -> Void

    var body: some View {
        List {
            // Built-in exercises
            Section(LocalizedString.Templates.builtInExercises) {
                ForEach(ExerciseType.allCases) { exercise in
                    let item = ExerciseItem(builtIn: exercise)
                    Button {
                        selectedExercise = item
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: exercise.icon)
                                .foregroundStyle(.blue)

                            Text(exercise.rawValue)

                            Spacer()

                            if selectedExercise?.id == item.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            // Custom exercises
            if !exerciseStore.customExercises.isEmpty {
                Section(LocalizedString.Templates.customExercises) {
                    ForEach(exerciseStore.customExercises) { exercise in
                        let item = ExerciseItem(custom: exercise)
                        Button {
                            selectedExercise = item
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: exercise.icon)
                                    .foregroundStyle(.green)

                                Text(exercise.name)

                                Spacer()

                                if selectedExercise?.id == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(LocalizedString.Templates.selectExercise)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(LocalizedString.Templates.cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAchievementTemplateView(
            gamificationStore: GamificationStore.shared,
            exerciseStore: ExerciseStore.shared
        )
    }
}
