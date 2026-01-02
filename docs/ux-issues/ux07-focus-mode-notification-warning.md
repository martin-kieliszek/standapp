# UX7: Focus Mode Notification Warning (Pending)

**Status:** ⏳ Pending

## Problem

When the user has a Focus Mode active (e.g., "Personal", "Work", "Sleep") that doesn't explicitly allow StandFit notifications, reminders are silently blocked. The user has no indication that their reminders won't be delivered.

## Proposed Solution

Two-part approach:

### Part A: Settings Warning (Always Visible)

Add a persistent informational row in SettingsView explaining that Focus Modes may silence reminders. This is always shown regardless of Focus status.

```swift
// In SettingsView
Section {
    HStack {
        Image(systemName: "moon.fill")
            .foregroundStyle(.purple)
        VStack(alignment: .leading) {
            Text("Focus Modes")
                .font(.caption)
            Text("Reminders may be silenced when a Focus is active")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
} footer: {
    Text("Check Settings > Focus to allow StandFit notifications.")
}
```

### Part B: Active Focus Warning (ContentView Banner)

When Focus Mode is detected as active, show a warning banner at the top of ContentView.

**Technical Approach:**
```swift
import Intents

// Request authorization on app launch
INFocusStatusCenter.default.requestAuthorization { status in
    // Handle authorization
}

// Check focus status
let isFocused = INFocusStatusCenter.default.focusStatus.isFocused ?? false
```

**UI (ContentView):**
```swift
if isFocusActive {
    HStack {
        Image(systemName: "moon.fill")
            .foregroundStyle(.purple)
        Text("Focus Mode active - reminders may be silenced")
            .font(.caption2)
    }
    .padding(8)
    .frame(maxWidth: .infinity)
    .background(.purple.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
}
```

## Technical Limitations

| What We Can Detect | What We Cannot Detect |
|-------------------|----------------------|
| Focus Mode is active | Which Focus is active |
| (with user permission) | Whether our app is blocked |
| | If "Share Focus Status" is off |

## API Requirements

- `INFocusStatusCenter` from Intents framework
- iOS 15+ / watchOS 8+ (unconfirmed for watchOS)
- Requires user authorization
- User must have "Share Focus Status" enabled in Settings

## Fallback

If `INFocusStatusCenter` is not available on watchOS or authorization is denied, Part A (Settings warning) still provides value as a static reminder.

## Files to Change

- `SettingsView.swift` (add Focus Mode info section)
- `ContentView.swift` (add Focus Mode banner when active)
- `NotificationManager.swift` or new `FocusStatusManager.swift` (Focus detection logic)
