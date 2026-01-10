# Notification Reliability Implementation Plan

**Document Created**: 2026-01-10
**Status**: Planning
**Priority**: Critical - Core app functionality depends on reliable notifications

---

## Executive Summary

StandFit's current notification system schedules only **one notification at a time** and relies on app execution when that notification fires to schedule the next one. This approach is fundamentally unreliable on iOS because:

1. **Background execution is not guaranteed** - iOS only calls `willPresent()` when app is in foreground
2. **User interaction required** - `didReceive()` only runs when user explicitly taps the notification
3. **No recovery mechanism** - If a notification fires and the chain breaks, no more notifications come

This plan implements a **batch-queuing approach** that pre-schedules up to 60 exercise reminder notifications, with reserved slots for other notification types and multiple safeguards to ensure the queue stays populated.

---

## Notification Types & Slot Allocation

iOS limits apps to **64 pending local notifications**. We must allocate slots carefully:

| Notification Type | Identifier Pattern | Reserved Slots | Notes |
|-------------------|-------------------|----------------|-------|
| **Exercise Reminders** | `exercise_YYYYMMDD_HHMM` | Up to 58 | Main queue, batch scheduled |
| **Snooze Reminder** | `snooze_YYYYMMDD_HHMM` | 1 | Replaces next exercise reminder timing |
| **Dead Response** | `dead_response` | 1 | Single slot, scheduled on notification fire |
| **Progress Report** | `progress_report` | 1 | Single repeating notification |
| **Achievement** | `achievement_<id>` | 3 | Immediate fire, rarely pending |
| **Buffer** | - | 0 | Safety margin |
| **TOTAL** | - | **64** | iOS maximum |

### Slot Allocation Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    64 NOTIFICATION SLOTS                         │
├─────────────────────────────────────────────────────────────────┤
│ ████████████████████████████████████████████████████████ │ █ │ █ │ ███ │
│           Exercise Reminders (58 max)            │Snz│DR │ PR │Ach│
└─────────────────────────────────────────────────────────────────┘

Exercise Reminders: Dynamically calculated based on profile (may be < 58)
Snooze (Snz): 1 slot - scheduled when user snoozes
Dead Response (DR): 1 slot - scheduled when notification fires
Progress Report (PR): 1 slot - recurring daily/weekly
Achievements (Ach): 3 slots - fire immediately, rarely pending
```

### Why Variable Exercise Reminder Count

The number of exercise reminders depends entirely on the **active schedule profile**:

| Profile Example | Reminders per Day | 7-Day Total | Fits in 58? |
|-----------------|-------------------|-------------|-------------|
| Every 30min, 9am-5pm, weekdays | 16 | 80 | No - cap at 58 (~3.6 days) |
| Every 60min, 9am-5pm, weekdays | 8 | 40 | Yes |
| Every 30min, 9am-12pm, weekdays | 6 | 30 | Yes |
| Every 2hr, 9am-5pm, all days | 4 | 28 | Yes |
| Fixed times (3 per day) | 3 | 21 | Yes |

**Key insight**: We schedule as many as will fit (up to 58), which may be less than 7 days for frequent reminder profiles. The queue self-refills as notifications fire and app runs.

---

## Current Implementation Analysis

### How It Works Now

```
User enables reminders
        ↓
scheduleReminderWithSchedule() → Creates 1 notification
        ↓
Notification fires → willPresent() (foreground only!)
        ↓
Schedule next notification ← THIS OFTEN DOESN'T RUN
        ↓
