# UX6: Reset Timer Button Lacks Context (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-02

## Problem

The "Reset Timer" button in ContentView doesn't indicate what interval it will reset to. Users must remember their configured interval or check Settings to know what will happen.

**Current State:**
```
Button label: "Reset Timer"
Actual behavior: Schedules reminder for configured interval (e.g., 30 min)
```

## User's Suggestion

Show "+30m" or similar to indicate the interval.

## UX Analysis

| Approach | Pros | Cons |
|----------|------|------|
| `Reset (+30m)` | Compact, shows interval | May be inaccurate if schedule pushes to next day |
| `Reset to 3:45 PM` | Accurate, shows actual time | Takes more space, needs calculation |
| `Reset` + post-tap feedback | Clean button, accurate info | Requires extra UI element |

## Important Consideration

The `nextValidReminderDate()` function respects active days and hours. If the user taps "Reset" at 4:55 PM with end hour at 5 PM and a 30-min interval, the actual next reminder might be **tomorrow at 9 AM**, not "+30m from now".

Showing "+30m" would be **misleading** in edge cases.

## Chosen Solution: Simple Interval Display

Show the configured interval on the button. The timer card already displays the actual scheduled time after reset, providing accurate feedback for edge cases.

**Rationale:**
- Communicates the *intent* of the interval setting
- Timer card immediately shows *actual* scheduled time after tap
- Edge cases (outside active hours) are rare
- Simple to implement and maintain

## Proposed Implementation

```swift
// Current
Label("Reset Timer", systemImage: "arrow.clockwise")

// Proposed
Label("Reset (+\(formatInterval(store.reminderIntervalMinutes)))", systemImage: "arrow.clockwise")

// Examples: "Reset (+30m)", "Reset (+1h)", "Reset (+1h 30m)"
```

## Files to Change

- `ContentView.swift` (update button label)
