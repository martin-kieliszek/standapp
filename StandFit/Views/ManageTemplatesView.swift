//
//  ManageTemplatesView.swift
//  StandFit
//
//  View for managing achievement templates (UX16)
//

import SwiftUI
import StandFitCore

struct ManageTemplatesView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @State private var showingCreateView = false
    @State private var showingPaywall = false
    @State private var templateToEdit: AchievementTemplate?
    @State private var templateToDelete: AchievementTemplate?

    private var canCreateTemplate: Bool {
        gamificationStore.canCreateTemplate(entitlements: exerciseStore.entitlements)
    }

    var body: some View {
        List {
            // Status section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Templates Created")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(gamificationStore.achievementTemplates.count)")
                            .font(.title2.bold())
                    }

                    Spacer()

                    if exerciseStore.isPremium {
                        Image(systemName: "infinity")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    } else {
                        Text("0 / 0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                // Regenerate button (useful after updates)
                if !gamificationStore.achievementTemplates.isEmpty {
                    Button {
                        gamificationStore.regenerateAchievementsFromTemplates(exerciseStore: exerciseStore)
                    } label: {
                        Label("Refresh Achievements", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                }
            } footer: {
                if !gamificationStore.achievementTemplates.isEmpty {
                    Text("Tap 'Refresh Achievements' to update achievement names and progress")
                }
            }

            // Templates list
            if gamificationStore.achievementTemplates.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "star.square.on.square")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)

                        Text("No Templates Yet")
                            .font(.headline)

                        Text("Create achievement templates to track progress on your custom exercises")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        if exerciseStore.isPremium {
                            Button {
                                showingCreateView = true
                            } label: {
                                Label("Create Template", systemImage: "plus.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
            } else {
                Section {
                    ForEach(gamificationStore.achievementTemplates) { template in
                        TemplateRow(
                            template: template,
                            exerciseStore: exerciseStore,
                            onEdit: {
                                templateToEdit = template
                            },
                            onToggle: {
                                gamificationStore.toggleTemplate(template.id, exerciseStore: exerciseStore)
                            },
                            onDelete: {
                                templateToDelete = template
                            }
                        )
                    }
                }
            }

            // Premium section (if not premium)
            if !exerciseStore.isPremium {
                Section {
                    AchievementTemplatePremiumPrompt {
                        showingPaywall = true
                    }
                }
            }
        }
        .navigationTitle("Achievement Templates")
        .toolbar {
            if exerciseStore.isPremium && !gamificationStore.achievementTemplates.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if canCreateTemplate {
                            showingCreateView = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateView) {
            NavigationStack {
                CreateAchievementTemplateView(
                    gamificationStore: gamificationStore,
                    exerciseStore: exerciseStore
                )
            }
        }
        .sheet(item: $templateToEdit) { template in
            NavigationStack {
                CreateAchievementTemplateView(
                    gamificationStore: gamificationStore,
                    exerciseStore: exerciseStore,
                    existingTemplate: template
                )
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(subscriptionManager: SubscriptionManager.shared)
        }
        .confirmationDialog(
            "Delete Template?",
            isPresented: Binding(
                get: { templateToDelete != nil },
                set: { if !$0 { templateToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: templateToDelete
        ) { template in
            Button("Delete", role: .destructive) {
                gamificationStore.deleteTemplate(template.id)
                templateToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                templateToDelete = nil
            }
        } message: { template in
            Text("This will delete the template and all generated achievements. Your exercise logs will be kept.")
        }
    }
}

// MARK: - Supporting Views

private struct TemplateRow: View {
    let template: AchievementTemplate
    @ObservedObject var exerciseStore: ExerciseStore
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void

    private var exercise: ExerciseItem? {
        template.exerciseReference.resolve(customExercises: exerciseStore.customExercises)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)

                    if let exercise = exercise {
                        Label(exercise.name, systemImage: exercise.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Exercise Deleted")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Spacer()

                // Active toggle
                Toggle("", isOn: Binding(
                    get: { template.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }

            // Type and tier count
            HStack(spacing: 16) {
                Label(template.templateType.rawValue, systemImage: template.templateType.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("\(template.tiers.count) tiers", systemImage: "square.stack.3d.up")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                if !template.isActive {
                    Text("Inactive")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
        .opacity(exercise == nil ? 0.5 : 1.0)
    }
}

#Preview("With Templates") {
    NavigationStack {
        ManageTemplatesView(
            gamificationStore: GamificationStore.shared,
            exerciseStore: ExerciseStore.shared
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        let store = GamificationStore.shared
        ManageTemplatesView(
            gamificationStore: store,
            exerciseStore: ExerciseStore.shared
        )
    }
}