Chain breaks...
```

### Key Problems Identified

| Problem | Impact | Current Code Location |
|---------|--------|----------------------|
| Single notification scheduling | Chain breaks easily | `NotificationManager.swift:264-302` |
| Relies on `willPresent()` | Only runs in foreground | `StandFitApp.swift:127-153` |
| No batch pre-scheduling | Can't survive app inactivity | N/A - not implemented |
| No background refresh | Queue empties over time | N/A - not implemented |
| Same identifier reused | Can't track individual notifications | Uses `exerciseReminder` for all |

### iOS Notification Constraints

- **Maximum 64 pending local notifications** per app
- `UNCalendarNotificationTrigger` with `repeats: true` only supports simple patterns (same time daily/weekly)
- Complex schedules (every 30 min, 9am-5pm, weekdays only) require individual notifications
- Background App Refresh can wake app periodically but is not guaranteed
- Push notifications require server infrastructure (out of scope for v1)

---

## Proposed Solution Architecture

### Core Principle: **Defensive Batch Scheduling**

Instead of scheduling one notification and hoping the app runs to schedule the next, we:

1. **Pre-schedule 7 days of notifications** at once (up to 60 notifications)
2. **Validate and refill** the queue at every opportunity
3. **Use unique identifiers** so notifications don't overwrite each other
4. **Enable Background App Refresh** as an additional safeguard

### New Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION QUEUE MANAGER                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌─────────────────────────────────┐   │
│  │ Schedule Engine  │────│ Queue of 60 Pending Notifications│   │
│  └──────────────────┘    └─────────────────────────────────┘   │
│           │                            │                        │
│           ▼                            ▼                        │
│  calculateAllReminders()        iOS Notification Center         │
│  for next 7 days                (up to 64 limit)               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

                    VALIDATION TRIGGERS

┌────────────┐  ┌─────────────────┐  ┌────────────────────────┐
│ App Launch │  │ App Foreground  │  │ Background App Refresh │
└─────┬──────┘  └────────┬────────┘  └───────────┬────────────┘
      │                  │                       │
      └──────────────────┼───────────────────────┘
                         ▼
              ensureNotificationQueue()
                         │
      ┌──────────────────┼──────────────────┐
      ▼                  ▼                  ▼
 Count pending    Remove expired    Fill to 60
 notifications    notifications    if below threshold
```

---

## Implementation Details

### 1. Notification Identifier System

**Current**: Single identifier `"exerciseReminder"` - each new notification overwrites the previous

**New**: Timestamp-based unique identifiers

```swift
// Format: "exercise_reminder_YYYYMMDD_HHMM"
// Example: "exercise_reminder_20260110_0930"

static func identifier(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmm"
    return "exercise_reminder_\(formatter.string(from: date))"
}

static func identifier(prefix: String, date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmm"
    return "\(prefix)_\(formatter.string(from: date))"
}
```

**Benefits**:
- Each notification has unique ID
- Can schedule 60+ without overwriting
- Can identify/cancel specific future notifications
- Easy to parse date from identifier for debugging

### 2. Batch Scheduling Engine

**New file**: `NotificationQueueManager.swift`

```swift
class NotificationQueueManager {
    static let shared = NotificationQueueManager()

    // Configuration
    private let maxQueuedNotifications = 60  // Leave room for progress reports, etc.
    private let daysToScheduleAhead = 7
    private let refillThreshold = 30  // Refill when below this count

    /// Calculate all reminder times for the next N days based on current schedule profile
    func calculateUpcomingReminderTimes(
        store: ExerciseStore,
        from startDate: Date = Date(),
        maxCount: Int = 60
    ) -> [Date] {
        // Implementation uses existing schedule calculation logic
        // Returns array of Date objects for each reminder
    }

    /// Ensure the notification queue is properly populated
    func ensureNotificationQueue(store: ExerciseStore) async {
        // 1. Get current pending notifications
        // 2. Filter to only exercise reminders
        // 3. Remove any that are in the past
        // 4. If count < threshold, calculate and schedule more
    }

    /// Full refresh - cancel all and reschedule from scratch
    func rebuildNotificationQueue(store: ExerciseStore) async {
        // Used when schedule profile changes
    }
}
```

### 3. Validation Trigger Points

The queue should be validated/refilled at these moments:

| Trigger | Implementation | Reliability |
|---------|---------------|-------------|
| App launch | `didFinishLaunchingWithOptions` | High - runs every cold start |
| App foreground | `willEnterForeground` | High - runs on every open |
| Background refresh | `BGAppRefreshTask` | Medium - iOS controls frequency |
| Settings change | `updateAllNotificationSchedules()` | High - user-triggered |
| Exercise logged | After successful log | High - frequent user action |

### 4. Background App Refresh Setup

**Info.plist additions**:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.standfit.notification-refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

**Registration in AppDelegate**:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.standfit.notification-refresh",
        using: nil
    ) { task in
        self.handleNotificationRefresh(task: task as! BGAppRefreshTask)
    }
}

func handleNotificationRefresh(task: BGAppRefreshTask) {
    task.expirationHandler = { task.setTaskCompleted(success: false) }

    Task {
        await NotificationQueueManager.shared.ensureNotificationQueue(
            store: ExerciseStore.shared
        )
        task.setTaskCompleted(success: true)

        // Schedule next refresh
        scheduleBackgroundRefresh()
    }
}

func scheduleBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.standfit.notification-refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60) // 4 hours
    try? BGTaskScheduler.shared.submit(request)
}
```

### 5. Profile Change Handling

When the user changes their schedule profile, the entire exercise reminder queue must be rebuilt:

```
Profile Change Detected
        ↓
┌───────────────────────────────────────────┐
│     rebuildNotificationQueue()            │
├───────────────────────────────────────────┤
│ 1. Cancel ALL exercise reminder notifs    │
│    (identifiers starting with "exercise_")│
│                                           │
│ 2. Cancel snooze notification             │
│    (if any pending)                       │
│                                           │
│ 3. Cancel dead response notification      │
│    (if any pending)                       │
│                                           │
│ 4. Recalculate reminder times using       │
│    NEW profile settings                   │
│                                           │
│ 5. Schedule new batch of notifications    │
│                                           │
│ 6. DO NOT touch progress report           │
│    (independent schedule)                 │
└───────────────────────────────────────────┘
```

**Triggers for queue rebuild**:
- `switchToProfile()` - User selects different profile
- `updateProfile()` - User edits active profile (times, days, intervals)
- `remindersEnabled` toggled on
- App detects time zone change

**Triggers for queue validation (not full rebuild)**:
- App launch / foreground
- Background refresh
- Exercise logged
- Notification fired (in foreground)

### 6. Snooze Handling

Snooze requires special handling:

```
User taps "Snooze 5 min"
        ↓
┌───────────────────────────────────────────┐
│ 1. Cancel dead response notification      │
│    (user responded, no need for follow-up)│
│                                           │
│ 2. Schedule snooze notification           │
│    - ID: "snooze_YYYYMMDD_HHMM"          │
│    - Fires in 5 minutes                   │
│    - Uses reserved snooze slot            │
│                                           │
│ 3. DO NOT cancel exercise queue           │
│    (next scheduled reminder stays)        │
│                                           │
│ 4. When snooze fires:                     │
│    - Behaves like exercise reminder       │
│    - Can be snoozed again                │
│    - Dead response scheduled if enabled   │
└───────────────────────────────────────────┘
```

**Important**: Snooze notification uses its own reserved slot and doesn't interfere with the pre-scheduled queue. The next regular reminder will still fire at its scheduled time.

### 7. Dead Response Handling

Dead response notifications are scheduled **reactively** when a notification fires (requires foreground execution):

```
Exercise/Snooze Notification Fires
        ↓
willPresent() runs (foreground only)
        ↓
┌───────────────────────────────────────────┐
│ scheduleDeadResponseReminder()            │
├───────────────────────────────────────────┤
│ - ID: "dead_response" (single slot)       │
│ - Fires in X minutes (configurable)       │
│ - Message: "Still there?"                 │
│ - Same actions as exercise reminder       │
└───────────────────────────────────────────┘
        ↓
User responds (logs, snoozes, dismisses)
        ↓
Cancel dead response notification

OR

No response → Dead response fires → Schedule another
```

**Limitation**: Dead response only works when app is in foreground during notification delivery. This is acceptable because:
1. The batch queue ensures primary notifications always fire
2. Dead response is a secondary "nudge" mechanism
3. If app isn't running, user sees the notification on lock screen anyway

### 8. Progress Report Handling

Progress reports use iOS's built-in repeating mechanism and are **independent** of exercise reminders:

```swift
// Daily: fires at same time every day
let trigger = UNCalendarNotificationTrigger(
    dateMatching: DateComponents(hour: 20, minute: 0),
    repeats: true  // iOS handles repetition
)

