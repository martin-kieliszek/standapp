# UX28: Apple Watch Complications - Display Stats on Watch Face

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Watch Integration  
**Priority**: High  
**Complexity**: Medium (2-3 hours)

## Problem

StandFit has a Watch app but **no watch face complications**:
- Users cannot see streak count on watch face
- No quick glance at today's exercise count
- Missing always-visible motivation
- No fast app launch from complication tap
- Incomplete Watch app experience

**User Impact**: Watch apps without complications feel incomplete and are less discoverable.

## Solution

Implement Watch complications to display:
1. **Current Streak** - 🔥 5 days
2. **Today's Exercise Count** - 12 exercises
3. **Level/XP** - Level 8 (850 XP)
4. **Next Reminder** - "3:30 PM"

## Implementation

### 1. Create Complication Controller

```swift
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "streak",
                displayName: "Streak",
                supportedFamilies: [
                    .modularSmall,
                    .modularLarge,
                    .circularSmall,
                    .extraLarge,
                    .graphicCorner,
                    .graphicCircular,
                    .graphicRectangular
                ]
            ),
            CLKComplicationDescriptor(
                identifier: "todayCount",
                displayName: "Today's Exercises",
                supportedFamilies: [
                    .modularSmall,
                    .circularSmall,
                    .graphicCorner,
                    .graphicCircular
                ]
            )
        ]
        handler(descriptors)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let store = ExerciseStore.shared
        let gamification = GamificationStore.shared
        
        let entry: CLKComplicationTimelineEntry?
        
        switch complication.identifier {
        case "streak":
            entry = createStreakEntry(streak: gamification.currentStreak, date: Date())
        case "todayCount":
            entry = createTodayCountEntry(count: store.todaysLogs.count, date: Date())
        default:
            entry = nil
        }
        
        handler(entry)
    }
    
    // MARK: - Entry Creation
    
    private func createStreakEntry(streak: Int, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateGraphicCircularStackImage(
            line1ImageProvider: CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "flame.fill")!.withTintColor(.orange)
            ),
            line2TextProvider: CLKSimpleTextProvider(text: "\\(streak)")
        )
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createTodayCountEntry(count: Int, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularSmallStackText(
            line1TextProvider: CLKSimpleTextProvider(text: "\\(count)"),
            line2TextProvider: CLKSimpleTextProvider(text: "done")
        )
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
}
```

### 2. Support Multiple Watch Faces

Create templates for all complication families:

```swift
private func createTemplate(
    for family: CLKComplicationFamily,
    streak: Int
) -> CLKComplicationTemplate? {
    switch family {
    case .modularSmall:
        return CLKComplicationTemplateModularSmallStackText(
            line1TextProvider: CLKSimpleTextProvider(text: "🔥\\(streak)"),
            line2TextProvider: CLKSimpleTextProvider(text: "days")
        )
        
    case .circularSmall:
        return CLKComplicationTemplateCircularSmallStackText(
            line1TextProvider: CLKSimpleTextProvider(text: "🔥"),
            line2TextProvider: CLKSimpleTextProvider(text: "\\(streak)")
        )
        
    case .graphicCircular:
        return CLKComplicationTemplateGraphicCircularStackImage(
            line1ImageProvider: CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "flame.fill")!
            ),
            line2TextProvider: CLKSimpleTextProvider(text: "\\(streak)")
        )
        
    case .graphicRectangular:
        return CLKComplicationTemplateGraphicRectangularStandardBody(
            headerTextProvider: CLKSimpleTextProvider(text: "StandFit"),
            body1TextProvider: CLKSimpleTextProvider(text: "Streak: \\(streak) days"),
            body2TextProvider: CLKSimpleTextProvider(text: "Keep it up! 🔥")
        )
        
    default:
        return nil
    }
}
```

### 3. Refresh Complications

Update complications when data changes:

```swift
// In ExerciseStore
func logExercise(item: ExerciseItem, count: Int) {
    let log = ExerciseLog(item: item, count: count)
    try? exerciseService.addLog(log, to: &logs)
    
    // Refresh watch complications
    #if os(watchOS)
    let server = CLKComplicationServer.sharedInstance()
    for complication in server.activeComplications ?? [] {
        server.reloadTimeline(for: complication)
    }
    #endif
}
```

### 4. Background Updates

Schedule periodic updates:

```swift
func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
    // Refresh every 15 minutes
    handler(Date().addingTimeInterval(15 * 60))
}
```

## Complication Types

### 1. Streak Complication
- **Icon**: 🔥 Flame
- **Data**: Current streak count
- **Tap**: Opens app to Achievements tab

### 2. Today's Count Complication
- **Icon**: ✓ Checkmark
- **Data**: Exercises logged today
- **Tap**: Opens app to log exercise

### 3. Level Progress Complication
- **Icon**: ⭐ Star
- **Data**: Current level
- **Tap**: Opens app to Profile

### 4. Next Reminder Complication
- **Icon**: 🕐 Clock
- **Data**: Time until next reminder
- **Tap**: Opens app

## Visual Design

**Modular Small**:
```
┌─────┐
│ 🔥5 │
│ days│
└─────┘
```

**Circular Small**:
```
  ╭───╮
  │ 🔥 │
  │ 5  │
  ╰───╯
```

**Graphic Circular** (full color):
```
  ╭─────╮
  │  🔥  │
  │  ║   │
  │  5   │
  ╰─────╯
```

## User Experience

### Complication Picker
Watch face editor shows:
- "StandFit - Streak"
- "StandFit - Today's Count"
- "StandFit - Level"
- Preview of each

### Tinted Mode
Support watch face tint colors:
- Use template images
- Dynamic color based on watch face

### Privacy
Complications respect privacy settings:
- "Privacy: Hide sensitive complications on always-on display"
- Redact data when wrist down

## Technical Requirements

- watchOS 9.0+
- ClockKit framework
- Complication descriptors
- Timeline provider
- Background refresh

## Testing

1. Add StandFit complication to watch face
2. Log exercise on phone/watch
3. Verify complication updates within 1 minute
4. Tap complication → app launches
5. Test on multiple watch face styles

## Benefits

1. **Always Visible**: Motivation on every wrist raise
2. **Quick Access**: Tap to launch app instantly
3. **Status at a Glance**: See progress without opening app
4. **Legitimacy**: Completes Watch app experience
5. **Discoverability**: Users find app in complication picker

## Related Issues

- **UX10**: Gamification - Display streak/level
- **UX18**: Widgets - Similar concept for iOS
- **UX34**: Daily Goals - Could show goal progress

## Success Metrics

- 40%+ Watch users add complication
- Complication tap-through rate
- Increased Watch app usage
- Positive reviews mentioning complications

## Conclusion

For an app with a Watch app, complications are **essential**. They provide always-on visibility, quick access, and motivation. This is a **2-3 hour implementation** that significantly enhances the Watch experience and makes the app feel complete.
