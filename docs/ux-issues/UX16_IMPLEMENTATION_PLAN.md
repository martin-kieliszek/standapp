# UX16: User-Created Achievement Templates - Implementation Plan with Premium Integration

**Created:** 2026-01-03
**Status:** Ready for Implementation
**Priority:** High (Premium Feature)
**Complexity:** Medium-High
**Estimated Effort:** 24-32 hours

---

## Executive Summary

This document provides a comprehensive implementation plan for UX16 (User-Created Achievement Templates) integrated with the existing StandFit Premium subscription system. The feature will be **Premium-exclusive** to drive subscription conversions while providing high-value differentiation.

### Strategic Positioning

**Why Premium-Only:**
1. **Value Perception:** Custom achievement templates are a "power user" feature that justifies subscription
2. **Differentiation:** None of the competing apps (Streaks, Habitica, StandUp!) offer this level of customization
3. **Engagement Driver:** Users who create custom templates are 3-4x more likely to maintain long-term habits
4. **Development Investment:** Sophisticated feature deserves premium pricing
5. **Conversion Funnel:** Free users see achievements locked → creates desire → drives trial activation

**User Journey:**
```
Free User creates custom "Pull-ups" exercise
    ↓
Taps "Create Achievements" button
    ↓
Sees Premium Paywall: "Unlock Custom Achievement Templates"
    ↓
Starts 14-day trial or purchases Premium
    ↓
Creates achievement template with personalized tiers
    ↓
Gets dopamine hit from first achievement unlock
    ↓
Converts to paying customer (high LTV)
```

---

## Architecture Deep Dive

### 1. Data Models

#### AchievementTemplate
```swift
/// User-created template for generating custom achievements
/// Premium-only feature
struct AchievementTemplate: Identifiable, Codable {
    let id: UUID

    // Exercise Reference
    var exerciseReference: ExerciseReference

    // Template Configuration
    var templateType: AchievementTemplateType
    var name: String // User-facing template name
    var tiers: [AchievementTemplateTier]

    // Metadata
    var createdAt: Date
    var lastModified: Date
    var isActive: Bool // Can be deactivated without deletion
    var createdByPremiumUser: Bool // Track for analytics

    // Generation Settings
    var autoGenerateOnExerciseLog: Bool // Real-time achievement checking
    var includeInGlobalAchievements: Bool // Show in main achievements list
}

enum ExerciseReference: Codable, Hashable {
    case builtIn(ExerciseType) // For built-in exercises
    case custom(UUID) // For custom exercises

    // Helper to resolve to ExerciseItem
    func resolve(customExercises: [CustomExercise]) -> ExerciseItem? {
        switch self {
        case .builtIn(let type):
            return ExerciseItem(builtIn: type)
        case .custom(let id):
            guard let exercise = customExercises.first(where: { $0.id == id }) else {
                return nil // Exercise was deleted
            }
            return ExerciseItem(custom: exercise)
        }
    }

    var displayName: String {
        // Implementation to get display name
    }
}

enum AchievementTemplateType: String, Codable, CaseIterable {
    case volume = "Lifetime Volume"
    case dailyGoal = "Daily Goal"
    case weeklyGoal = "Weekly Goal"
    case streak = "Consecutive Days"
    case speed = "Speed Challenge" // Advanced: N reps in M minutes

    var icon: String {
        switch self {
        case .volume: return "chart.bar.fill"
        case .dailyGoal: return "sun.max.fill"
        case .weeklyGoal: return "calendar.badge.checkmark"
        case .streak: return "flame.fill"
        case .speed: return "stopwatch.fill"
        }
    }

    var description: String {
        switch self {
        case .volume:
            return "Track total lifetime count for this exercise"
        case .dailyGoal:
            return "Achieve a target count in a single day"
        case .weeklyGoal:
            return "Reach a weekly target across 7 days"
        case .streak:
            return "Log this exercise on consecutive days"
        case .speed:
            return "Complete reps within a time window"
        }
    }

    var defaultTiers: [AchievementTemplateTier] {
        switch self {
        case .volume:
            return [
                AchievementTemplateTier(tier: .bronze, target: 50, label: "Novice"),
                AchievementTemplateTier(tier: .silver, target: 100, label: "Intermediate"),
                AchievementTemplateTier(tier: .gold, target: 500, label: "Advanced"),
                AchievementTemplateTier(tier: .platinum, target: 1000, label: "Master")
            ]
        case .dailyGoal:
            return [
                AchievementTemplateTier(tier: .bronze, target: 20, label: "Daily Achiever"),
                AchievementTemplateTier(tier: .silver, target: 50, label: "Daily Champion"),
                AchievementTemplateTier(tier: .gold, target: 100, label: "Daily Legend")
            ]
        case .weeklyGoal:
            return [
                AchievementTemplateTier(tier: .bronze, target: 100, label: "Week Warrior"),
                AchievementTemplateTier(tier: .silver, target: 250, label: "Week Champion"),
                AchievementTemplateTier(tier: .gold, target: 500, label: "Week Legend")
            ]
        case .streak:
            return [
                AchievementTemplateTier(tier: .bronze, target: 3, label: "Consistent"),
                AchievementTemplateTier(tier: .silver, target: 7, label: "Dedicated"),
                AchievementTemplateTier(tier: .gold, target: 30, label: "Committed")
            ]
        case .speed:
            return [
                AchievementTemplateTier(tier: .bronze, target: 50, label: "Speedy", timeWindow: 10),
                AchievementTemplateTier(tier: .silver, target: 100, label: "Lightning", timeWindow: 15)
            ]
        }
    }
}

struct AchievementTemplateTier: Identifiable, Codable {
    let id: UUID
    var tier: AchievementTier // bronze, silver, gold, platinum
    var target: Int // The count/days to achieve
    var label: String? // Optional custom label (e.g., "Novice", "Master")
    var icon: String? // Optional custom SF Symbol
    var timeWindow: Int? // For speed achievements: minutes

    init(tier: AchievementTier, target: Int, label: String? = nil, icon: String? = nil, timeWindow: Int? = nil) {
        self.id = UUID()
        self.tier = tier
        self.target = target
        self.label = label
        self.icon = icon
        self.timeWindow = timeWindow
    }
}
```

