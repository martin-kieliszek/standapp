# StandFit - Claude Development Guide

**Project Type:** Fitness App (iOS + WatchOS)
**Architecture:** Shared business logic via StandFitCore package
**Current Status:** iOS app successfully ported from WatchOS, notifications working
**Last Updated:** 2026-01-02

---

## Project Overview

StandFit is a fitness reminder app that helps users build exercise habits through:
- Scheduled exercise reminders with configurable intervals
- Exercise logging (built-in + custom exercises)
- Progress tracking with charts and analytics
- Gamification (achievements, streaks, challenges)
- Timeline visualization showing notification response patterns

### Key Features
- **Exercise Logging**: Track squats, pushups, lunges, plank, and custom exercises
- **Smart Notifications**: Configurable reminders with dead-response recovery
- **Progress Reports**: Daily/weekly/month analytics with Swift Charts
- **Gamification**: Achievements system with 4 tiers (bronze/silver/gold/platinum)
- **Timeline Analysis**: Visualize correlation between notifications and exercise response
- **Custom Exercises**: Users can create exercises with SF Symbol icons and custom units (reps/seconds)

---

## Architecture

### Code Organization

```
StandFit/
├── StandFitCore/               # Shared business logic package
│   ├── Models.swift            # Data models (ExerciseLog, Achievement, CustomExercise, etc.)
│   ├── Services/
│   │   ├── ExerciseService.swift
│   │   ├── GamificationService.swift
│   │   ├── ReportingService.swift
│   │   └── AchievementService.swift
│   └── Extensions/
│
├── StandFit/                   # iOS App
│   ├── App/
│   │   └── StandFitApp.swift   # AppDelegate, notification handling
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ExercisePickerView.swift
│   │   ├── ExerciseLoggerView.swift
│   │   ├── HistoryView.swift
│   │   ├── ProgressReportView.swift
│   │   ├── ProgressChartsView.swift
│   │   ├── TimelineGraphView.swift
│   │   ├── AchievementsView.swift
│   │   ├── SettingsView.swift
│   │   ├── ReminderScheduleView.swift
│   │   ├── CreateExerciseView.swift
│   │   └── IconPickerView.swift
│   ├── Stores/
│   │   ├── ExerciseStore.swift      # Main state management
│   │   └── GamificationStore.swift  # Achievements, streaks, levels
│   ├── Managers/
│   │   ├── NotificationManager.swift
│   │   ├── NotificationType.swift
│   │   └── NotificationFiredLog.swift
│   └── Extensions/
│       └── StandFitCore+iOS.swift   # Platform-specific color extensions
│
└── StandFit Watch App/         # WatchOS App (same structure)
```

### Key Design Patterns
- **StandFitCore**: Protocol-based business logic shared between iOS and WatchOS
- **@StateObject Stores**: ExerciseStore and GamificationStore manage app state
- **AppDelegate Pattern**: StandFitApp.swift handles notification lifecycle
- **SwiftUI Views**: All UI built with SwiftUI (no UIKit except for alerts)
- **File-based Persistence**: JSON files in Documents directory (future: CloudKit)

---

## Critical Files & Their Roles

### StandFitCore (Shared)
- **Models.swift**: All data models (ExerciseLog, CustomExercise, ExerciseItem, Achievement, etc.)
- **ExerciseService.swift**: Exercise CRUD, statistics aggregation
- **GamificationService.swift**: Achievement tracking, streak calculation, XP/leveling
- **ReportingService.swift**: Progress reports, timeline event aggregation
- **AchievementService.swift**: Achievement unlock logic and notifications

### iOS App
- **StandFitApp.swift**:
  - AppDelegate with UNUserNotificationCenterDelegate
  - Handles foreground notifications with alert dialog (shows action buttons)
  - Posts navigation events (showExercisePicker, showProgressReport)
  - Schedules follow-up reminders on notification delivery

- **ExerciseStore.swift**:
  - Published properties: logs, customExercises, settings
  - Persistence: exercise_logs.json, custom_exercises.json
  - Settings: reminderIntervalMinutes, activeHours, activeDays, deadResponseEnabled
  - Statistics methods: getStats(for:), calculateStreak()

- **GamificationStore.swift**:
  - Published properties: achievements, currentStreak, totalXP, level
  - Persistence: achievements.json, streaks.json
  - Achievement checking on exercise log

