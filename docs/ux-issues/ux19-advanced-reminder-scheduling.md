# UX19: Advanced Reminder Scheduling System

**Status:** ⏳ Pending
**Priority:** High
**Complexity:** High
**Impact:** Critical - Core feature that directly affects user engagement and retention

---

## Problem Statement

The current reminder scheduling system operates on a one-size-fits-all model with significant limitations:

### Current System Constraints

1. **Uniform Hours Across All Days**
   - Same start/end hours apply to every active day
   - Reality: Weekday routine ≠ Weekend routine
   - Example: User wants 9am-5pm Mon-Fri, but 10am-8pm Sat-Sun (impossible currently)

2. **Fixed Interval Throughout Day**
   - Same interval (e.g., 30 min) applies to all hours
   - Reality: User attention/availability varies throughout the day
   - Example: User wants frequent reminders during work hours (every 30 min), but less aggressive in evening (every 60 min)

3. **Binary Day Selection**
   - Days are either fully active or fully inactive
   - No support for different schedules on the same weekday
   - Example: User has alternating work-from-home schedule (Mon/Wed/Fri vs Tue/Thu)

4. **No Context-Aware Scheduling**
   - No awareness of calendar events, focus modes, or location
   - No "quiet hours" or "intensive training" periods
   - No temporary schedule overrides

5. **Limited Interval Granularity**
   - Predefined intervals: [1, 15, 20, 30, 45, 60, 90, 120 minutes]
   - No support for "every 2.5 hours" or custom intervals
   - No interval randomization to prevent habituation

6. **No Multi-Profile Support**
   - Can't save and switch between different schedules
   - Example: "Intense Training Week" vs "Maintenance Mode" vs "Recovery Week"

### Real-World User Scenarios (Currently Impossible)

**Scenario 1: The Office Worker**
- Mon-Fri: 9am-12pm (every 20 min), 1pm-5pm (every 30 min), 6pm-9pm (every 60 min)
- Sat-Sun: 10am-8pm (every 45 min)
- Current system: Forces same hours and intervals across all days

**Scenario 2: The Shift Worker**
- Rotating schedule: Different hours each day of the week
- Some days 6am-2pm, others 2pm-10pm
- Current system: Can't represent this at all

**Scenario 3: The Fitness Enthusiast**
- "Training Week": Reminders every 15 min during 6am-8pm
- "Recovery Week": Reminders every 90 min during 10am-6pm
- Current system: Must manually reconfigure entire schedule each week

**Scenario 4: The Remote Worker**
- Needs different schedules based on location (home vs office vs traveling)
- Different intensity based on calendar (meetings vs focus time)
- Current system: No context awareness

---

## Proposed Solution

A hierarchical, flexible scheduling system with profiles, per-day customization, time-block support, and intelligent defaults.

### Architecture Overview

```
Schedule Profile (e.g., "Default", "Training Week", "Recovery")
├── Global Settings
│   ├── Fallback interval (used when no time blocks match)
│   ├── Default active days
│   └── Dead response settings
│
├── Per-Day Schedules (Monday-Sunday)
│   ├── Day enabled/disabled
│   ├── Time Blocks (ordered list)
│   │   ├── Time range (start-end)
│   │   ├── Reminder interval
│   │   ├── Optional: Exercise preferences
│   │   └── Optional: Notification style
│   └── Fallback to global if no blocks defined
│
└── Context Rules (Advanced)
    ├── Location-based overrides
    ├── Focus mode behavior
    ├── Calendar integration
    └── Temporary schedule overrides
```

---

## UX Design

### 1. Schedule Profiles System

#### Main Settings Screen Enhancement

```
┌─────────────────────────────────────┐
│  Reminder Schedule                   │
├─────────────────────────────────────┤
│                                      │
│  Active Profile: Default       [Edit]│
│  ┌───────────────────────────────┐  │
│  │ 📅 Mon-Fri: 9am-5pm, every 30m│  │
│  │ 📅 Weekends: Off               │  │
│  │                                │  │
│  │ Next: Today 2:30 PM (15 min)  │  │
│  └───────────────────────────────┘  │
│                                      │
│  [Switch Profile]  [Manage Profiles] │
│                                      │
└─────────────────────────────────────┘
```

**Profile Picker Sheet:**
```
┌─────────────────────────────────────┐
│  Select Schedule Profile             │
├─────────────────────────────────────┤
│                                      │
│  ✓ Default                           │
│    Mon-Fri: 9am-5pm every 30min     │
│    Active since: Jan 1              │
│                                      │
│  Training Week                       │
│    All days: 6am-8pm every 15min    │
│    Last used: Dec 28                │
│                                      │
│  Recovery                            │
│    Mon/Wed/Fri: 10am-6pm every 90m  │
│    Created: Dec 15                  │
│                                      │
│  + Create New Profile                │
│                                      │
└─────────────────────────────────────┘
```

