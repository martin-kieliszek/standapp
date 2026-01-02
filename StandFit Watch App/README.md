# StandFit Watch App - Directory Structure

**Last Updated:** 2026-01-02
**Architecture:** Refactored to use StandFitCore

---

## Directory Organization

```
StandFit Watch App/
├── App/                    # App entry point
│   └── StandFitApp.swift   # @main app definition with WatchKit delegate
│
├── Views/                  # SwiftUI Views (14 files)
│   ├── ContentView.swift              # Main navigation hub
│   ├── ExercisePickerView.swift       # Exercise selection
│   ├── ExerciseLoggerView.swift       # Log exercise with count
│   ├── HistoryView.swift              # Exercise history
│   ├── AchievementsView.swift         # Gamification achievements
│   ├── ProgressChartsView.swift       # Statistics charts
│   ├── ProgressReportView.swift       # Detailed progress reports
│   ├── ProgressReportSettingsView.swift # Report configuration
│   ├── TimelineGraphView.swift        # UX14 timeline visualization
│   ├── SettingsView.swift             # App settings
│   ├── ReminderScheduleView.swift     # Notification schedule
│   ├── CreateExerciseView.swift       # Create custom exercises
│   ├── IconPickerView.swift           # Icon selection utility
│   └── StatsHeaderView.swift          # Reusable stats header
│
├── Stores/                 # ObservableObject state managers (2 files)
│   ├── ExerciseStore.swift            # Exercise & logs state (wraps StandFitCore services)
│   └── GamificationStore.swift        # Gamification state (wraps StandFitCore services)
│
├── Managers/               # Platform-specific managers (2 files)
│   ├── NotificationManager.swift      # WatchOS notification handling
│   └── NotificationFiredLog.swift     # Track when notifications fire
│
├── Extensions/             # Platform-specific extensions (1 file)
│   └── StandFitCore+WatchOS.swift     # SwiftUI colors for core types
│
└── Assets.xcassets/        # App icons, colors, images
```

---

## File Count Summary

