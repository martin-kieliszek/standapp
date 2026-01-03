# UX7: Focus Mode Notification Warning (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-03

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

## Implementation Summary

Successfully implemented a two-part Focus Mode warning system that alerts users when their notifications may be silenced.

### Part A: Settings Warning (Always Visible)

Added a persistent informational section in SettingsView that appears for all users on iOS 15+, explaining that Focus Modes may silence reminders. This section includes:
- Purple moon icon for visual recognition
- "Focus Modes" heading
- Descriptive text explaining reminders may be silenced
- Footer with instructions to check Settings > Focus

### Part B: Active Focus Warning Banner

When Focus Mode is detected as active, a warning banner appears at the top of ContentView:
- Purple-tinted background for visual distinction
- Moon icon matching the settings section
- Real-time detection of Focus Mode status
- Updates automatically when Focus Mode is enabled/disabled

### Key Changes

1. **Created `FocusStatusManager.swift`**
   - Manages Focus Mode status detection using `INFocusStatusCenter`
   - Requests authorization on app launch
   - Publishes `isFocusActive` state for UI binding
   - Observes focus status changes via NotificationCenter
   - iOS 15+ with proper availability checks

2. **Updated `SettingsView.swift`**
   - Added Focus Mode warning section (iOS 15+)
   - Displays static informational content
   - Provides user guidance on managing Focus settings

3. **Updated `ContentView.swift`**
   - Added `@StateObject` for FocusStatusManager
   - Displays warning banner when focus is active
   - Banner positioned above trial expiration banner
   - Purple-themed design matching iOS Focus Mode aesthetics

4. **Updated `StandFitApp.swift`**
   - Requests Focus Status authorization on app launch
   - Integrated alongside notification permissions

5. **Added localized strings to `Settings.xcstrings`**
   - `settings.focus_modes` - "Focus Modes"
   - `settings.focus_may_silence` - "Reminders may be silenced when a Focus is active"
   - `settings.focus_check_settings` - "Check Settings > Focus to allow StandFit notifications"
   - `settings.focus_active_banner` - "Focus Mode active – reminders may be silenced"
   - All strings translated to 7 languages (en, de, es, fr, ja, pt-BR, zh-Hans)

6. **Updated `LocalizedString.swift`**
   - Added Settings.focusModes
   - Added Settings.focusMaySilence
   - Added Settings.focusCheckSettings
   - Added Settings.focusActiveBanner

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

## Files Changed

- ✅ `StandFit/Managers/FocusStatusManager.swift` (created)
  - Focus status detection and authorization
  - Real-time status updates via NotificationCenter
  
- ✅ `StandFit/Views/SettingsView.swift`
  - Added static Focus Mode warning section
  
- ✅ `StandFit/Views/ContentView.swift`
  - Added FocusStatusManager state object
  - Added dynamic focus mode warning banner
  
- ✅ `StandFit/App/StandFitApp.swift`
  - Request Focus Status authorization on launch
  
- ✅ `StandFit/Resources/Localizations/Settings.xcstrings`
  - Added 4 new localized strings (7 languages each)
  
- ✅ `StandFitCore/Sources/StandFitCore/Localization/LocalizedString.swift`
  - Added 4 new Settings enum properties

## Testing Results

- ✅ Settings warning section displays on iOS 15+
- ✅ Banner appears when Focus Mode is enabled
- ✅ Banner disappears when Focus Mode is disabled
- ✅ Authorization request on app launch
- ✅ Real-time status updates when focus changes
- ✅ All localized strings display correctly
- ✅ Graceful degradation on older iOS versions (warning section hidden)

## Related Issues

- UX1: Silent Settings Changes (users now warned about Focus Mode silencing)
- UX2: Dead Response Reset (Focus Mode may prevent both initial and follow-up notifications)
