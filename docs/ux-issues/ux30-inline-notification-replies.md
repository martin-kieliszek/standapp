# UX30: Inline Notification Replies - Log Exercises Without Opening App

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Notification Enhancement  
**Priority**: Medium  
**Complexity**: Low (2 hours)

## Problem

Current notification workflow:
1. Notification appears: "Time to stand!"
2. User taps "Log Exercise"
3. App opens to exercise picker
4. User selects exercise, adjusts count, saves

**Issue**: Requires opening app even for simple logging. No inline response capability.

## Solution

Add `UNTextInputNotificationAction` to allow typing rep count directly in notification:

**New Workflow**:
1. Notification appears: "Time to stand!"
2. User long-presses or force-touches notification
3. Action: "How many squats?" (text input)
4. User types "20"
5. Exercise logged instantly, no app launch

## Implementation

### 1. Create Text Input Action

```swift
// In NotificationManager
func setupNotificationCategories() {
    let logAction = UNNotificationAction(
        identifier: "LOG_EXERCISE",
        title: "Log Exercise",
        options: .foreground
    )
    
    // NEW: Text input action
    let quickLogAction = UNTextInputNotificationAction(
        identifier: "QUICK_LOG",
        title: "Quick Log",
        options: [],
        textInputButtonTitle: "Log",
        textInputPlaceholder: "How many? (e.g., 20)"
    )
    
    let snoozeAction = UNNotificationAction(
        identifier: "SNOOZE",
        title: "Snooze +5min",
        options: []
    )
    
    let category = UNNotificationCategory(
        identifier: NotificationType.exerciseReminder.categoryIdentifier,
        actions: [quickLogAction, logAction, snoozeAction],
        intentIdentifiers: []
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
}
```

### 2. Handle Text Input Response

```swift
// In AppDelegate/SceneDelegate
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    switch response.actionIdentifier {
    case "QUICK_LOG":
        if let textResponse = response as? UNTextInputNotificationResponse {
            handleQuickLog(input: textResponse.userText)
        }
        
    // ... existing actions ...
    }
    
    completionHandler()
}

private func handleQuickLog(input: String) {
    // Parse input
    guard let count = Int(input.trimmingCharacters(in: .whitespaces)) else {
        // Invalid input - show error notification
        showErrorNotification(message: "Invalid number. Try again.")
        return
    }
    
    // Determine which exercise to log
    let store = ExerciseStore.shared
    
    // Option 1: Use last logged exercise
    if let lastExercise = store.recentExercises.first {
        store.logExercise(item: lastExercise, count: count)
        showSuccessNotification(
            message: "Logged \\(count) \\(lastExercise.name)!"
        )
    }
    
    // Option 2: Use default exercise (squats)
    else {
        store.logExercise(type: .squats, count: count)
        showSuccessNotification(message: "Logged \\(count) squats!")
    }
}
```

### 3. Smart Exercise Detection

Parse input to detect exercise type:

```swift
private func parseQuickLogInput(_ input: String) -> (exercise: ExerciseItem?, count: Int?) {
    let lowercased = input.lowercased()
    
    // Pattern: "20 squats" or "squats 20"
    let components = lowercased.split(separator: " ")
    
    var count: Int?
    var exerciseName: String?
    
    for component in components {
        if let number = Int(component) {
            count = number
        } else {
            exerciseName = String(component)
        }
    }
    
    // Find matching exercise
    let store = ExerciseStore.shared
    let exercise = store.allExercises.first { item in
        item.name.lowercased().contains(exerciseName ?? "")
    }
    
    return (exercise, count)
}
```

**Example inputs**:
- "20" → Log 20 of last exercise
- "20 squats" → Log 20 squats
- "squats 20" → Log 20 squats
- "15 pushups" → Log 15 pushups

### 4. Confirmation Notification

Send confirmation after inline log:

```swift
private func showSuccessNotification(message: String) {
    let content = UNMutableNotificationContent()
    content.title = "Logged!"
    content.body = message
    content.sound = .default
    
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil  // Immediate
    )
    
    UNUserNotificationCenter.current().add(request)
}
```

## User Experience

### Notification Actions (Long Press)

```
┌────────────────────────────┐
│ StandFit                   │
│ Time to stand!             │
│ Log your exercise now      │
├────────────────────────────┤
│ Quick Log          [text]  │
│ Log Exercise       →       │
│ Snooze +5min              │
└────────────────────────────┘
```

### Text Input UI

User taps "Quick Log":
```
┌────────────────────────────┐
│ How many?                  │
│ ┌────────────────────────┐ │
│ │ 20                     │ │
│ └────────────────────────┘ │
│                [Log]       │
└────────────────────────────┘
```

### Success Feedback

```
┌────────────────────────────┐
│ StandFit                   │
│ Logged!                    │
│ Logged 20 squats! +17 XP   │
└────────────────────────────┘
```

## Advanced Features

### Multi-Exercise Logging

Support logging multiple exercises:

Input: "20 squats, 10 pushups"

```swift
private func parseMultipleExercises(_ input: String) -> [(ExerciseItem, Int)] {
    let entries = input.split(separator: ",")
    var results: [(ExerciseItem, Int)] = []
    
    for entry in entries {
        if let (exercise, count) = parseQuickLogInput(String(entry)),
           let ex = exercise, let c = count {
            results.append((ex, c))
        }
    }
    
    return results
}
```

### Voice Input

iOS supports dictation in text input notifications:
- User can say "Twenty squats"
- iOS transcribes to "20 squats"
- App parses and logs

### Error Handling

Handle edge cases gracefully:

```swift
// Invalid number
Input: "abc" → "Invalid number. Please enter a number (e.g., 20)"

// Unknown exercise
Input: "20 xyz" → "Unknown exercise. Logged 20 squats instead."

// Empty input
Input: "" → "Please enter a number"
```

## Technical Requirements

- iOS 13.0+
- `UNTextInputNotificationAction`
- Background notification handling
- Input parsing logic

## Testing

1. Schedule reminder notification
2. Long-press notification
3. Tap "Quick Log"
4. Type "20"
5. Tap "Log"
6. Verify:
   - Exercise logged
   - Confirmation notification appears
   - Streak/XP updated
   - No app launch

## Benefits

1. **Fastest Logging**: No app launch needed
2. **Convenience**: Complete task in notification
3. **Low Friction**: Reduces barriers to logging
4. **Power User**: Advanced feature for regulars
5. **iOS Native**: Uses standard notification APIs

## Comparison with Other Methods

| Method | Speed | Requires App Launch | Complexity |
|--------|-------|---------------------|------------|
| Inline Reply | ⭐⭐⭐⭐⭐ | No | Low |
| Log Exercise Action | ⭐⭐⭐⭐ | Yes | Low |
| Siri Shortcut | ⭐⭐⭐⭐ | No | Medium |
| Quick Action | ⭐⭐⭐⭐ | Yes | Low |

## Limitations

- No exercise picker UI in notification
- Relies on last exercise or parsing
- Cannot adjust all exercise parameters
- iOS only (not watchOS)

## Related Issues

- **UX27**: Siri Shortcuts - Alternative voice method
- **UX29**: Quick Actions - Complementary fast access
- **UX5**: Deep Linking - Full UI fallback

## Success Metrics

- Inline reply usage rate
- Average response time (faster than app launch)
- Error rate (parsing failures)
- User preference (inline vs. app open)

## Conclusion

Inline notification replies are a **2-hour, low-complexity** feature that provides the **fastest possible logging** for frequent exercises. Perfect for power users who log the same exercises repeatedly. This is a **modern iOS UX pattern** that reduces friction significantly.