**Profile Quick Actions:**
- Switch between profiles with single tap
- Schedule profile changes (e.g., "Switch to Training Week on Monday")
- Duplicate existing profiles as templates
- Share profiles via AirDrop/export

---

### 2. Per-Day Schedule Editor

#### Day-by-Day View

```
┌─────────────────────────────────────┐
│  Edit Profile: Default               │
├─────────────────────────────────────┤
│                                      │
│  ┌─ Monday ──────────────────── ✓ │  │
│  │  9:00 AM - 5:00 PM              │  │
│  │  Remind every 30 min            │  │
│  │  [Edit Details] ───────────────→│  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Tuesday ─────────────────── ✓ │  │
│  │  9:00 AM - 5:00 PM              │  │
│  │  Remind every 30 min            │  │
│  │  [Copy from Monday]             │  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Wednesday ────────────────── ✓ │  │
│  │  Same as Monday                 │  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Thursday ─────────────────── ✓ │  │
│  │  Same as Monday                 │  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Friday ───────────────────── ✓ │  │
│  │  Same as Monday                 │  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Saturday ─────────────────── ✗ │  │
│  │  No reminders                   │  │
│  │  [Set Schedule] ───────────────→│  │
│  └─────────────────────────────────┘  │
│                                      │
│  ┌─ Sunday ───────────────────── ✗ │  │
│  │  No reminders                   │  │
│  └─────────────────────────────────┘  │
│                                      │
│  Quick Actions:                      │
│  • Copy weekdays to weekends         │
│  • Set all days to same schedule     │
│  • Clear all schedules               │
│                                      │
└─────────────────────────────────────┘
```

**Smart Defaults:**
- When enabling a day: Suggest copying most recent day's schedule
- When creating profile: Offer templates (Weekday Worker, Every Day, Weekend Warrior)
- Visual indicators: Show which days share identical schedules

---

### 3. Time Block Editor (Per-Day Detail)

#### Monday Detail View with Time Blocks

```
┌─────────────────────────────────────┐
│  Monday Schedule                     │
├─────────────────────────────────────┤
│                                      │
│  Time Blocks (Swipe to delete)       │
│                                      │
│  ┌─ Morning Focus ─────────────┐    │
│  │  🌅 6:00 AM - 9:00 AM        │    │
│  │  Every 45 min                │    │
│  │  Gentle reminders            │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌─ Work Hours ─────────────────┐    │
│  │  💼 9:00 AM - 12:00 PM       │    │
│  │  Every 20 min                │    │
│  │  Frequent, keep moving!      │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌─ Lunch Break ────────────────┐    │
│  │  🍽️ 12:00 PM - 1:00 PM       │    │
│  │  Paused                      │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌─ Afternoon Work ─────────────┐    │
│  │  💼 1:00 PM - 5:00 PM        │    │
│  │  Every 30 min                │    │
│  │  Standard reminders          │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌─ Evening Wind-Down ──────────┐    │
│  │  🌙 6:00 PM - 9:00 PM        │    │
│  │  Every 60 min                │    │
│  │  Light reminders             │    │
│  └──────────────────────────────┘    │
│                                      │
│  + Add Time Block                    │
│                                      │
│  Outside these blocks:               │
│  [●] Use default interval (30 min)   │
│  [○] No reminders                    │
│                                      │
└─────────────────────────────────────┘
```

**Time Block Creation Flow:**

1. **Tap "Add Time Block"**
   ```
   ┌─────────────────────────────────┐
   │  New Time Block                  │
   ├─────────────────────────────────┤
   │                                  │
   │  Block Name (optional)           │
   │  ┌─────────────────────────────┐│
   │  │ Morning Focus               ││
   │  └─────────────────────────────┘│
   │                                  │
   │  Time Range                      │
   │  From: 6:00 AM    To: 9:00 AM   │
   │                                  │
   │  Reminder Interval               │
   │  Every: [45] minutes             │
   │  ┌───┬───┬───┬───┬───┬───┐     │
   │  │15 │30 │45 │60 │90 │120│     │
   │  └───┴───┴───┴───┴───┴───┘     │
   │  [Custom interval...]            │
   │                                  │
   │  Notification Style (optional)   │
   │  [●] Standard                    │
   │  [○] Gentle (no sound)           │
   │  [○] Urgent (persistent)         │
   │                                  │
   │  Icon (optional)                 │
   │  🌅 ☀️ 💼 🍽️ 🌙 💪 🏃 🧘     │
   │                                  │
   │          [Cancel]  [Save]        │
   │                                  │
   └─────────────────────────────────┘
   ```

