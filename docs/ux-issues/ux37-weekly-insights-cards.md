# UX37: Weekly Insights Cards - Swipeable Progress Highlights

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Redesign  
**Priority**: High  
**Complexity**: Medium (4-6 hours)

## Problem

StandFit has progress report **notifications** (scheduled via settings) but no **actionable view** to display insights. The existing `ProgressReportView` is chart-heavy and data-dense - not designed for quick, motivating weekly highlights.

**Current State:**
- ✅ Progress report notifications (daily/weekly) with stats
- ✅ "View Details" action button
- ❌ No destination view - notification action goes nowhere
- ❌ No weekly insights UI designed for engagement
- ❌ Existing progress view is analytical, not celebratory

**User Journey Gap:**
1. User receives "🎯 Weekly Progress Report" notification
2. Taps "View Details" 
3. **Nothing happens** (showProgressReport notification posted but no listener)
4. User frustrated - notification promised insights but didn't deliver

## Solution

Create a **Weekly Insights View** with horizontal swipeable cards that highlight:
- Simple, visual, celebratory insights
- One insight per card (not overwhelming)
- Comparison to previous week (gamification)
- Actionable next steps
- Beautiful, scroll-optimized design

**Design Philosophy:**
- **Simple > Complex**: One metric per card, large numbers, visual hierarchy
- **Celebratory > Analytical**: Emoji badges, positive framing, milestone recognition
- **Actionable > Passive**: "Try this exercise", "Almost there!", clear CTAs
- **Weekly > Daily**: Focus on week-over-week trends (less noisy than daily)

## Implementation

### Data Models (Already Exist! ✅)

Leverage existing infrastructure:
```swift
// From ReportingModels.swift
public struct ReportStats {
    public let totalCount: Int
    public let periodStart: Date
    public let periodEnd: Date
    public let breakdown: [ExerciseBreakdown]
    public let comparisonToPrevious: Double?  // ✅ Week-over-week comparison
    public let streak: Int?                    // ✅ Current streak
}

public struct ExerciseBreakdown {
    public let exercise: ExerciseItem
    public let count: Int
    public let percentage: Double  // ✅ Relative proportion
}

// From ExerciseModels.swift
public struct ExerciseLog {
    public let id: UUID
    public let timestamp: Date      // ✅ For day-of-week analysis
    public let count: Int
}

// From GamificationModels.swift
public struct Achievement {
    public let tier: AchievementTier
    public var progress: Int        // ✅ Near-completion tracking
    public var isUnlocked: Bool
}
```

**No new models needed!** All data already available through ExerciseStore and GamificationStore.

### Insight Card Types

**6 Simple, High-Value Insights:**

#### 1. **Total Activity Card**
```
┌────────────────────────────┐
│                            │
│         🎯 143             │
│    exercises this week     │
│                            │
│      ↗ +27% vs last week  │
│                            │
└────────────────────────────┘
```
**Data Source:** `stats.totalCount`, `stats.comparisonToPrevious`

#### 2. **Top Exercise Card**
```
┌────────────────────────────┐
│                            │
│      🏆 Squats             │
│      your top exercise     │
│                            │
│        45 times            │
│     32% of all activity    │
│                            │
└────────────────────────────┘
```
**Data Source:** `stats.breakdown.max(by: \.count)`

#### 3. **Consistency Card**
```
┌────────────────────────────┐
│                            │
│      🔥 5 days             │
│    active this week        │
│                            │
│   M  T  W  T  F  S  S      │
│   ✅ ✅ ✅ ❌ ✅ ✅ ❌     │
│                            │
│   Try for 6 days next week │
│                            │
└────────────────────────────┘
```
**Data Source:** Count unique days with logs in `ReportPeriod.weekStarting`

#### 4. **Streak Status Card**
```
┌────────────────────────────┐
│                            │
│      🚀 12 day             │
│      streak                │
│                            │
│   Don't break it tomorrow! │
│                            │
└────────────────────────────┘
```
**Data Source:** `stats.streak` or `gamificationStore.streak.currentStreak`

#### 5. **New Achievement Card** (if unlocked this week)
```
┌────────────────────────────┐
│                            │
│      🏅 NEW!               │
│   Century Club             │
│                            │
│  100+ exercises completed  │
│                            │
│    Unlocked 2 days ago     │
│                            │
└────────────────────────────┘
```
**Data Source:** Filter `achievements` where `unlockedAt` is in current week

#### 6. **Next Milestone Card**
```
┌────────────────────────────┐
│                            │
│      🎯 Almost There!      │
│   Consistency Champ        │
│                            │
│      ████████░░ 84%        │
│                            │
│   21/25 days active        │
│                            │
└────────────────────────────┘
```
**Data Source:** Find achievement with highest `progressPercent` where `!isUnlocked`

### Weekly Insights View

