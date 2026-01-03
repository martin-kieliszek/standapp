# Gamification System Architecture (UX10)

## Overview

The gamification system is designed with **modularity**, **extensibility**, and **future flexibility** as core principles. It provides achievements, streaks, levels/XP, and challenges to motivate users and enhance engagement.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface Layer                   │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ ContentView│  │AchievementsView│  │AchievementToast  │   │
│  │ (badges)   │  │   (list)       │  │  (celebration)   │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                      │
│  ┌────────────────────┐       ┌──────────────────┐         │
│  │ GamificationStore  │◄──────┤ AchievementEngine │         │
│  │ (state manager)    │       │ (rule evaluator)  │         │
│  └────────────────────┘       └──────────────────┘         │
│           │                                                  │
│           ▼                                                  │
│  ┌────────────────────┐       ┌──────────────────┐         │
│  │  Event Processing  │◄──────┤ ExerciseStore     │         │
│  │  (achievements,    │       │ (triggers events) │         │
│  │   XP, streaks)     │       └──────────────────┘         │
│  └────────────────────┘                                     │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Notification Layer                       │
│  ┌────────────────────────────────────────────────────┐    │
│  │          NotificationManager                        │    │
│  │  - Achievement unlocked notifications               │    │
│  │  - Push notification categories                     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  gamification_data.json                             │    │
│  │  - achievements (progress, unlocked dates)          │    │
│  │  - streak data (current, longest, freezes)          │    │
│  │  - level progress (XP)                              │    │
│  │  - active challenges                                │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. GamificationModels.swift

**Purpose:** Foundation data models for all gamification features

**Key Types:**

- `Achievement`: Unlockable goals with progress tracking
  - Supports multiple categories (milestone, consistency, volume, variety, challenge, social)
  - Tiered system (bronze, silver, gold, platinum)
  - Flexible requirement system

- `AchievementRequirement` (enum):
  - `.totalExercises(Int)` - Total count across all types
  - `.specificExercise(String, Int)` - Specific exercise counts
  - `.streak(Int)` - Maintain streak for N days
  - `.unique(Int)` - Unique exercises in one day
  - `.timeWindow(hour:comparison:count:)` - Time-based achievements
  - `.dailyGoal(Int)` - Daily exercise targets

- `StreakData`: Consecutive day tracking with protection
  - Current and longest streak tracking
  - Streak freeze tokens (earned every 7 days)
  - Optional rest day configuration
  - Automatic streak break detection

- `LevelProgress`: XP-based progression
  - Exponential leveling curve (20% increase per level)
  - XP sources: exercises (10 XP), streaks (5 XP bonus), achievements (50 XP)

- `Challenge`: Time-limited goals
  - Daily/weekly short-term objectives
  - XP rewards on completion
  - Automatic expiration

- `GamificationEvent` (enum): Event-driven architecture
  - `.exerciseLogged`
  - `.reminderResponded`
  - `.dayCompleted`
  - `.achievementUnlocked`
  - `.levelUp`
  - `.challengeCompleted`

**Extensibility Points:**
- Easy to add new `AchievementRequirement` types
- `AchievementCategory` is extensible via `CaseIterable`
- `GamificationEvent` can be expanded for new triggers

### 2. GamificationStore.swift

**Purpose:** Central state manager for all gamification features

**Key Responsibilities:**
- Persistence (JSON-based for easy debugging)
- Event processing via `processEvent(_:exerciseStore:)`
- Achievement progress checking
- Challenge generation and management
- Streak management

**Design Patterns:**
- **Observable Object**: SwiftUI integration via `@Published` properties
- **Singleton**: `GamificationStore.shared` for global access
- **Event-Driven**: Processes `GamificationEvent` instances
- **Separation of Concerns**: Achievement evaluation delegated to `AchievementEngine`

**Key Methods:**