2. **Smart Validation:**
   - Detect overlapping time blocks → Offer to merge or prioritize
   - Detect gaps → Suggest filling or confirm intentional
   - Detect unrealistic intervals (e.g., every 1 min for 8 hours) → Warn

3. **Visual Timeline:**
   ```
   0──────6──────12──────18──────24
   ░░░░░░████░░░█████████░░░████░░░
         45m    20m  30m    60m
   ```
   - Show density visualization
   - Highlight active periods vs quiet periods

---

### 4. Smart Templates & Presets

#### Template Library

**Built-in Templates:**

1. **Office Worker**
   - Mon-Fri: 9am-12pm (20min), 1pm-5pm (30min), 6pm-9pm (60min)
   - Sat-Sun: Off

2. **Remote/Flexible Worker**
   - Mon-Fri: 8am-6pm (30min)
   - Sat-Sun: 10am-4pm (45min)

3. **Athlete/Training Mode**
   - All days: 6am-8pm (15min)
   - High-intensity reminders

4. **Wellness/Recovery**
   - All days: 10am-6pm (90min)
   - Gentle reminders

5. **Weekend Warrior**
   - Mon-Fri: Off
   - Sat-Sun: 8am-6pm (30min)

6. **Shift Worker (Rotating)**
   - Early shift days: 5am-1pm (20min)
   - Late shift days: 1pm-9pm (20min)
   - Off days: 10am-4pm (60min)

7. **Minimalist**
   - All days: 3 reminders only (9am, 1pm, 6pm)
   - Fixed times, not intervals

**Template Customization:**
- Start with template
- Modify any day/time block
- Save as new custom profile

---

### 5. Advanced Features

#### A. Interval Randomization

```
┌─────────────────────────────────────┐
│  Advanced Interval Settings          │
├─────────────────────────────────────┤
│                                      │
│  Base Interval: 30 minutes           │
│                                      │
│  [✓] Add randomness                  │
│      ± 5 minutes                     │
│      (Prevents habituation)          │
│                                      │
│      Example schedule:               │
│      • 9:00 AM                       │
│      • 9:32 AM (+32m)                │
│      • 10:05 AM (+33m)               │
│      • 10:33 AM (+28m)               │
│                                      │
└─────────────────────────────────────┘
```

**Why Randomization:**
- Prevents users from anticipating and ignoring reminders
- Mimics natural attention fluctuation
- Research-backed: Random intervals more effective than fixed

#### B. Context-Aware Rules (Premium Feature)

```
┌─────────────────────────────────────┐
│  Smart Schedule Rules                │
├─────────────────────────────────────┤
│                                      │
│  Focus Mode Integration              │
│  When Do Not Disturb is on:          │
│  [●] Pause all reminders             │
│  [○] Silent reminders only           │
│  [○] Continue as normal              │
│                                      │
│  Calendar Integration                │
│  During calendar events:             │
│  [✓] Pause reminders                 │
│  [○] Silent reminders only           │
│      Exceptions:                     │
│      • Events marked "Free"          │
│      • Events < 15 minutes           │
│                                      │
│  Location-Based                      │
│  At Home:      Use default schedule  │
│  At Office:    [Training Week]       │
│  At Gym:       Pause reminders       │
│  + Add location rule                 │
│                                      │
│  Activity Detection                  │
│  [✓] Pause during detected workouts  │
│      (Uses HealthKit data)           │
│                                      │
└─────────────────────────────────────┘
```

#### C. Fixed-Time Reminders

```
┌─────────────────────────────────────┐
│  Monday Schedule                     │
├─────────────────────────────────────┤
│                                      │
│  Schedule Type:                      │
│  [○] Interval-based (every X min)    │
│  [●] Fixed times                     │
│                                      │
│  Reminder Times:                     │
│  • 7:00 AM  Morning kickstart        │
│  • 12:00 PM Lunch break move         │
│  • 3:00 PM  Afternoon energy         │
│  • 6:00 PM  Evening wind-down        │
│                                      │
│  + Add reminder time                 │
│                                      │
│  [✓] Smart spacing                   │
│      (Adjust times if you miss one)  │
│                                      │
└─────────────────────────────────────┘
```

