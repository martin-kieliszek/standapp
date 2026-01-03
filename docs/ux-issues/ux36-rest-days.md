# UX36: Rest Day Tracking - Recognize Recovery Days

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Enhancement  
**Priority**: Low  
**Complexity**: Low (1-2 hours)

## Problem

StandFit treats every day the same. Missing features:
- No rest day designation
- Recovery days break streaks
- No distinction between "forgot" and "intentional rest"
- Promotes overtraining

**Fitness reality**: Rest days are essential for recovery and growth.

## Solution

Add rest day tracking:
- Mark specific days as "Rest Days"
- Rest days don't break streaks
- Rest days count toward consistency
- Optional rest day exercises (light stretching)
- Weekly rest day recommendations

## Implementation

### Rest Day Model

```swift
struct RestDay: Codable, Identifiable {
    let id: UUID
    let date: Date
    var reason: String?  // "Recovery", "Travel", "Illness", etc.
    var lightExercises: [ExerciseLog]?  // Optional stretching/walking
    
    init(date: Date, reason: String? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.reason = reason
    }
}

extension UserProfile {
    var restDays: [RestDay] {
        get { /* Load from UserDefaults */ }
        set { /* Save to UserDefaults */ }
    }
}
```

### Rest Day Tracking

```swift
extension ExerciseStore {
    func markRestDay(date: Date, reason: String? = nil) {
        let restDay = RestDay(date: date, reason: reason)
        userProfile.restDays.append(restDay)
        
        // Show confirmation
        showRestDayMarked()
    }
    
    func isRestDay(_ date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return userProfile.restDays.contains { restDay in
            Calendar.current.isDate(restDay.date, inSameDayAs: dayStart)
        }
    }
    
    func updateStreakWithRestDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentDate = today
        var streak = 0
        
        while true {
            // Check if exercised OR rest day
            let hasExercise = exerciseLogs.contains { log in
                calendar.isDate(log.timestamp, inSameDayAs: currentDate)
            }
            let isRest = isRestDay(currentDate)
            
            if hasExercise || isRest {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        userProfile.currentStreak = streak
    }
}
```

### Rest Day Calendar View

```swift
struct RestDayCalendarView: View {
    @EnvironmentObject var exerciseStore: ExerciseStore
    @State private var selectedDate = Date()
    @State private var showingRestDaySheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Calendar
                CalendarView(selectedDate: $selectedDate)
                    .overlay(alignment: .topTrailing) {
                        // Mark rest days
                        ForEach(exerciseStore.userProfile.restDays) { restDay in
                            RestDayBadge(date: restDay.date)
                        }
                    }
                
                // Mark today as rest day
                Button {
                    showingRestDaySheet = true
                } label: {
                    Label("Mark Today as Rest Day", systemImage: "bed.double.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Rest Days")
            .sheet(isPresented: $showingRestDaySheet) {
                RestDaySheet(date: selectedDate)
            }
        }
    }
}
```

### Rest Day Sheet

```swift
struct RestDaySheet: View {
    let date: Date
    @EnvironmentObject var exerciseStore: ExerciseStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedReason = "Recovery"
    
    let reasons = ["Recovery", "Travel", "Illness", "Busy Day", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rest Day Reason") {
                    Picker("Reason", selection: $selectedReason) {
                        ForEach(reasons, id: \.self) { reason in
                            Text(reason)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section {
                    Button("Mark as Rest Day") {
                        exerciseStore.markRestDay(date: date, reason: selectedReason)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Rest Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
```

### Rest Day Recommendations

```swift
extension ExerciseStore {
    func suggestRestDay() -> Bool {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: Date())
        }
        
        // Count exercises in last 7 days
        let recentExercises = last7Days.map { day in
            exerciseLogs.filter { log in
                calendar.isDate(log.timestamp, inSameDayAs: day)
            }.count
        }
        
        let consecutiveDays = recentExercises.prefix(while: { $0 > 0 }).count
        
        // Suggest rest after 6 consecutive days
        return consecutiveDays >= 6
    }
}

func showRestDayRecommendation() {
    if exerciseStore.suggestRestDay() {
        let content = UNMutableNotificationContent()
        content.title = "Consider a Rest Day"
        content.body = "You've been consistent for 6 days. Recovery is important!"
        content.categoryIdentifier = "REST_DAY_SUGGESTION"
        
        // Add "Mark Rest Day" action
        let markRestDayAction = UNNotificationAction(
            identifier: "MARK_REST_DAY",
            title: "Mark Rest Day",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "REST_DAY_SUGGESTION",
            actions: [markRestDayAction],
            intentIdentifiers: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
```