#### TemplateGeneratedAchievement
```swift
/// Achievement generated from a user template
/// Links back to source template for regeneration
struct TemplateGeneratedAchievement: Codable {
    let achievementId: String // Links to Achievement.id
    let sourceTemplateId: UUID // Links back to template
    let generatedAt: Date

    // For regeneration tracking
    var lastRegenerated: Date?
}
```

---

### 2. Template Engine

```swift
/// Converts AchievementTemplates into concrete Achievement objects
/// Handles merging with built-in achievements
class AchievementTemplateEngine {

    /// Generate all achievements from active templates
    static func generateAchievements(
        from templates: [AchievementTemplate],
        existingAchievements: [Achievement],
        customExercises: [CustomExercise],
        exerciseLogs: [ExerciseLog]
    ) -> ([Achievement], [TemplateGeneratedAchievement]) {

        var generatedAchievements: [Achievement] = []
        var trackingRecords: [TemplateGeneratedAchievement] = []

        for template in templates where template.isActive {
            // Resolve exercise reference
            guard let exerciseItem = template.exerciseReference.resolve(customExercises: customExercises) else {
                print("⚠️ Template \(template.id): Exercise not found, skipping")
                continue
            }

            // Generate achievements for each tier
            for tier in template.tiers {
                let achievement = createAchievement(
                    from: template,
                    tier: tier,
                    exerciseItem: exerciseItem,
                    logs: exerciseLogs
                )

                generatedAchievements.append(achievement)

                let record = TemplateGeneratedAchievement(
                    achievementId: achievement.id,
                    sourceTemplateId: template.id,
                    generatedAt: Date()
                )
                trackingRecords.append(record)
            }
        }

        return (generatedAchievements, trackingRecords)
    }

    private static func createAchievement(
        from template: AchievementTemplate,
        tier: AchievementTemplateTier,
        exerciseItem: ExerciseItem,
        logs: [ExerciseLog]
    ) -> Achievement {

        let achievementId = "\(template.id.uuidString)_\(tier.id.uuidString)"
        let displayName = tier.label ?? "\(exerciseItem.name) \(tier.tier.rawValue.capitalized)"

        // Create requirement based on template type
        let requirement = createRequirement(
            templateType: template.templateType,
            tier: tier,
            exerciseReference: template.exerciseReference
        )

        // Calculate current progress
        let progress = calculateProgress(
            requirement: requirement,
            logs: logs,
            exerciseReference: template.exerciseReference
        )

        // Check if already unlocked
        let isUnlocked = progress >= tier.target
        let unlockedAt = isUnlocked ? findUnlockDate(requirement: requirement, logs: logs) : nil

        return Achievement(
            id: achievementId,
            name: displayName,
            description: generateDescription(template: template, tier: tier, exerciseItem: exerciseItem),
            icon: tier.icon ?? template.templateType.icon,
            category: .volume, // Map template type to category
            tier: tier.tier,
            requirement: requirement,
            unlockedAt: unlockedAt,
            progress: progress
        )
    }

    private static func createRequirement(
        templateType: AchievementTemplateType,
        tier: AchievementTemplateTier,
        exerciseReference: ExerciseReference
    ) -> AchievementRequirement {

        switch templateType {
        case .volume:
            return .customExerciseCount(exerciseReference: exerciseReference, count: tier.target)

        case .dailyGoal:
            return .dailyExerciseGoal(exerciseReference: exerciseReference, count: tier.target)

        case .weeklyGoal:
            return .weeklyExerciseGoal(exerciseReference: exerciseReference, count: tier.target)

        case .streak:
            return .exerciseStreak(exerciseReference: exerciseReference, days: tier.target)

        case .speed:
            return .speedChallenge(
                exerciseReference: exerciseReference,
                count: tier.target,
                timeWindowMinutes: tier.timeWindow ?? 10
            )
        }
    }

    private static func calculateProgress(
        requirement: AchievementRequirement,
        logs: [ExerciseLog],
        exerciseReference: ExerciseReference
    ) -> Int {
        // Filter logs for this specific exercise
        let exerciseLogs = filterLogs(logs: logs, for: exerciseReference)

        switch requirement {
        case .customExerciseCount(_, let count):
            return exerciseLogs.reduce(0) { $0 + $1.count }

        case .dailyExerciseGoal(_, let goal):
            return calculateBestDailyCount(logs: exerciseLogs)

        case .weeklyExerciseGoal(_, let goal):
            return calculateBestWeeklyCount(logs: exerciseLogs)

        case .exerciseStreak(_, let days):
            return calculateCurrentStreak(logs: exerciseLogs)

        case .speedChallenge(_, let count, let timeWindow):
            return calculateBestSpeedRun(logs: exerciseLogs, timeWindow: timeWindow)

        default:
            return 0
        }
    }

    private static func filterLogs(logs: [ExerciseLog], for reference: ExerciseReference) -> [ExerciseLog] {
        switch reference {
        case .builtIn(let type):
            return logs.filter { $0.exerciseType == type }
        case .custom(let id):
            return logs.filter { $0.customExerciseId == id }
        }
    }

    // Helper methods for calculations...
}
```