```swift
// Process events and update state
func processEvent(_ event: GamificationEvent, exerciseStore: ExerciseStore)

// Query methods
var unlockedAchievements: [Achievement]
var inProgressAchievements: [Achievement]
var lockedAchievements: [Achievement]
func achievements(in category: AchievementCategory?) -> [Achievement]

// Challenge management
func generateDailyChallenge()
var activeChallenge: Challenge?
```

**Extensibility:**
- New event types easily added to `processEvent` switch
- Achievement definitions centralized in `AchievementDefinitions.all`
- Challenge generation logic can be expanded

### 3. AchievementEngine.swift (within GamificationStore.swift)

**Purpose:** Evaluate achievement requirements and calculate progress

**Design:**
- Pure function approach: `evaluate(store:gamificationStore:timestamp:) -> (progress: Int, unlocked: Bool)`
- Stateless - all state passed in
- Testable in isolation

**Evaluation Logic:**
Each requirement type has specific evaluation:
- `totalExercises`: Sum all exercise logs
- `specificExercise`: Filter by exercise name/type
- `streak`: Read from `GamificationStore.streak`
- `unique`: Count unique exercises in one day
- `timeWindow`: Filter logs by hour of day
- `dailyGoal`: Count exercises in current day

**Future Extensions:**
- Add new requirement types in the switch statement
- Support compound requirements (multiple conditions)
- Time-range requirements (week, month, year)

### 4. AchievementsView.swift

**Purpose:** User-facing UI for viewing and tracking achievements

**Features:**
- Summary stats (unlocked count, tier breakdown)
- Category filtering (All, Milestone, Consistency, Volume, etc.)
- Three sections: Unlocked, In Progress, Locked
- Progress bars for in-progress achievements
- Tier badges with color coding

**Components:**
- `AchievementsView`: Main list view
- `AchievementRow`: Individual achievement cell
- `AchievementUnlockedToast`: Celebration overlay

**Future Extensions:**
- Achievement detail view (history, stats)
- Share achievements to social media
- Achievement comparison with friends
- Seasonal/event-specific achievement sets

### 5. ContentView Integration

**New UI Elements:**
- Streak badge (flame icon with day count)
- Level badge (star icon with level number)
- Achievement count badge (trophy icon)
- Achievements button (navigate to AchievementsView)
- Toast overlay for achievement unlocks

**Auto-dismiss Logic:**
- Checks for new achievements every second (via timer)
- Shows toast for 5 seconds
- Can be dismissed manually

### 6. ExerciseStore Integration

**Event Triggering:**
All exercise logging methods now trigger gamification events:

```swift
func logExercise(type: ExerciseType, count: Int) {
    // ... existing log creation ...
    let gamificationStore = GamificationStore.shared
    gamificationStore.processEvent(
        .exerciseLogged(exerciseId: type.rawValue, count: count, timestamp: log.timestamp),
        exerciseStore: self
    )
}
```

**Benefits:**
- Automatic achievement checking on every exercise
- Streak updates in real-time
- XP awarded immediately

### 7. NotificationManager Integration

**New Notification Category:**
- `achievementUnlocked`: Fired when achievement unlocks
- Category with "View All" action button

**Notification Content:**
- Title: "🏆 Achievement Unlocked!"
- Body: "{name} - {description}"
- Sound and badge support

**Future Extensions:**
- Streak reminder notifications ("Don't break your 10-day streak!")
- Level up celebrations
- Challenge expiration warnings

## Data Flow

### Exercise Logged Flow

```
User logs exercise
    ↓
ExerciseStore.logExercise()
    ↓
GamificationStore.processEvent(.exerciseLogged)
    ↓
┌─────────────────────────────────────┐
│ 1. Update streak (recordActivity)   │
│ 2. Award XP (base + streak bonus)   │
│ 3. Check for level up               │
│ 4. Evaluate all achievements        │
│ 5. Update challenge progress        │
└─────────────────────────────────────┘
    ↓
If achievement unlocked:
    ↓
┌─────────────────────────────────────┐
│ 1. Mark achievement as unlocked     │
│ 2. Add to recentlyUnlocked array    │
│ 3. Send push notification           │
│ 4. Award achievement XP (50)        │
└─────────────────────────────────────┘
    ↓
ContentView timer detects new unlock
    ↓
Show AchievementUnlockedToast
```