## Features

### Light Exercise Option
Allow optional light exercises on rest days:
```swift
// Stretching, walking, etc.
let lightExercises = ["Gentle Stretching", "Light Walk", "Breathing Exercises"]

struct RestDayExerciseView: View {
    @State private var selectedExercise: String?
    
    var body: some View {
        VStack {
            Text("Optional Light Activity")
                .font(.headline)
            
            ForEach(lightExercises, id: \.self) { exercise in
                Button(exercise) {
                    logLightExercise(exercise)
                }
            }
        }
    }
}
```

### Rest Day Statistics
```swift
struct RestDayStats: View {
    let restDays: [RestDay]
    
    var thisMonth: Int {
        restDays.filter { restDay in
            Calendar.current.isDate(restDay.date, equalTo: Date(), toGranularity: .month)
        }.count
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Rest Days This Month")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("\\(thisMonth)")
                .font(.title)
                .bold()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Weekly Rest Reminder
```swift
func scheduleWeeklyRestReminder() {
    var components = DateComponents()
    components.weekday = 1  // Sunday
    components.hour = 8
    
    let content = UNMutableNotificationContent()
    content.title = "Rest Day Check-In"
    content.body = "Planning a rest day this week? Recovery is key to progress!"
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    // ... schedule notification
}
```

### Rest Day Achievements
```swift
Achievement(
    id: "first_rest_day",
    title: "Recovery Mode",
    description: "Mark your first intentional rest day",
    xp: 10,
    icon: "bed.double.fill"
)

Achievement(
    id: "balanced_week",
    title: "Balanced Week",
    description: "Complete 5 workout days and 1 rest day in a week",
    xp: 50,
    icon: "heart.fill"
)

Achievement(
    id: "rest_advocate",
    title: "Rest Advocate",
    description: "Take a rest day after 10 consecutive workout days",
    xp: 75,
    icon: "moon.stars.fill"
)
```

## Benefits

- Promotes healthy recovery habits
- Removes guilt from rest days
- Maintains streaks during recovery
- Educates users about fitness fundamentals
- Prevents overtraining

## User Experience

### Marking Rest Day
1. User goes to calendar
2. Selects today
3. "Mark as Rest Day"
4. Choose reason (Recovery, Travel, etc.)
5. Confirmation: "✅ Rest day marked. Your streak continues!"

### Rest Day Flow
- Morning: "Consider a rest day after 6 consecutive workouts"
- User marks rest day
- Streak continues
- Optional light exercise suggestion
- Next day: Normal workout notifications resume

### Statistics Integration
```
This Week:
🏃 5 Workout Days
🛌 1 Rest Day
✅ Balanced Week Achievement
```

## Technical Requirements

- UserDefaults storage
- Calendar date matching
- Streak calculation update
- Notification actions
- 1-2 hour implementation

## Related Issues

- **UX34**: Daily Goals - Rest days excluded from goal tracking
- **UX35**: Streak Freeze - Different from freezes (intentional vs. emergency)
- **UX09**: Progress Reports - Show rest day patterns
- **UX26**: HealthKit - Sync rest days with Apple Health

## Fitness Best Practices

### Recommended Rest Schedule
- Beginners: 2-3 rest days per week
- Intermediate: 1-2 rest days per week
- Advanced: 1 rest day per week
- All levels: After intense workout streaks

### Education
Include in-app tips:
- "Muscles grow during rest, not during exercise"
- "Rest days prevent injury and burnout"
- "Active recovery (light stretching) is beneficial"

## Conclusion

Aligns app with fitness science. **1-2 hour implementation**. Promotes sustainable habits, removes streak anxiety, educates users about recovery importance. Essential for long-term fitness success.
