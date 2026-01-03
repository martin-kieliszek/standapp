# UX25: Notification Styles - Implement Gentle/Urgent Notification Behavior

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Bug - Incomplete Feature Implementation  
**Priority**: Medium  
**Complexity**: Low (1-2 hours)

## Problem

The `TimeBlock.NotificationStyle` enum exists in the codebase with three values (`.gentle`, `.urgent`, `.standard`), and users can select these styles in the TimeBlockEditorSheet UI. However, **this setting is completely non-functional** — the selected style is stored but never used when creating notifications.

### Current State

**What Exists**:
- `TimeBlock.notificationStyle` property (`.gentle`, `.urgent`, `.standard`)
- UI picker in TimeBlockEditorSheet to select notification style
- Localized strings for "Gentle (Silent)" and "Urgent"
- Schedule templates that specify notification styles
- The setting is stored and persisted correctly

**What's Missing**:
- **Zero implementation** in NotificationManager
- No code that reads `notificationStyle` when scheduling
- No differentiation in notification behavior (sound, interruption level, priority)
- All notifications behave identically regardless of selected style

### User Impact

Users select "Gentle (Silent)" expecting silent notifications during certain hours (e.g., early morning, late night), but:
- Notifications still make sound
- Notifications still show banners
- No difference from standard notifications

Users select "Urgent" expecting more prominent notifications during critical hours (e.g., work hours), but:
- No increased prominence
- Can be suppressed by Focus modes
- No special handling

This creates a **false promise** — the UI suggests functionality that doesn't exist, damaging user trust.

## Solution Overview

Implement the notification style behavior using iOS's `UNNotificationInterruptionLevel` API (available iOS 15+). This native iOS feature provides exactly what's needed:

| Style | Interruption Level | Sound | Behavior |
|-------|-------------------|-------|----------|
| **Gentle** | `.passive` | None (silent) | Only appears in Notification Center, no banner, no sound |
| **Standard** | `.active` (default) | `.default` | Normal banner + sound |
| **Urgent** | `.timeSensitive` | `.default` or `.defaultCritical` | Breaks through Focus modes, prominent banner |

## iOS Notification Interruption Levels

iOS provides four interruption levels:

```swift
public enum UNNotificationInterruptionLevel : UInt, @unchecked Sendable {
    case passive = 0        // Added to Notification Center, no banner/sound
    case active = 1         // Default behavior, banner + sound
    case timeSensitive = 2  // Breaks through Focus modes
    case critical = 3       // Requires special entitlement, always plays sound
}
```

### Level Details

**`.passive` (Gentle)**:
- No sound
- No banner
- Only appears in Notification Center
- Respects all Focus modes
- Perfect for non-urgent reminders during quiet hours

**`.active` (Standard)**:
- Default iOS notification behavior
- Plays sound
- Shows banner
- Respects Focus mode settings (may be suppressed)

**`.timeSensitive` (Urgent)**:
- Breaks through most Focus modes
- Shows banner even in Focus
- Plays sound
- Requires "Time Sensitive Notifications" permission (auto-granted)
- Perfect for critical work hours or important reminders

**`.critical`**:
- Not recommended for our use case
- Requires special entitlement from Apple
- Always plays sound at full volume
- Used for emergency alerts only

## Technical Implementation

### Step 1: Update NotificationManager to Accept Style

Currently, `scheduleReminderWithSchedule()` creates notifications without considering the time block's style. We need to:

1. Determine which `TimeBlock` the notification falls into
2. Read its `notificationStyle` property
3. Configure the notification content accordingly

### Step 2: Modify Notification Content Creation

**Current Code** (NotificationManager.swift ~265):
```swift
let content = UNMutableNotificationContent()
content.title = LocalizedString.Notifications.timeToMoveTitle
content.body = LocalizedString.Notifications.standUpExerciseBody
content.sound = .default  // Always uses default sound
content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier
// No interruptionLevel set - defaults to .active
```

**Updated Code**:
```swift
let content = UNMutableNotificationContent()
content.title = LocalizedString.Notifications.timeToMoveTitle
content.body = LocalizedString.Notifications.standUpExerciseBody
content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

// Apply notification style based on time block
switch notificationStyle {
case .gentle:
    content.interruptionLevel = .passive
    content.sound = nil  // Silent
    
case .urgent:
    content.interruptionLevel = .timeSensitive
    content.sound = .default  // Could use .defaultCritical for more prominence
    
case .standard:
    content.interruptionLevel = .active
    content.sound = .default
}
```

