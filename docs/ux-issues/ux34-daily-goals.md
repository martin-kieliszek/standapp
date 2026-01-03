# UX34: Daily Exercise Goals - Customizable Movement Targets

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Enhancement  
**Priority**: Medium  
**Complexity**: Low (2-3 hours)

## Problem

StandFit lacks daily exercise targets. Users cannot:
- Set custom daily exercise goals
- Track goal completion percentage
- Receive notifications when goals are met
- View goal streaks

Current system only tracks:
- Exercises completed
- XP earned
- Notification completion

Missing: **What's today's target?**

## Solution

Add customizable daily goals:
- Set target exercises per day
- Track completion percentage
- Goal streak counter
- Achievement for goal streaks
- Visual progress rings (like Activity app)

## Implementation

### Goal Model

```swift
struct DailyGoal: Codable {
    var targetExercises: Int  // Default: 5
    var isEnabled: Bool       // Default: true
    
    static let `default` = DailyGoal(targetExercises: 5, isEnabled: true)
}

extension UserProfile {
    var dailyGoal: DailyGoal {
        get { /* Load from UserDefaults */ }
        set { /* Save to UserDefaults */ }
    }
}
```

### Goal Tracking

```swift
extension ExerciseStore {
    func todayProgress() -> (completed: Int, target: Int, percentage: Double) {
        let today = Calendar.current.startOfDay(for: Date())
        let todayExercises = exerciseLogs.filter { log in
            Calendar.current.isDate(log.timestamp, inSameDayAs: today)
        }.count
        
        let target = userProfile.dailyGoal.targetExercises
        let percentage = min(1.0, Double(todayExercises) / Double(target))
        
        return (todayExercises, target, percentage)
    }
    
    func currentGoalStreak() -> Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        
        while true {
            let dayExercises = exerciseLogs.filter { log in
                Calendar.current.isDate(log.timestamp, inSameDayAs: date)
            }.count
            
            if dayExercises >= userProfile.dailyGoal.targetExercises {
                streak += 1
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return streak
    }
}
```

### Goal Progress Ring

```swift
struct DailyGoalRing: View {
    let progress: Double  // 0.0 to 1.0
    let target: Int
    let completed: Int
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: progress >= 1.0 
                            ? [.green, .green] 
                            : [.blue, .cyan],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Center text
            VStack(spacing: 4) {
                Text("\\(completed)")
                    .font(.system(.title, design: .rounded))
                    .bold()
                Text("of \\(target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
    }
}
```

### Goal Settings View

```swift
struct GoalSettingsView: View {
    @Binding var dailyGoal: DailyGoal
    
    var body: some View {
        Form {
            Section("Daily Goal") {
                Toggle("Enable Daily Goal", isOn: $dailyGoal.isEnabled)
                
                if dailyGoal.isEnabled {
                    Stepper(
                        "Target: \\(dailyGoal.targetExercises) exercises",
                        value: $dailyGoal.targetExercises,
                        in: 1...20
                    )
                }
            }
            
            Section("Recommendations") {
                Text("Beginner: 3-5 exercises")
                Text("Intermediate: 5-8 exercises")
                Text("Advanced: 8-12 exercises")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .navigationTitle("Daily Goal")
    }
}
```

### Home View Integration

```swift
struct HomeView: View {
    @EnvironmentObject var exerciseStore: ExerciseStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Daily goal ring
                let progress = exerciseStore.todayProgress()
                DailyGoalRing(
                    progress: progress.percentage,
                    target: progress.target,
                    completed: progress.completed
                )
                
                // Goal streak
                if exerciseStore.currentGoalStreak() > 0 {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\\(exerciseStore.currentGoalStreak()) day goal streak")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Rest of home view...
            }
        }
    }
}
```

## Features

### Goal Completion Notification
Celebrate when daily goal is reached:
```swift
func checkGoalCompletion() {
    let progress = todayProgress()
    
    if progress.completed == progress.target && progress.target > 0 {
        // Show celebration
        let content = UNMutableNotificationContent()
        content.title = "🎉 Daily Goal Complete!"
        content.body = "You hit your target of \\(progress.target) exercises!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // ... schedule notification
    }
}
```

### Goal Achievements
```swift
Achievement(
    id: "goal_streak_7",
    title: "Week Warrior",
    description: "Complete your daily goal for 7 days straight",
    xp: 100,
    icon: "calendar.badge.checkmark"
)

Achievement(
    id: "goal_streak_30",
    title: "Month Master",
    description: "Complete your daily goal for 30 days straight",
    xp: 500,
    icon: "star.fill"
)
```

### Weekly Goal Summary
```swift
struct WeeklyGoalSummary: View {
    let daysCompleted: Int
    let totalDays: Int = 7
    
    var body: some View {
        VStack(spacing: 8) {
            Text("This Week")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<7) { day in
                    Circle()
                        .fill(day < daysCompleted ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            
            Text("\\(daysCompleted)/7 days")
                .font(.caption2)
                .bold()
        }
    }
}
```

## User Experience

### First Launch
- Default goal: 5 exercises
- Can customize in onboarding (UX24)
- Adjustable anytime in settings

### Daily Flow
1. Open app → see progress ring
2. Complete exercises → ring fills
3. Hit goal → celebration notification
4. View streak → motivation to continue

### Motivation Loop
- Clear daily target
- Visual progress feedback
- Streak preservation
- Achievement rewards

## Benefits

- Clear daily targets
- Progress visualization
- Streak motivation
- Beginner-friendly (adjustable targets)
- Works with existing XP system
- No breaking changes

## Technical Requirements

- UserDefaults storage
- Date calculations
- Progress ring rendering
- Local notifications
- 2-3 hour implementation

## Related Issues

- **UX10**: Gamification - Goal achievements
- **UX09**: Progress Reports - Include goal completion
- **UX35**: Streak Freeze - Protect goal streaks
- **UX36**: Rest Days - Exclude from goal tracking

## Conclusion

Essential feature for user engagement. **2-3 hour implementation**. Provides clear daily targets and progress visualization. Complements existing notification system with outcome-focused goals.