**Use Case:** Users who prefer predictable, anchor-point reminders rather than continuous intervals

#### D. Adaptive Scheduling (AI-Powered - Future)

```
┌─────────────────────────────────────┐
│  🤖 Adaptive Scheduling               │
├─────────────────────────────────────┤
│                                      │
│  StandFit can learn your patterns    │
│  and optimize reminder timing:       │
│                                      │
│  ✓ Analyzes when you respond fastest │
│  ✓ Identifies your productive hours  │
│  ✓ Avoids times you always ignore    │
│  ✓ Adjusts frequency based on success│
│                                      │
│  Current insights:                   │
│  • You respond best 9-11am           │
│  • 3-4pm has low response rate       │
│  • Weekends need longer intervals    │
│                                      │
│  [●] Let StandFit optimize my schedule│
│  [○] Manual control only             │
│                                      │
│  (Requires 2+ weeks of data)         │
│                                      │
└─────────────────────────────────────┘
```

---

### 6. Schedule Preview & Testing

#### Preview Mode

```
┌─────────────────────────────────────┐
│  Schedule Preview: Monday            │
├─────────────────────────────────────┤
│                                      │
│  Showing next 24 hours:              │
│                                      │
│  Today (Monday)                      │
│  ┌────────────────────────────────┐ │
│  │ 6:00 AM  First reminder         │ │
│  │ 6:47 AM  Morning Focus (+47m)   │ │
│  │ 7:32 AM  Morning Focus (+45m)   │ │
│  │ 8:18 AM  Morning Focus (+46m)   │ │
│  │ 9:00 AM  ──→ Work Hours         │ │
│  │ 9:21 AM  Work Hours (+21m)      │ │
│  │ 9:40 AM  Work Hours (+19m)      │ │
│  │ 10:02 AM Work Hours (+22m)      │ │
│  │ 10:21 AM Work Hours (+19m)      │ │
│  │ ... (36 more reminders)         │ │
│  └────────────────────────────────┘ │
│                                      │
│  Total: 42 reminders tomorrow        │
│                                      │
│  [⚠️ That's a lot! Consider reducing │
│      frequency during some blocks]   │
│                                      │
│  [Export Schedule] [Test Notification]│
│                                      │
└─────────────────────────────────────┘
```

**Features:**
- See exact timing for next week
- Export to calendar for visibility
- Send test notification to preview sound/style
- Warning if schedule seems too aggressive (>60/day) or too sparse (<3/day)

---

### 7. Migration & Onboarding

#### Upgrading Existing Users

```
┌─────────────────────────────────────┐
│  🎉 New Scheduling Features!         │
├─────────────────────────────────────┤
│                                      │
│  We've upgraded reminder scheduling  │
│  with powerful new features:         │
│                                      │
│  ✨ Different schedules per day      │
│  ✨ Time blocks for fine control     │
│  ✨ Multiple schedule profiles       │
│  ✨ Smart templates                  │
│                                      │
│  Your current schedule:              │
│  Mon-Fri: 9am-5pm every 30min       │
│                                      │
│  has been converted to:              │
│  Profile "Default" with Monday-Friday│
│  active from 9am-5pm, 30min intervals│
│                                      │
│  [Keep as-is] [Explore New Features] │
│                                      │
└─────────────────────────────────────┘
```

**Migration Strategy:**
1. Convert existing `activeDays + startHour + endHour + interval` → Single time block per active day
2. Create "Default" profile with migrated settings
3. Show education overlay highlighting new capabilities
4. Offer guided tour: "Let's customize Monday's schedule"

#### New User Onboarding

```
Step 1: Choose Your Lifestyle
┌─────────────────────────────────────┐
│  How would you describe your         │
│  typical week?                       │
│                                      │
│  [○] Office worker (M-F, 9-5)        │
│  [○] Remote/Flexible                 │
│  [○] Shift worker (rotating hours)   │
│  [○] Every day is different          │
│  [○] I'll set it up myself           │
│                                      │
└─────────────────────────────────────┘

Step 2: Fine-tune Your Schedule
┌─────────────────────────────────────┐
│  Great! Here's your starting schedule│
│                                      │
│  Mon-Fri: 9am-5pm every 30min       │
│  Weekends: Off                       │
│                                      │
│  Want to customize further?          │
│  • Different hours per day           │
│  • Time blocks (morning/afternoon)   │
│  • Weekend schedule                  │
│                                      │
│  [Start with this] [Customize more]  │
│                                      │
└─────────────────────────────────────┘
```

---

## Technical Implementation

### Data Models

#### New Models