### Step 3: Track Which Block Generated the Notification

The challenge is knowing which `TimeBlock`'s style to apply. We need to modify `calculateNextReminderTime()` to return both the time AND the associated block's style.

**Solution**: Modify return type to include notification style:

```swift
// Change return type from Date? to (Date, TimeBlock.NotificationStyle)?
func calculateNextReminderTime(store: ExerciseStore, from date: Date) -> (date: Date, style: TimeBlock.NotificationStyle)? {
    // ... existing logic ...
    
    // When finding a valid time in a block, return both:
    switch daySchedule.scheduleType {
    case .timeBlocks(let blocks):
        if let matchingBlock = blocks.first(where: { $0.contains(minutes: currentMinutes) }) {
            let nextTime = calculateNextTimeInBlock(
                block: matchingBlock,
                from: candidateTime,
                profile: profile,
                store: store
            )
            return (nextTime, matchingBlock.notificationStyle)
        }
        
    case .fixedTimes(let reminders):
        // Fixed times don't have styles, use standard
        if let nextReminder = reminders.first(where: { $0.totalMinutes > currentMinutes }) {
            let nextTime = calendar.date(
                bySettingHour: nextReminder.hour,
                minute: nextReminder.minute,
                second: 0,
                of: candidateTime
            )
            return (nextTime, .standard)  // Default for fixed times
        }
        
    case .useFallback:
        let nextTime = candidateTime.addingTimeInterval(
            TimeInterval(profile.fallbackInterval * 60)
        )
        return (nextTime, .standard)  // Default for fallback
    }
}
```

### Step 4: Update scheduleReminderWithSchedule()

```swift
func scheduleReminderWithSchedule(store: ExerciseStore) {
    // Cancel any existing (including follow-ups)
    cancelAllReminders()

    // Find next valid time AND notification style
    guard let (nextTime, notificationStyle) = calculateNextReminderTime(store: store, from: Date()) else {
        print("No valid reminder time found in the next week")
        return
    }

    let content = UNMutableNotificationContent()
    content.title = LocalizedString.Notifications.timeToMoveTitle
    content.body = LocalizedString.Notifications.standUpExerciseBody
    content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier

    // Apply notification style
    switch notificationStyle {
    case .gentle:
        content.interruptionLevel = .passive
        content.sound = nil
        
    case .urgent:
        content.interruptionLevel = .timeSensitive
        content.sound = .default
        
    case .standard:
        content.interruptionLevel = .active
        content.sound = .default
    }

    let interval = nextTime.timeIntervalSince(Date())
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: max(interval, 1),
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: NotificationType.exerciseReminder.rawValue,
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to schedule notification: \(error)")
        } else {
            print("Scheduled \(notificationStyle) reminder for \(nextTime)")
            DispatchQueue.main.async {
                store.nextScheduledNotificationTime = nextTime
            }
        }
    }
}
```

## Implementation Details

### Files to Modify

1. **NotificationManager.swift**
   - Update `calculateNextReminderTime()` return type: `(Date, TimeBlock.NotificationStyle)?`
   - Update `scheduleReminderWithSchedule()` to use notification style
   - Update `calculateNextTimeInBlock()` to return style information
   - Handle all schedule types (time blocks, fixed times, fallback)

### Edge Cases to Handle

1. **Fixed Time Reminders**: Don't have a `notificationStyle` property
   - Solution: Default to `.standard`
   
2. **Fallback Interval**: When using profile's fallback interval
   - Solution: Default to `.standard`
   
3. **Snooze Notifications**: Called via "Snooze +5min" button
   - Solution: Use `.standard` (user explicitly requested)
   
4. **Follow-up/Dead Response Reminders**: After missed notification
   - Solution: Use `.urgent` (escalate after no response)
   
5. **Progress Report Notifications**: Automatic daily/weekly reports
   - Solution: Use `.passive` (informational, not urgent)

### Code Changes Summary

