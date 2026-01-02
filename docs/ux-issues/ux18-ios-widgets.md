# UX18: iOS Widgets - Home Screen & Lock Screen Engagement

**Status:** ⏳ Pending
**Priority:** Medium
**Complexity:** Medium
**Impact:** High engagement boost, Premium feature potential

---

## Problem Statement

Users must open the StandFit app to see their progress, check their streak, or view today's stats. This creates friction and reduces engagement, especially for users who want quick at-a-glance information without launching the app.

iOS widgets provide prime real estate on the Home Screen, Lock Screen, and StandBy mode that can:
- Increase user engagement through passive visibility
- Remind users to exercise without notifications
- Showcase progress and streaks to build habit momentum
- Provide quick access to logging exercises

**Key Insight:** Widgets keep the app "top of mind" even when not actively used. Users see their streak every time they check their phone, creating subtle accountability.

---

## Proposed Solution

Implement a suite of iOS widgets across all available widget families, optimized for different use cases and screen positions.

### Widget Strategy

| Widget Type | Primary Use Case | Data Shown | Update Frequency |
|-------------|------------------|------------|------------------|
| **Home Screen Small** | Quick streak check | Streak flame badge | Every 15-30 min |
| **Home Screen Medium** | Today's progress | Stats + next reminder | Every 15 min |
| **Home Screen Large** | Full dashboard | Charts + achievements | Every 15 min |
| **Lock Screen Circular** | Streak indicator | Days count | Every hour |
| **Lock Screen Inline** | Next reminder time | Countdown to next | Every 5 min |
| **Lock Screen Rectangular** | Today's summary | Exercises logged today | Every 15 min |
| **StandBy Mode** | Glanceable stats | Large streak/progress | Every 15 min |

---

## Widget Designs

### 1. Home Screen Small Widget (2x2)

**Layout: Streak Focus**

```
┌────────────────┐
│                │
│      🔥        │
│      42        │
│    day streak  │
│                │
└────────────────┘
```

**Data Displayed:**
- Flame icon (animated on widget refresh)
- Current streak count (large, bold)
- "day streak" label
- Background color gradient (intensifies with streak length)

**Interaction:**
- Tap → Opens app to Achievements view

**Alternative Design: Today's Count**
```
┌────────────────┐
│   Today        │
│                │
│      8         │
│  exercises     │
│                │
└────────────────┘
```

**Color Logic:**
- Streak < 3 days: Gray gradient
- Streak 3-6: Orange gradient
- Streak 7-29: Red/orange gradient
- Streak 30+: Purple/gold gradient

---

### 2. Home Screen Medium Widget (4x2)

**Layout: Today's Dashboard**

```
┌──────────────────────────────┐
│  🔥 7-day streak    Next: 3:30 PM │
├──────────────────────────────┤
│  Today's Progress             │
│  ████████░░░░  8/12          │
│                               │
│  💪 Pushups  🏋️ Squats  🧘 Plank │
│      15        20        45s  │
└──────────────────────────────┘
```

**Data Displayed:**
- Top row: Streak badge + Next reminder time
- Progress bar: Today's exercises vs. daily goal (if set)
- Bottom row: Top 3 exercises logged today with icons & counts

**Interaction:**
- Tap top area → Opens app
- Tap exercise icon → Opens logger for that exercise (deep link)
- Tap "Next: 3:30 PM" → Opens reminder settings

**Dynamic Behavior:**
- If no exercises logged: Show motivational message ("Ready to start your day?")
- If daily goal met: Show celebration ("Goal crushed! 🎉")
- If next reminder < 30 min: Highlight reminder time in orange

---

### 3. Home Screen Large Widget (4x4)

**Layout: Full Stats Dashboard**

```
┌──────────────────────────────────────┐
│  StandFit                 🔥 7 days   │
├──────────────────────────────────────┤
│  Today                                │
│  ████████████████░░  16/20           │
│                                       │
│  This Week          ↗ +15%           │
│  ┌─────────────────────────────┐    │
│  │ ▅▄▇██▆▅  Weekly Chart       │    │
│  └─────────────────────────────┘    │
│                                       │
│  Recent Achievements                  │
│  🥇 Week Warrior  🏆 Century Club    │
│                                       │
│  Next Reminder: 3:30 PM (45 min)     │
└──────────────────────────────────────┘
```

