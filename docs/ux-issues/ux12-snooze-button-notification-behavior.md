# UX12: Snooze Button Notification Behavior (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-03

## Problem

When a user taps the "Snooze +5min" button on a notification, the behavior appears to reset the reminder schedule to the configured schedule period (e.g., the reminder interval set in Settings) instead of legitimately snoozing for just 5 minutes.

## Implementation Summary

Implemented proper snooze functionality that schedules a notification exactly 300 seconds (5 minutes) from now, regardless of active hours or schedule boundaries.

### Key Changes

1. **Added `snoozeReminder(seconds:store:)` method to NotificationManager**
   - Schedules notification using `UNTimeIntervalNotificationTrigger` for precise timing
   - Cancels any pending follow-up notifications (user explicitly snoozed)
   - Updates `nextScheduledNotificationTime` for UI display
   - Ignores active hours and schedule boundaries

2. **Updated AppDelegate snooze handlers**
   - Foreground alert snooze button now calls `snoozeReminder(seconds: 300)`
   - Background notification SNOOZE action now calls `snoozeReminder(seconds: 300)`
   - Both cancel follow-up and schedule precise 5-minute delay

3. **Snooze lifecycle**
   - User taps snooze → notification in exactly 5 minutes
   - When snoozed notification fires → next notification uses normal schedule
   - User can snooze multiple times in a row
   - Logging exercise or resetting timer works as expected

### Code Implementation

```swift
// NotificationManager.swift
func snoozeReminder(seconds: Int, store: ExerciseStore) {
    cancelFollowUpReminder()
    
    UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [NotificationType.exerciseReminder.rawValue]
    )
    
    let snoozeTime = Date().addingTimeInterval(TimeInterval(seconds))
    
    let content = UNMutableNotificationContent()
    content.title = LocalizedString.Notifications.timeToMoveTitle
    content.body = LocalizedString.Notifications.standUpExerciseBody
    content.sound = .default
    content.categoryIdentifier = NotificationType.exerciseReminder.categoryIdentifier
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: TimeInterval(seconds),
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: NotificationType.exerciseReminder.rawValue,
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to schedule snooze: \(error)")
        } else {
            print("✅ Snoozed reminder for \(seconds) seconds (will fire at \(snoozeTime))")
            DispatchQueue.main.async {
                store.nextScheduledNotificationTime = snoozeTime
            }
        }
    }
}
```

```swift
// StandFitApp.swift - Updated snooze handlers
case "SNOOZE":
    notificationManager.snoozeReminder(seconds: 300, store: store)
    notificationManager.playClickHaptic()
```

## Observed Behavior

- User receives notification at scheduled time (e.g., 2:30 PM for a 30-min interval reminder)
- User taps "Snooze +5min" button
- Expected: Next reminder should fire in 5 minutes (2:35 PM)
- Actual: Next reminder appears to fire at the next scheduled time based on configured interval (e.g., 3:00 PM for 30-min interval)

## Impact

- User's snooze action is ignored
- Feels like notification system ignored the snooze request
- Reduces trust in snooze feature
- Users may tap snooze multiple times expecting it to work

## Likely Root Cause

The snooze action likely triggers the standard reminder rescheduling logic instead of scheduling a temporary snooze notification. When the snooze is handled:
1. Notification is dismissed ✓
2. App reschedules using `scheduleReminderWithSchedule()` ❌
3. This respects active days/hours and configured interval ❌
4. Instead of snoozing for 5 minutes ✓

## Proposed Solution

Implement proper snooze handling with a separate code path:

```swift
// In NotificationManager
func snoozeReminder(minutes: Int) {
    // Snooze notifications are temporary and override the schedule
    // They should NOT respect active days/hours
    // They should fire in exactly N minutes

    let snoozeTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
    let trigger = UNCalendarNotificationTrigger(
        matching: Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: snoozeTime
        ),
        repeats: false
    )

    let snoozeRequest = UNNotificationRequest(
        identifier: "SNOOZE_REMINDER",
        content: snoozeContent,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(snoozeRequest) { error in
        if let error = error {
            print("Failed to schedule snooze: \(error)")
        }
    }
}
```

## Key Differences from Normal Reschedule

- Snooze schedules immediately without checking active days/hours
- Snooze doesn't respect schedule boundaries (e.g., can snooze past end-of-day)
- Snooze is explicitly temporary (user manually triggered)
- Snooze doesn't trigger dead response follow-up (user consciously snoozed)
- Snooze cancels any pending follow-up from missed notification (UX2)

## User Flow (Corrected)

1. User receives reminder at 2:30 PM (configured 30-min interval)
2. Taps "Snooze +5min"
3. Notification dismisses
4. App schedules immediate re-notification for 2:35 PM (not respecting active hours)
5. At 2:35 PM, same reminder fires again
6. User can log exercise or snooze again

## Edge Cases to Handle

```swift
// What if user snoozes past midnight?
// Snooze should still fire (don't check active days)

// What if user snoozes past configured end hour (e.g., 5 PM)?
// Snooze should still fire (bypass active hours check)

// What if user snoozes then manually resets timer?
// Reset should cancel the pending snooze and schedule normally

// What if dead response timeout fires while snooze is pending?
// Snooze takes precedence (user explicitly snoozed)
// Cancel follow-up notification
```

## Files Changed

- `StandFit/Managers/NotificationManager.swift`
  - ✅ Added `snoozeReminder(seconds:store:)` method
  - ✅ Cancels follow-up reminders when snoozing
  - ✅ Uses `UNTimeIntervalNotificationTrigger` for precise timing

- `StandFit/App/StandFitApp.swift`
  - ✅ Updated SNOOZE action handler to call `snoozeReminder(seconds: 300)`
  - ✅ Updated foreground alert snooze button to call `snoozeReminder(seconds: 300)`
  - ✅ Ensured next notification after snooze uses normal schedule

## Testing Results

All test cases verified:
- ✅ Tap snooze → notification fires in exactly 5 minutes
- ✅ Snooze works regardless of active hours (e.g., snooze past end hour)
- ✅ Snooze works regardless of active days (e.g., snooze on inactive day)
- ✅ Snooze cancels pending dead response follow-up
- ✅ Multiple consecutive snoozes work correctly
- ✅ Reset timer after snooze → next notification uses normal schedule
- ✅ Logging exercise while snoozed → clears snooze and reschedules normally
- ✅ When snoozed notification fires → next one uses configured schedule

## Testing Results

All test cases verified:
- ✅ Tap snooze → notification fires in exactly 5 minutes
- ✅ Snooze works regardless of active hours (e.g., snooze past end hour)
- ✅ Snooze works regardless of active days (e.g., snooze on inactive day)
- ✅ Snooze cancels pending dead response follow-up
- ✅ Multiple consecutive snoozes work correctly
- ✅ Reset timer after snooze → next notification uses normal schedule
- ✅ Logging exercise while snoozed → clears snooze and reschedules normally
- ✅ When snoozed notification fires → next one uses configured schedule

## Related Issues

- UX2: Dead Response Reset (follow-ups should be cancelled on snooze)
- UX4: Snooze duration is hardcoded (could be made configurable)

## Priority

Medium (affects user experience with notifications, but users can work around by logging exercise)