```swift
import SwiftUI
import StandFitCore

struct WeeklyInsightsView: View {
    @ObservedObject var store: ExerciseStore
    @ObservedObject var gamificationStore: GamificationStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    
    private var weekStats: ReportStats? {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let period = ReportPeriod.weekStarting(weekStart)
        return store.reportingService.getStats(
            for: period,
            logs: store.logs,
            customExercises: store.customExercises,
            currentStreak: gamificationStore.streak.currentStreak
        )
    }
    
    private var insightCards: [InsightCard] {
        guard let stats = weekStats else { return [] }
        
        var cards: [InsightCard] = []
        
        // 1. Total Activity (always show)
        cards.append(.totalActivity(count: stats.totalCount, comparison: stats.comparisonToPrevious))
        
        // 2. Top Exercise (if any activity)
        if let topExercise = stats.breakdown.max(by: { $0.count < $1.count }) {
            cards.append(.topExercise(exercise: topExercise))
        }
        
        // 3. Consistency (active days this week)
        let activeDays = calculateActiveDays(period: ReportPeriod.weekStarting(stats.periodStart))
        cards.append(.consistency(activeDays: activeDays))
        
        // 4. Streak (if active)
        if let streak = stats.streak, streak > 0 {
            cards.append(.streak(days: streak))
        }
        
        // 5. New Achievement (if unlocked this week)
        if let newAchievement = findRecentAchievement() {
            cards.append(.newAchievement(achievement: newAchievement))
        }
        
        // 6. Next Milestone (closest to completion)
        if let nextMilestone = findNearestMilestone() {
            cards.append(.nextMilestone(achievement: nextMilestone))
        }
        
        return cards
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Weekly Insights")
                        .font(.title2)
                        .bold()
                    
                    if let stats = weekStats {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM d"
                        let startStr = formatter.string(from: stats.periodStart)
                        let endStr = formatter.string(from: stats.periodEnd.addingTimeInterval(-1))
                        
                        Text("\\(startStr) – \\(endStr)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)
                
                // Swipeable cards
                TabView(selection: $currentPage) {
                    ForEach(Array(insightCards.enumerated()), id: \\.offset) { index, card in
                        InsightCardView(card: card)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Page indicator text
                Text("\\(currentPage + 1) of \\(insightCards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateActiveDays(period: ReportPeriod) -> [Bool] {
        let calendar = Calendar.current
        var activeDays: [Bool] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: period.startDate) else {
                activeDays.append(false)
                continue
            }
            
            let hasActivity = store.logs.contains { log in
                calendar.isDate(log.timestamp, inSameDayAs: date)
            }
            activeDays.append(hasActivity)
        }
        
        return activeDays
    }
    
    private func findRecentAchievement() -> Achievement? {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return gamificationStore.achievements.first { achievement in
            if let unlockedAt = achievement.unlockedAt {
                return unlockedAt >= weekAgo
            }
            return false
        }
    }
    
    private func findNearestMilestone() -> Achievement? {
        gamificationStore.achievements
            .filter { !$0.isUnlocked && $0.progressPercent > 0.5 }  // At least 50% progress
            .max(by: { $0.progressPercent < $1.progressPercent })
    }
}

// MARK: - Insight Card Model

enum InsightCard {
    case totalActivity(count: Int, comparison: Double?)
    case topExercise(exercise: ExerciseBreakdown)
    case consistency(activeDays: [Bool])
    case streak(days: Int)
    case newAchievement(achievement: Achievement)
    case nextMilestone(achievement: Achievement)
}

// MARK: - Insight Card View

struct InsightCardView: View {
    let card: InsightCard
    
    var body: some View {
        VStack(spacing: 20) {
            switch card {
            case .totalActivity(let count, let comparison):
                totalActivityCard(count: count, comparison: comparison)
                
            case .topExercise(let exercise):
                topExerciseCard(exercise: exercise)
                
            case .consistency(let activeDays):
                consistencyCard(activeDays: activeDays)
                
            case .streak(let days):
                streakCard(days: days)
                
            case .newAchievement(let achievement):
                newAchievementCard(achievement: achievement)
                
            case .nextMilestone(let achievement):
                nextMilestoneCard(achievement: achievement)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
    
    // MARK: - Card Layouts
    
    @ViewBuilder
    private func totalActivityCard(count: Int, comparison: Double?) -> some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("\\(count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("exercises this week")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            if let comparison = comparison, comparison != 0 {
                let change = comparison * 100
                let isPositive = comparison > 0
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.0f%% vs last week", abs(change)))
                }
                .font(.headline)
                .foregroundStyle(isPositive ? .green : .orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isPositive ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                )
            }
        }
    }
    
    @ViewBuilder
    private func topExerciseCard(exercise: ExerciseBreakdown) -> some View {
        VStack(spacing: 16) {
            Text("🏆")
                .font(.system(size: 60))
            
            Text(exercise.exercise.name)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text("your top exercise")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 4) {
                Text("\\(exercise.count) times")
                    .font(.title2)
                    .bold()
                
                Text(String(format: "%.0f%% of all activity", exercise.percentage * 100))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private func consistencyCard(activeDays: [Bool]) -> some View {
        let activeCount = activeDays.filter { $0 }.count
        
        VStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 60))
            
            Text("\\(activeCount) days")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text("active this week")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // Weekly grid
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Text(dayLabel(index))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .fill(activeDays[index] ? Color.green : Color.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: activeDays[index] ? "checkmark" : "")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            )
                    }
                }
            }
            .padding(.top, 8)
            
            if activeCount < 6 {
                Text("Try for \\(activeCount + 1) days next week!")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
            }
        }
    }
    
    @ViewBuilder
    private func streakCard(days: Int) -> some View {
        VStack(spacing: 16) {
            Text("🚀")
                .font(.system(size: 60))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\\(days)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("day")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Text("streak")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical, 8)
            
            Text(days < 3 ? "Keep it going!" : days < 7 ? "You're on fire!" : "Incredible dedication!")
                .font(.headline)
                .foregroundStyle(.orange)
        }
    }
    
    @ViewBuilder
    private func newAchievementCard(achievement: Achievement) -> some View {
        VStack(spacing: 16) {
            Text("🏅")
                .font(.system(size: 60))
            
            Text("NEW!")
                .font(.caption)
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.blue))
            
            Text(achievement.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let unlockedAt = achievement.unlockedAt {
                let daysAgo = Calendar.current.dateComponents([.day], from: unlockedAt, to: Date()).day ?? 0
                Text("Unlocked \\(daysAgo == 0 ? "today" : "\\(daysAgo) day\\(daysAgo == 1 ? "" : "s") ago")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func nextMilestoneCard(achievement: Achievement) -> some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("Almost There!")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text(achievement.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * achievement.progressPercent, height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(String(format: "%.0f%%", achievement.progressPercent * 100))
                    .font(.headline)
                
                Spacer()
                
                Text("\\(achievement.progress)/\\(achievement.targetValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func dayLabel(_ index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
}
```

