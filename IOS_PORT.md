# StandFit iOS Port - Implementation Plan

**Created:** 2026-01-02
**Architecture:** Uses StandFitCore for all business logic
**Code Reuse:** ~70% shared with WatchOS via StandFitCore

---

## Overview

This document outlines the phased approach to building the iOS version of StandFit. Each phase can be built and tested independently before moving to the next.

### Key Principles

1. **Reuse StandFitCore** - All business logic, models, and services are already built
2. **Platform-specific UI** - iOS has different screen sizes and interaction patterns
3. **Incremental builds** - Each phase should compile and run
4. **Test as we go** - Build → Test → Commit → Next phase

---

## Phase 1: Project Setup & Basic Structure ✅

**Goal:** Create iOS target and verify StandFitCore integration
**Status:** COMPLETE

### Tasks

- [x] Create new iOS App target in Xcode project (directory structure ready)
  - Name: `StandFit iOS`
  - Interface: SwiftUI
  - Minimum deployment: iOS 16.0

- [x] Add StandFitCore package dependency to iOS target
  - Same local package used by WatchOS

- [x] Create basic directory structure:
  ```
  StandFit iOS/
  ├── App/
  │   └── StandFitApp.swift
  ├── Views/
  ├── Stores/
  ├── Managers/
  └── Extensions/
  ```

- [x] Create minimal `ContentView.swift`:
  ```swift
  import SwiftUI
  import StandFitCore

  struct ContentView: View {
      var body: some View {
          Text("StandFit iOS")
              .font(.largeTitle)
      }
  }
  ```

- [x] **Build & Test:** App launches with "StandFit iOS" text

**Success Criteria:** iOS app builds and runs on simulator ✅

---

## Phase 2: State Management (Stores) ✅

**Goal:** Port ExerciseStore and GamificationStore to iOS
**Status:** COMPLETE

### Tasks

- [x] Create `Stores/ExerciseStore.swift`
  - Copy from WatchOS version
  - Remove `@MainActor` if not needed on iOS
  - Keep all StandFitCore service integrations
  - Adjust for iOS-specific persistence paths if needed

- [x] Create `Stores/GamificationStore.swift`
  - Copy from WatchOS version
  - Same pattern as ExerciseStore

- [x] Update `ContentView.swift` to initialize stores:
  ```swift
  struct ContentView: View {
      @StateObject private var exerciseStore = ExerciseStore.shared
      @StateObject private var gamificationStore = GamificationStore.shared

      var body: some View {
          Text("Stores initialized!")
          Text("Logs: \(exerciseStore.logs.count)")
      }
  }
  ```

- [x] **Build & Test:** Stores initialize, can read saved data

**Success Criteria:** App shows log count from persisted data ✅

---

## Phase 3: Platform-Specific Managers ✅

**Goal:** Create iOS notification and haptic managers
**Status:** COMPLETE

### Tasks

- [x] Create `Managers/NotificationType.swift`
  - Copy from WatchOS (identical)

- [x] Create `Managers/NotificationManager.swift`
  - Copy from WatchOS as base
  - Adjust for iOS-specific APIs:
    - Use `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator` for haptics
    - Same notification presentation (UserNotifications framework works identically)
  - Keep same notification categories and scheduling logic

- [x] Create `Managers/NotificationFiredLog.swift`
  - Copy from WatchOS (identical)

- [x] Create `App/StandFitApp.swift` with **AppDelegate** for notification handling
  - Implement `UNUserNotificationCenterDelegate` to handle foreground notifications
  - Handle notification actions (`LOG_EXERCISE`, `SNOOZE`, `VIEW_REPORT`)
  - Post `Notification.Name` events for navigation (showExercisePicker, showProgressReport)
  - Request notification authorization on app launch
  - Setup notification categories synchronously (critical for action availability)

- [x] Update `ContentView.swift`
  - Add `.onReceive()` listeners for navigation notifications
  - Add `.sheet()` for exercise picker modal
  - Navigation events properly update UI state

