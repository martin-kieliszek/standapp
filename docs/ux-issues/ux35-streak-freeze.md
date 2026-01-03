# UX35: Streak Freeze/Recovery - Protect Engagement Streaks

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Enhancement  
**Priority**: Medium  
**Complexity**: Low (2-3 hours)

## Problem

StandFit's streak system is unforgiving. Users lose streaks due to:
- Illness
- Travel
- Busy days
- App bugs
- Forgot to log

**No recovery mechanism** means:
- Demotivation after losing long streaks
- All-or-nothing pressure
- User churn after breaking streaks

Example: User with 47-day streak misses one day → back to 0 → feels defeated → stops using app.

## Solution

Add streak protection system:
- **Streak Freeze**: Earn 1 freeze per 7-day streak
- **Grace Period**: 1-hour window after missed day
- **Manual Recovery**: One-time recovery (achievement unlock)
- Transparent tracking of freezes used

## Implementation

### Streak Protection Model

```swift
struct StreakProtection: Codable {
    var freezesAvailable: Int = 0
    var freezesUsed: Int = 0
    var lastFreezeDate: Date?
    var hasUsedManualRecovery: Bool = false
    
    mutating func earnFreeze() {
        freezesAvailable += 1
    }
    
    mutating func useFreeze() -> Bool {
        guard freezesAvailable > 0 else { return false }
        freezesAvailable -= 1
        freezesUsed += 1
        lastFreezeDate = Date()
        return true
    }
}

extension UserProfile {
    var streakProtection: StreakProtection {
        get { /* Load from UserDefaults */ }
        set { /* Save to UserDefaults */ }
    }
}
```

### Automatic Freeze Application

```swift
extension ExerciseStore {
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastExerciseDate = exerciseLogs.last?.timestamp ?? .distantPast
        let lastExerciseDay = calendar.startOfDay(for: lastExerciseDate)
        
        let daysSinceLastExercise = calendar.dateComponents([.day], from: lastExerciseDay, to: today).day ?? 0
        
        if daysSinceLastExercise == 1 {
            // Continue streak
            userProfile.currentStreak += 1
            
            // Earn freeze every 7 days
            if userProfile.currentStreak % 7 == 0 {
                userProfile.streakProtection.earnFreeze()
                showStreakFreezeEarned()
            }
        } else if daysSinceLastExercise == 2 {
            // Missed one day - try to use freeze
            if userProfile.streakProtection.useFreeze() {
                // Streak protected!
                userProfile.currentStreak += 1
                showStreakProtected()
            } else {
                // No freeze available - streak broken
                userProfile.currentStreak = 1
                showStreakBroken()
            }
        } else if daysSinceLastExercise > 2 {
            // Too many days missed - streak broken
            userProfile.currentStreak = 1
        }
    }
}
```

### Streak Recovery View

```swift
struct StreakRecoveryView: View {
    @EnvironmentObject var exerciseStore: ExerciseStore
    @State private var showingRecovery = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
                .opacity(0.5)
            
            Text("Streak Broken")
                .font(.title)
                .bold()
            
            Text("Your \\(previousStreak)-day streak ended")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Freeze availability
            if exerciseStore.userProfile.streakProtection.freezesAvailable > 0 {
                Button {
                    recoverStreak()
                } label: {
                    VStack(spacing: 4) {
                        Text("Use Streak Freeze")
                            .font(.headline)
                        Text("\\(exerciseStore.userProfile.streakProtection.freezesAvailable) available")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Manual recovery (one-time)
            if !exerciseStore.userProfile.streakProtection.hasUsedManualRecovery {
                Button {
                    showingRecovery = true
                } label: {
                    Text("Manual Recovery (One-Time)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .alert("Recover Streak?", isPresented: $showingRecovery) {
            Button("Cancel", role: .cancel) { }
            Button("Recover") {
                exerciseStore.manualStreakRecovery()
            }
        } message: {
            Text("This is a one-time recovery. Use it wisely!")
        }
    }
}
```

### Freeze Notification