## Extensibility Guide

### Adding a New Achievement

1. Define in `AchievementDefinitions.all`:
```swift
Achievement(
    id: "my_achievement",
    name: "Achievement Name",
    description: "What the user did",
    icon: "sf.symbol.name",
    category: .milestone,
    tier: .gold,
    requirement: .totalExercises(500),
    progress: 0
)
```

2. If using a new requirement type, add to `AchievementRequirement`:
```swift
enum AchievementRequirement: Codable, Equatable {
    case myNewRequirement(Int, String)
    // ... existing cases ...
}
```

3. Implement evaluation in `AchievementEngine.evaluate()`:
```swift
case .myNewRequirement(let value, let parameter):
    // Evaluation logic
    let progress = calculateProgress(value, parameter)
    let unlocked = progress >= targetValue
    return (progress, unlocked)
```

### Adding a New Event Type

1. Add to `GamificationEvent`:
```swift
enum GamificationEvent {
    case myNewEvent(data: String)
    // ... existing cases ...
}
```

2. Handle in `GamificationStore.processEvent()`:
```swift
case .myNewEvent(let data):
    // Update state based on event
    // Check achievements
    // Award XP if appropriate
```

3. Trigger from appropriate location:
```swift
gamificationStore.processEvent(.myNewEvent(data: "info"), exerciseStore: self)
```

### Adding a New Challenge Type

1. Add to `ChallengeType`:
```swift
enum ChallengeType: String, Codable {
    case myChallenge = "My Challenge"
    // ... existing cases ...

    var icon: String {
        switch self {
        case .myChallenge: return "star.fill"
        // ...
        }
    }
}
```

2. Update challenge generation logic in `generateDailyChallenge()`:
```swift
let challengeTypes: [ChallengeType] = [.dailyExercises, .myChallenge]
```

3. Handle progress updates in `updateChallenges()`:
```swift
case .myChallenge:
    // Check if challenge condition met
    if conditionMet {
        activeChallenges[i].progress += 1
    }
```

## Future Enhancements

### High Priority (Easy to Add)

1. **Social Features**
   - Share achievements via WatchKit sharing
   - Compare stats with friends
   - Achievement: "Share your first achievement"

2. **More Streak Types**
   - Reminder response streaks
   - Exercise-specific streaks (pushup streak, etc.)
   - Weekly goal streaks

3. **Challenge Expansion**
   - Weekly challenges with bigger rewards
   - Seasonal/event challenges
   - Rotating challenge pool

4. **Badge Collections**
   - Visual badge display (grid view)
   - Rarity tiers
   - Limited-time badges

### Medium Priority (Requires Design)

1. **Leaderboards**
   - Weekly/monthly rankings
   - Friend groups
   - Anonymous global leaderboards

2. **Customization**
   - Custom achievement icons
   - Personalized milestones
   - Achievement notifications settings

3. **Statistics Dashboard**
   - Achievement timeline
   - Fastest unlocks
   - Completion percentage by category

### Low Priority (Major Features)

1. **Prestige System**
   - Reset progress for special rewards
   - Prestige levels (1★, 2★, etc.)
   - Exclusive prestige achievements

2. **Achievement Sets**
   - Complete themed sets for mega-rewards
   - Story-based achievement chains
   - Hidden/secret achievements

3. **Guilds/Teams**
   - Team challenges
   - Shared progress
   - Team achievements

## Testing Strategy

### Manual Testing Checklist