| Directory | Files | Purpose |
|-----------|-------|---------|
| **App/** | 1 | App entry point |
| **Views/** | 14 | SwiftUI user interface |
| **Stores/** | 2 | State management (wraps StandFitCore) |
| **Managers/** | 2 | Notification & platform services |
| **Extensions/** | 1 | Platform-specific helpers |
| **Total** | **20** | Swift files |

---

## Architecture Overview

### **Stores** (State Management)

Both stores follow the same pattern:
1. Wrap StandFitCore services (platform-agnostic business logic)
2. Expose `@Published` properties for SwiftUI
3. Handle platform-specific concerns (notifications, etc.)

**ExerciseStore:**
- Uses `ExerciseService`, `ReportingService`, `TimelineService` from StandFitCore
- Manages exercise logs and custom exercises
- Coordinates notification scheduling
- **310 lines** (down from 613 - 49% reduction!)

**GamificationStore:**
- Uses `GamificationService` from StandFitCore
- Manages achievements, streaks, levels, challenges
- Triggers achievement notifications
- **193 lines** (down from 399 - 52% reduction!)

### **Views** (SwiftUI UI)

All views are WatchOS-specific SwiftUI code:
- **ContentView.swift** - Main navigation hub
- **Exercise Views** - ExercisePicker, ExerciseLogger, CreateExercise, History
- **Progress Views** - ProgressCharts, ProgressReport, ProgressReportSettings
- **Gamification Views** - Achievements
- **Settings Views** - Settings, ReminderSchedule
- **Utility Views** - IconPicker, StatsHeader, TimelineGraph

**Import Requirements:**
All views need `import StandFitCore` to access model types (ExerciseLog, Achievement, etc.)

### **Managers** (Platform Services)

**NotificationManager:**
- Handles WatchOS notification scheduling
- Uses `UNUserNotificationCenter`
- Sends achievement/progress notifications
- Platform-specific (uses WatchKit for haptics)

**NotificationFiredLog:**
- Tracks when notifications actually fire (for timeline analysis)
- ObservableObject for SwiftUI integration
- Ephemeral data (only keeps today's records)

### **Extensions** (Platform Helpers)

**StandFitCore+WatchOS:**
- Adds SwiftUI `Color` support to core types
- `AchievementTier.color` - Bronze/Silver/Gold/Platinum colors
- `ExerciseColorPalette` - Consistent colors for exercise items
- `TimelineEventType.color` - Colors for timeline events

---

## Dependencies

### **StandFitCore Package** (Local Swift Package)

All business logic is in StandFitCore:
- **Models:** ExerciseLog, Achievement, StreakData, etc.
- **Services:** ExerciseService, GamificationService, ReportingService, TimelineService
- **Persistence:** JSONFilePersistence (swappable to CloudKit later)
- **Utilities:** NotificationScheduleCalculator

See `/StandFitCore/README.md` for full API documentation.

### **System Frameworks**

- `SwiftUI` - User interface
- `Combine` - Reactive state management
- `UserNotifications` - Notification scheduling
- `WatchKit` - WatchOS-specific features (haptics, app delegate)

---

## Code Reuse

**Shared with iOS (via StandFitCore):**
- ✅ All data models (100%)
- ✅ All business logic (100%)
- ✅ All persistence code (100%)

**WatchOS-Specific:**
- ❌ Views (different layouts for iPhone)
- ❌ NotificationManager (different entry points on iOS)
- ❌ App entry point (UIApplicationDelegate on iOS)
- ❌ Haptic feedback (different APIs)

**Estimated code reuse for iOS:** ~60-70%

---

## Migration from Old Structure

### Before (Flat Structure):
```
StandFit Watch App/
├── 22 Swift files in root directory ❌ Hard to navigate
├── Models.swift, GamificationModels.swift, etc. ❌ Duplicated in iOS
└── ExerciseStore.swift (613 lines) ❌ Mixed concerns
```

### After (Organized Structure):
```
StandFit Watch App/
├── App/         ✅ Clear entry point
├── Views/       ✅ All UI in one place
├── Stores/      ✅ Clean state management (310 & 193 lines)
├── Managers/    ✅ Platform services
├── Extensions/  ✅ Platform helpers
└── StandFitCore ✅ Shared business logic (reusable on iOS)
```

---

## Next Steps

1. **✅ DONE: Add `import StandFitCore` to all views** (14 files in Views/)
   - All views now have the necessary import statements

2. **⚠️ CRITICAL: Add StandFitCore package to Xcode project** (manual step required)
   - Open the project in Xcode
   - File → Add Package Dependencies → Add Local
   - Select `/Users/marty/xcode/watch/StandFit/StandFitCore`
   - **This must be done before the app will compile**
   - The IDE errors you're seeing are because the package isn't linked yet

3. **✅ DONE: Archive backup files outside project**
   - Backup files moved to `/Users/marty/xcode/watch/StandFit/archived_backups/`
   - Files preserved for reference but won't interfere with compilation
   - `Backup/` directory removed from Watch App

4. **Test the app** (ensure nothing broke from reorganization)
   - Build and run in simulator
   - Test all features

---

## File Locations Quick Reference

| Looking for... | Location |
|----------------|----------|
| App entry point | `App/StandFitApp.swift` |
| Exercise logging UI | `Views/ExerciseLoggerView.swift` |
| Main navigation | `Views/ContentView.swift` |
| Exercise state | `Stores/ExerciseStore.swift` |
| Achievements state | `Stores/GamificationStore.swift` |
| Notification logic | `Managers/NotificationManager.swift` |
| Data models | `StandFitCore/Sources/StandFitCore/Models/` |
| Business logic | `StandFitCore/Sources/StandFitCore/Services/` |

---

## Troubleshooting

### "Module 'StandFitCore' not found"
→ Add StandFitCore package to Xcode project (see Next Steps #1)

### "Cannot find type 'ExerciseLog' in scope"
→ Add `import StandFitCore` to the view file

### Views not compiling
→ Ensure all 14 views have `import StandFitCore` after `import SwiftUI`

### App crashes on launch
→ Check console for errors, verify stores initialize correctly

---

**Directory Structure Version:** 1.0
**Compatible with:** StandFitCore 1.0, watchOS 9.0+
