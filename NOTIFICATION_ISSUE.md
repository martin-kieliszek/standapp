# Notification Actions Not Appearing on iOS

**Date Reported:** 2026-01-02  
**Platform:** iOS  
**Status:** IMPLEMENTED ✅  
**Severity:** High - Core Feature Broken

---

## Problem Statement

When receiving a notification on iOS, the action buttons ("Log Exercise", "Snooze", "View Details") that appear on the Watch app are **not visible**. When the user taps the notification, it only navigates to the app rather than presenting the action options.

### Expected Behavior (Watch App)
- User receives notification
- Notification expands with two action buttons: "Log Exercise" and "Snooze 5 min"
- User can tap either button to perform the action
- Actions are handled by `AppDelegate.userNotificationCenter(_:didReceive:)` 
- Appropriate follow-up actions occur (navigate, reschedule, etc.)

### Actual Behavior (iOS App)
- User receives notification
- Notification displays but **no action buttons are visible**
- Tapping the notification just opens the app (default action)
- Action handlers in AppDelegate are never called

---

## Root Cause Analysis

The code appears structurally identical between iOS and Watch apps:

1. ✅ **AppDelegate setup** - Both implement `UNUserNotificationCenterDelegate`
2. ✅ **Delegate assignment** - `UNUserNotificationCenter.current().delegate = self`
3. ✅ **Category setup** - `NotificationManager.shared.setupNotificationCategories()` called
4. ✅ **Category identifier** - Notifications set `content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier`
5. ✅ **Action handlers** - `userNotificationCenter(_:didReceive:)` implemented

**However, there are platform-specific differences in how notifications are presented:**

### iOS vs Watch Notification Presentation

| Aspect | Watch | iOS |
|--------|-------|-----|
| **Foreground presentation** | `.banner, .sound` | `.banner, .sound, .badge` |
| **Action visibility** | Actions always visible in lock screen/banner | Actions require user interaction (swipe/long-press) |
| **Notification style** | watchOS shows actions prominently | iOS only shows actions on lock screen/notification center, NOT in banner |
| **Authorization** | `.alert, .sound` (no badge) | `.alert, .sound, .badge` |

### The Real Issue: iOS Banner vs Lock Screen

On iOS, when a notification arrives while the app is in foreground or user is on home screen:

1. If `willPresent()` returns `.banner` → Only shows as a banner, **actions hidden**
2. If user is on home screen → Notification goes to lock screen, **actions visible**
3. If user swipes/long-presses the lock screen notification → **Actions appear**

**The problem:** The notification might be arriving while the user is looking at the app (foreground), so `.banner` presentation hides the actions. Users expect iOS notifications to show actions like the Watch does.

---

## Solution Implemented ✅

**Approach:** Alert Dialog Instead of Banner (Option 2)

Show an alert dialog with action buttons when notification arrives in foreground. This mimics native iOS notification behavior and gives action buttons prominence.

### Code Changes Made

**File:** `StandFit/App/StandFitApp.swift`

Updated `willPresent()` to call new `showNotificationAlert()` method:

```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    NotificationManager.shared.playReminderHaptic()
    NotificationFiredLog.shared.recordNotificationFired()
    NotificationManager.shared.scheduleFollowUpReminder(store: ExerciseStore.shared)
    
    // ✅ NEW: Show alert with action buttons when in foreground
    await showNotificationAlert(for: notification)
    
    return [.banner, .sound, .badge]
}
```

Added new method to handle presentation:

```swift
private func showNotificationAlert(for notification: UNNotification) async {
    let content = notification.request.content
    let categoryIdentifier = content.categoryIdentifier
    
    // Create alert controller
    let alert = UIAlertController(
        title: content.title,
        message: content.body,
        preferredStyle: .alert
    )
    
    // Add actions based on category
    if categoryIdentifier == NotificationType.exerciseReminder.categoryIdentifier {
        // Log Exercise button
        alert.addAction(UIAlertAction(title: "Log Exercise", style: .default) { _ in
            NotificationManager.shared.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showExercisePicker, object: nil)
            }
        })
        
        // Snooze button
        alert.addAction(UIAlertAction(title: "Snooze 5 min", style: .default) { _ in
            NotificationManager.shared.scheduleReminderWithSchedule(store: ExerciseStore.shared)
            NotificationManager.shared.playClickHaptic()
        })
    } else if categoryIdentifier == NotificationType.progressReport.categoryIdentifier {
        // View Details button
        alert.addAction(UIAlertAction(title: "View Details", style: .default) { _ in
            NotificationManager.shared.playClickHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .showProgressReport, object: nil)
            }
        })
    } else if categoryIdentifier == NotificationType.achievementUnlocked.categoryIdentifier {
        // View Achievements button
        alert.addAction(UIAlertAction(title: "View All", style: .default) { _ in
            NotificationManager.shared.playClickHaptic()
        })
    }
    
    // Always add dismiss button
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
    
    // Present on main window
    await MainActor.run {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}
```

### Why This Approach Works

1. **Action buttons always visible** - Alert dialog appears immediately with all actions
2. **Matches iOS UX patterns** - Similar to how native iOS apps present important actions
3. **Consistent with watch behavior** - Users see the same action options on iOS and Watch
4. **Thread-safe** - Uses `await MainActor.run` for UI presentation
5. **Reuses existing logic** - Calls same action handlers as lock screen buttons

---

## Comparison: Watch vs iOS Notification Experience

### Watch App (Current Working State)
```
[Notification arrives]
    ↓
[User sees notification on lock screen/banner with action buttons]
    ↓
[User taps "Log Exercise" or "Snooze"]
    ↓
[Action is performed]
```

### iOS App (Current Broken State)
```
[Notification arrives]
    ↓
[User sees banner with no action buttons]
    ↓
[User taps notification → just opens app]
    ↗
[Actions never called, user has to navigate manually]
```

### iOS App (After Fix)
```
[Notification arrives]
    ↓
[Alert dialog shows with "Log Exercise", "Snooze", "Dismiss" buttons]
    ↓
[User taps action button in alert]
    ↓
[Action is performed immediately]
```

---

## Testing Strategy

After implementing the fix:

1. **Build and run** iOS app on simulator
2. **Trigger a notification** (use "Trigger Now" button in UI or wait for scheduled time)
3. **Verify alert dialog appears** with proper action buttons
4. **Tap "Log Exercise"** → should show exercise picker
5. **Dismiss and trigger another** → Tap "Snooze" → should reschedule notification
6. **Verify notifications** on lock screen also have action buttons

---

## Files Affected

- `StandFit/App/StandFitApp.swift` - Update AppDelegate
- `StandFit/Views/ContentView.swift` - (No changes needed if using alert approach)

---

## Watch App Reference

The Watch app correctly handles notifications because:
1. watchOS prioritizes notification actions in the UI
2. `willPresent()` returns `.banner, .sound` which on watchOS includes actions
3. No alert dialog needed - actions are always accessible

iOS requires explicit handling because:
1. iOS banners don't show actions
2. Lock screen and notification center are secondary presentations
3. Users expect action buttons to be immediately visible, not hidden behind UI

---

## Related Issues

- None yet

---

## Blocking

This is the main reason notifications appear to be "not working" on iOS despite the code being correct. Without action buttons, the primary user workflow is broken.