- [x] **Notification Issues Fixed:**
  - ✅ Alert dialog with action buttons shows when notification arrives in foreground
  - ✅ Notification categories registered synchronously on app launch (before any async operations)
  - ✅ When notification is tapped, exercise picker opens and next notification is rescheduled
  - ✅ When "Snooze" button is tapped, reschedules next notification
  - ✅ When notification is delivered, next notification is automatically scheduled (keeps timer running)
  - ✅ Lock screen notifications can show custom actions when swiped

- [x] **Build & Test:** Notification permissions work, foreground notifications display alert with actions, background notifications reschedule automatically

**Success Criteria:** All notification flows work (foreground alert, background drawer, action buttons, timer keeps running) ✅

---

## Phase 4: Core Extensions ✅

**Goal:** Add iOS-specific extensions for StandFitCore types
**Status:** COMPLETE

### Tasks

- [x] Create `Extensions/StandFitCore+iOS.swift`
  - Copy from `StandFitCore+WatchOS.swift`
  - Keep `AchievementTier.color`
  - Keep `ExerciseColorPalette`
  - Keep `TimelineEventType.color`
  - All work identically on iOS

- [x] **Build & Test:** Extensions compile and work

**Success Criteria:** Color extensions accessible in views ✅

---

## Phase 5: Exercise Logging UI (Core Feature) ✅

**Goal:** Build the main exercise logging flow
**Status:** COMPLETE

### Tasks

- [x] Create `Views/ExercisePickerView.swift`
  - Grid layout for iPhone (3 columns instead of 2)
  - Larger tap targets for iPhone (100px minimum height)
  - Support both built-in and custom exercises
  - Navigation to logger

- [x] Create `Views/ExerciseLoggerView.swift`
  - Larger number display for iPhone (72pt font)
  - Bigger +/- buttons (48pt icons)
  - Same logic as WatchOS version
  - Quick-add buttons for common increments

- [x] Update `ContentView.swift`:
  - Main screen with exercise picker
  - Show today's stats (logs, achievements, level)
  - Display today's activity list
  - Sheet-based logger presentation

- [x] **Build & Test:** Can select exercise, adjust count, save log

**Success Criteria:** Can log an exercise and see it saved ✅

---

## Phase 6: History & Progress Views ✅

**Goal:** Show exercise history and statistics
**Status:** COMPLETE

### Tasks

- [x] Create `Views/HistoryView.swift`
  - List of logged exercises grouped by day
  - Swipe to delete
  - Larger display optimized for iPhone (40px icons)

- [x] Create `Views/ProgressReportView.swift`
  - Adapted from WatchOS
  - Larger layout for iPhone
  - Show stats for today/week/month (segmented picker)

- [x] Create `Views/ProgressChartsView.swift`
  - Adapted from WatchOS
  - Larger charts for iPhone (200pt height)
  - Same Chart API, better spacing

- [x] Create `Views/StatsHeaderView.swift`
  - Reusable component (nearly identical to WatchOS)
  - Larger padding and fonts for iOS

- [x] Create `Views/TimelineGraphView.swift`
  - Shows notification vs exercise timeline
  - Response rate analysis
  - Larger visualization for iPhone

- [x] Add navigation to these views from ContentView
  - History button in sheet
  - Progress button in sheet

- [x] **Build & Test:** Can view history, see charts, view stats

**Success Criteria:** History shows logged exercises, charts display correctly ✅

---

## Phase 7: Settings & Configuration

**Goal:** App settings and customization

### Tasks

- [ ] Create `Views/SettingsView.swift`
  - Copy structure from WatchOS
  - iOS-specific layout (form with sections)
  - Reminder settings
  - Custom exercises
  - Progress reports

- [ ] Create `Views/ReminderScheduleView.swift`
  - Copy from WatchOS
  - Adjust for larger screen

- [ ] Create `Views/ProgressReportSettingsView.swift`
  - Copy from WatchOS

- [ ] Create `Views/CreateExerciseView.swift`
  - Copy from WatchOS
  - Larger form for iPhone

- [ ] Create `Views/IconPickerView.swift`
  - Grid layout instead of TabView
  - Search functionality (bonus)

- [ ] **Build & Test:** Can configure all settings, create custom exercises

**Success Criteria:** All settings save and persist

---

## Phase 8: Gamification (Achievements)

**Goal:** Achievement system and progress tracking

### Tasks

