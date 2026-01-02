# UX16: User-Created Achievement Templates (Pending)

**Status:** ⏳ Pending

## Problem

Users can create custom exercises, but there's no way to create achievement milestones for those exercises. Built-in exercises have volume achievements (e.g., "100 pushups"), but custom exercises lack this motivation layer. Additionally, there's no way to filter achievements by exercise type, making it hard to track progress toward exercise-specific goals.

## User Story

> "I created a custom 'Pull-ups' exercise. I want to set achievement goals like '50 pull-ups', '100 pull-ups', and '250 pull-ups' just like the built-in exercises have. I also want to see all my pull-up achievements in one place."

## Proposed Solution

Implement an **Achievement Template System** that allows users to create customizable achievement tiers for any exercise (built-in or custom), with filtering, templates, and automatic progression tracking.

## Design Philosophy

The system must be:
1. **Template-Based**: Users shouldn't recreate the same structure; they apply templates
2. **Modular**: Templates, tiers, and achievements are separate concerns
3. **Extensible**: Easy to add new template types beyond volume
4. **Automatic**: Achievements auto-generate from templates
5. **Persistent**: User templates survive exercise deletion (can be reapplied)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User-Facing Layer                        │
│  ┌──────────────────┐  ┌──────────────────────────────┐   │
│  │ AchievementsView │  │ CreateAchievementTemplateView│   │
│  │ (with filters)   │  │ (template builder)           │   │
│  └──────────────────┘  └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Template System                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │ AchievementTemplate                                 │    │
│  │ - Exercise reference (UUID or name)                 │    │
│  │ - Template type (volume, streak, time-based)        │    │
│  │ - Tier definitions (targets + icons)                │    │
│  │ - Auto-generation rules                             │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                 Achievement Generation                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │ TemplateEngine                                      │    │
│  │ - Converts templates → concrete achievements        │    │
│  │ - Handles exercise deletion gracefully              │    │
│  │ - Merges with built-in achievements                 │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. AchievementTemplate

```swift
struct AchievementTemplate: Identifiable, Codable {
    let id: UUID
    var exerciseReference: ExerciseReference
    var templateType: AchievementTemplateType
    var tiers: [AchievementTemplateTier]
    var createdAt: Date
    var isActive: Bool
}

enum AchievementTemplateType: String, Codable, CaseIterable {
    case volume = "Volume"           // Total count achievements
    case streak = "Streak"           // Consecutive days with this exercise
    case daily = "Daily Goal"        // N reps/time in one day
    case weekly = "Weekly Goal"      // N reps/time in one week
    case speed = "Speed"             // N reps in M minutes
}
```

### 2. Template Engine

```swift
struct TemplateEngine {
    static func generateAchievements(
        from templates: [AchievementTemplate],
        existingAchievements: [Achievement],
        exerciseStore: ExerciseStore
    ) -> [Achievement]
}
```

### 3. Exercise Filter in AchievementsView

Update achievements view to include:
- Category filters (Milestones, Consistency, Volume, etc.)
- Exercise filters (All, Pushups, Custom Exercise, etc.)
- Combined filtering for specific exercise achievements

### 4. UI Components

**CreateAchievementTemplateView:**
- Exercise selection picker
- Template type picker (Volume, Streak, Daily Goal, etc.)
- Tier configuration (Bronze, Silver, Gold, Platinum)
- Preview section showing generated achievement names
- Save button

**ManageTemplatesView:**
- List existing templates
- Enable/disable toggles
- Edit/delete actions
- Apply preset templates

## Template Types & Default Tiers

### Volume Template
- Bronze: 50 total
- Silver: 100 total
- Gold: 500 total
- Platinum: 1000 total

### Streak Template
- Bronze: 3 consecutive days
- Silver: 7 consecutive days
- Gold: 30 consecutive days

### Daily Goal Template
- Bronze: 20 in one day
- Silver: 50 in one day
- Gold: 100 in one day

### Weekly Goal Template
- Bronze: 100 in one week
- Silver: 250 in one week

## Data Flow Example

```
User creates custom "Pull-ups" exercise
    ↓
User taps "Create Achievements" → Opens CreateAchievementTemplateView
    ↓
Selects "Pull-ups" + "Volume" template type
    ↓
System auto-populates default tiers (50, 100, 500, 1000)
    ↓
User adjusts tiers (25, 50, 100, 250)
    ↓
User taps "Create"
    ↓
AchievementTemplate created with reference to Pull-ups custom exercise ID
    ↓
TemplateEngine.generateAchievements() runs
    ↓
4 achievements created:
- "Pull-ups Novice" (25 total)
- "Pull-ups Intermediate" (50 total)
- "Pull-ups Advanced" (100 total)
- "Pull-ups Master" (250 total)
    ↓
Achievements appear in AchievementsView
    ↓
User filters by "Pull-ups" → sees only pull-up achievements
    ↓
Progress tracked automatically via existing AchievementEngine
```

## Exercise Deletion Handling

When a user deletes a custom exercise:
- Templates are deactivated (not deleted)
- Achievements are preserved but hidden
- Template can be reactivated if exercise is recreated

## Implementation Recommendations

### Phase 1: Foundation (Core Template System)
**Files to Create:**
- `AchievementTemplateModels.swift` - Template data structures
- `TemplateEngine.swift` - Template → Achievement generation logic
- `CreateAchievementTemplateView.swift` - Basic template creation UI

**Files to Modify:**
- `GamificationModels.swift` - Add new `AchievementRequirement` cases
- `GamificationStore.swift` - Add template management, regeneration logic
- `AchievementEngine.swift` - Add evaluation for new requirement types

**Estimated Scope:** 400-500 lines total

### Phase 2: UI Enhancement (Filtering & Presets)
**Files to Modify:**
- `AchievementsView.swift` - Add exercise filtering, template creation button
- `CreateExerciseView.swift` - Add "Create Achievements" quick action

**Files to Create:**
- `TemplatePresetsView.swift` - Preset template library
- `ManageTemplatesView.swift` - View/edit/delete existing templates

**Estimated Scope:** 300-400 lines total

### Phase 3: Advanced Features (Optional)
- Exercise-specific streak tracking (requires per-exercise `StreakData`)
- Speed achievements with time window detection
- Batch template application (apply template to all exercises)
- Template sharing (export/import JSON)

## Architectural Benefits

✅ **Modular**: Templates are separate from achievements (concerns separated)
✅ **Extensible**: New template types = add enum case + evaluation logic
✅ **Persistent**: Templates survive exercise deletion, can be reapplied
✅ **Automatic**: Achievements regenerate on template changes
✅ **Flexible**: Same template can create 1-10 achievements depending on tiers
✅ **User-Friendly**: Presets provide instant gratification
✅ **Maintainable**: Clear separation between built-in and generated achievements

## Future Enhancements

1. **Template Marketplace**: Share templates with community
2. **Auto-Template Suggestions**: AI suggests templates based on usage patterns
3. **Progressive Template**: Automatically increase targets when achieved (infinite progression)
4. **Comparative Achievements**: "More than 75% of users" style benchmarks
5. **Time-Decay Templates**: Achievements that reset monthly/yearly
6. **Combo Templates**: Multi-exercise achievements (10 push-ups + 10 squats)