**Data Displayed:**
- Header: App name + streak badge
- Today's progress bar with count
- Weekly stats with trend indicator (↗/↘)
- Mini bar chart (last 7 days)
- Recent achievements (2-3 badges)
- Next reminder countdown

**Interaction:**
- Tap "Today" section → ExercisePickerView
- Tap chart → ProgressReportView
- Tap achievement → AchievementsView
- Tap next reminder → Opens app to main view

**Premium Feature Indicator:**
- If user is on free tier, show "Premium" badge on chart section
- Unlock advanced analytics with subscription

---

### 4. Lock Screen Widgets (iOS 16+)

#### Circular Widget (Accessory Circular)

**Layout:**
```
    ┌───┐
    │🔥7│  Circular badge with flame + streak number
    └───┘
```

**Data:** Current streak count
**Tap:** Opens app

#### Inline Widget (Accessory Inline)

**Layout:**
```
Next: 3:30 PM (in 1h 15m)
```

**Data:** Time until next reminder
**Tap:** Opens app to main view

#### Rectangular Widget (Accessory Rectangular)

**Layout:**
```
┌────────────────────────┐
│ StandFit    🔥 7 days  │
│ Today: 8 exercises     │
└────────────────────────┘
```

**Data:**
- Streak
- Today's exercise count

**Tap:** Opens ExercisePickerView

---

### 5. StandBy Mode Widget (Large Display)

**Layout:** Full-screen optimized for horizontal display

```
┌──────────────────────────────────────────┐
│                                           │
│              🔥                           │
│              42                           │
│          DAY STREAK                       │
│                                           │
│       Today: 12 exercises                 │
│    Next reminder: 3:30 PM                 │
│                                           │
└──────────────────────────────────────────┘
```

**Data Displayed:**
- Extra-large streak count
- Today's total
- Next reminder time

**Use Case:** Nightstand mode, desk display
**Update Frequency:** Every 5-10 minutes

---

## Widget Configuration Options

### Widget Intent Configuration

Allow users to customize widget behavior via long-press → Edit Widget:

```swift
struct WidgetConfiguration: AppIntent {
    @Parameter(title: "Display Mode")
    var displayMode: DisplayMode

    @Parameter(title: "Show Streak")
    var showStreak: Bool

    @Parameter(title: "Daily Goal")
    var dailyGoal: Int?
}

enum DisplayMode: String, AppEnum {
    case streak = "Streak Focus"
    case todayProgress = "Today's Progress"
    case weekSummary = "Weekly Summary"
    case nextReminder = "Next Reminder"
}
```

**Configurable Options:**
- Display mode (what to show)
- Show/hide streak
- Daily exercise goal
- Color theme (matches streak tier colors)
- Tap action destination

---

## Data & Timeline Management

### Widget Timeline Strategy

```swift
struct StandFitWidget: Widget {
    let kind: String = "StandFitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StandFitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("StandFit")
        .description("Track your exercise streak and progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
```

### Timeline Provider

```swift
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streak: 7, todayCount: 8, nextReminder: Date().addingTimeInterval(3600))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            streak: ExerciseStore.shared.currentStreak,
            todayCount: ExerciseStore.shared.todaysExerciseCount,
            nextReminder: NotificationManager.shared.nextScheduledNotification
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate timeline entries for next 4 hours
        let currentDate = Date()
        for offset in 0..<16 { // Every 15 minutes
            let entryDate = Calendar.current.date(byAdding: .minute, value: offset * 15, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                streak: ExerciseStore.shared.currentStreak,
                todayCount: ExerciseStore.shared.todaysExerciseCount,
                nextReminder: NotificationManager.shared.nextScheduledNotification
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .after(entries.last!.date))
        completion(timeline)
    }
}
```

### Widget Data Model