**Before**:
```swift
guard let nextTime = calculateNextReminderTime(store: store, from: Date()) else {
    return
}
// ... create notification with hardcoded .default sound
```

**After**:
```swift
guard let (nextTime, notificationStyle) = calculateNextReminderTime(store: store, from: Date()) else {
    return
}
// ... create notification with style-specific settings
```

## Testing Plan

### Manual Testing

1. **Gentle Style**:
   - Create time block with "Gentle (Silent)" style
   - Wait for notification
   - ✓ Should appear in Notification Center only (no banner)
   - ✓ Should be completely silent
   - ✓ Should not interrupt Focus mode

2. **Urgent Style**:
   - Create time block with "Urgent" style
   - Enable Focus mode (Do Not Disturb)
   - Wait for notification
   - ✓ Should break through Focus mode
   - ✓ Should show banner
   - ✓ Should play sound

3. **Standard Style**:
   - Create time block with default style
   - Wait for notification
   - ✓ Should behave like normal notification
   - ✓ Should respect Focus mode settings

### Automated Testing

```swift
func testNotificationStyleMapping() {
    let styles: [TimeBlock.NotificationStyle: (UNNotificationInterruptionLevel, UNNotificationSound?)] = [
        .gentle: (.passive, nil),
        .urgent: (.timeSensitive, .default),
        .standard: (.active, .default)
    ]
    
    for (style, expected) in styles {
        let content = createNotificationContent(style: style)
        XCTAssertEqual(content.interruptionLevel, expected.0)
        XCTAssertEqual(content.sound, expected.1)
    }
}
```

## User-Facing Changes

### Behavior Changes

After implementation:

- **"Gentle (Silent)"** time blocks will now actually be silent and non-intrusive
- **"Urgent"** time blocks will break through Focus modes and demand attention
- **Standard** time blocks will behave as they always have

### Documentation Needed

Update user-facing documentation:

1. **TimeBlockEditorSheet** - Add help text:
   - "Gentle: Silent notifications that don't interrupt"
   - "Standard: Normal notification behavior"
   - "Urgent: Break through Focus mode for important times"

2. **Schedule Templates** - Update descriptions:
   - "Office Worker" template uses `.urgent` during work hours (9-5)
   - "Recovery Mode" template uses `.gentle` for rest days
   - "Gentle Movement" template uses `.gentle` throughout

## Performance Impact

**Negligible**. Changes only affect:
- Return type of one function (tuple instead of single value)
- Switch statement when creating notification content
- No additional API calls
- No performance overhead

## Backwards Compatibility

**Fully compatible**. Existing profiles and time blocks:
- Have `notificationStyle` already stored (defaults to `.standard`)
- Will use `.standard` behavior (same as current)
- No migration needed
- No breaking changes

## Privacy & Permissions

**No new permissions required**:
- `.passive` and `.active` work with existing notification permission
- `.timeSensitive` is automatically granted with notification permission
- `.critical` is NOT used (would require special entitlement)

Users can still disable all notifications or configure Focus mode — this just makes the selected styles actually work.

## Related Issues

- **UX19**: Advanced Reminder Scheduling - Time blocks are the foundation
- **UX7**: Focus Mode Notification Warning - Urgent style helps here
- **UX1**: Silent settings changes - Gentle style useful for testing

## Success Metrics

**Immediate Validation**:
- Gentle notifications are actually silent
- Urgent notifications break through Focus mode
- No regression in standard notification behavior

**User Satisfaction**:
- Reduced complaints about "loud" early morning notifications
- Increased engagement during work hours (urgent style)
- Better alignment between UI promise and actual behavior

## Implementation Estimate

**Time**: 1-2 hours
**Complexity**: Low
**Risk**: Very low (additive change, no breaking changes)

### Breakdown:
- 30 min: Update `calculateNextReminderTime()` return type
- 30 min: Add notification style switch statement
- 15 min: Handle edge cases (snooze, follow-up, progress reports)
- 15 min: Testing
- 15 min: Documentation updates

## Conclusion

This is a **low-hanging fruit fix** that:
- Closes the gap between UI and implementation
- Uses native iOS capabilities properly
- Requires minimal code changes
- Provides immediate user value
- Has zero breaking changes
- Fixes a misleading feature

The notification style setting already exists in the UI — we just need to make it actually work.