- **NotificationManager.swift**:
  - Schedules exercise reminders with UNCalendarNotificationTrigger
  - Handles follow-up/"dead response" reminders (reschedule if no response)
  - Manages notification categories and actions
  - Haptic feedback (UIImpactFeedbackGenerator)

### Key Views
- **ContentView.swift**: Main screen with timer, quick log, today's stats
- **ExercisePickerView.swift**: Grid of exercises (built-in + custom) for selection
- **ExerciseLoggerView.swift**: Count adjuster with +/- buttons, save/cancel
- **ProgressReportView.swift**: Charts for day/week/month with Swift Charts
- **TimelineGraphView.swift**: Notification vs. exercise correlation visualization
- **AchievementsView.swift**: Achievement browser with categories and progress

---

## Notification System Architecture

### Notification Flow (iOS)

```
[Notification Scheduled]
    ↓
[Notification Fires] → willPresent() in AppDelegate
    ↓
[Follow-up scheduled] (dead response timer)
    ↓
[Alert Dialog Shows] (foreground) OR [Lock Screen] (background)
    ↓
User taps action button → didReceive() in AppDelegate
    ↓
[Cancel follow-up] + [Post navigation event] + [Schedule next reminder]
```

### Critical Implementation Details

1. **Foreground Notifications** (iOS):
   - iOS banners don't show action buttons by default
   - Solution: `showNotificationAlert()` presents UIAlertController with action buttons
   - Alert shows "Log Exercise", "Snooze 5 min", "Dismiss"
   - This ensures users can respond to notifications while in-app

2. **Dead Response Recovery**:
   - When notification fires, immediately schedule follow-up (5 min default)
   - If user responds (logs exercise, snoozes), cancel follow-up
   - If no response, follow-up fires with "Still there?" message
   - Configurable timeout: 1/2/3/5/10/15 minutes

3. **Notification Categories**:
   - `EXERCISE_REMINDER`: Log Exercise, Snooze actions
   - `PROGRESS_REPORT`: View Details action
   - `ACHIEVEMENT_UNLOCKED`: View All action
   - Categories must be registered synchronously on app launch

4. **Navigation from Notifications**:
   - Action handlers post NotificationCenter events (.showExercisePicker, .showProgressReport)
   - ContentView listens with `.onReceive()` and presents sheets
   - Exercise picker opens as full-screen sheet when "Log Exercise" tapped

---

## Data Models

### ExerciseLog
```swift
struct ExerciseLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let exerciseType: ExerciseType?       // For built-in exercises
    let customExerciseId: UUID?           // For custom exercises
    let count: Int
}
```

### CustomExercise
```swift
struct CustomExercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String                      // SF Symbol name
    var unitType: ExerciseUnitType        // .reps or .seconds
    var defaultCount: Int
    var colorHex: String?
}
```

### ExerciseItem (Unified Representation)
```swift
struct ExerciseItem: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let unitType: ExerciseUnitType
    let defaultCount: Int
    let isCustom: Bool
}
```

### Achievement
```swift
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory      // milestone, consistency, volume, variety, challenge
    let tier: AchievementTier              // bronze, silver, gold, platinum
    let requirement: AchievementRequirement
    var unlockedAt: Date?
    var progress: Int
}
```

---

## Settings & Configuration

### ExerciseStore Settings (@AppStorage)
- `reminderIntervalMinutes`: Int (default: 30)
- `startHour`: Int (default: 9)
- `endHour`: Int (default: 17)
- `activeDays`: Set<Int> (0=Sunday, 6=Saturday)
- `deadResponseEnabled`: Bool (default: true)
- `deadResponseMinutes`: Int (default: 5)
- `autoReportEnabled`: Bool (default: true)
- `dailyReportEnabled`: Bool (default: true)
- `dailyReportHour`: Int (default: 20)

### Persistence Files
- `exercise_logs.json`: Array of ExerciseLog
- `custom_exercises.json`: Array of CustomExercise
- `achievements.json`: Achievement state and unlock dates
- `streaks.json`: Streak data (current, longest, last active)
- `notification_fired_log.json`: Today's notification timestamps (for timeline)

---

## Common Development Tasks

### Adding a New View
1. Create SwiftUI view file in `StandFit/Views/`
2. Import StandFitCore for models
3. Accept ExerciseStore/GamificationStore as @ObservedObject
4. Add navigation link from ContentView or SettingsView
5. Test on iOS simulator