```swift
struct SimpleEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let todayCount: Int
    let todayGoal: Int?
    let nextReminder: Date?
    let recentAchievements: [Achievement]
    let weeklyData: [DailyStats]  // For chart

    var progressPercent: Double {
        guard let goal = todayGoal else { return 0 }
        return min(Double(todayCount) / Double(goal), 1.0)
    }

    var timeUntilReminder: String {
        guard let reminder = nextReminder else { return "No reminder" }
        let interval = reminder.timeIntervalSinceNow
        if interval < 0 { return "Overdue" }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }
}
```

---

## Deep Linking & Interaction

### Widget Tap Actions

```swift
struct StandFitWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            // Widget content
        }
        .widgetURL(URL(string: "standfit://today")!)  // Default tap action
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

### Widget Links (iOS 17+)

Allow different tap areas to open different app screens:

```swift
// Medium widget with multiple tap targets
Link(destination: URL(string: "standfit://streak")!) {
    StreakBadge(streak: entry.streak)
}

Link(destination: URL(string: "standfit://log-exercise")!) {
    Button("Log Exercise") { }
}

Link(destination: URL(string: "standfit://progress")!) {
    ProgressChart(data: entry.weeklyData)
}
```

### Deep Link Routing

Update `StandFitApp.swift` to handle widget deep links:

```swift
.onOpenURL { url in
    guard url.scheme == "standfit" else { return }

    switch url.host {
    case "today":
        // Navigate to ContentView (default)
        break
    case "streak":
        // Navigate to AchievementsView
        navigationPath.append("achievements")
    case "log-exercise":
        // Open ExercisePickerView
        showExercisePicker = true
    case "progress":
        // Open ProgressReportView
        navigationPath.append("progress")
    default:
        break
    }
}
```

---

## Shared Data with App Group

### App Group Setup

1. Create App Group: `group.com.standfit.shared`
2. Enable in both App target and Widget Extension target
3. Share ExerciseStore data via App Group container

### Shared UserDefaults

```swift
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.standfit.shared")!
}

// In ExerciseStore
@AppStorage("currentStreak", store: .shared) var currentStreak: Int = 0
@AppStorage("todaysExerciseCount", store: .shared) var todaysCount: Int = 0
@AppStorage("nextReminderTimestamp", store: .shared) var nextReminderTimestamp: Double = 0
```

### Shared Data Files

```swift
extension FileManager {
    static var sharedContainerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.standfit.shared"
        )!
    }
}

// Widget reads exercise logs from shared container
let logsURL = FileManager.sharedContainerURL.appendingPathComponent("exercise_logs.json")
```

### Widget Reload Triggers

Notify widgets to reload when data changes:

```swift
import WidgetKit

// In ExerciseStore after logging exercise
func logExercise(...) {
    // Save exercise
    // ...

    // Refresh all widgets
    WidgetCenter.shared.reloadAllTimelines()
}

