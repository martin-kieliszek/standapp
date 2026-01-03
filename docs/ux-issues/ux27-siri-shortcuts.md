# UX27: Siri Shortcuts - Voice-Activated Exercise Logging

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Platform Integration  
**Priority**: High  
**Complexity**: Medium (3-4 hours)

## Problem

Users cannot log exercises via voice commands:
- Must open app, navigate, select exercise, adjust count, save
- No hands-free logging during workouts
- Cannot add to Siri routines or automations
- Misses modern iOS voice control expectations

**User Impact**: "Hey Siri, log 20 squats in StandFit" → "I can't help with that"

## Solution

Implement Siri Shortcuts using `App Intents` framework (iOS 16+):
1. Voice commands to log exercises
2. Suggested shortcuts after logging exercises
3. Add to Shortcuts app for custom routines
4. Support parameters (exercise type, count)

## Implementation

### 1. Create App Intent

```swift
import AppIntents

struct LogExerciseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Exercise"
    static var description = IntentDescription("Log an exercise to StandFit")
    
    @Parameter(title: "Exercise")
    var exercise: ExerciseEntity
    
    @Parameter(title: "Count", default: 10)
    var count: Int
    
    func perform() async throws -> some IntentResult {
        // Log exercise
        await MainActor.run {
            let store = ExerciseStore.shared
            store.logExercise(item: exercise.exerciseItem, count: count)
        }
        
        return .result(dialog: "Logged \(count) \(exercise.name)")
    }
}

// Exercise entity for parameter
struct ExerciseEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Exercise")
    
    let id: String
    let name: String
    let exerciseItem: ExerciseItem
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var defaultQuery = ExerciseQuery()
}

struct ExerciseQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ExerciseEntity] {
        let store = await ExerciseStore.shared
        return await store.allExercises.filter { identifiers.contains($0.id) }
            .map { ExerciseEntity(id: $0.id, name: $0.name, exerciseItem: $0) }
    }
    
    func suggestedEntities() async throws -> [ExerciseEntity] {
        let store = await ExerciseStore.shared
        return await store.recentExercises.map { 
            ExerciseEntity(id: $0.id, name: $0.name, exerciseItem: $0) 
        }
    }
}
```

### 2. Add Shortcuts Capability

Enable "Siri & Shortcuts" in Xcode capabilities.

### 3. Donate Shortcuts

Donate shortcuts after user logs exercises:

```swift
func logExercise(item: ExerciseItem, count: Int) {
    let log = ExerciseLog(item: item, count: count)
    try? exerciseService.addLog(log, to: &logs)
    
    // Donate shortcut for Siri suggestions
    Task {
        let intent = LogExerciseIntent()
        intent.exercise = ExerciseEntity(id: item.id, name: item.name, exerciseItem: item)
        intent.count = count
        
        let shortcut = INShortcut(intent: intent)
        INVoiceShortcutCenter.shared.setShortcutSuggestions([shortcut])
    }
}
```

### 4. Quick Log Shortcuts

Create convenience shortcuts for common exercises:

```swift
struct QuickLogSquatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Log 20 Squats"
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            let store = ExerciseStore.shared
            store.logExercise(type: .squats, count: 20)
        }
        return .result(dialog: "Logged 20 squats!")
    }
}
```

## User Experience

### Siri Voice Commands

Users can say:
- "Hey Siri, log 20 squats in StandFit"
- "Hey Siri, log exercise in StandFit" → prompts for exercise and count
- "Hey Siri, log my plank" → uses recent/default count

### Shortcuts App Integration

Users can:
- Add StandFit actions to custom shortcuts
- Create "Morning Routine" shortcut: Log stretching + check streak
- Schedule automatic exercise logging
- Combine with other apps (e.g., "After workout, log 50 squats")

### Suggested Shortcuts

iOS suggests shortcuts on Lock Screen:
- "Log 10 Pushups" (appears at typical workout time)
- "Log Exercise" (appears after notification)

## Advanced Features

### Parameterized Shortcuts

```swift
@Parameter(title: "Exercise Type")
var exerciseType: String

@Parameter(title: "Repetitions", default: 10)
var reps: Int

@Parameter(title: "Add Note")
var note: String?
```

### Conversational Shortcuts

Siri asks follow-up questions:
1. "Which exercise?" → User: "Squats"
2. "How many?" → User: "30"
3. "Logged 30 squats to StandFit!"

## Settings Integration

```swift
Section {
    NavigationLink("Siri & Shortcuts") {
        ShortcutsSettingsView()
    }
} header: {
    Text("Voice Control")
} footer: {
    Text("Create voice shortcuts to log exercises hands-free.")
}
```

## Technical Requirements

- iOS 16.0+ for App Intents framework
- Intents Extension (optional, for background execution)
- Siri capability enabled
- Donate shortcuts after user actions

## Testing

1. Create custom phrase: "Log my workout"
2. Record Siri phrase in Settings → Siri & Search
3. Say "Hey Siri, log my workout"
4. Verify exercise is logged
5. Check streak updates, XP awarded

## Benefits

1. **Hands-Free**: Log during workout without touching phone
2. **Speed**: Fastest possible logging method
3. **Automation**: Schedule automatic logs, create routines
4. **Discovery**: Siri suggestions expose features
5. **Modern**: Expected in contemporary iOS apps

## Related Issues

- **UX24**: Onboarding - Introduce Siri shortcuts
- **UX30**: Inline Notification Replies - Alternative quick log method
- **UX26**: HealthKit - Shortcuts can trigger Health sync

## Success Metrics

- 20%+ users create custom Siri phrase
- 10%+ users add to Shortcuts app
- Shortcut execution rate increases over time
- Positive reviews mention voice control

## Conclusion

Siri Shortcuts provide the fastest, most convenient exercise logging method. For a fitness app focused on quick standing exercises throughout the day, voice control is a perfect fit. This is a **high-value, modern iOS feature** that significantly enhances UX.