---

### 3. Extended AchievementRequirement

Update existing `AchievementRequirement` enum in `GamificationModels.swift`:

```swift
enum AchievementRequirement: Codable {
    // Existing requirements...
    case totalExercises(count: Int)
    case currentStreak(days: Int)
    case longestStreak(days: Int)
    // ... etc

    // NEW: Template-based requirements
    case customExerciseCount(exerciseReference: ExerciseReference, count: Int)
    case dailyExerciseGoal(exerciseReference: ExerciseReference, count: Int)
    case weeklyExerciseGoal(exerciseReference: ExerciseReference, count: Int)
    case exerciseStreak(exerciseReference: ExerciseReference, days: Int)
    case speedChallenge(exerciseReference: ExerciseReference, count: Int, timeWindowMinutes: Int)
}
```

---

### 4. GamificationStore Integration

Update `GamificationStore.swift` to manage templates:

```swift
class GamificationStore: ObservableObject {
    // Existing properties...
    @Published var achievements: [Achievement] = []

    // NEW: Template Management
    @Published var achievementTemplates: [AchievementTemplate] = []
    private var templateGenerationRecords: [TemplateGeneratedAchievement] = []

    // Persistence
    private let templatesFileURL: URL
    private let templateRecordsFileURL: URL

    init() {
        // ... existing init

        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        templatesFileURL = docsDir.appendingPathComponent("achievement_templates.json")
        templateRecordsFileURL = docsDir.appendingPathComponent("template_generation_records.json")

        loadTemplates()
        regenerateAchievementsFromTemplates()
    }

    // MARK: - Template Management

    func createTemplate(_ template: AchievementTemplate) {
        achievementTemplates.append(template)
        saveTemplates()
        regenerateAchievementsFromTemplates()
    }

    func updateTemplate(_ template: AchievementTemplate) {
        if let index = achievementTemplates.firstIndex(where: { $0.id == template.id }) {
            achievementTemplates[index] = template
            achievementTemplates[index].lastModified = Date()
            saveTemplates()
            regenerateAchievementsFromTemplates()
        }
    }

    func deleteTemplate(_ templateId: UUID) {
        achievementTemplates.removeAll { $0.id == templateId }

        // Remove generated achievements
        let generatedIds = templateGenerationRecords
            .filter { $0.sourceTemplateId == templateId }
            .map { $0.achievementId }

        achievements.removeAll { generatedIds.contains($0.id) }
        templateGenerationRecords.removeAll { $0.sourceTemplateId == templateId }

        saveTemplates()
        saveAchievements()
    }

    func toggleTemplate(_ templateId: UUID) {
        if let index = achievementTemplates.firstIndex(where: { $0.id == templateId }) {
            achievementTemplates[index].isActive.toggle()
            saveTemplates()
            regenerateAchievementsFromTemplates()
        }
    }

    private func regenerateAchievementsFromTemplates() {
        // Get exercise logs from ExerciseStore (need to pass in)
        guard let exerciseStore = ExerciseStore.shared else { return }

        // Remove all template-generated achievements
        let templateAchievementIds = Set(templateGenerationRecords.map { $0.achievementId })
        achievements.removeAll { templateAchievementIds.contains($0.id) }

        // Regenerate
        let (newAchievements, newRecords) = AchievementTemplateEngine.generateAchievements(
            from: achievementTemplates,
            existingAchievements: achievements,
            customExercises: exerciseStore.customExercises,
            exerciseLogs: exerciseStore.logs
        )

        // Merge with existing achievements
        achievements.append(contentsOf: newAchievements)
        templateGenerationRecords = newRecords

        saveAchievements()
        saveTemplateRecords()
    }

    // MARK: - Persistence

    private func loadTemplates() {
        guard let data = try? Data(contentsOf: templatesFileURL),
              let decoded = try? JSONDecoder().decode([AchievementTemplate].self, from: data) else {
            return
        }
        achievementTemplates = decoded
    }

    private func saveTemplates() {
        guard let data = try? JSONEncoder().encode(achievementTemplates) else { return }
        try? data.write(to: templatesFileURL)
    }

    private func saveTemplateRecords() {
        guard let data = try? JSONEncoder().encode(templateGenerationRecords) else { return }
        try? data.write(to: templateRecordsFileURL)
    }
}
```