- [ ] Create `Views/AchievementsView.swift`
  - Copy from WatchOS
  - Larger cards/badges for iPhone
  - Filter by category
  - Show locked/unlocked

- [ ] Test achievement unlocking:
  - Log exercises until achievement triggers
  - Verify notification appears

- [ ] **Build & Test:** Achievements unlock correctly, notifications work

**Success Criteria:** Can unlock achievements, see progress

---

## Phase 9: Timeline & Analytics (UX14)

**Goal:** Response time tracking and visualization

### Tasks

- [ ] Create `Views/TimelineGraphView.swift`
  - Copy from WatchOS
  - Larger timeline visualization
  - Better for landscape orientation

- [ ] Integrate into ProgressReportView

- [ ] **Build & Test:** Timeline shows notification fires vs exercises

**Success Criteria:** Timeline accurately tracks response times

---

## Phase 10: Polish & iOS-Specific Features

**Goal:** iOS enhancements and final touches

### Tasks

- [ ] **App Icon:** Create iOS app icon (1024x1024)

- [ ] **Launch Screen:** Custom launch screen

- [ ] **Dark Mode:** Test and adjust colors for dark mode

- [ ] **iPad Support:**
  - Multi-column layout for larger screens
  - Split view for history + charts
  - Optimized for landscape

- [ ] **Widgets (Bonus):**
  - Today widget showing daily progress
  - Lock screen widget with quick stats

- [ ] **Home Screen Quick Actions:**
  - "Log Exercise" quick action
  - "View Stats" quick action

- [ ] **Accessibility:**
  - VoiceOver support
  - Dynamic Type support
  - High contrast mode

- [ ] **Build & Test:** All features work, app feels native on iOS

**Success Criteria:** App is polished and iOS-native

---

## File Count Estimates

| Category | Files | Notes |
|----------|-------|-------|
| **App/** | 1 | App entry point |
| **Views/** | 14 | Same as WatchOS (different layouts) |
| **Stores/** | 2 | Nearly identical to WatchOS |
| **Managers/** | 3 | Slight iOS adjustments |
| **Extensions/** | 1 | Identical to WatchOS |
| **Total** | **21** | ~70% code reuse from WatchOS via StandFitCore |

---

## Code Reuse Breakdown

### Shared via StandFitCore (100% reuse)
- ✅ All data models (ExerciseLog, Achievement, CustomExercise, etc.)
- ✅ All business logic (ExerciseService, GamificationService, etc.)
- ✅ All persistence (JSON files → CloudKit later)
- ✅ Notification scheduling calculations

### Platform-Specific (iOS-adapted)
- 🔄 Views (same logic, different layouts for iPhone)
- 🔄 NotificationManager (iOS notification APIs)
- 🔄 Haptic feedback (UIKit instead of WatchKit)
- 🔄 App lifecycle (UIApplicationDelegate vs WatchKit)

### Estimated LOC Savings
- **WatchOS app:** ~3,500 lines (including views)
- **StandFitCore:** ~2,500 lines (shared)
- **iOS app:** ~3,500 lines estimated
- **Total without sharing:** ~7,000 lines
- **Total with sharing:** ~6,000 lines
- **Savings:** ~1,000 lines (14% reduction, mostly from business logic reuse)
- **More importantly:** Single source of truth for bug fixes and features!

---

## Testing Strategy

After each phase:

1. **Build** - Ensure no compilation errors
2. **Run** - Launch on simulator
3. **Test** - Verify phase functionality works
4. **Commit** - Git commit with phase completion message
5. **Document** - Update this file with ✅ for completed tasks

---

## Phase 1 - Next Steps

Ready to start? Here's what to do:

1. Open Xcode project
2. File → New → Target → iOS → App
3. Name it "StandFit iOS"
4. Add StandFitCore package dependency
5. Create basic ContentView
6. Build and run!

Once Phase 1 works, we'll move to Phase 2.

---

## Notes

- **CloudKit Sync:** Not in initial port, but StandFitCore's protocol-based persistence makes it easy to add later
- **Apple Watch Companion:** iOS app can control WatchOS app later
- **Data Sharing:** Both apps share same StandFitCore persistence (App Group)
- **Universal App:** Could combine into single target later if desired

---

**Ready to begin Phase 1?** 🚀