### Adding a New Achievement
1. Define in `GamificationService.allAchievements` array
2. Specify: id, name, description, icon, category, tier, requirement
3. Achievement auto-checks on exercise log if requirement is count/streak
4. For complex requirements, add custom check in `checkForNewAchievements()`

### Modifying Notification Behavior
1. Update `NotificationManager.scheduleReminderWithSchedule()`
2. Ensure notification has proper `categoryIdentifier`
3. Test both foreground (alert dialog) and background (lock screen) delivery
4. Verify follow-up reminder cancellation logic

### Adding Custom Exercise Icon
1. Update `IconPickerView.allExerciseIcons` array
2. Add SF Symbol name to appropriate category
3. Icons are organized in pages of 6 for swipeable picker

---

## Testing Checklist

### Notification Testing
- [ ] Notification fires at scheduled time
- [ ] Foreground: Alert dialog appears with action buttons
- [ ] Background: Lock screen shows notification with actions
- [ ] "Log Exercise" opens exercise picker
- [ ] "Snooze" reschedules reminder
- [ ] Follow-up fires if no response within timeout
- [ ] Follow-up cancelled if user responds
- [ ] Next reminder scheduled after exercise log

### Exercise Logging Flow
- [ ] Select exercise from picker
- [ ] Adjust count with +/- buttons
- [ ] Quick increment buttons work (+5, +10, etc.)
- [ ] Save logs exercise and dismisses view
- [ ] Exercise appears in today's activity list
- [ ] Statistics update correctly

### Achievement System
- [ ] First exercise unlocks "First Steps" achievement
- [ ] Streak achievements unlock at 7/30/365 days
- [ ] Volume achievements track lifetime counts
- [ ] Achievement notification appears on unlock
- [ ] Progress shows correctly in AchievementsView

### Progress Reports
- [ ] Day/Week/Month period selector works
- [ ] Charts render with correct data
- [ ] Timeline graph shows notifications and exercises
- [ ] Stats header shows totals and comparisons

---

## Known Issues & Workarounds

### iOS Notification Actions (RESOLVED ✅)
**Issue**: Notification banners didn't show action buttons on iOS
**Solution**: Added `showNotificationAlert()` in StandFitApp.swift that presents UIAlertController with action buttons when notification arrives in foreground

### Progress Report Crash (RESOLVED ✅)
**Issue**: App crashed when selecting Week/Month period
**Root Cause**: Computed properties recalculated on every access, breaking Picker binding stability
**Solution**: Added cached @State properties for period calculations, invalidated on .onAppear

### Timeline Graph Data Gap
**Issue**: Notification fired times aren't persisted, only inferred from schedule
**Solution**: NotificationFiredLog.swift records actual delivery timestamps for accurate timeline

---

## Future Development Priorities

### Phase 7: Settings & Configuration (In Progress)
- [ ] Complete SettingsView with all configuration options
- [ ] ReminderScheduleView (exists, may need refinement)
- [ ] ProgressReportSettingsView
- [ ] CreateExerciseView (exists, may need refinement)
- [ ] IconPickerView (exists, may need refinement)

### Phase 8: Gamification (Pending)
- [ ] Full AchievementsView with category filtering
- [ ] Achievement unlock celebrations
- [ ] Streak protection (freeze tokens)
- [ ] Daily/weekly challenges
- [ ] Level/XP system

### Phase 9: Timeline & Analytics (Partial)
- [ ] Complete TimelineGraphView integration
- [ ] Response time analytics
- [ ] Peak response time identification
- [ ] Adaptive notification timing recommendations

### Phase 10: Polish & iOS-Specific Features (Pending)
- [ ] App icon (1024x1024)
- [ ] Launch screen
- [ ] Dark mode testing
- [ ] iPad support (multi-column layout)
- [ ] Widgets (Today widget, lock screen widget)
- [ ] Home screen quick actions
- [ ] Accessibility (VoiceOver, Dynamic Type)

### UX Issues (see UX_ISSUES.md for details)
- **UX4**: Additional polish items (save confirmation, error messages, etc.)
- **UX7**: Focus Mode notification warning
- **UX11**: Social features (friends, leaderboards, sharing)
- **UX12**: Snooze button behavior refinement
- **UX15**: Monetization strategy implementation
- **UX16**: User-created achievement templates
- **UX17**: Multi-platform deployment strategy