```swift
/// A complete schedule profile with all settings
struct ScheduleProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var createdDate: Date
    var lastUsedDate: Date?

    // Global fallback settings
    var fallbackInterval: Int = 30 // minutes
    var deadResponseEnabled: Bool = true
    var deadResponseMinutes: Int = 30

    // Per-day schedules
    var dailySchedules: [Int: DailySchedule] // Weekday (1-7) -> Schedule

    // Context rules (future)
    var contextRules: [ContextRule] = []
}

/// Schedule for a single day
struct DailySchedule: Codable {
    var enabled: Bool = true
    var scheduleType: ScheduleType

    enum ScheduleType: Codable {
        case timeBlocks([TimeBlock])
        case fixedTimes([FixedReminder])
        case useFallback // Inherit from global settings
    }
}

/// A time block with specific settings
struct TimeBlock: Codable, Identifiable {
    let id: UUID
    var name: String? // Optional user-facing name
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var intervalMinutes: Int
    var randomizationRange: Int? // ± minutes to randomize
    var icon: String? // SF Symbol name
    var notificationStyle: NotificationStyle = .standard

    enum NotificationStyle: String, Codable {
        case standard
        case gentle // No sound
        case urgent // Persistent
    }
}

/// Fixed-time reminder
struct FixedReminder: Codable, Identifiable {
    let id: UUID
    var hour: Int
    var minute: Int
    var label: String?
    var smartSpacing: Bool = false // Adjust if previous missed
}

/// Context-aware rule (Premium feature)
struct ContextRule: Codable, Identifiable {
    let id: UUID
    var ruleType: RuleType
    var action: RuleAction

    enum RuleType: Codable {
        case focusMode(enabled: Bool)
        case calendarEvent(freeTimeOnly: Bool)
        case location(identifier: String, name: String)
        case activityDetection(type: String)
    }

    enum RuleAction: String, Codable {
        case pause
        case silentOnly
        case switchProfile(UUID)
    }
}
```

#### Updated ExerciseStore

```swift
class ExerciseStore: ObservableObject {
    // Old properties (deprecated but kept for migration)
    @AppStorage("reminderIntervalMinutes") private var legacyInterval: Int = 30
    @AppStorage("activeDaysData") private var legacyActiveDaysData: Data = Data()
    @AppStorage("startHour") private var legacyStartHour: Int = 9
    @AppStorage("endHour") private var legacyEndHour: Int = 17

    // New profile-based system
    @AppStorage("scheduleProfiles") private var profilesData: Data = Data()
    @AppStorage("activeProfileId") private var activeProfileIdString: String = ""

    var scheduleProfiles: [ScheduleProfile] = []
    var activeProfile: ScheduleProfile?

    // Computed properties for backward compatibility
    var reminderIntervalMinutes: Int {
        activeProfile?.fallbackInterval ?? legacyInterval
    }

    var activeDays: Set<Int> {
        guard let profile = activeProfile else { return legacyActiveDays }
        return Set(profile.dailySchedules.keys.filter { profile.dailySchedules[$0]?.enabled == true })
    }

    // Migration logic
    func migrateToProfileSystem() {
        guard scheduleProfiles.isEmpty else { return }

        // Create default profile from legacy settings
        let defaultProfile = ScheduleProfile(
            id: UUID(),
            name: "Default",
            createdDate: Date(),
            fallbackInterval: legacyInterval,
            dailySchedules: createDailySchedulesFromLegacy()
        )

        scheduleProfiles = [defaultProfile]
        activeProfile = defaultProfile
        saveProfiles()
    }

    private func createDailySchedulesFromLegacy() -> [Int: DailySchedule] {
        var dailySchedules: [Int: DailySchedule] = [:]

        for day in legacyActiveDays {
            let timeBlock = TimeBlock(
                id: UUID(),
                name: nil,
                startHour: legacyStartHour,
                startMinute: 0,
                endHour: legacyEndHour,
                endMinute: 0,
                intervalMinutes: legacyInterval
            )

            dailySchedules[day] = DailySchedule(
                enabled: true,
                scheduleType: .timeBlocks([timeBlock])
            )
        }

        return dailySchedules
    }
}
```

### Scheduling Algorithm Updates