// Or reload specific widget kind
WidgetCenter.shared.reloadTimelines(ofKind: "StandFitWidget")
```

---

## Visual Design Considerations

### Color Schemes

**Streak-Based Gradients:**
```swift
func streakGradient(for streak: Int) -> LinearGradient {
    switch streak {
    case 0...2:
        return LinearGradient(colors: [.gray, .gray.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
    case 3...6:
        return LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    case 7...29:
        return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
    case 30...:
        return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
    default:
        return LinearGradient(colors: [.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
```

**Dark Mode Support:**
- All widgets automatically adapt to system dark/light mode
- Use `.containerBackground()` for proper widget styling
- Ensure text contrast meets accessibility standards

### Typography

```swift
// Small widget
Text("\(streak)")
    .font(.system(size: 48, weight: .bold, design: .rounded))

// Medium widget
Text("Today's Progress")
    .font(.caption)
    .fontWeight(.semibold)

// Large widget
Text(achievementName)
    .font(.caption2)
```

### SF Symbols & Icons

```swift
// Flame icon with size variants
Image(systemName: "flame.fill")
    .font(.title)  // Small widget
    .foregroundStyle(.orange)

// Exercise type icons
Image(systemName: "figure.walk")
Image(systemName: "figure.strengthtraining.traditional")
```

---

## Implementation Phases

### Phase 1: Core Widget Infrastructure
- [ ] Create Widget Extension target in Xcode
- [ ] Set up App Group for data sharing
- [ ] Implement basic Timeline Provider
- [ ] Create SimpleEntry data model
- [ ] Set up shared UserDefaults for key stats

**Estimated Effort:** 4-6 hours

### Phase 2: Home Screen Widgets
- [ ] Small widget (streak focus)
- [ ] Medium widget (today's dashboard)
- [ ] Large widget (full stats)
- [ ] Widget configuration intents

**Estimated Effort:** 8-10 hours

### Phase 3: Lock Screen Widgets
- [ ] Circular widget (streak badge)
- [ ] Inline widget (next reminder)
- [ ] Rectangular widget (today summary)
- [ ] Test on various Lock Screen layouts

**Estimated Effort:** 4-6 hours

### Phase 4: Deep Linking & Interaction
- [ ] Implement widget URL handling
- [ ] Set up deep link routing in app
- [ ] Add Widget Links for iOS 17+ (multiple tap targets)
- [ ] Test all navigation flows

**Estimated Effort:** 3-4 hours

### Phase 5: Polish & Testing
- [ ] Dark mode optimization
- [ ] Dynamic Type support (accessibility)
- [ ] Widget gallery screenshots
- [ ] Performance optimization (timeline generation)
- [ ] Memory usage testing

**Estimated Effort:** 4-6 hours

**Total Estimated Effort:** 23-32 hours

---

## Technical Requirements

### iOS Version Support
- **Home Screen Widgets:** iOS 14+
- **Lock Screen Widgets:** iOS 16+
- **Widget Links (multiple tap areas):** iOS 17+
- **StandBy Mode:** iOS 17+

### Frameworks
- `WidgetKit` - Widget lifecycle and timeline management
- `SwiftUI` - Widget UI rendering
- `AppIntents` - Widget configuration (iOS 16+)

### Data Storage
- App Group container for shared data
- Shared UserDefaults for quick stats
- JSON files for exercise logs and achievements

### Performance Considerations
- Widget memory limit: ~30MB
- Timeline generation should complete in <2 seconds
- Minimize network requests (all data should be local)
- Use `@AppStorage` for reactive updates

---

## Engagement & Analytics

### Expected Impact

**Engagement Metrics:**
- **Daily Active Users (DAU):** Expected +15-25% increase
  - Passive visibility keeps app "top of mind"
  - Streak display creates accountability pressure

- **Widget Tap-Through Rate:** 5-15% of widget impressions
  - Quick access to logging reduces friction
  - Streak badges trigger curiosity ("how close am I?")

- **Retention:** Expected +10-20% improvement in 7-day retention
  - Users who add widgets show 2-3x higher retention
  - Constant visual reminder maintains habit momentum

**Monetization Opportunities:**
- Lock large widget charts behind Premium (freemium conversion driver)
- Premium-only widget themes/color schemes
- "Unlock all widget styles" upsell in settings

### Tracking Widget Usage

```swift
// In widget provider
func getSnapshot(...) {
    // Log widget impression (passive)
    Analytics.logEvent("widget_displayed", parameters: ["type": context.family.description])
}

// In app when widget deep link tapped
.onOpenURL { url in
    Analytics.logEvent("widget_tap", parameters: ["destination": url.host])
}
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `StandFitWidget/StandFitWidget.swift` | Main widget definition |
| `StandFitWidget/StandFitWidgetBundle.swift` | Widget bundle (multiple widget types) |
| `StandFitWidget/Provider.swift` | Timeline provider implementation |
| `StandFitWidget/SimpleEntry.swift` | Widget data model |
| `StandFitWidget/Views/SmallWidgetView.swift` | Small widget layout |
| `StandFitWidget/Views/MediumWidgetView.swift` | Medium widget layout |
| `StandFitWidget/Views/LargeWidgetView.swift` | Large widget layout |
| `StandFitWidget/Views/LockScreenWidgets.swift` | All lock screen variants |
| `StandFitWidget/Assets.xcassets` | Widget preview images |

---

## Files to Modify

| File | Changes |
|------|---------|
| `StandFitApp.swift` | Add `.onOpenURL()` for widget deep links |
| `ExerciseStore.swift` | Add widget reload triggers, shared UserDefaults |
| `GamificationStore.swift` | Share streak data via App Group |
| `NotificationManager.swift` | Expose next reminder timestamp for widgets |
| `Info.plist` | Add App Group entitlement |

---

## Testing Checklist

### Widget Gallery Testing
- [ ] Small widget displays correctly
- [ ] Medium widget shows all sections
- [ ] Large widget renders chart
- [ ] Lock screen circular widget visible
- [ ] Lock screen inline widget shows text
- [ ] Lock screen rectangular widget fits

### Data Accuracy
- [ ] Streak count matches app
- [ ] Today's exercise count updates immediately
- [ ] Next reminder time is accurate
- [ ] Progress bar reflects correct percentage
- [ ] Achievements display recent unlocks

### Interaction Testing
- [ ] Tap small widget → opens app
- [ ] Tap medium widget exercise → opens logger
- [ ] Tap large widget chart → opens progress view
- [ ] Lock screen widget tap → opens app
- [ ] Widget Links navigate to correct views (iOS 17+)

### Edge Cases
- [ ] Widget shows correct data when no exercises logged
- [ ] Widget handles streak = 0
- [ ] Widget handles no upcoming reminder
- [ ] Widget updates after midnight (new day)
- [ ] Widget survives app deletion/reinstall (App Group persists)

### Performance
- [ ] Timeline generation completes in <2 seconds
- [ ] Widget memory usage <30MB
- [ ] No crashes when data is missing
- [ ] Graceful degradation if App Group unavailable

---

## Success Criteria

✅ **Core Functionality:**
- All widget families render correctly
- Data syncs accurately between app and widgets
- Widgets update within 15 minutes of data changes
- Deep links navigate to correct app screens

✅ **User Experience:**
- Widgets are visually appealing and easy to read
- Widget configuration is intuitive
- Tap interactions feel responsive
- Dark mode support works seamlessly

✅ **Engagement Goals:**
- >40% of users add at least one widget within 7 days
- Widget tap-through rate >8%
- Users with widgets show >15% higher retention

---

## Premium Feature Integration

### Free Tier Widgets
- Small widget (streak only)
- Medium widget (basic today stats)
- Lock screen inline widget (next reminder)

### Premium Tier Widgets
- Large widget with weekly chart
- Lock screen circular & rectangular widgets
- Widget configuration options
- Custom color themes
- StandBy Mode widget

**Paywall Strategy:**
When free user tries to add premium widget:
```
┌─────────────────────────────┐
│  🔒 Premium Widget          │
│                             │
│  Unlock advanced widgets    │
│  with StandFit Premium      │
│                             │
│  • Weekly progress charts   │
│  • Custom themes            │
│  • All lock screen widgets  │
│                             │
│  [Try Premium] [Not Now]    │
└─────────────────────────────┘
```

---

## Future Enhancements

### Interactive Widgets (iOS 17+)
- Tap to log exercise directly from widget (no app open required)
- Swipe through exercise types in medium widget
- Toggle/Button controls for quick actions

### Live Activities (iOS 16.1+)
- Show real-time workout session progress
- Live countdown to next reminder
- Dynamic Island integration for active exercises

### Smart Stack Suggestions
- Widget appears at optimal times (before scheduled reminder)
- Promoted after achievement unlock
- Contextual display based on time of day

### Widget Complications (watchOS)
- Match iOS widget functionality on Apple Watch faces
- Consistent design language across platforms

---

## Related Issues & Dependencies

### Dependencies
- UX10: Gamification System (provides streak and achievement data)
- UX8: Progress Reporting View (provides weekly chart data)
- UX14: Timeline visualization data for advanced widgets

### Enables
- UX15: Monetization Strategy (Premium widget features drive conversions)
- Increased user engagement across all features
- Passive marketing (widgets visible to others seeing user's phone)

---

**Recommendation:** Implement widgets in Phase 10 of iOS port roadmap, after core features are stable. Widgets are a significant engagement multiplier but require solid data infrastructure first.