```swift
func showStreakFreezeEarned() {
    let content = UNMutableNotificationContent()
    content.title = "🎁 Streak Freeze Earned!"
    content.body = "Your \\(userProfile.currentStreak)-day streak earned you a protective freeze"
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    // ... schedule notification
}

func showStreakProtected() {
    let content = UNMutableNotificationContent()
    content.title = "🛡️ Streak Protected!"
    content.body = "Your streak was automatically protected by a freeze"
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    // ... schedule notification
}
```

### Grace Period Warning

```swift
func scheduleGracePeriodWarning() {
    // If user hasn't exercised today, warn them at 11 PM
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let todayExercises = exerciseLogs.filter { log in
        calendar.isDate(log.timestamp, inSameDayAs: today)
    }
    
    if todayExercises.isEmpty && userProfile.currentStreak > 0 {
        var components = DateComponents()
        components.hour = 23
        components.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Streak at Risk!"
        content.body = "Your \\(userProfile.currentStreak)-day streak needs attention"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // ... schedule notification
    }
}
```

## Features

### Freeze Economy
- Earn 1 freeze per 7-day streak
- Max 5 freezes stored
- Automatic application
- Usage history tracking

### Manual Recovery
- One-time use per account
- Unlocks "Second Chance" achievement
- Recovers any streak length
- Permanent flag (no reset)

### Transparency
Show freeze status prominently:
```swift
struct StreakStatusView: View {
    let streak: Int
    let freezes: Int
    
    var body: some View {
        HStack {
            // Streak flame
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                Text("\\(streak)")
            }
            .foregroundStyle(.orange)
            
            Divider()
            
            // Freezes
            HStack(spacing: 4) {
                Image(systemName: "snowflake")
                Text("\\(freezes)")
            }
            .foregroundStyle(.cyan)
        }
        .font(.headline)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Freeze Achievements
```swift
Achievement(
    id: "first_freeze",
    title: "Safety Net",
    description: "Earn your first streak freeze",
    xp: 25,
    icon: "snowflake"
)

Achievement(
    id: "freeze_saver",
    title: "Freeze Saver",
    description: "Have 5 streak freezes at once",
    xp: 100,
    icon: "snowflake.circle"
)

Achievement(
    id: "second_chance",
    title: "Second Chance",
    description: "Use your one-time manual recovery",
    xp: 50,
    icon: "arrow.clockwise"
)
```

## User Experience

### Earning Freezes
- Day 7: "🎁 Streak Freeze Earned!"
- Day 14: "🎁 Streak Freeze Earned!" (2 total)
- Day 21: "🎁 Streak Freeze Earned!" (3 total)

### Automatic Protection
- User misses day 15
- App automatically uses 1 freeze
- Notification: "🛡️ Streak Protected!"
- Streak continues: 16 days

### Manual Recovery
- User breaks 90-day streak
- Offered one-time recovery
- Must confirm ("Use it wisely!")
- Unlocks achievement

## Benefits

- Reduces streak anxiety
- Rewards consistency (earn freezes)
- Forgives occasional mistakes
- Increases user retention
- Aligns with modern app psychology

## Technical Requirements

- UserDefaults storage
- Automatic freeze logic in streak calculation
- Notification scheduling
- UI for freeze status
- 2-3 hour implementation

## Edge Cases

### Multiple Missed Days
- 1 day missed: Use 1 freeze
- 2+ days missed: Streak broken (no freeze)
- Grace period: 1 hour into next day

### Freeze Earning
- Earn on day 7, 14, 21, etc.
- Max 5 freezes stored
- Earning 6th freeze: "Max freezes reached"

### Manual Recovery
- Only works once ever
- Can recover any streak length
- Doesn't restore freezes
- Permanent account flag

## Related Issues

- **UX34**: Daily Goals - Goal streaks also protected
- **UX36**: Rest Days - Rest days don't break streaks
- **UX09**: Progress Reports - Show freeze usage history
- **UX10**: Gamification - Freeze-related achievements

## Conclusion

Modern apps (Duolingo, Streaks, etc.) use streak protection. **2-3 hour implementation**. Reduces user frustration, increases retention, rewards consistency. Essential for long-term engagement.
