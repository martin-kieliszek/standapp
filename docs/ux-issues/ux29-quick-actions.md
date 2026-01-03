# UX29: Quick Actions - Home Screen 3D Touch/Long Press Shortcuts

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: iOS Integration  
**Priority**: Medium  
**Complexity**: Low (1 hour)

## Problem

Users cannot access StandFit features from home screen long-press:
- Must open app to log exercise
- No quick access to common actions
- Missing standard iOS feature (Home Screen Quick Actions)
- Requires extra taps for frequent tasks

## Solution

Implement Home Screen Quick Actions (3D Touch/Haptic Touch):
- Long-press app icon → menu of shortcuts
- 3-4 most common actions
- Deep link directly to specific features
- System-standard iOS interaction

## Implementation

### 1. Define Quick Actions in Info.plist

```xml
<key>UIApplicationShortcutItems</key>
<array>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.standfit.logexercise</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Log Exercise</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeAdd</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.standfit.viewstreak</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>View Streak</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeTime</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.standfit.viewprogress</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>View Progress</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeCompose</string>
    </dict>
</array>
```

### 2. Handle Quick Actions in SceneDelegate

```swift
func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
) {
    handleShortcutItem(shortcutItem)
    completionHandler(true)
}

func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
    switch shortcutItem.type {
    case "com.standfit.logexercise":
        // Show exercise picker
        NotificationCenter.default.post(name: .showExercisePicker, object: nil)
        
    case "com.standfit.viewstreak":
        // Navigate to achievements/gamification view
        NotificationCenter.default.post(name: .showAchievements, object: nil)
        
    case "com.standfit.viewprogress":
        // Navigate to progress report
        NotificationCenter.default.post(name: .showProgress, object: nil)
        
    case "com.standfit.loglast":
        // Log last exercise automatically
        if let lastExercise = ExerciseStore.shared.recentExercises.first {
            // Auto-log with default count
            ExerciseStore.shared.logExercise(
                item: lastExercise,
                count: lastExercise.defaultCount
            )
        }
        
    default:
        break
    }
}
```

### 3. Dynamic Quick Actions

Add recently logged exercises dynamically:

```swift
// In ExerciseStore after logging
func logExercise(item: ExerciseItem, count: Int) {
    // ... existing code ...
    
    // Update quick actions
    updateQuickActions()
}

private func updateQuickActions() {
    guard let recentExercise = recentExercises.first else { return }
    
    let quickAction = UIApplicationShortcutItem(
        type: "com.standfit.loglast",
        localizedTitle: "Log \\(recentExercise.name)",
        localizedSubtitle: "Quick log from home screen",
        icon: UIApplicationShortcutIcon(systemImageName: recentExercise.icon)
    )
    
    UIApplication.shared.shortcutItems = [
        quickAction,
        // ... static actions ...
    ]
}
```

## Quick Action Options

### Option 1: Log Exercise
- **Title**: "Log Exercise"
- **Icon**: Plus circle
- **Action**: Opens exercise picker
- **Use Case**: Most common action

### Option 2: Log Last Exercise
- **Title**: "Log [Exercise Name]"
- **Icon**: Exercise icon (dynamic)
- **Action**: Auto-logs last exercise with default count
- **Use Case**: Repeat logging

### Option 3: View Streak
- **Title**: "View Streak"
- **Icon**: Flame
- **Action**: Opens achievements view
- **Use Case**: Check progress

### Option 4: View Progress
- **Title**: "View Progress"
- **Icon**: Chart
- **Action**: Opens progress report
- **Use Case**: Weekly review

## Visual Design

**Home Screen Long Press**:
```
┌─────────────────────────────┐
│ StandFit                    │
├─────────────────────────────┤
│ ➕ Log Exercise             │
│ 🔥 View Streak (5 days)     │
│ 📊 View Progress            │
│ ✓  Log Squats (last)        │
└─────────────────────────────┘
```

## User Experience

### Haptic Feedback
- Long press → light haptic
- Selection → selection haptic
- Quick action executed → success haptic

### Icons
Use SF Symbols for consistency:
- `plus.circle.fill` - Log Exercise
- `flame.fill` - View Streak  
- `chart.bar.fill` - View Progress
- Exercise icon - Log Last (dynamic)

### Subtitle Support
Add context to actions:
```swift
UIApplicationShortcutItem(
    type: "com.standfit.viewstreak",
    localizedTitle: "View Streak",
    localizedSubtitle: "\\(currentStreak) days",  // Dynamic
    icon: UIApplicationShortcutIcon(systemImageName: "flame.fill")
)
```

## Advanced Features

### Conditional Actions

Show different actions based on state:

```swift
func updateQuickActions() {
    var actions: [UIApplicationShortcutItem] = []
    
    // Always show log exercise
    actions.append(logExerciseAction)
    
    // Show streak if active
    if gamificationStore.currentStreak > 0 {
        actions.append(viewStreakAction)
    }
    
    // Show last exercise if exists
    if let recent = recentExercises.first {
        actions.append(logRecentAction(recent))
    }
    
    // Show progress if data exists
    if !logs.isEmpty {
        actions.append(viewProgressAction)
    }
    
    UIApplication.shared.shortcutItems = Array(actions.prefix(4)) // Max 4
}
```

### Localization

Use Localizable.strings for titles:

```swift
let title = NSLocalizedString(
    "quick_action.log_exercise",
    comment: "Quick action to log exercise"
)
```

## Technical Requirements

- iOS 13.0+ (for UISceneDelegate)
- Max 4 quick actions (iOS limit)
- Handle in SceneDelegate or AppDelegate
- Update dynamically based on app state

## Testing

1. Long-press app icon on home screen
2. Verify 3-4 actions appear
3. Tap "Log Exercise" → exercise picker opens
4. Tap "View Streak" → achievements view opens
5. Log exercise → verify "Log [Last]" updates

## Benefits

1. **Speed**: Launch directly to feature
2. **Convenience**: No navigation needed
3. **Discoverability**: Users discover features
4. **Standard iOS**: Expected behavior
5. **Power User**: Rewards frequent users

## Implementation Estimate

**Time**: 1 hour  
**Complexity**: Low  
**Files Modified**: 
- Info.plist
- SceneDelegate.swift
- ExerciseStore.swift (dynamic actions)

## Related Issues

- **UX27**: Siri Shortcuts - Complementary quick access
- **UX30**: Inline Notifications - Another quick log method
- **UX5**: Deep Linking - Similar navigation logic

## Success Metrics

- Quick action usage rate
- Most popular action (log exercise expected)
- Reduced time-to-task completion
- User reviews mention convenience

## Conclusion

Quick Actions are a **1-hour, low-hanging fruit** that provides immediate value. They're a standard iOS feature users expect, especially for productivity/fitness apps. Easy to implement, high impact on UX.