```swift
extension NotificationManager {
    /// Calculate next reminder time using new profile system
    func calculateNextReminderTime(profile: ScheduleProfile, from date: Date) -> Date? {
        let calendar = Calendar.current
        var candidateTime = date

        // Try up to 7 days ahead
        for _ in 0..<(7 * 24 * 60) {
            let weekday = calendar.component(.weekday, from: candidateTime)
            let hour = calendar.component(.hour, from: candidateTime)
            let minute = calendar.component(.minute, from: candidateTime)

            guard let daySchedule = profile.dailySchedules[weekday],
                  daySchedule.enabled else {
                // Skip to next day
                candidateTime = calendar.nextDate(
                    after: candidateTime,
                    matching: DateComponents(hour: 0, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? candidateTime.addingTimeInterval(86400)
                continue
            }

            switch daySchedule.scheduleType {
            case .timeBlocks(let blocks):
                // Find matching time block
                if let matchingBlock = blocks.first(where: { block in
                    isTime(hour: hour, minute: minute, inBlock: block)
                }) {
                    // Calculate next time within this block
                    return calculateNextTimeInBlock(
                        block: matchingBlock,
                        from: candidateTime,
                        profile: profile
                    )
                } else {
                    // Jump to next block or next day
                    candidateTime = jumpToNextBlock(
                        blocks: blocks,
                        from: candidateTime,
                        weekday: weekday,
                        profile: profile
                    )
                }

            case .fixedTimes(let reminders):
                // Find next fixed time
                return findNextFixedTime(reminders: reminders, from: candidateTime)

            case .useFallback:
                // Use global fallback interval
                return candidateTime.addingTimeInterval(
                    TimeInterval(profile.fallbackInterval * 60)
                )
            }
        }

        return nil // No valid time found in next week
    }

    private func calculateNextTimeInBlock(
        block: TimeBlock,
        from date: Date,
        profile: ScheduleProfile
    ) -> Date {
        var interval = block.intervalMinutes

        // Apply randomization if enabled
        if let randomRange = block.randomizationRange {
            let randomOffset = Int.random(in: -randomRange...randomRange)
            interval = max(1, interval + randomOffset)
        }

        return date.addingTimeInterval(TimeInterval(interval * 60))
    }

    private func isTime(hour: Int, minute: Int, inBlock block: TimeBlock) -> Bool {
        let currentMinutes = hour * 60 + minute
        let blockStart = block.startHour * 60 + block.startMinute
        let blockEnd = block.endHour * 60 + block.endMinute

        return currentMinutes >= blockStart && currentMinutes < blockEnd
    }
}
```

---

## Implementation Phases

### Phase 1: Core Profile System (Week 1-2)
**Estimated Effort:** 16-24 hours

**Deliverables:**
- New data models (ScheduleProfile, DailySchedule, TimeBlock)
- Migration logic from legacy system
- Basic profile CRUD operations
- Profile switcher UI
- Update NotificationManager to use profiles

**Files to Create/Modify:**
- `StandFitCore/Models/ScheduleProfile.swift` (new)
- `StandFitCore/Models/DailySchedule.swift` (new)
- `StandFitCore/Models/TimeBlock.swift` (new)
- `StandFit/Stores/ExerciseStore.swift` (modify)
- `StandFit/Managers/NotificationManager.swift` (modify)
- `StandFit/Views/ScheduleProfilePickerView.swift` (new)

**Testing:**
- Verify migration preserves existing schedules
- Test profile switching updates notifications correctly
- Validate data persistence across app restarts

---

### Phase 2: Per-Day Customization (Week 3)
**Estimated Effort:** 12-16 hours

**Deliverables:**
- Per-day schedule editor UI
- Copy/paste day schedules
- Visual day-by-day overview
- Quick actions (copy weekdays to weekends, etc.)

**Files to Create/Modify:**
- `StandFit/Views/DayScheduleEditorView.swift` (new)
- `StandFit/Views/PerDayScheduleView.swift` (new)
- Update `ReminderScheduleView.swift` to launch new editors

**Testing:**
- Test different schedules on different days
- Verify copied schedules are independent
- Test edge cases (all days disabled, overlapping times)

---

### Phase 3: Time Block Editor (Week 4)
**Estimated Effort:** 16-20 hours

**Deliverables:**
- Time block creation/editing UI
- Time block list with reordering
- Visual timeline preview
- Overlap detection and resolution
- Interval validation

**Files to Create/Modify:**
- `StandFit/Views/TimeBlockEditorView.swift` (new)
- `StandFit/Views/TimelinePreviewView.swift` (new)
- `StandFit/Components/TimeRangePicker.swift` (new)

**Testing:**
- Test overlapping time blocks
- Verify time block ordering affects priority
- Test gaps between blocks (fallback behavior)
- Test 24-hour coverage scenarios

---

### Phase 4: Templates & Presets (Week 5)
**Estimated Effort:** 8-12 hours