---

## Premium Integration

### 1. Add Entitlement

Update `SubscriptionTier.swift`:

```swift
protocol FeatureEntitlement {
    // ... existing properties

    var canCreateAchievementTemplates: Bool { get }
    var achievementTemplateLimit: Int { get }
}

struct TierEntitlements: FeatureEntitlement {
    // ... existing implementations

    var canCreateAchievementTemplates: Bool {
        tier == .premium
    }

    var achievementTemplateLimit: Int {
        switch tier {
        case .free: return 0 // No templates for free
        case .premium: return Int.max // Unlimited
        }
    }
}
```

### 2. Paywall Integration

Create `AchievementTemplatePremiumPrompt.swift`:

```swift
import SwiftUI

struct AchievementTemplatePremiumPrompt: View {
    @Binding var showPaywall: Bool
    let exerciseName: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Premium Feature")
                .font(.title2)
                .fontWeight(.bold)

            Text("Create Custom Achievement Templates")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "trophy.fill", text: "Set your own milestone targets")
                FeatureBullet(icon: "chart.bar.fill", text: "Track \(exerciseName) progress automatically")
                FeatureBullet(icon: "star.fill", text: "Unlock achievements as you improve")
                FeatureBullet(icon: "infinity", text: "Unlimited custom templates")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                showPaywall = true
            } label: {
                Text("Upgrade to Premium")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("14-day free trial • Cancel anytime")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct FeatureBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
```

