# UX26: Apple Health (HealthKit) Integration

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Platform Integration  
**Priority**: Very High  
**Complexity**: Medium (3-4 hours)

## Problem

StandFit is a fitness app that tracks exercises, but it **does not integrate with Apple Health**. This is a significant oversight because:

- Users expect fitness apps to sync with Apple Health
- Exercise data is siloed within StandFit only
- No contribution to Activity Rings
- Cannot view exercise history in Health app alongside other health data
- Reduces app legitimacy and trustworthiness
- Misses ecosystem integration benefits

**User Impact**: "Why doesn't my exercise show up in my Health app?" is a common complaint for fitness apps without HealthKit integration.

## Solution

Implement HealthKit integration to:
1. Write exercises as `HKWorkout` sessions to Apple Health
2. Sync exercise calories and activity data
3. Read user's health data (optional: heart rate, weight) for enhanced features
4. Show up in Activity app and close Activity Rings
5. Display HealthKit permission UI during onboarding

## Implementation

### HealthKit Capabilities

**1. Add HealthKit Entitlement**:
- Enable HealthKit in Xcode project capabilities
- Add to Info.plist:
```xml
<key>NSHealthShareUsageDescription</key>
<string>StandFit reads your health data to provide personalized exercise recommendations.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>StandFit logs your exercises to Apple Health so you can track all your fitness data in one place.</string>
```

**2. Create HealthKit Manager**:
```swift
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    // Request authorization
    func requestAuthorization() async throws -> Bool {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType()
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        return true
    }
    
    // Save workout
    func saveWorkout(for exercise: ExerciseItem, count: Int, timestamp: Date) async throws {
        let activityType = exercise.healthKitActivityType
        let duration = exercise.estimatedDuration(for: count)
        
        let workout = HKWorkout(
            activityType: activityType,
            start: timestamp,
            end: timestamp.addingTimeInterval(duration),
            duration: duration,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: [
                "ExerciseName": exercise.name,
                "RepCount": count
            ]
        )
        
        try await healthStore.save(workout)
    }
}
```

**3. Update ExerciseStore**:
```swift
func logExercise(item: ExerciseItem, count: Int) {
    let log = ExerciseLog(item: item, count: count)
    try? exerciseService.addLog(log, to: &logs)
    
    // Sync to HealthKit
    if UserDefaults.standard.bool(forKey: "healthKitEnabled") {
        Task {
            try? await HealthKitManager.shared.saveWorkout(
                for: item, 
                count: count, 
                timestamp: log.timestamp
            )
        }
    }
    
    // Trigger gamification...
}
```

### Activity Type Mapping

```swift
extension ExerciseItem {
    var healthKitActivityType: HKWorkoutActivityType {
        switch name.lowercased() {
        case "squats": return .functionalStrengthTraining
        case "pushups", "push-ups": return .functionalStrengthTraining
        case "plank": return .coreTraining
        case "jumping jacks": return .jumpRope
        case "lunges": return .functionalStrengthTraining
        case "wall sit": return .functionalStrengthTraining
        case "stretching": return .flexibility
        case "yoga": return .yoga
        case "walking": return .walking
        case "running": return .running
        default: return .other
        }
    }
    
    func estimatedDuration(for count: Int) -> TimeInterval {
        switch unitType {
        case .seconds: return TimeInterval(count)
        case .minutes: return TimeInterval(count * 60)
        case .reps: return TimeInterval(count * 2) // Estimate 2 seconds per rep
        }
    }
}
```

## User Experience

### Onboarding Integration
Add HealthKit permission request to UX24 onboarding flow:
- Screen after notification permission
- Clear explanation of benefits
- "Sync to Apple Health" toggle in settings

### Settings Toggle
```swift
Section {
    Toggle("Sync to Apple Health", isOn: $healthKitEnabled)
        .onChange(of: healthKitEnabled) { enabled in
            if enabled {
                Task {
                    try? await HealthKitManager.shared.requestAuthorization()
                }
            }
        }
} header: {
    Text("Health Integration")
} footer: {
    Text("Your exercises will appear in the Health app and count toward your Activity Rings.")
}
```

## Benefits

1. **User Trust**: Legitimate fitness apps integrate with Health
2. **Data Persistence**: Health app is Apple's official fitness data store
3. **Cross-App Visibility**: Users see all fitness data in one place
4. **Activity Rings**: Exercises contribute to closing rings
5. **Watch Integration**: Automatically syncs to Apple Watch Activity
6. **Third-Party Access**: Other apps can read StandFit's workout data

## Technical Requirements

- iOS 15.0+ (current minimum)
- HealthKit framework
- Privacy permissions in Info.plist
- Background delivery (optional, for reading health data)

## Testing

1. Enable HealthKit in test app
2. Log exercise in StandFit
3. Open Health app → Browse → Activity → Workouts
4. Verify workout appears with correct:
   - Exercise type
   - Duration
   - Timestamp
   - Metadata (exercise name, rep count)

## Related Issues

- **UX24**: Onboarding - Add HealthKit permission request
- **UX34**: Daily Goals - Could read Health app goals
- **UX18**: Widgets - Display Activity Ring progress

## Success Metrics

- 60%+ users enable HealthKit sync
- Zero HealthKit permission errors
- Workout data appears correctly in Health app
- User reviews mention Health integration positively

## Conclusion

**This is the #1 missing feature**. For a fitness app on iOS, HealthKit integration is expected, not optional. It's a 3-4 hour implementation that dramatically increases app legitimacy and user satisfaction.