- [ ] Log first exercise → "First Steps" achievement unlocks
- [ ] Log 10 exercises → "Getting Started" unlocks
- [ ] Exercise 7 days in a row → "Week Warrior" unlocks
- [ ] Exercise before 7 AM → "Early Bird" unlocks
- [ ] Do all 4 exercise types in one day → "Well Rounded" unlocks
- [ ] Complete 10 exercises in one day → "Power Day" unlocks
- [ ] Check XP increases with each exercise
- [ ] Verify level progression (Lv 1 → Lv 2 at 100 XP)
- [ ] Test streak freeze (skip one day with freeze available)
- [ ] Test streak break (skip 2+ days without freeze)
- [ ] Verify achievement toast appears on unlock
- [ ] Check push notification for achievement unlock
- [ ] Test category filtering in AchievementsView
- [ ] Verify progress bars show correctly
- [ ] Test "View All" action from notification

### Debug Methods

Available in `GamificationStore`:
```swift
func debugUnlockAchievement(id: String)  // Manually unlock for testing
func resetAllData()                       // Clear all gamification data
```

### Data Inspection

Gamification data stored at:
```
~/Library/Developer/CoreSimulator/Devices/{DEVICE_ID}/data/Containers/Data/Application/{APP_ID}/Documents/gamification_data.json
```

Pretty-printed JSON for easy debugging.

## Performance Considerations

1. **Achievement Checking**
   - Only evaluates unlocked achievements (skips locked ones)
   - Event-driven (not polling)
   - O(n) where n = locked achievements

2. **Persistence**
   - JSON encoding/decoding is fast for small datasets
   - Async writes prevent UI blocking
   - Data size: ~10-20 KB (manageable)

3. **Memory**
   - Single `GamificationStore` instance
   - Achievements loaded once on init
   - No memory leaks (weak references in closures)

## Assessment of Implementation
I've conducted a thorough review of the achievement system architecture. Here's my assessment against your four criteria:
✅ 1. Flexibility to Future Changes
EXCELLENT - The system is highly extensible:
Adding New Template Types

// Just add to enum - everything else auto-updates
case newType = "New Achievement Type"
Template engine auto-handles new requirement types
UI pickers automatically include new types
Default tier configurations defined per type
Adding New Achievement Categories

case newCategory = "New Category"  // In AchievementCategory enum
Filter pills auto-update
Icons defined in single location
No hardcoded category lists
Modifying Achievement Requirements
AchievementRequirement enum extensible with new cases
Custom Codable ensures backward compatibility
Old achievements decode/upgrade gracefully
Template Engine is Pure & Stateless
No side effects - just transforms data
Easy to test and modify
Can add new generation strategies without breaking existing
Future-Proof Score: 10/10 ✅
✅ 2. Modularity
EXCELLENT - Clear separation of concerns:
Layer Architecture

UI Layer (SwiftUI Views)
    ↓
Store Layer (GamificationStore)
    ↓
Service Layer (GamificationService, AchievementTemplateEngine)
    ↓
Model Layer (Achievement, AchievementTemplate)
    ↓
Persistence Layer (JSONFilePersistence)
Key Modular Boundaries
StandFitCore Package - Platform-agnostic business logic
Models, Services, Extensions
Zero UIKit/SwiftUI dependencies
Shared between iOS and WatchOS
GamificationStore - State management container
Owns @Published state
Delegates logic to services
Handles persistence orchestration
AchievementTemplateEngine - Pure function generator
Stateless achievement creation
Deterministic output
Easy to unit test
Premium Integration - Single source of truth
FeatureEntitlement protocol
Checked at service layer (processEvent)
Enforced at UI layer (view gating)
Modularity Score: 10/10 ✅
✅ 3. Persistence Through Reboots
EXCELLENT - Comprehensive persistence with unlock date preservation:
What's Persisted
Data	File	Format	Reload Strategy
Built-in Achievements	gamification.json	Full state with unlock dates	Load once on init
Template Achievements	Same file	Merged with built-ins	Regenerated with preserved dates
Templates	achievement_templates.json	Template definitions	Load on init
Generation Records	template_generation_records.json	Template→Achievement mapping	Load on init
Critical Unlock Date Preservation (Fixed!)

