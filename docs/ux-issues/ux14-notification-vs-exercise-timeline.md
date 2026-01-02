# UX14: Notification vs. Exercise Timeline Graph (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-02

## Problem Statement

Users have no visibility into whether they're responding to notifications promptly or delaying exercise logging. There's no correlation visualization between when notifications fire and when exercises are actually logged. This makes it hard to identify patterns like:
- Do users respond immediately to notifications?
- Is there a typical delay between notification and logging?
- Which times of day have the most responsive user behavior?
- Are certain notifications being consistently missed?

## Proposed Solution

A timeline visualization on the Today period showing two data series:
1. **Notification Dots** - Plot points showing when exercise reminder notifications fired
2. **Exercise Log Crosses** - Plot points showing when exercises were actually logged

## Visual Design Concept

```
Today Timeline - 24 Hour View
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      N = Notification fired (dot marker)
      X = Exercise logged (cross marker)

Notification Series ●●●●●●●
Exercise Series     ✕✕✕ ✕ ✕✕

9am        12pm       3pm        6pm        9pm
|----------|----------|----------|----------|
●        ✕ ●       ✕  ●          ✕   ●  ✕  ●

Legend: ● Notification  ✕ Exercise Logged
```

## Key Design Challenges & Solutions

| Challenge | Consideration | Proposed Solution |
|-----------|---|---|
| **Y-Axis Unit** | Two series need different vertical positions to be distinguishable | Use categorical Y-axis: top row = Notifications, bottom row = Exercises |
| **Time Resolution** | Notifications fire at scheduled intervals; exercises log at specific seconds | Group by minute (show multiple logs/notifications in same minute as stacked or overlapping) |
| **Time Range** | 24-hour view is wide; detail gets lost on watchOS screen | Option 1: Show last 12 hours. Option 2: Scrollable horizontal timeline |
| **Missing Notifications** | How to show notifications that fired but had no subsequent logs? | Mark notification dots differently (e.g., hollow vs. filled) if no log within 5-min window |
| **Multiple Logs** | What if user logs multiple exercises between notification times? | Each log gets its own marker; can stack vertically in same time slot |
| **No Logs Yet** | Today still in progress; some scheduled notifications haven't fired yet | Only show past notifications and logs |

## Data Structure Requirements

```swift
struct TimelineEvent: Identifiable {
    let id: UUID
    let timestamp: Date
    let type: TimelineEventType
    let metadata: TimelineEventMetadata
}

enum TimelineEventType {
    case notificationFired(exerciseType: ExerciseType)
    case exerciseLogged(exerciseItem: ExerciseItem, count: Int)
}

struct TimelineEventMetadata {
    let minuteOfDay: Int  // 0-1440 (for grouping)
    let secondOfMinute: Int  // for display precision
    let respondedWithinMinutes: Int?  // if notification → time until first log
}
```

## Implementation Phases

### Phase 1: Data Collection (Current State)
- Notifications are already logged via `willPresent` delegate
- Exercise logs already recorded with timestamp
- **Action needed**: Create helper methods to query today's notifications and logs by time

### Phase 2: UI Component (Proposed)
New file: `TimelineGraphView.swift`
- SwiftUI with custom Canvas or Charts framework
- Two parallel tracks (Notification row, Exercise row)
- Time axis (9 AM - 9 PM recommended for watch, or scrollable 24h)
- Interactive: tap dot to see notification details, tap cross to see exercise details

### Phase 3: Integration
- Add to `ProgressReportView` when `.today` period selected
- Position above current "Stats Header" or below "Period Range"
- Hide on Week/Month periods (data would be too dense)

### Phase 4: Advanced Features (Future)
- **Response Time Visualization**: Draw connecting lines between notification → exercise log, color-coded by delay (green <2min, yellow <5min, red >5min)
- **Heat Map**: Show busiest exercise times (density of marks indicates concentration)
- **Notification Effectiveness**: Metric showing % of notifications that resulted in logs within 5 minutes
- **Smart Grouping**: Collapse multiple notifications of same exercise type into single marker with count badge

## Critical Implementation Gap

Currently, the app doesn't persist when notifications actually fired. We only know:
1. Scheduled times (calculated from interval + active hours)
2. Exercise logs (with timestamps)

**To accurately show "Notification Fired" events**, we need to either:

**Option A (Preferred): Add timestamp to notification delivery**
```swift
// In NotificationManager
func willPresent(notification: UNNotification) {
    let firedAt = Date()  // Capture actual delivery time
    NotificationFiredLog.shared.record(firedAt, exerciseType: ...)
}
```

**Option B: Infer from schedule**
Assume notifications fired at scheduled times. This works when users aren't missing notifications, but fails to show "missed" notifications (which is valuable data).

**Recommendation**: Go with Option A for better accuracy and deeper insight into notification behavior.

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `TimelineGraphView.swift` | NEW | Timeline visualization component |
| `TimelineEvent.swift` | NEW | Data model for timeline events |
| `NotificationScheduleCalculator.swift` | NEW | Calculates expected notification times |
| `NotificationFiredLog.swift` | NEW | Lightweight store for today's notification fires |
| `ProgressReportView.swift` | MODIFY | Add TimelineGraphView when `.today` selected |
| `NotificationManager.swift` | MODIFY | Record notification fire timestamp |
| `ReportingService.swift` | EXTEND | Add `getTodaysTimeline()` method |
| `ExerciseStore.swift` | EXTEND | Add `todaysFiredNotifications` property |

## Success Metrics

- User can visualize correlation between notification times and exercise response
- Identifies peak response times (e.g., notifications sent at 3 PM have 80% response rate)
- Spots missed notifications (notification dots with no corresponding exercise log)
- Guides interval/schedule optimization (e.g., "you respond best to 2 PM reminders")

## Future Enhancements

1. **Weekly Timeline**: Show density heatmap across all days (e.g., "Mondays at 2 PM are your peak time")
2. **Response Analytics**: Dashboard showing average response time, effectiveness by time-of-day, etc.
3. **Adaptive Notifications**: Use timeline data to recommend optimal notification times based on historical response patterns