// Weekly: fires at same time every Sunday
let trigger = UNCalendarNotificationTrigger(
    dateMatching: DateComponents(hour: 20, minute: 0, weekday: 1),
    repeats: true
)
```

**Key points**:
- Uses single slot with `repeats: true`
- Not affected by profile changes
- Scheduled/cancelled based on `progressReportSettings.enabled`
- Content updates require cancelling and rescheduling (for fresh stats)

---

## File Changes Summary

### New Files

| File | Purpose |
|------|---------|
| `NotificationQueueManager.swift` | Core batch scheduling logic |
| `NotificationIdentifier.swift` | Identifier generation utilities |

### Modified Files

| File | Changes |
|------|---------|
| `NotificationManager.swift` | Deprecate single-notification methods, add queue integration |
| `StandFitApp.swift` | Add Background App Refresh, update lifecycle handlers |
| `ExerciseStore.swift` | Trigger queue validation after exercise log |
| `Info.plist` | Add background modes and task identifiers |

### Removed/Deprecated

| Method | Replacement |
|--------|-------------|
| `scheduleReminderWithSchedule()` | `NotificationQueueManager.ensureNotificationQueue()` |
| `cancelAllReminders()` | `NotificationQueueManager.clearExerciseReminders()` |

---

## Implementation Phases

### Phase 1: Core Queue Manager (Day 1)

1. Create `NotificationQueueManager.swift` with:
   - Identifier generation
   - `calculateUpcomingReminderTimes()` using existing schedule logic
   - `ensureNotificationQueue()` main validation method
   - `rebuildNotificationQueue()` for full refresh

2. Create `NotificationIdentifier.swift` with:
   - Identifier format constants
   - Date parsing from identifier
   - Identifier validation

### Phase 2: Integration (Day 1-2)

1. Update `NotificationManager.swift`:
   - Add `scheduleNotificationBatch()` method
   - Keep existing methods for backwards compatibility during transition
   - Add queue status debugging methods

2. Update `StandFitApp.swift`:
   - Replace single notification scheduling with queue validation
   - Update `ensureNotificationChainActive()` to use new system

### Phase 3: Background Refresh (Day 2)

1. Update `Info.plist` with required entries
2. Add Background Task registration in AppDelegate
3. Implement refresh task handler
4. Add scheduling of next refresh task

### Phase 4: Testing & Debugging (Day 2-3)

1. Add comprehensive logging
2. Create debug view showing:
   - Pending notification count
   - Next N notification times
   - Last queue validation time
3. Test scenarios:
   - Fresh install
   - Schedule profile change
   - Snooze handling
   - Multiple days without opening app
   - App killed and restarted

### Phase 5: Polish & Edge Cases (Day 3)

1. Handle schedule profile switches
2. Handle reminders being disabled/enabled
3. Handle time zone changes
4. Handle clock changes (DST, manual adjustment)
5. Memory and battery optimization

---

## Testing Checklist

### Unit Tests

- [ ] `calculateUpcomingReminderTimes()` returns correct times for various profiles
- [ ] Identifier generation produces unique, parseable IDs
- [ ] Queue fills correctly from empty state
- [ ] Queue refills when below threshold
- [ ] Past notifications are removed during validation

### Integration Tests

- [ ] App launch triggers queue validation
- [ ] App foreground triggers queue validation
- [ ] Settings change triggers queue rebuild
- [ ] Exercise log triggers queue validation
- [ ] Snooze works without disrupting queue
- [ ] Dead response still works

### Manual Testing Scenarios

#### Core Queue Behavior
| Scenario | Expected Behavior |
|----------|------------------|
| Fresh install, enable reminders | Queue fills with up to 58 exercise notifications |
| Open Settings > Notifications on device | See exercise reminders + 1 progress report |
| Leave app closed for 3 days | Notifications still fire (pre-scheduled) |
| Disable then re-enable reminders | Queue rebuilt from scratch |

#### Profile Change Scenarios
| Scenario | Expected Behavior |
|----------|------------------|
| Switch to different profile | All exercise notifs cancelled, queue rebuilt with new profile |
| Edit active profile (change interval) | Queue rebuilt with new interval |
| Edit active profile (change hours) | Queue rebuilt with new hours |
| Edit active profile (change active days) | Queue rebuilt with new days |
| Profile with 30min interval, 9-5 weekdays | ~58 notifications (caps at limit, ~3.6 days coverage) |
| Profile with 2hr interval, 9-5 weekdays | ~28 notifications (full 7 days coverage) |
| Profile with fixed times (3/day) | 21 notifications (full 7 days coverage) |

#### Snooze Scenarios
| Scenario | Expected Behavior |
|----------|------------------|
| Snooze a notification | Snooze fires in 5 min, exercise queue intact |
| Snooze then another exercise reminder fires | Both work independently |
| Snooze twice in a row | Second snooze replaces first |
| Snooze then change profile | Snooze cancelled, new queue scheduled |

#### Dead Response Scenarios
| Scenario | Expected Behavior |
|----------|------------------|
| Notification fires (app foreground) | Dead response scheduled |
| User logs exercise | Dead response cancelled |
| User snoozes | Dead response cancelled |
| User dismisses | Dead response stays scheduled |
| No response, dead response fires | Another dead response scheduled |
| Notification fires (app background) | No dead response (expected limitation) |

#### Progress Report Scenarios
| Scenario | Expected Behavior |
|----------|------------------|
| Enable daily reports at 8pm | Single repeating notification scheduled |
| Enable weekly reports | Single repeating notification (Sundays) |
| Change report time | Old cancelled, new scheduled |
| Change schedule profile | Progress report unchanged |
| Disable progress reports | Progress report cancelled |

#### Edge Cases
| Scenario | Expected Behavior |
|----------|------------------|
| Time zone change | Queue rebuilt with correct local times |
| DST transition | Queue rebuilt, times adjust correctly |
| Very frequent reminders (every 5 min) | Caps at 58 notifications |
| No active days in profile | No exercise notifications scheduled |
| App force quit then reopened | Queue validated, refilled if needed |
| Low battery mode | Background refresh may be delayed (acceptable) |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Background refresh not running | Medium | Medium | Multiple validation triggers + 7-day queue |
| iOS changes notification limits | Low | High | Monitor iOS releases, stay well under 64 |
| Schedule calculation bugs | Medium | High | Extensive testing, logging, debug UI |
| Performance impact of queue management | Low | Low | Async operations, efficient algorithms |
| Battery drain from background refresh | Low | Medium | Request refresh sparingly (every 4+ hours) |

---

## Success Criteria

1. **Reliability**: Notifications fire for at least 7 days without user opening app
2. **Self-healing**: Queue automatically recovers from any broken state
3. **No regressions**: Snooze, dead response, progress reports still work
4. **Performance**: Queue operations complete in <100ms
5. **Debuggability**: Clear logging shows queue state at all times

---

## Appendix A: iOS Notification System Reference

### UNUserNotificationCenter Limits
- Maximum 64 pending local notifications per app
- Notifications with same identifier replace previous
- `UNCalendarNotificationTrigger` repeating only works for simple patterns

### UNNotificationTrigger Types
- `UNTimeIntervalNotificationTrigger` - fires after X seconds, optionally repeats
- `UNCalendarNotificationTrigger` - fires at specific date/time, optionally repeats
- `UNLocationNotificationTrigger` - fires at location (not used)

### Background Execution Options
- `BGAppRefreshTask` - periodic refresh, system-controlled timing
- `BGProcessingTask` - longer tasks, requires device charging
- Silent push notifications - requires server infrastructure

---

## Appendix B: Code Examples

### Notification Identifier Constants

```swift
/// Centralized identifier management for all notification types
enum NotificationIdentifier {
    // MARK: - Prefixes
    static let exercisePrefix = "exercise_"
    static let snoozePrefix = "snooze_"
    static let deadResponse = "dead_response"  // Single identifier (only one at a time)
    static let progressReport = "progress_report"  // Single identifier (repeating)
    static let achievementPrefix = "achievement_"

