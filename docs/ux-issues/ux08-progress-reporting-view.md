# UX8: Progress Reporting View (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-01

## Problem

Users have no way to compare their exercise progress across different time periods. The current HistoryView only shows a flat list of logs without aggregation or visualization.

## Solution Implemented

Created a dedicated `ProgressReportView` with interactive charts showing exercise data across day/week/month/year periods.

### Data Model Considerations

Current exercise types fall into two categories:

| Category | Exercises | Unit | Scoring |
|----------|-----------|------|---------|
| **Reps** | Squats, Pushups, Lunges | count | 1 point per rep |
| **Duration** | Plank | seconds | 1 point per second (or per 10 sec?) |

Need to decide on unified scoring:
- Option A: Raw totals (10 squats = 10, 30 sec plank = 30)
- Option B: Normalized scoring (e.g., 1 point per rep, 1 point per 10 seconds)
- Option C: Configurable multipliers per exercise type

### UI Design

**Period Selector:**
```swift
Picker("Period", selection: $selectedPeriod) {
    Text("Day").tag(Period.day)
    Text("Week").tag(Period.week)
    Text("Month").tag(Period.month)
    Text("Year").tag(Period.year)
}
.pickerStyle(.segmented)
```

**Stacked Bar Chart:**
```
Week View (Mon-Sun)
┌────────────────────────────────┐
│  ████                          │ Mon: 45 pts
│  ██████████                    │ Tue: 82 pts
│  ████████                      │ Wed: 67 pts
│  ███                           │ Thu: 23 pts
│  ██████████████                │ Fri: 120 pts
│  █████████                     │ Sat: 78 pts
│  ██████                        │ Sun: 52 pts
└────────────────────────────────┘
Legend: ■ Squats ■ Pushups ■ Lunges ■ Plank
```

Each bar is stacked by exercise type, colored differently, showing contribution to total.

**Summary Stats:**
- Total score for period
- Comparison to previous period (↑12% vs last week)
- Best day/week in period
- Exercise breakdown (pie chart or list)
- Streak tracking (consecutive active days)

### Swift Charts Implementation

```swift
import Charts

struct ProgressChartView: View {
    let data: [DailyProgress]

    var body: some View {
        Chart(data) { day in
            ForEach(day.exerciseBreakdown, id: \.type) { exercise in
                BarMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Score", exercise.score)
                )
                .foregroundStyle(by: .value("Exercise", exercise.type.rawValue))
            }
        }
        .chartForegroundStyleScale([
            "Squats": .blue,
            "Pushups": .green,
            "Lunges": .orange,
            "Plank": .purple
        ])
    }
}
```

### Data Structures

```swift
struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let exerciseBreakdown: [ExerciseScore]
    var totalScore: Int { exerciseBreakdown.reduce(0) { $0 + $1.score } }
}

struct ExerciseScore {
    let type: ExerciseType
    let count: Int
    let score: Int  // Normalized score
}

enum ReportPeriod: String, CaseIterable {
    case day, week, month, year
}
```

### Navigation

Access from:
1. HistoryView toolbar button (chart icon)
2. ContentView (new "Progress" section or toolbar item)

## Files to Create

- `ProgressReportView.swift` - Main reporting view with period picker and charts
- `ProgressChartView.swift` - Reusable chart component (or inline)

## Files to Modify

- `ExerciseStore.swift` - Add aggregation methods for reporting
- `HistoryView.swift` - Add navigation to ProgressReportView
- `ContentView.swift` - Optional: Add quick access to reports

## Dependencies

- Swift Charts framework (iOS 16+ / watchOS 9+)
