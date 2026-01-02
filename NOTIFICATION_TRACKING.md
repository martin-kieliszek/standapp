# Notification Tracking Implementation

**Date:** 2026-01-02  
**Status:** ✅ Implemented

---

## Overview

The StandFit app now properly tracks and persists notification delivery timestamps to provide accurate timeline visualization. Only **real notification data** is shown in the timeline - no inferred or scheduled times.

---

## Implementation Details

### 1. Persistent Notification Log

**File:** `StandFit/Managers/NotificationFiredLog.swift`

#### Features:
- ✅ **JSON file persistence** - Notifications saved to `notification_fired_log.json`
- ✅ **Automatic cleanup** - Old records (previous days) are removed on init
- ✅ **Real-time updates** - Timestamps saved immediately when notifications fire
- ✅ **ObservableObject** - SwiftUI views react to changes automatically

#### Storage Location:
```
Documents/notification_fired_log.json
```

#### Data Format:
```json
[
  "2026-01-02T10:30:00Z",
  "2026-01-02T11:00:00Z",
  "2026-01-02T11:30:00Z"
]
```

---

### 2. Notification Capture Points

Notifications are captured in **two scenarios**:

#### A. Foreground Delivery
**File:** `StandFit/App/StandFitApp.swift` - `willPresent()`

When a notification fires while the app is in the foreground:
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    // 📝 Record timestamp immediately
    NotificationFiredLog.shared.recordNotificationFired()
    
    // ... rest of handling
}
```

#### B. Background Interaction
**File:** `StandFit/App/StandFitApp.swift` - `didReceive()`

When user interacts with a notification from lock screen or notification center:
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
) async {
    // 📝 Record timestamp when user interacts
    NotificationFiredLog.shared.recordNotificationFired()
    
    // ... rest of handling
}
```

**Note:** Background notifications capture the interaction timestamp, which is close enough to delivery time for timeline purposes.

---

### 3. Timeline Service Updates

**File:** `StandFitCore/Sources/StandFitCore/Services/TimelineService.swift`

#### Before (Had Fallback):
```swift
if !firedNotifications.isEmpty {
    // Use real data
} else if let calc = calculator {
    // ❌ Fall back to scheduled times (FAKE DATA)
} else {
    notificationEvents = []
}
```

#### After (Real Data Only):
```swift
// ✅ ONLY use actual fired notifications (no inferred/fake data)
let notificationEvents = firedNotifications
    .filter { $0 >= dayStart && $0 < dayEnd }
    .map { TimelineEvent(timestamp: $0, type: .notificationFired) }
```

---

## Timeline Behavior

### Empty Timeline (First Day)
- **Before:** Timeline showed fake dots based on schedule
- **After:** Timeline is empty until notifications actually fire
- **User Impact:** More honest - users see real data accumulate over time

### With Data
- **Notification dots:** Only appear when notifications were actually delivered
- **Exercise logs:** Always shown (unchanged)
- **Correlation:** Accurate representation of notification → exercise response pattern

---

## Testing

### Manual Testing Steps

1. **Fresh Install:**
   - Install app
   - Enable notifications
   - Timeline should be **empty** (no fake dots)

2. **Receive Notification (Foreground):**
   - Open app
   - Wait for notification to fire
   - Check console: Should see `📝 Notification fired recorded at...`
   - Open Progress Report → Timeline should show **one dot**

3. **Receive Notification (Background):**
   - Close app or lock device
   - Wait for notification
   - Tap notification
   - Check console: Should see `📝 Notification fired recorded at...`
   - Timeline should show the dot

4. **Persistence:**
   - Force quit app
   - Relaunch
   - Check console: Should see `📂 Loaded X notification records from disk`
   - Timeline should show same dots as before

5. **Cleanup (Next Day):**
   - Change device time to next day
   - Relaunch app
   - Check console: Should see `🧹 Cleaned up X old notification records`
   - Timeline should be empty for new day

---

## Console Messages

### Success Messages:
```
📝 Notification fired recorded at 10:30:00 AM
💾 Saved 3 notification records to disk
📂 Loaded 3 notification records from disk
🧹 Cleaned up 5 old notification records
```

### Error Messages:
```
❌ Failed to save notification log: [error details]
❌ Failed to load notification log: [error details]
```

### Info Messages:
```
ℹ️ No existing notification log found, starting fresh
🗑️ All notification records cleared
```

---

## Privacy & Data Management

### Data Retention:
- **Current day only** - Previous days automatically deleted
- **Minimal storage** - Just timestamps (ISO8601 format)
- **No personal data** - Only when notifications fired, not content

### User Control:
Users can clear notification history:
```swift
NotificationFiredLog.shared.clearAll()
```

### File Size:
- **~50 bytes per notification**
- **~30 notifications/day** = ~1.5 KB
- **Negligible storage impact**

---

## Integration Points

### ExerciseStore
Uses real notification data for timeline:
```swift
func getTodaysTimeline() -> (notifications: [TimelineEvent], exercises: [TimelineEvent]) {
    let firedNotifications = NotificationFiredLog.shared.todaysFiredNotifications
    // ... uses real timestamps
}
```

### TimelineGraphView
Automatically shows real data (no code changes needed):
```swift
let (notifications, exercises) = store.getTodaysTimeline()
return TimelineGraphView(notifications: notifications, exercises: exercises)
```

---

## Future Enhancements

### Potential Improvements:
1. **Multi-day history** - Keep last 7/30 days for trends
2. **Notification type tracking** - Distinguish reminder vs follow-up vs report
3. **Response tracking** - Link notifications to subsequent exercises
4. **Analytics** - Average delivery time, peak notification hours
5. **iCloud sync** - Share notification history across devices

---

## Related Files

- `StandFit/Managers/NotificationFiredLog.swift` - Persistence layer
- `StandFit/App/StandFitApp.swift` - Capture points (willPresent, didReceive)
- `StandFitCore/Services/TimelineService.swift` - Timeline generation
- `StandFit/Stores/ExerciseStore.swift` - Timeline data provider
- `StandFit/Views/TimelineGraphView.swift` - Visualization

---

## Migration Notes

### Existing Users:
- **First launch after update:** Timeline will be empty
- **After first notification:** Timeline starts showing real data
- **No data loss:** Exercise logs unaffected
- **Gradual improvement:** Timeline accuracy improves as app runs

### New Users:
- Timeline empty on install (expected)
- First notification creates first data point
- Natural onboarding - users understand timeline builds over time

---

**✅ Implementation Complete**  
The timeline now shows only **real, persisted notification data** with no inferred or fake timestamps.