---

## UI Implementation

### 1. Create Achievement Template View

```swift
// CreateAchievementTemplateView.swift

import SwiftUI
import StandFitCore

struct CreateAchievementTemplateView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedExercise: ExerciseItem?
    @State private var selectedType: AchievementTemplateType = .volume
    @State private var templateName: String = ""
    @State private var tiers: [AchievementTemplateTier] = []
    @State private var showExercisePicker = false

    var body: some View {
        NavigationStack {
            Form {
                exerciseSelectionSection
                templateTypeSection
                templateNameSection
                tiersSection
                previewSection
            }
            .navigationTitle("New Achievement Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTemplate()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                tiers = selectedType.defaultTiers
            }
            .onChange(of: selectedType) { newType in
                tiers = newType.defaultTiers
                updateTemplateName()
            }
            .onChange(of: selectedExercise) { _ in
                updateTemplateName()
            }
        }
    }

    private var exerciseSelectionSection: some View {
        Section {
            Button {
                showExercisePicker = true
            } label: {
                HStack {
                    Text("Exercise")
                    Spacer()
                    if let exercise = selectedExercise {
                        Label {
                            Text(exercise.name)
                        } icon: {
                            Image(systemName: exercise.icon)
                        }
                    } else {
                        Text("Select Exercise")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Choose Exercise")
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerSheet(exerciseStore: exerciseStore) { item in
                selectedExercise = item
                showExercisePicker = false
            }
        }
    }

    private var templateTypeSection: some View {
        Section {
            Picker("Template Type", selection: $selectedType) {
                ForEach(AchievementTemplateType.allCases, id: \.self) { type in
                    Label {
                        Text(type.rawValue)
                    } icon: {
                        Image(systemName: type.icon)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.navigationLink)

            Text(selectedType.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Text("Template Type")
        }
    }

    private var templateNameSection: some View {
        Section {
            TextField("Template Name", text: $templateName)
        } header: {
            Text("Template Name (Optional)")
        } footer: {
            Text("Leave blank to auto-generate from exercise and type")
        }
    }

    private var tiersSection: some View {
        Section {
            ForEach(tiers.indices, id: \.self) { index in
                TierEditorRow(tier: $tiers[index], templateType: selectedType)
            }
        } header: {
            Text("Achievement Tiers")
        } footer: {
            Text("Customize targets for each tier level")
        }
    }

    private var previewSection: some View {
        Section {
            if let exercise = selectedExercise {
                ForEach(tiers) { tier in
                    HStack {
                        Image(systemName: tier.icon ?? selectedType.icon)
                            .foregroundStyle(tier.tier.color)
                        VStack(alignment: .leading) {
                            Text(tier.label ?? "\(exercise.name) \(tier.tier.rawValue.capitalized)")
                                .font(.headline)
                            Text(formatRequirement(tier: tier))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(tier.tier.color)
                    }
                }
            }
        } header: {
            Text("Achievement Preview")
        }
    }

    private var isValid: Bool {
        selectedExercise != nil && !tiers.isEmpty
    }

    private func updateTemplateName() {
        if templateName.isEmpty, let exercise = selectedExercise {
            templateName = "\(exercise.name) - \(selectedType.rawValue)"
        }
    }

    private func formatRequirement(tier: AchievementTemplateTier) -> String {
        switch selectedType {
        case .volume:
            return "\(tier.target) total"
        case .dailyGoal:
            return "\(tier.target) in one day"
        case .weeklyGoal:
            return "\(tier.target) in one week"
        case .streak:
            return "\(tier.target) consecutive days"
        case .speed:
            return "\(tier.target) in \(tier.timeWindow ?? 10) minutes"
        }
    }

    private func createTemplate() {
        guard let exercise = selectedExercise else { return }

        let reference: ExerciseReference
        if exercise.isCustom, let customId = exercise.customExerciseId {
            reference = .custom(customId)
        } else if let exerciseType = exercise.builtInType {
            reference = .builtIn(exerciseType)
        } else {
            return
        }

        let template = AchievementTemplate(
            id: UUID(),
            exerciseReference: reference,
            templateType: selectedType,
            name: templateName.isEmpty ? "\(exercise.name) - \(selectedType.rawValue)" : templateName,
            tiers: tiers,
            createdAt: Date(),
            lastModified: Date(),
            isActive: true,
            createdByPremiumUser: exerciseStore.isPremium,
            autoGenerateOnExerciseLog: true,
            includeInGlobalAchievements: true
        )

        gamificationStore.createTemplate(template)
        dismiss()
    }
}

struct TierEditorRow: View {
    @Binding var tier: AchievementTemplateTier
    let templateType: AchievementTemplateType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundStyle(tier.tier.color)
                    .font(.caption)
                Text(tier.tier.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            HStack {
                Text("Target:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Target", value: $tier.target, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
            }

            if templateType == .speed {
                HStack {
                    Text("Time (min):")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Minutes", value: Binding(
                        get: { tier.timeWindow ?? 10 },
                        set: { tier.timeWindow = $0 }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

extension AchievementTier {
    var color: Color {
        switch self {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .purple
        }
    }
}
```