**Deliverables:**
- Built-in template library
- Template customization flow
- Save custom templates
- Share/export templates

**Files to Create/Modify:**
- `StandFit/Views/TemplateLibraryView.swift` (new)
- `StandFitCore/Models/ScheduleTemplate.swift` (new)
- `StandFit/Utilities/TemplateManager.swift` (new)

**Testing:**
- Verify all built-in templates work correctly
- Test template modification and saving
- Test template import/export

---

### Phase 5: Advanced Features (Week 6-7)
**Estimated Effort:** 20-28 hours

**Deliverables:**
- Interval randomization
- Fixed-time reminders
- Schedule preview with exact times
- Test notification feature
- Export to calendar

**Files to Create/Modify:**
- Update `NotificationManager.swift` for randomization
- `StandFit/Views/FixedTimeReminderEditor.swift` (new)
- `StandFit/Views/SchedulePreviewView.swift` (new)
- `StandFit/Utilities/CalendarExporter.swift` (new)

**Testing:**
- Verify randomization stays within bounds
- Test fixed-time reminders don't drift
- Validate calendar export format
- Test preview accuracy

---

### Phase 6: Context Rules (Premium - Week 8+)
**Estimated Effort:** 24-32 hours

**Deliverables:**
- Focus Mode detection
- Calendar event integration (EventKit)
- Location-based rules (CoreLocation)
- Activity detection (HealthKit)
- Rule management UI

**Files to Create/Modify:**
- `StandFitCore/Models/ContextRule.swift` (new)
- `StandFit/Managers/ContextManager.swift` (new)
- `StandFit/Views/ContextRulesView.swift` (new)
- Update permissions handling for EventKit, CoreLocation, HealthKit

**Testing:**
- Test each context type independently
- Test rule precedence (multiple rules active)
- Verify permissions are requested correctly
- Test battery impact of location monitoring

---

### Phase 7: Adaptive Scheduling (AI - Future)
**Estimated Effort:** 40+ hours (Research + Implementation)

**Deliverables:**
- Response time analytics
- Pattern recognition algorithms
- Automatic schedule optimization
- Insights dashboard

**Requires:**
- Minimum 2 weeks of user data
- Machine learning framework (CoreML)
- A/B testing framework

**Not included in initial release - Future enhancement**

---

## UX Considerations & Edge Cases

### Edge Cases to Handle

1. **No Valid Time Slots**
   - User sets schedule with no active days
   - All time blocks end before current time
   - **Solution:** Show warning, suggest enabling at least one day

2. **Too Many Reminders**
   - User sets every 1 min for 16 hours = 960 notifications/day
   - iOS limit: 64 scheduled notifications
   - **Solution:** Warn when >60/day, implement sliding window scheduling

3. **Overlapping Time Blocks**
   - User creates blocks 9am-12pm and 10am-2pm
   - **Solution:** Detect overlap, offer to merge or ask which takes priority

4. **Time Block Gaps**
   - User has 9am-12pm and 2pm-5pm, nothing 12pm-2pm
   - **Solution:** Ask if should use fallback interval or pause

5. **Timezone Changes**
   - User travels across timezones
   - **Solution:** Option to "Keep schedule in local time" vs "Keep absolute times"

6. **DST Transitions**
   - Daylight saving time adds/removes an hour
   - **Solution:** Detect DST, adjust schedule times accordingly

7. **Profile Conflicts**
   - User schedules profile switch but forgets
   - **Solution:** Show upcoming profile switches in main UI

### Accessibility

- **VoiceOver:** All pickers and time blocks fully labeled
- **Dynamic Type:** Support all text sizes
- **Reduce Motion:** Disable timeline animations
- **Color Contrast:** Ensure time block colors meet WCAG AA

### Performance

- **Lazy Loading:** Only load active profile initially
- **Background Calculation:** Pre-calculate next week of reminders
- **Notification Efficiency:** Use iOS notification grouping
- **Battery Impact:** Minimize location/calendar polling

---

## Success Metrics

### Quantitative
- % of users who customize per-day schedules (target: >30%)
- % of users who create multiple profiles (target: >15%)
- % of users who use time blocks (target: >40%)
- Average notification response time improvement (target: -15%)
- User retention 30-day (target: +10% vs current)

### Qualitative
- User feedback on flexibility ("finally matches my schedule!")
- Reduced support requests about scheduling limitations
- App Store reviews mentioning scheduling as strength

---

## Open Questions

1. **Premium Feature Boundary:**
   - Should basic time blocks be free or premium?
   - Context rules clearly premium - what else?
   - **Recommendation:** Core (free) = Profiles + Per-day + Time blocks. Premium = Context rules + Templates + Adaptive AI

