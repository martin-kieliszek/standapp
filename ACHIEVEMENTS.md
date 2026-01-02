# How to Add New Achievements, Streaks, and Milestones

**A Developer's Guide to Extending the Gamification System**

This guide walks you through adding new gamification features to StandFit. The system was designed to be extremely simple to extend - in most cases, you just add configuration to an array!

---

## Table of Contents

1. [Adding New Achievements](#adding-new-achievements)
2. [Adding New Achievement Requirements](#adding-new-achievement-requirements)
3. [Adding New Streak Types](#adding-new-streak-types)
4. [Adding New Challenge Types](#adding-new-challenge-types)
5. [Adding New Achievement Categories](#adding-new-achievement-categories)
6. [Testing Your New Features](#testing-your-new-features)

---

## Adding New Achievements

**TL;DR:** Just add to the `AchievementDefinitions.all` array in `GamificationModels.swift`. That's it!

### Step 1: Define Your Achievement

Open `GamificationModels.swift` and scroll to the `AchievementDefinitions` struct (around line 300+). You'll see an array called `all` with existing achievements.

Add your new achievement to this array:

```swift
struct AchievementDefinitions {
    static let all: [Achievement] = [
        // ... existing achievements ...

        // Your new achievement
        Achievement(
            id: "unique_achievement_id",           // Must be unique!
            name: "Achievement Name",              // Shown to user
            description: "What the user achieved", // Shown in details
            icon: "star.fill",                     // SF Symbol name
            category: .milestone,                  // See categories below
            tier: .gold,                           // bronze/silver/gold/platinum
            requirement: .totalExercises(100),     // See requirements below
            progress: 0                            // Always start at 0
        ),
    ]
}
```

### Step 2: Choose Your Category

Available categories (defined in `AchievementCategory` enum):

- `.milestone` - General progress markers (1st exercise, 100th exercise, etc.)
- `.consistency` - Streak-based achievements (7-day streak, 30-day streak)
- `.volume` - Total count achievements (100 pushups, 1000 squats)
- `.variety` - Diversity achievements (all exercise types, mix it up)
- `.challenge` - Special conditions (early bird, night owl, power day)
- `.social` - Sharing and community (coming soon)

### Step 3: Choose Your Requirement Type

The `requirement` parameter determines WHAT the user needs to do. Here are all available types:

#### Total Exercises Across All Types
```swift
requirement: .totalExercises(500)  // User needs 500 total exercises
```

#### Specific Exercise Type Count
```swift
requirement: .specificExercise("Pushups", 100)  // 100 pushups
requirement: .specificExercise("Squats", 500)   // 500 squats
```

#### Streak-Based
```swift
requirement: .streak(7)    // 7-day streak
requirement: .streak(30)   // 30-day streak
requirement: .streak(365)  // 365-day streak
```

#### Variety (Unique Exercise Types in One Day)
```swift
requirement: .unique(4)  // Do all 4 exercise types in one day
requirement: .unique(5)  // Do 5 different exercises in one day
```

#### Time Window (Before/After Specific Hour)
```swift
requirement: .timeWindow(hour: 7, comparison: .before, count: 1)  // Before 7 AM
requirement: .timeWindow(hour: 22, comparison: .after, count: 1)  // After 10 PM
requirement: .timeWindow(hour: 6, comparison: .before, count: 10) // 10 exercises before 6 AM
```

#### Daily Goal (Exercises in One Day)
```swift
requirement: .dailyGoal(10)  // 10 exercises in one day
requirement: .dailyGoal(20)  // 20 exercises in one day
requirement: .dailyGoal(50)  // 50 exercises in one day
```

### Step 4: Choose Your Tier

Tiers affect the visual appearance (color) and perceived value:

- `.bronze` - Easy achievements (brown color)
- `.silver` - Moderate achievements (gray color)
- `.gold` - Hard achievements (yellow color)
- `.platinum` - Elite achievements (cyan color)

### Step 5: That's It!

Build and run. Your achievement will:
- ✅ Automatically appear in the Achievements view
- ✅ Track progress automatically
- ✅ Send a notification when unlocked
- ✅ Award XP (50 points) when unlocked
- ✅ Show in the achievement count badge

### Real-World Examples

**Example 1: Consistency Achievement**
```swift
Achievement(
    id: "hundred_day_streak",
    name: "Centurion",
    description: "Maintain a 100-day exercise streak",
    icon: "flame.circle.fill",
    category: .consistency,
    tier: .platinum,
    requirement: .streak(100),
    progress: 0
)
```

**Example 2: Volume Achievement**
```swift
Achievement(
    id: "plank_master",
    name: "Plank Master",
    description: "Hold planks for 1 hour total (3600 seconds)",
    icon: "figure.core.training",
    category: .volume,
    tier: .gold,
    requirement: .specificExercise("Plank (seconds)", 3600),
    progress: 0
)
```

**Example 3: Challenge Achievement**
```swift
Achievement(
    id: "weekend_warrior",
    name: "Weekend Warrior",
    description: "Complete 30 exercises in one day",
    icon: "bolt.circle.fill",
    category: .challenge,
    tier: .platinum,
    requirement: .dailyGoal(30),
    progress: 0
)
```

**Example 4: Variety Achievement**
```swift
Achievement(
    id: "jack_of_all_trades",
    name: "Jack of All Trades",
    description: "Do 6 different exercise types in one day",
    icon: "star.circle.fill",
    category: .variety,
    tier: .gold,
    requirement: .unique(6),
    progress: 0
)
```

---

## Adding New Achievement Requirements

Want a requirement type that doesn't exist yet? Here's how to add one.

### Step 1: Add to the Enum

Open `GamificationModels.swift` and find the `AchievementRequirement` enum (around line 80):

```swift
enum AchievementRequirement: Codable, Equatable {
    case totalExercises(Int)
    case specificExercise(String, Int)
    case streak(Int)
    case unique(Int)
    case timeWindow(hour: Int, comparison: TimeComparison, count: Int)
    case dailyGoal(Int)

    // Add your new requirement type here:
    case exerciseInWeek(Int)  // Example: Complete N exercises in one week
}
```

### Step 2: Update `targetValue` Property

Add a case to the `targetValue` computed property (same file, around line 100):

```swift
var targetValue: Int {
    switch self {
    case .totalExercises(let count): return count
    case .specificExercise(_, let count): return count
    case .streak(let days): return days
    case .unique(let count): return count
    case .timeWindow(_, _, let count): return count
    case .dailyGoal(let count): return count
    case .exerciseInWeek(let count): return count  // Add this
    }
}
```

### Step 3: Add Evaluation Logic

Open `GamificationStore.swift` and find the `AchievementEngine` struct's `evaluate` method (around line 270):

```swift
func evaluate(store: ExerciseStore, gamificationStore: GamificationStore, timestamp: Date = Date()) -> (progress: Int, unlocked: Bool) {
    switch achievement.requirement {
    // ... existing cases ...

    case .exerciseInWeek(let target):
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekLogs = store.logs.filter { $0.timestamp >= weekStart }
        let count = weekLogs.count
        return (count, count >= target)
    }
}
```

### Step 4: Use It!

Now you can use your new requirement type in achievements:

```swift
Achievement(
    id: "weekly_warrior",
    name: "Weekly Warrior",
    description: "Complete 50 exercises in one week",
    icon: "calendar.badge.checkmark",
    category: .challenge,
    tier: .gold,
    requirement: .exerciseInWeek(50),
    progress: 0
)
```

---

## Adding New Streak Types

The app currently tracks one main streak (daily activity). Here's how to add more streak types like "reminder response streak" or "pushup streak".

### Step 1: Understand Current Structure

The current streak is stored in `GamificationStore.streak` as a single `StreakData` instance.

To support multiple streak types, you have two options:

**Option A: Simple - Multiple StreakData Properties**

In `GamificationStore.swift`:

```swift
@Published var streak: StreakData = StreakData()              // Daily activity
@Published var reminderStreak: StreakData = StreakData()      // Reminder responses
@Published var pushupStreak: StreakData = StreakData()        // Consecutive days with pushups
```

**Option B: Advanced - Dictionary of Streaks**

```swift
@Published var streaks: [StreakType: StreakData] = [:]

// Access like:
streaks[.dailyActive]?.recordActivity()
streaks[.reminderResponse]?.recordActivity()
```

### Step 2: Update Persistence

In `GamificationStore.swift`, update the `GamificationData` struct:

```swift
struct GamificationData: Codable {
    var achievements: [Achievement]
    var streak: StreakData
    var reminderStreak: StreakData  // Add new streaks here
    var pushupStreak: StreakData
    var levelProgress: LevelProgress
    var activeChallenges: [Challenge]
}
```

And update `loadData()` and `saveData()` to include the new properties.

### Step 3: Record Streak Activity

In `GamificationStore.processEvent()`, record streak activity when appropriate:

```swift
case .exerciseLogged(let exerciseId, _, let timestamp):
    // Update main streak
    streak.recordActivity(on: timestamp)

    // Update pushup-specific streak
    if exerciseId == "Pushups" {
        pushupStreak.recordActivity(on: timestamp)
    }
```

For reminder streaks, you'd add a new event type:

```swift
case .reminderResponded(let timestamp):
    reminderStreak.recordActivity(on: timestamp)
```

### Step 4: Create Achievements for the New Streak

```swift
Achievement(
    id: "pushup_streak_7",
    name: "Pushup Streak",
    description: "Do pushups 7 days in a row",
    icon: "figure.strengthtraining.traditional",
    category: .consistency,
    tier: .bronze,
    requirement: .pushupStreak(7),  // New requirement type needed
    progress: 0
)
```

### Step 5: Display in UI

Update `ContentView.swift` to show multiple streaks:

```swift
VStack(spacing: 4) {
    // Daily streak
    streakBadge(
        icon: "flame.fill",
        color: .orange,
        count: gamificationStore.streak.currentStreak,
        label: "Daily"
    )

    // Pushup streak
    streakBadge(
        icon: "figure.strengthtraining.traditional",
        color: .blue,
        count: gamificationStore.pushupStreak.currentStreak,
        label: "Pushups"
    )
}
```

---

## Adding New Challenge Types

Challenges are time-limited goals. Here's how to add new ones.

### Step 1: Add to ChallengeType Enum

Open `GamificationModels.swift` and find the `ChallengeType` enum (around line 200):

```swift
enum ChallengeType: String, Codable {
    case dailyExercises = "Daily Exercises"
    case specificExercise = "Specific Exercise"
    case varietyChallenge = "Variety Challenge"
    case streakProtect = "Streak Protect"
    case earlyBird = "Early Bird"

    // Add your new challenge type:
    case doubleUp = "Double Up"  // Do twice your normal amount
}
```

### Step 2: Add Icon and Description

In the same enum, update the computed properties:

```swift
var icon: String {
    switch self {
    case .dailyExercises: return "figure.run"
    case .specificExercise: return "target"
    case .varietyChallenge: return "shuffle"
    case .streakProtect: return "shield.fill"
    case .earlyBird: return "sunrise.fill"
    case .doubleUp: return "arrow.up.arrow.down"  // Add this
    }
}

var description: String {
    switch self {
    case .dailyExercises: return "Complete exercises today"
    case .specificExercise: return "Complete specific exercise"
    case .varietyChallenge: return "Try different exercises"
    case .streakProtect: return "Maintain your streak"
    case .earlyBird: return "Exercise before 8 AM"
    case .doubleUp: return "Do twice your daily average"  // Add this
    }
}
```

### Step 3: Add to Challenge Generation

In `GamificationStore.swift`, find the `generateDailyChallenge()` method:

```swift
func generateDailyChallenge() {
    // Remove old challenges
    activeChallenges.removeAll { $0.isExpired || $0.isComplete }

    guard activeChallenges.isEmpty else { return }

    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let endOfDay = Calendar.current.startOfDay(for: tomorrow)

    // Add your challenge type to the pool:
    let challengeTypes: [ChallengeType] = [
        .dailyExercises,
        .earlyBird,
        .varietyChallenge,
        .doubleUp  // Add this
    ]

    guard let randomType = challengeTypes.randomElement() else { return }

    let target: Int
    switch randomType {
    case .dailyExercises: target = Int.random(in: 5...10)
    case .earlyBird: target = 1
    case .varietyChallenge: target = 3
    case .doubleUp:
        // Calculate user's average
        let recentLogs = ExerciseStore.shared.logsForLastDays(7)
        let average = recentLogs.count / 7
        target = max(average * 2, 10)  // At least 10
    default: target = 5
    }

    let challenge = Challenge(
        type: randomType,
        target: target,
        expiresAt: endOfDay,
        xpReward: 25
    )

    activeChallenges.append(challenge)
    saveData()
}
```

### Step 4: Handle Progress Tracking

In `GamificationStore.swift`, find the `updateChallenges()` method:

```swift
private func updateChallenges(exerciseId: String, count: Int, timestamp: Date) {
    for i in 0..<activeChallenges.count {
        guard activeChallenges[i].isActive else { continue }

        switch activeChallenges[i].type {
        case .dailyExercises:
            activeChallenges[i].progress += 1

        case .specificExercise:
            // Check if matches specific exercise
            break

        case .varietyChallenge:
            // Track unique exercises
            break

        case .earlyBird:
            let hour = Calendar.current.component(.hour, from: timestamp)
            if hour < 8 {
                activeChallenges[i].progress += 1
            }

        case .doubleUp:
            // Just count exercises like dailyExercises
            activeChallenges[i].progress += 1

        default:
            break
        }

        if activeChallenges[i].isComplete {
            processEvent(.challengeCompleted(challengeId: activeChallenges[i].id), exerciseStore: ExerciseStore.shared)
        }
    }

    activeChallenges.removeAll { $0.isExpired }
}
```

---

## Adding New Achievement Categories

Categories help organize achievements. Here's how to add one.

### Step 1: Add to AchievementCategory Enum

Open `GamificationModels.swift` and find the `AchievementCategory` enum (around line 50):

```swift
enum AchievementCategory: String, Codable, CaseIterable, Identifiable {
    case milestone = "Milestone"
    case consistency = "Consistency"
    case volume = "Volume"
    case variety = "Variety"
    case challenge = "Challenge"
    case social = "Social"

    // Add your new category:
    case speed = "Speed"  // For time-based achievements
}
```

### Step 2: Add Icon

Update the `icon` computed property:

```swift
var icon: String {
    switch self {
    case .milestone: return "flag.fill"
    case .consistency: return "flame.fill"
    case .volume: return "chart.bar.fill"
    case .variety: return "circle.hexagongrid.fill"
    case .challenge: return "trophy.fill"
    case .social: return "person.2.fill"
    case .speed: return "speedometer"  // Add this
    }
}
```

### Step 3: Use It!

Now you can create achievements in the new category:

```swift
Achievement(
    id: "speed_demon",
    name: "Speed Demon",
    description: "Complete 10 exercises in under 5 minutes",
    icon: "bolt.fill",
    category: .speed,  // Your new category
    tier: .gold,
    requirement: .timeBasedCompletion(exercises: 10, seconds: 300),  // Would need new requirement type
    progress: 0
)
```

### Step 4: That's It!

The category will automatically:
- ✅ Appear in the filter pills in AchievementsView
- ✅ Have proper icon and color
- ✅ Work with all existing achievement filtering logic

---

## Testing Your New Features

### Manual Testing

1. **Install the app** on a simulator or device
2. **Clear gamification data** (if needed):
   ```swift
   // In debug console or add a debug button:
   GamificationStore.shared.resetAllData()
   ```

3. **Log some exercises** to trigger your achievement
4. **Check the Achievements view** to see your new achievement
5. **Verify progress tracking** is working correctly
6. **Test the unlock flow**:
   - Achievement toast should appear
   - Push notification should fire
   - XP should be awarded
   - Achievement marked as unlocked

### Debug Methods

Use these helper methods in `GamificationStore` for testing:

```swift
// Manually unlock an achievement
GamificationStore.shared.debugUnlockAchievement(id: "your_achievement_id")

// Reset all data
GamificationStore.shared.resetAllData()

// Check current progress
let achievement = GamificationStore.shared.achievements.first { $0.id == "your_achievement_id" }
print("Progress: \(achievement?.progress ?? 0) / \(achievement?.targetValue ?? 0)")
```

### Automated Testing

Create unit tests in your test target:

```swift
func testNewAchievement() {
    let store = ExerciseStore()
    let gamificationStore = GamificationStore()

    // Log enough exercises to unlock
    for _ in 0..<100 {
        store.logExercise(type: .pushups, count: 10)
    }

    // Check achievement unlocked
    let achievement = gamificationStore.achievements.first { $0.id == "pushup_100" }
    XCTAssertNotNil(achievement?.unlockedAt)
    XCTAssertTrue(achievement?.isUnlocked ?? false)
}
```

---

## Quick Reference: File Locations

| What You're Adding | File | Location |
|-------------------|------|----------|
| New achievement | `GamificationModels.swift` | `AchievementDefinitions.all` array |
| New requirement type | `GamificationModels.swift` | `AchievementRequirement` enum |
| Requirement evaluation | `GamificationStore.swift` | `AchievementEngine.evaluate()` method |
| New streak type | `GamificationStore.swift` | Add property + update persistence |
| New challenge type | `GamificationModels.swift` | `ChallengeType` enum |
| Challenge generation | `GamificationStore.swift` | `generateDailyChallenge()` method |
| Challenge tracking | `GamificationStore.swift` | `updateChallenges()` method |
| New category | `GamificationModels.swift` | `AchievementCategory` enum |

---

## Best Practices

### Achievement IDs
- Use snake_case: `pushup_master` not `PushupMaster`
- Be descriptive: `week_streak` not `achievement_42`
- Make them unique: Don't reuse IDs!

### Achievement Names
- Keep them short (1-3 words)
- Make them exciting: "Week Warrior" not "7 Day Streak"
- Use title case

### Descriptions
- Be specific about the requirement
- Keep it concise (one sentence)
- Celebrate the user: "Maintain a 7-day streak" not "7 days completed"

### Tiers
- Bronze: Everyone should be able to get these
- Silver: Moderate effort required
- Gold: Significant dedication needed
- Platinum: Elite achievements for the most dedicated users

### Testing
- Always test on a real device (notifications work differently)
- Test edge cases (streak breaks, deleted exercises, etc.)
- Verify XP awards are reasonable

---

## Common Patterns

### Progressive Achievement Series

Create a series of related achievements with increasing difficulty:

```swift
// Pushup series
Achievement(id: "pushup_novice", ..., requirement: .specificExercise("Pushups", 10), tier: .bronze),
Achievement(id: "pushup_intermediate", ..., requirement: .specificExercise("Pushups", 100), tier: .silver),
Achievement(id: "pushup_advanced", ..., requirement: .specificExercise("Pushups", 500), tier: .gold),
Achievement(id: "pushup_master", ..., requirement: .specificExercise("Pushups", 1000), tier: .platinum),
```

### Time-Based Achievements

Encourage specific behaviors:

```swift
Achievement(id: "morning_person", ..., requirement: .timeWindow(hour: 8, comparison: .before, count: 5)),
Achievement(id: "lunch_break_warrior", ..., requirement: .timeWindow(hour: 13, comparison: .after, count: 10)),
```

### Combo Achievements

Require multiple conditions (you'd need to create a compound requirement type):

```swift
// Hypothetical: 10 exercises + before 7 AM + all 4 types
Achievement(
    id: "morning_master",
    name: "Morning Master",
    description: "Complete 10 varied exercises before 7 AM",
    icon: "sunrise.circle.fill",
    category: .challenge,
    tier: .platinum,
    requirement: .compound([
        .dailyGoal(10),
        .timeWindow(hour: 7, comparison: .before, count: 10),
        .unique(4)
    ]),
    progress: 0
)
```

---

## Conclusion

The gamification system was designed to be **dead simple to extend**. 90% of the time, you're just adding entries to arrays and enums. The heavy lifting (progress tracking, persistence, UI updates, notifications) is all handled automatically.

**Quick Win Checklist:**
- ✅ Add achievement to array → Works immediately
- ✅ Add category to enum → Shows in filters automatically
- ✅ Add challenge type → Can be generated randomly
- ✅ Everything persists, syncs, and notifies automatically

Happy gamifying! 🎮🏆

---

## Need Help?

Check these files for reference implementations:
- **Simple achievement**: See `"first_exercise"` in `AchievementDefinitions.all`
- **Complex requirement**: See `"well_rounded"` (unique exercises)
- **Time-based**: See `"early_bird"` achievement
- **Challenge tracking**: See `earlyBird` case in `updateChallenges()`

Or refer to `GAMIFICATION_ARCHITECTURE.md` for system internals.