---

## Code Style & Conventions

### SwiftUI View Structure
```swift
struct ExampleView: View {
    @ObservedObject var store: ExerciseStore  // Shared state
    @State private var localState: String = "" // Local state

    var body: some View {
        // View hierarchy
    }

    // Helper views as computed properties or subviews
    private var sectionHeader: some View {
        // ...
    }
}
```

### Naming Conventions
- Views: `PascalCase` ending with `View` (e.g., `ExercisePickerView`)
- Stores: `PascalCase` ending with `Store` (e.g., `ExerciseStore`)
- Services: `PascalCase` ending with `Service` (e.g., `GamificationService`)
- Models: `PascalCase` (e.g., `ExerciseLog`, `Achievement`)
- Functions: `camelCase` with verb prefix (e.g., `scheduleReminder`, `logExercise`)

### Error Handling
- Use `guard let` for safe unwrapping
- Add early-exit guards to prevent infinite loops (e.g., `getStats()`)
- Log errors with descriptive messages
- Never use force unwrap (`!`) in production code

---

## Important Notes for Claude

### When Making Changes
1. **Always read files before modifying** - Don't propose changes to code you haven't seen
2. **Respect existing patterns** - Follow the architecture and conventions already in place
3. **Test notification flows** - iOS has different behavior than WatchOS
4. **Check both platforms** - Changes to StandFitCore affect both iOS and WatchOS
5. **Update documentation** - Keep IOS_PORT.md and UX_ISSUES.md current

### When Adding Features
1. **Start with StandFitCore** - Add models and business logic to shared package first
2. **Then add UI** - Create platform-specific views in iOS/WatchOS apps
3. **Consider both platforms** - WatchOS has smaller screen, different interaction patterns
4. **Maintain backwards compatibility** - Existing logs and data must continue to work

### When Debugging Notifications
1. **Check AppDelegate setup** - Delegate must be set synchronously on launch
2. **Verify category registration** - Categories must be registered before notification scheduling
3. **Test foreground vs background** - Different code paths execute
4. **Check notification permissions** - Use Settings app to verify authorization

### When Working with Persistence
1. **Always decode with error handling** - JSON files can be corrupted
2. **Provide default values** - Missing files should initialize with empty arrays
3. **Save after mutations** - Changes must be persisted to disk
4. **Consider migration** - Plan for schema changes in future

---

## Resources & Documentation

### Apple Frameworks Used
- **SwiftUI**: All UI components
- **UserNotifications**: Notification scheduling and handling
- **Swift Charts**: Progress report visualizations
- **Combine**: @Published property observation
- **Foundation**: Date handling, file I/O, JSON encoding

### External Dependencies
- None (pure Apple ecosystem)

### Reference Files
- [IOS_PORT.md](IOS_PORT.md) - iOS porting implementation plan with phase completion status
- [UX_ISSUES.md](UX_ISSUES.md) - Comprehensive UX issue tracker with solutions and analysis
- [NOTIFICATION_ISSUE.md](NOTIFICATION_ISSUE.md) - Deep dive into iOS notification action button issue (resolved)

---

## Quick Reference Commands

### Build & Run
```bash
# Build iOS app
xcodebuild -scheme "StandFit" -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Build WatchOS app
xcodebuild -scheme "StandFit Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### Git Workflow
```bash
# Current branch: feature/ios-amp
# Main branch: (not specified, ask user before creating PRs)

# Typical workflow
git status
git add .
git commit -m "Descriptive message"
# Do NOT push unless user explicitly requests
```

### File Operations
```bash
# Find exercise logs
find . -name "exercise_logs.json"

# Check app storage
ls ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Documents/

# Clear notification database (simulator)
xcrun simctl spawn booted log config --subsystem com.apple.notificationcenter --mode "level:debug"
```

---

## Contact & Support

**Developer**: Marty (user)
**Project Location**: `/Users/marty/xcode/ios/StandFit`
**Last Claude Session**: 2026-01-02

**For Questions**:
- Check UX_ISSUES.md for known problems and solutions
- Check IOS_PORT.md for implementation status
- Refer to code comments for inline documentation
- Ask Marty for clarification on product decisions

---

**Remember**: This is a real app actively in development. Changes should be production-ready, well-tested, and maintain backwards compatibility with existing user data.