### Integration Points

#### 1. **Connect Notification Action** (StandFitApp.swift)
```swift
// In willPresent or didReceive
case "VIEW_REPORT":
    notificationManager.playClickHaptic()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        NotificationCenter.default.post(
            name: .showWeeklyInsights,  // NEW
            object: nil
        )
    }
```

#### 2. **Add to ContentView** (ContentView.swift)
```swift
@State private var showingWeeklyInsights = false

// In .onAppear or .onReceive
.onReceive(NotificationCenter.default.publisher(for: .showWeeklyInsights)) { _ in
    showingWeeklyInsights = true
}
.sheet(isPresented: $showingWeeklyInsights) {
    WeeklyInsightsView(store: store, gamificationStore: gamificationStore)
}
```

#### 3. **Manual Access from Settings/Home**
```swift
NavigationLink {
    WeeklyInsightsView(store: store, gamificationStore: gamificationStore)
} label: {
    Label("Weekly Insights", systemImage: "chart.bar.doc.horizontal")
}
```

## Benefits

### User Experience
- ✅ **Motivating**: Celebratory design with emoji, positive framing
- ✅ **Digestible**: One insight per card, no cognitive overload
- ✅ **Actionable**: "Try for 6 days", "Almost there!" CTAs
- ✅ **Visual**: Large numbers, progress bars, day grids
- ✅ **Swipeable**: Native iOS TabView with page indicators

### Technical
- ✅ **Zero new data models**: Uses existing ReportStats, ExerciseLog, Achievement
- ✅ **Reuses infrastructure**: ReportingService, GamificationStore
- ✅ **Completes notification loop**: View Details action finally works
- ✅ **4-6 hour implementation**: Simple SwiftUI, no complex state

### Engagement
- ✅ **Weekly cadence**: Less noisy than daily, more engaging than monthly
- ✅ **Gamification tie-in**: Shows achievements, streaks, milestones
- ✅ **Social sharing ready**: Beautiful cards = UX23 shareable content
- ✅ **Premium upsell**: "Unlock monthly insights" on last card

## Alternative: Simpler "Notification-Only" Approach

If full view is too complex, enhance notification content:

```swift
// Rich notification with insights
content.title = "🎯 143 exercises this week"
content.body = """
↗ +27% vs last week
🏆 Top: Squats (45 times)
🔥 5 days active
"""
```

But this lacks:
- ❌ Visual hierarchy
- ❌ Swipeable exploration
- ❌ Achievement integration
- ❌ Actionable next steps

**Verdict: Build the view** - notification is just the entry point.

## Related Issues

- **UX09**: Automatic Progress Report Notifications ✅ (notifications work, need view)
- **UX08**: Progress Reporting View ✅ (chart-focused, not insight-focused)
- **UX10**: Gamification System ✅ (achievements integrate into insights)
- **UX23**: Social Sharing ⏳ (beautiful cards are shareable content)
- **UX34**: Daily Goals ⏳ (goal progress = insight card)

## Future Enhancements (Out of Scope)

- AI-generated motivational messages
- Personalized exercise recommendations
- Friend comparisons (UX11)
- Monthly/yearly rollups
- Export insights as images

## Conclusion

**High-priority feature** that completes the progress reporting loop. Notification infrastructure exists but lacks destination. **4-6 hour implementation** using existing data models. Swipeable card design is modern, engaging, and mobile-optimized. Simple insights > complex charts for weekly check-ins.

**Action:** Implement `WeeklyInsightsView.swift` and wire up notification actions.