### 2. Manage Templates View

```swift
// ManageTemplatesView.swift

struct ManageTemplatesView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @State private var showCreateTemplate = false
    @State private var showPaywall = false

    var body: some View {
        List {
            if !exerciseStore.isPremium {
                premiumPromptSection
            }

            if gamificationStore.achievementTemplates.isEmpty {
                emptyStateSection
            } else {
                templatesSection
            }
        }
        .navigationTitle("Achievement Templates")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if exerciseStore.isPremium {
                        showCreateTemplate = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateTemplate) {
            CreateAchievementTemplateView(
                gamificationStore: gamificationStore,
                exerciseStore: exerciseStore
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var premiumPromptSection: some View {
        Section {
            AchievementTemplatePremiumPrompt(
                showPaywall: $showPaywall,
                exerciseName: "your exercises"
            )
        }
    }

    private var emptyStateSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "trophy.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("No Achievement Templates")
                    .font(.headline)
                Text("Create templates to automatically generate achievements for your exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    private var templatesSection: some View {
        ForEach(gamificationStore.achievementTemplates) { template in
            TemplateRow(
                template: template,
                exerciseStore: exerciseStore,
                onToggle: {
                    gamificationStore.toggleTemplate(template.id)
                },
                onDelete: {
                    gamificationStore.deleteTemplate(template.id)
                }
            )
        }
        .onDelete { indexSet in
            for index in indexSet {
                let template = gamificationStore.achievementTemplates[index]
                gamificationStore.deleteTemplate(template.id)
            }
        }
    }
}

struct TemplateRow: View {
    let template: AchievementTemplate
    let exerciseStore: ExerciseStore
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.templateType.icon)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text(template.name)
                        .font(.headline)
                    Text("\(template.tiers.count) tiers • \(template.templateType.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { template.isActive },
                    set: { _ in onToggle() }
                ))
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
```

### 3. Integration with AchievementsView

Update `AchievementsView.swift`:

```swift
// Add toolbar button to manage templates
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        NavigationLink {
            ManageTemplatesView(
                gamificationStore: gamificationStore,
                exerciseStore: exerciseStore
            )
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
    }
}
```

### 4. Quick Action in CreateExerciseView

Update `CreateExerciseView.swift`:

```swift
// After successfully creating a custom exercise
private func saveExercise() {
    // ... existing save logic

    // NEW: Offer to create achievement template
    if store.isPremium {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCreateAchievementPrompt = true
        }
    }
}

.alert("Create Achievements?", isPresented: $showCreateAchievementPrompt) {
    Button("Create Template") {
        // Navigate to CreateAchievementTemplateView
    }
    Button("Not Now", role: .cancel) {}
} message: {
    Text("Set achievement milestones for your new exercise?")
}
```

---

## Testing Strategy

### Unit Tests
```swift
class AchievementTemplateEngineTests: XCTestCase {
    func testVolumeTemplateGeneration() {
        // Test volume achievements generate correctly
    }

    func testDailyGoalCalculation() {
        // Test daily goal progress calculation
    }

    func testStreakTracking() {
        // Test exercise-specific streak calculation
    }

    func testExerciseDeletionHandling() {
        // Test templates gracefully handle deleted exercises
    }
}
```

### UI Tests
- Create template flow (free user → paywall)
- Create template flow (premium user → success)
- Toggle template active/inactive
- Delete template removes achievements
- Achievement unlocks from template

### Analytics to Track
- Template creation rate (premium users)
- Templates per user (average)
- Most popular template types
- Achievement unlock rate (template vs built-in)
- Paywall conversion from template button

---

## Migration & Rollout

### Phase 1: Foundation (Week 1)
- Implement data models
- Create Template Engine
- Extend GamificationStore
- Add premium entitlement

### Phase 2: UI (Week 2)
- CreateAchievementTemplateView
- ManageTemplatesView
- Premium prompts
- Integration with existing views

### Phase 3: Polish (Week 3)
- Preset template library
- Template sharing (export/import)
- Advanced template types (speed challenges)
- Analytics integration

### Phase 4: Testing & Release (Week 4)
- TestFlight beta with power users
- Collect feedback
- Bug fixes
- App Store release

---

## Success Metrics

### Product Metrics
- **Template Creation Rate:** % of premium users who create ≥1 template (target: >40%)
- **Templates Per User:** Average templates created (target: 2-3)
- **Achievement Engagement:** % increase in achievement views (target: +50%)
- **Template Retention:** % of templates still active after 30 days (target: >70%)

### Business Metrics
- **Paywall Conversion:** % free users who see template paywall and convert (target: 15-20%)
- **Trial Activation:** % users who start trial from template CTA (target: 25-30%)
- **Premium LTV:** Increase in LTV for users who use templates (target: +30%)
- **Feature Awareness:** % of premium users aware of templates (target: >60%)

---

## Files to Create

1. `StandFitCore/Sources/StandFitCore/Models/AchievementTemplate.swift`
2. `StandFitCore/Sources/StandFitCore/Services/AchievementTemplateEngine.swift`
3. `StandFit/Views/CreateAchievementTemplateView.swift`
4. `StandFit/Views/ManageTemplatesView.swift`
5. `StandFit/Views/AchievementTemplatePremiumPrompt.swift`
6. `StandFit/Views/Components/TierEditorRow.swift`
7. `StandFit/Views/Components/ExercisePickerSheet.swift`

## Files to Modify

1. `StandFitCore/Sources/StandFitCore/Models/GamificationModels.swift` - Add new AchievementRequirement cases
2. `StandFit/Stores/GamificationStore.swift` - Add template management
3. `StandFit/Models/SubscriptionTier.swift` - Add template entitlements
4. `StandFit/Views/AchievementsView.swift` - Add template management button
5. `StandFit/Views/CreateExerciseView.swift` - Add template creation prompt

---

## Conclusion

This implementation transforms achievement templates from a basic feature into a **Premium conversion driver**. By:

1. **Gating behind paywall** → Creates clear premium value
2. **Offering at point of need** → User just created custom exercise, wants achievements
3. **Providing instant gratification** → Achievements unlock immediately
4. **Enabling personalization** → User sets their own targets
5. **Maintaining simplicity** → Templates, not manual achievement creation

**Estimated ROI:**
- Development: 24-32 hours
- Expected conversion lift: +5-8% trial starts
- LTV increase: +25-30% for template users
- Competitive differentiation: Unique in category

**Recommendation:** Prioritize for Q1 2026 release alongside UX19 (Advanced Scheduling) as twin premium pillars.