2. **Notification Limit Handling:**
   - iOS allows 64 scheduled notifications max
   - Do we schedule sliding window (next 64) or full week?
   - **Recommendation:** Sliding window with daily refresh at midnight

3. **Default Experience:**
   - Should new users see simple or advanced view first?
   - **Recommendation:** Simple by default, "Advanced Options" disclosure

4. **Calendar Export Format:**
   - Should exported reminders be events or reminders?
   - All-day or specific times?
   - **Recommendation:** Specific-time events with "StandFit Reminder" prefix

5. **Sharing/Collaboration:**
   - Should users be able to share profiles with friends?
   - Team/family shared schedules?
   - **Recommendation:** Phase 1 = Export/Import only. Phase 2 = Cloud sharing

---

## Related Issues

- **UX12:** Snooze button behavior - Advanced scheduling could include "snooze profiles"
- **UX18:** iOS Widgets - Show active profile name in widget
- **UX15:** Monetization - Context rules and adaptive AI as Premium features

---

## Appendix: User Research Insights

### Pain Points from User Feedback

> "I work from home 3 days a week and office 2 days. My schedule is completely different but the app treats them the same." - User #1247

> "I want aggressive reminders during my work hours but something gentler in the evening. Can't set that up." - User #892

> "Weekends I wake up later and work out at different times. The app keeps bugging me at 9am when I'm still asleep." - User #2103

> "I wish I could have a 'training week' setting I could switch on when I'm really focused, then back to normal maintenance mode." - User #1556

### Competitive Analysis

- **Streaks:** Simple interval-based, no per-day customization
- **Habitica:** Fixed daily checklist, no interval reminders
- **StandUp!:** Per-day hours but same interval across all days
- **BreakTimer:** Time blocks but desktop only, no mobile
- **None offer:** Profile switching, context awareness, or adaptive scheduling

**Opportunity:** StandFit can differentiate with most flexible scheduling in the category

---

## Files Changed / Created

### New Files
- `StandFitCore/Sources/StandFitCore/Models/ScheduleProfile.swift`
- `StandFitCore/Sources/StandFitCore/Models/DailySchedule.swift`
- `StandFitCore/Sources/StandFitCore/Models/TimeBlock.swift`
- `StandFitCore/Sources/StandFitCore/Models/FixedReminder.swift`
- `StandFitCore/Sources/StandFitCore/Models/ContextRule.swift`
- `StandFitCore/Sources/StandFitCore/Models/ScheduleTemplate.swift`
- `StandFit/Views/ScheduleProfilePickerView.swift`
- `StandFit/Views/DayScheduleEditorView.swift`
- `StandFit/Views/PerDayScheduleView.swift`
- `StandFit/Views/TimeBlockEditorView.swift`
- `StandFit/Views/TimelinePreviewView.swift`
- `StandFit/Views/FixedTimeReminderEditor.swift`
- `StandFit/Views/SchedulePreviewView.swift`
- `StandFit/Views/ContextRulesView.swift`
- `StandFit/Views/TemplateLibraryView.swift`
- `StandFit/Components/TimeRangePicker.swift`
- `StandFit/Managers/ContextManager.swift`
- `StandFit/Utilities/TemplateManager.swift`
- `StandFit/Utilities/CalendarExporter.swift`

### Modified Files
- `StandFit/Stores/ExerciseStore.swift` - Add profile system, migration logic
- `StandFit/Managers/NotificationManager.swift` - Update scheduling algorithm
- `StandFit/Views/ReminderScheduleView.swift` - Launch new editors
- `StandFit/Views/ContentView.swift` - Show active profile
- `StandFit/Views/SettingsView.swift` - Link to profile management

### Database/Storage
- Add `scheduleProfiles` to AppStorage (JSON-encoded)
- Add `activeProfileId` to AppStorage
- Maintain legacy keys for migration
- Keychain for premium feature unlock status

---

**Total Estimated Effort:** 96-132 hours (12-16 working days) for Phases 1-5
**Premium Features (Phase 6):** Additional 24-32 hours (3-4 days)
**Adaptive AI (Phase 7):** Future research project (40+ hours)

**Recommended Approach:**
1. Implement Phases 1-3 first (core functionality) - 4 weeks
2. Gather user feedback, iterate on UX
3. Implement Phases 4-5 (polish & advanced) - 2 weeks
4. Consider Phase 6 as Premium add-on - 1 week
5. Phase 7 remains long-term research goal