    // MARK: - Date Formatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter
    }()

    // MARK: - Identifier Generators
    static func exerciseReminder(for date: Date) -> String {
        return "\(exercisePrefix)\(dateFormatter.string(from: date))"
    }

    static func snoozeReminder(for date: Date) -> String {
        return "\(snoozePrefix)\(dateFormatter.string(from: date))"
    }

    static func achievement(id: String) -> String {
        return "\(achievementPrefix)\(id)"
    }

    // MARK: - Identifier Checks
    static func isExerciseReminder(_ identifier: String) -> Bool {
        return identifier.hasPrefix(exercisePrefix)
    }

    static func isSnoozeReminder(_ identifier: String) -> Bool {
        return identifier.hasPrefix(snoozePrefix)
    }

    static func isAchievement(_ identifier: String) -> Bool {
        return identifier.hasPrefix(achievementPrefix)
    }

    // MARK: - Date Extraction
    static func date(from identifier: String) -> Date? {
        let prefixes = [exercisePrefix, snoozePrefix]
        for prefix in prefixes {
            if identifier.hasPrefix(prefix) {
                let dateString = String(identifier.dropFirst(prefix.count))
                return dateFormatter.date(from: dateString)
            }
        }
        return nil
    }
}
```

### Calculating Reminder Times

```swift
func calculateUpcomingReminderTimes(
    store: ExerciseStore,
    from startDate: Date = Date(),
    maxCount: Int = 58  // Reserve slots for snooze, dead response, etc.
) -> [Date] {
    var reminderTimes: [Date] = []
    var currentDate = startDate

    // Use existing calculateNextReminderTime but iterate
    while reminderTimes.count < maxCount {
        guard let nextTime = NotificationManager.shared.calculateNextReminderTime(
            store: store,
            from: currentDate
        ) else {
            break // No more valid times based on profile
        }

        // Safety: don't go more than 7 days out
        if nextTime.timeIntervalSince(startDate) > 7 * 24 * 60 * 60 {
            break
        }

        reminderTimes.append(nextTime)
        currentDate = nextTime.addingTimeInterval(60) // Move past this time
    }

    return reminderTimes
}
```

### Scheduling Exercise Reminder Batch

```swift
func scheduleExerciseReminderBatch(times: [Date]) async {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "Time to Move!"
    content.body = "Stand up and do some exercise"
    content.sound = .default
    content.categoryIdentifier = "EXERCISE_REMINDER"

    for time in times {
        let identifier = NotificationIdentifier.exerciseReminder(for: time)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: time
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification for \(time): \(error)")
        }
    }

    print("✅ Scheduled \(times.count) exercise reminders")
}
```

### Cancelling Exercise Reminders Only

```swift
func cancelAllExerciseReminders() async {
    let center = UNUserNotificationCenter.current()
    let pendingRequests = await center.pendingNotificationRequests()

    // Find all exercise reminder identifiers
    let exerciseIds = pendingRequests
        .map(\.identifier)
        .filter { NotificationIdentifier.isExerciseReminder($0) }

    center.removePendingNotificationRequests(withIdentifiers: exerciseIds)
    print("🗑️ Cancelled \(exerciseIds.count) exercise reminders")
}
```

### Profile Change Handler

```swift
func handleProfileChange(store: ExerciseStore) async {
    print("📅 Profile changed - rebuilding notification queue")

    // 1. Cancel all exercise-related notifications (but NOT progress report)
    await cancelAllExerciseReminders()
    UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [NotificationIdentifier.deadResponse]
    )
    // Also cancel any pending snooze
    let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
    let snoozeIds = pending.map(\.identifier).filter { NotificationIdentifier.isSnoozeReminder($0) }
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: snoozeIds)

    // 2. Recalculate and schedule new queue
    let newTimes = calculateUpcomingReminderTimes(store: store, maxCount: 58)
    await scheduleExerciseReminderBatch(times: newTimes)

    print("✅ Queue rebuilt with \(newTimes.count) notifications based on new profile")
}
```

### Queue Validation (Ensure/Refill)

```swift
func ensureNotificationQueue(store: ExerciseStore, refillThreshold: Int = 30) async {
    guard store.remindersEnabled else { return }

    let center = UNUserNotificationCenter.current()
    let pendingRequests = await center.pendingNotificationRequests()

    // Count only exercise reminders
    let exerciseCount = pendingRequests.filter {
        NotificationIdentifier.isExerciseReminder($0.identifier)
    }.count

    print("📊 Queue status: \(exerciseCount) exercise reminders pending")

    if exerciseCount < refillThreshold {
        print("⚠️ Below threshold (\(refillThreshold)) - refilling queue")

        // Find the latest scheduled time to continue from there
        let latestScheduledTime = pendingRequests
            .compactMap { NotificationIdentifier.date(from: $0.identifier) }
            .max() ?? Date()

        let newTimes = calculateUpcomingReminderTimes(
            store: store,
            from: latestScheduledTime.addingTimeInterval(60),
            maxCount: 58 - exerciseCount  // Only fill remaining slots
        )

        await scheduleExerciseReminderBatch(times: newTimes)
        print("✅ Added \(newTimes.count) notifications, total now: \(exerciseCount + newTimes.count)")
    } else {
        print("✅ Queue is healthy")
    }
}
```

---

## Next Steps

1. **Review this plan** - Ensure alignment with product goals
2. **Implement Phase 1** - Core queue manager
3. **Test thoroughly** - Use simulator and device testing
4. **Monitor in production** - Add analytics for notification reliability

---

*Document prepared for StandFit iOS notification reliability improvement project*