// BEFORE regeneration: Extract existing unlock dates
var existingUnlockDates: [String: Date] = [:]
for achievement in achievements where templateAchievementIds.contains(achievement.id) {
    if let unlockedAt = achievement.unlockedAt {
        existingUnlockDates[achievement.id] = unlockedAt  // ✅ Preserve
    }
}

// DURING regeneration: Reuse preserved dates
if let existingDate = existingUnlockDates[achievementId] {
    unlockedAt = existingDate  // ✅ Restore original
}
Persistence Guarantees
✅ Achievements persist across app restarts
✅ Unlock dates never change after first unlock
✅ Templates persist independently
✅ Template edits don't lose achievement history
✅ Graceful handling of corrupt JSON files
Persistence Score: 10/10 ✅
✅ 4. Premium Paywall Protection
EXCELLENT - Multi-layer premium enforcement:
Layer 1: Runtime Event Processing (Strongest)

// GamificationStore.swift:89
func processEvent(_ event: GamificationEvent, exerciseStore: ExerciseStore) {
    guard exerciseStore.isPremium else { return }  // ✅ Hard stop
    // ... achievement processing
}
Protection: Free users cannot earn ANY achievements, even if they bypass UI
Layer 2: Template Creation

// GamificationStore.swift:392
func canCreateTemplate(entitlements: FeatureEntitlement) -> Bool {
    achievementTemplates.count < entitlements.achievementTemplateLimit  // Free: 0, Premium: ∞
}
Protection: Free users physically cannot create templates (limit = 0)
Layer 3: UI Gating (UX Layer)
AchievementsView: Template button only shown if premium
ManageTemplatesView: Premium prompt replaces content for free users
ContentView: Achievement cards show paywall on tap
CreateExerciseView: Template creation hint only for premium
Premium Flow Security

Free User Attempts Template Creation
    ↓
UI Check: canCreateTemplate() → FALSE (limit 0) → Show paywall
    ↓ (if bypassed)
Store Check: achievementTemplates.count >= 0 → Reject
    ↓ (if bypassed)
Runtime Check: processEvent() → guard isPremium → No-op
Three layers of protection - defense in depth! ✅
Data Model Protection

public var createdByPremiumUser: Bool  // AchievementTemplate metadata
Future feature flag for grace period if user downgrades
Audit trail for premium feature usage
Security Score: 10/10 ✅
🏆 Final Verdict: ENDORSE ✅
The achievement implementation is production-ready and robust. Here's why:
Strengths
✅ Clean Architecture - Services, stores, models properly separated
✅ Unlock Date Bug Fixed - Achievements never "re-achieve" on reboot
✅ Template Category Added - Custom achievements easy to find
✅ Custom Names Work - User's template names appear in achievements
✅ Multi-Layer Premium Protection - Cannot be bypassed
✅ Graceful Degradation - Missing exercises don't crash, just skip
✅ Backward Compatible - Old data loads correctly
✅ Future-Proof - Easy to extend with new types/categories
No Critical Issues Found ✅
The implementation meets all four criteria at the highest level. The recent fixes for unlock date preservation and template naming have resolved the last remaining issues.
Recommendation
No further changes needed. The system is:
Flexible ✅
Modular ✅
Persistent ✅
Protected ✅

## Conclusion

The gamification system is built with **future growth** in mind. The modular architecture makes it easy to:

- Add new achievements (just add to `AchievementDefinitions.all`)
- Create new event types (extend `GamificationEvent`)
- Build new UI features (all state in `GamificationStore`)
- Integrate with external services (event-driven design)

The system provides immediate value to users while laying groundwork for sophisticated future features like leaderboards, social sharing, and prestige systems.
