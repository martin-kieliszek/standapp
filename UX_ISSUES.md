# StandFit UX Issues Tracker

## Priority Tasks Queue

| ID | Issue | Status | Completion Date |
|----|-------|--------|-----------------|
| UX1 | Silent interval/settings changes - no user feedback when notifications reschedule | ✅ Complete | 2026-01-01 |
| UX2 | Missed notifications lost forever - need "dead response reset" with configurable timeout | ✅ Complete | 2026-01-01 |
| UX3 | Hardcoded exercises - users cannot add custom exercises or choose icons | ✅ Complete | 2026-01-01 |
| UX4 | Additional UX polish items (see below) | ⏳ Pending | — |
| UX5 | "Log Exercise" notification lands on main view instead of exercise picker | ✅ Complete | 2026-01-01 |
| UX6 | "Reset Timer" button doesn't indicate what interval it will reset to | ✅ Complete | 2026-01-02 |
| UX7 | No warning when Focus Mode may block notifications | ⏳ Pending | — |
| UX8 | No progress comparison view (day/week/month/year reporting) | ✅ Complete | 2026-01-01 |
| UX9 | No automatic progress report notifications | ✅ Complete | 2026-01-01 |
| UX10 | No gamification (streaks, achievements, milestones) | ✅ Complete | 2026-01-02 |
| UX11 | No social features (friends, sharing, leaderboards) | ⏳ Pending | — |
| UX12 | Snooze +5min button resets schedule instead of legitimate snooze | ⏳ Pending | — |
| UX13 | Progress Report crashes when selecting Week or Month period | ✅ Complete | 2026-01-02 |
| UX14 | Notification vs. Exercise Timeline visualization | ✅ Complete | 2026-01-02 |
| UX15 | Monetization Strategy (analysis) | 📋 Strategy Phase | — |
| UX16 | User-created achievement templates for custom exercises | ⏳ Pending | — |
| UX17 | Multi-platform deployment strategy (iOS/WatchOS) | 📋 Strategy Phase | — |

---

## UX15: Monetization Strategy & Revenue Model (Analysis)

### Executive Summary

StandFit has strong potential to monetize through a **freemium subscription model** targeting office workers and fitness-conscious users. Recommended approach: **14-day free trial with App Store Subscription (StandFit Premium)** offering advanced analytics, social features, and personalization. This balances user acquisition (generous trial) with sustainable revenue ($3.99-4.99/month or $29.99/year).

---

## Market Context & Research

**Comparable Apps & Their Models:**

| App | Sector | Model | Conversion Rate | Pricing |
|-----|--------|-------|-----------------|---------|
| Strong | Habit Tracking | Freemium Subscription | 2-5% | $4.99/mo, $39.99/yr |
| Habitica | Gamified Habits | Freemium + In-App | 8-12% | $4.99/mo, $40/yr |
| Strava | Fitness Social | Freemium Subscription | 3-7% | $4.99/mo, $59.99/yr |
| Fitbit | Activity Tracking | Freemium + Device Sales | 5-15% | $9.99/mo, $79.99/yr |
| Apple Fitness+ | Premium Fitness | Pure Subscription | 40%+ | $9.99/mo (ecosystem lock-in) |

**Key Insights:**
- Fitness subscription market growing 15-25% annually
- Health/wellness apps show 40-60% higher retention than casual apps
- Social features drive 3-5x higher engagement
- Gamification increases willingness to pay by 2-3x
- Habit tracking users show 35-45% 30-day retention (much higher than casual apps)
- Freemium apps that offer 7-14 day trials see 25-35% trial-to-paid conversion
- Time-gated free trial converts better than feature-gated (users experience full value)

---

## Recommended Strategy: Tiered Freemium + Subscription

### Tier 1: StandFit Free (Forever Free)

**Core Features (Always Free):**
- Exercise reminders & notifications
- Basic exercise logging (built-in exercises only)
- Daily/weekly progress view
- Personal streak tracking (current day only)
- Basic statistics (today's count, total lifetime)

**Limitations:**
- Max 2 custom exercises (vs. unlimited in Premium)
- No historical streak data (only current)
- No social features
- No advanced analytics
- Limited to 7-day history in charts

**Why This Works:**
- Users can verify the app solves their core problem (standing up, exercising)
- Habits take 14-21 days to form, so 7-day free access is too limiting
- Core value prop (reminders + logging) is free

### Tier 2: StandFit Premium (Subscription)

**Free Trial:** 14 days (iOS App Store subscription requirement)

**Pricing Options** (recommend Option A):
- **Option A (Recommended):** $3.99/month or $29.99/year (2.5 mo equivalent)
- **Option B (Aggressive):** $2.99/month or $19.99/year
- **Option C (Premium):** $4.99/month or $39.99/year

**Premium Features:**

| Feature Category | Details | Unlock Value |
|---|---|---|
| **Custom Exercises** | Unlimited custom exercises + icon picker | Personalization |
| **Advanced Analytics** | 30/60/90-day summaries, trend analysis | Long-term insights |
| **Achievements** | Full achievement system (streaks, challenges, badges) | Gamification/Motivation |
| **Timeline Graph** | Daily notification vs. exercise timeline (UX14) | Response pattern insights |
| **Social Features** | Share achievements, friend activity feed, leaderboards | Accountability |
| **Insights & Trends** | Peak response times, optimal notification times | Behavior optimization |
| **Export Data** | Download activity data (CSV/PDF) | Data ownership |
| **Siri Shortcuts** | Advanced automation for exercise logging | Power user features |
| **Backup & Sync** | iCloud backup across devices | Data security |
| **Ad-Free** | Remove any future ads | Cleaner experience |

**Why Premium Conversion Happens:**
1. User forms habit over 2-week trial (habit formation)
2. Sees their streak/progress data (sunk cost fallacy)
3. Wants to unlock achievements (gamification engagement)
4. Discovers friends/leaderboards (social pressure)
5. Realizes $4/month << gym membership

---

## Revenue Projections

**Assumptions:**
- 10,000 downloads in Year 1 (conservative for watchOS app)
- 30% trial activation rate
- 20% trial-to-paid conversion (2,000 Premium users)
- 15% annual churn
- Pricing: $3.99/month ($47.88/year blended)

**Year 1 Projections:**
- Total Revenue: $95,760
- Monthly Recurring: $7,980 (Month 12)
- Cost of goods (Apple cut): ~30% = $28,728
- Net Revenue: $67,032

**Year 2 Projections** (with word-of-mouth growth):
- 50,000 cumulative downloads (5x growth)
- 6,000 Premium users (30% growth from year 1 + new conversions)
- Total Revenue: $287,280
- Net Revenue: $200,896

**Year 3+:** Potential 8-12% annual growth in fitness app category

---

## Freemium vs. Other Models: Comparative Analysis

### Option A: Freemium Subscription (Recommended) ✅

**Pros:**
- Sustainable recurring revenue
- Industry standard for fitness apps
- Low friction for user acquisition
- Trial period builds habit before paywall
- Aligns with Apple subscription guidelines
- Premium features scale with zero marginal cost
- Easy to add features over time

**Cons:**
- Requires continuous development (feature updates expected)
- User acquisition costly (need ongoing marketing)
- Churn risk if features aren't compelling

**Implementation:**
```
Day 1-14: Full Premium access (trial)
Day 15+: Paywall if not subscribed
```

---

### Option B: Time-Gated Freemium (Alternative)

**Concept:** 14 days unlimited, then app is "locked" but functional at lower tier

**Pros:**
- Familiar to users (common pattern)
- Clear upgrade incentive

**Cons:**
- Creates friction/frustration
- Lower long-term retention than feature-gated
- Users abandon if price surprise occurs
- Feels more aggressive than feature limiting

---

### Option C: Feature-Gated Freemium (Alternative)

**Concept:** All features available, but premium adds advanced tiers

**Pros:**
- No time pressure, users convert when ready
- Better for casual users
- Feels less aggressive

**Cons:**
- Lower conversion rate (users procrastinate)
- Requires compelling premium features
- Harder to justify pricing without artificial limits

---

### Option D: One-Time Purchase (Not Recommended)

**Pricing:** $9.99-14.99 upfront

**Why Not:**
- Extremely hard to market ($10-15 upfront barrier)
- Cannot iterate—locked in at launch quality
- Fitness apps benefit from ongoing updates
- No recurring revenue stream
- Risk: bad reviews → death spiral

---

### Option E: Ad-Supported Free (Not Recommended)

**Why Not:**
- Fitness app audiences hate ads
- Revenue per user extremely low ($0.50-2/year)
- Damages premium positioning
- Ad networks avoid "health" category (liability)

---

### Option F: Hybrid Subscription + One-Time Unlock (Possible)

**Concept:** $3.99/month subscription OR $39.99 lifetime unlock

**Pros:**
- Appeals to users resistant to subscriptions
- Can convert procrastinators

**Cons:**
- Splits user base/analytics
- Complicates pricing psychology
- Cannibalizes subscription revenue
- Recommend only if subscription conversion <10%

---

## Pricing Psychology & Conversion Strategy

### The 14-Day Trial Effect

**Why 14 days beats 7:**
- Habit formation requires 18-66 days (average 66 days per research)
- But 14 days is enough to:
  - Establish reminder routine (3-5 days)
  - See first streak progress (7 days)
  - Form basic habit loop (14 days)
  - Develop FOMO before paywall (sunk cost fallacy)

**Conversion Timeline:**
```
Days 1-3:   "Cool app, let me try it"
Days 4-7:   "This is helping me stand up"
Days 8-10:  "I'm on a 7-day streak now"
Days 11-13: "Don't want to lose my streak..." (escalating attachment)
Day 14:     "Do I really want to pay?" (Price sensitivity peaks)
Day 15:     If paywall reached without warning → 60% bounce rate
```

**Mitigation:**
- Day 10: Push notification: "You're doing great! 4 days left of premium access"
- Day 13: In-app banner: "Your 7-day streak is saved with Premium"
- Day 15: Soft paywall with pricing shown, NOT a hard block

---

## Paywall Strategy: Soft vs. Hard

### Recommended: Soft Paywall (Conversion-Optimized)

```
Day 15 when user taps a premium feature:

┌─────────────────────────────────┐
│  🔒 Premium Feature             │
├─────────────────────────────────┤
│                                 │
│ "See your peak response times"  │
│                                 │
│ This feature is part of Premium │
│                                 │
│ [Try Premium →] [Not Now]       │
├─────────────────────────────────┤
```

**Why This Converts Better:**
- User already trying to access feature (high intent)
- Not disruptive if they're in free tier
- Shows immediate value of Premium
- "Not Now" option prevents friction
- Typical conversion rate: 8-15% of premium feature taps

### Alternative: Hard Paywall (Not Recommended)

```
Day 15 when user taps ANY premium feature:
- App navigates to pricing screen
- Blocks feature access entirely
- High friction, low conversion (3-5%)
```

---

## Onboarding Messaging Strategy

### Trial Phase Messaging (Days 1-14)

**Day 1: Welcome**
```
"Welcome to StandFit Premium (free for 14 days)

Reminders to stand up
Track your progress  
Unlock achievements  
Share with friends  

Enjoy full access for 14 days. No credit card required."
```
*Doesn't emphasize paywall, just highlights benefits*

**Day 10: Mid-Trial Engagement**
```
"Your 7-day streak is safe with Premium! 
Just 4 days left of free access.
Subscribe to keep all features and your progress."
```
*Emphasizes sunk cost (streak they've built)*

**Day 14: Final Day**
```
"Your Premium trial ends tomorrow!
You're on a 7-day streak. Don't break it.
Premium: $3.99/month | See pricing →"
```

### Post-Trial Messaging (Day 15+)

**Non-Intrusive Prompts:**
- Bottom of settings: "Upgrade to Premium" link
- Achievement notifications: "Premium: Unlock all achievements"
- Social feature access: "Want to share? Try Premium free for 7 days"

**No Nagging:**
- Max 2 soft paywalls per session
- Never pop-up on app launch
- Never interrupt streak/data viewing

---

## Monetization Roadmap by Phase

### Phase 1: Launch (Today)
- ✅ StandFit Free (all core features)
- ✅ 14-day free trial of Premium
- ✅ Basic soft paywall (feature-gated)
- Pricing: $3.99/month, $29.99/year
- Target: 20% trial conversion

### Phase 2: Social Features (Q2 2026)
- Add: Achievement system, friend activity, leaderboards
- These become **premium-only** features
- Expected: Conversion increases to 25-30%

### Phase 3: Advanced Analytics (Q3 2026)
- Add: Timeline graph (UX14), response time insights, trend analysis
- These become **premium-only** features  
- Expected: Conversion increases to 30-35% (analytics drives engagement)

### Phase 4: Ecosystem Expansion (Q4 2026+)
- iPad version (same subscription)
- Mac companion app (linked to iOS subscription)
- Web dashboard (analytics view)
- Siri Shortcuts integration
- HealthKit integration (step data, workouts)
- Expected: Multi-device users have 2-3x higher LTV

---

## Compliance & Best Practices

### Apple App Store Requirements

**Subscription Setup:**
- ✅ Clear trial terms in app + in-app messaging
- ✅ Easy subscription management (Settings → Subscriptions)
- ✅ No "hidden" features; all features listed as free or premium
- ✅ Free trial must have full feature access
- ✅ Clear cancellation path (must be as easy as signup)
- ✅ No feature restrictions during trial (except cosmetic)

**Marketing Compliance:**
- ✅ Privacy policy mentions analytics (if tracking conversion funnels)
- ✅ No misleading "Free" claims (must say "Free trial")
- ✅ No pressure/scare tactics in paywall copy

### Revenue Recognition (Finance)
- Subscription revenue recognized monthly (IFRS 15)
- Apple takes 30% cut (standard)
- Track: CAC (customer acquisition cost), LTV (lifetime value), churn rate

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Low trial→paid conversion | $0 revenue | Focus on habit formation (14-day trial is critical) |
| High churn (>3% monthly) | Declining revenue | Monthly feature updates, community engagement |
| User backlash on paywall | Negative reviews | Soft paywall only, generous trial, no dark patterns |
| Apple policy change | Subscription blocked | Maintain free tier as sustainable product |
| Competition enters market | Revenue loss | First-mover advantage, strong social feature moat |
| Feature complexity for free tier | Maintenance burden | Keep free tier simple, don't over-engineer limitations |

---

## Recommended Rollout: Implementation Plan

### Week 1: Paywall Setup
- [ ] Add `isPremium` flag to ExerciseStore
- [ ] Add StoreKit2 subscription configuration
- [ ] Create soft paywall UI component
- [ ] Tag premium features (achievements, timeline, social, export)
- [ ] Configure Apple App Store subscription

### Week 2: Trial & Messaging
- [ ] Add trial expiry date tracking (UserDefaults or CoreData)
- [ ] Add local notifications (Day 10, Day 14)
- [ ] Implement paywall dismissal logic
- [ ] Create onboarding messaging

### Week 3: Testing & Deployment
- [ ] TestFlight trial of subscription
- [ ] A/B test paywall copy (3 variants)
- [ ] Monitor Day 1, Day 7, Day 14 retention
- [ ] Monitor conversion funnel (trial activation → payment)

### Week 4: Launch
- [ ] Submit to App Store as "Free" (with IAP subscription)
- [ ] Monitor first 100 installs for funnel drops
- [ ] Iterate on messaging based on early data

---

## Success Metrics to Track

**Acquisition Funnel:**
- Download rate
- Trial activation rate (target: >30%)
- Trial completion rate (target: >60% reach Day 14)

**Monetization Funnel:**
- Trial-to-paid conversion (target: 20-30%)
- Time-to-first-payment (target: 5-12 days)
- Premium feature adoption rate (target: >70% of subscribers use premium features)

**Retention & Engagement:**
- 30-day retention: Free users (target: 35%), Premium users (target: 60%)
- Churn rate (target: <3% monthly)
- Subscription reactivation rate (lapsed users) (target: 5-10%)

**Revenue Metrics:**
- MRR (Monthly Recurring Revenue)
- ARPU (Average Revenue Per User)
- LTV (Lifetime Value)
- CAC (Customer Acquisition Cost)
- LTV:CAC ratio (target: >3:1)

---

## Recommended Pricing: Final Analysis

### Best Option for StandFit: $3.99/month | $29.99/year

**Why:**
- **Accessibility:** Office workers see $4/month as impulse purchase (less than 1 coffee)
- **Conversion:** Lower price → 25-30% trial conversion (vs. 15-20% at $4.99)
- **Comparison:** Slightly cheaper than Strava ($4.99) but more features than Habitica ($4.99)
- **Annual Option:** $29.99/year = $2.50/month equivalent (37% discount drives annual subs)
- **Psychology:** $29.99 < $30 feels significantly cheaper than $30-39 range

**Annual vs. Monthly Mix Expected:**
- 40% choose annual (higher LTV users)
- 60% choose monthly (higher churn risk)
- Blended ARPU: ~$3.80/month

**Example Year 1 Revenue (Conservative):**
- 2,000 paying users (20% of 10K downloads)
- Mix: 800 annual @ $29.99, 1,200 monthly @ $3.99
- Year 1 Revenue: (800 × $29.99) + (1,200 × $3.99 × 12) = $24K + $58K = **$82,080**
- Apple cut (30%): $24,624
- **Net: $57,456** (sustainable, supports 1 part-time developer)

---

## Alternative: Premium Tier (Stretch Goal)

If Premium conversion reaches >30% and retention is high (>55% 30-day):

**Consider StandFit Premium+:**
- Price: $9.99/month or $79.99/year
- Features: Everything in Premium PLUS:
  - Weekly email digest with insights
  - Personal coaching tips based on your patterns
  - API access for advanced integrations
  - White-label reports (for corporate wellness programs)
- Target: 5-10% of Premium users upgrade

This creates a revenue uplift but requires much more infrastructure.

---

## Final Recommendation Summary

✅ **Launch with:** Freemium subscription ($3.99/month or $29.99/year)
✅ **Trial length:** 14 days (full premium access, no credit card required)
✅ **Paywall style:** Soft paywall (feature-gated, not time-gated)
✅ **Premium tiers:** Single tier (Premium), no Premium+ initially
✅ **Success target:** 20% trial-to-paid conversion = $57K Year 1 revenue
✅ **Growth strategy:** Monthly feature updates, social features, analytics drive upgrade decisions

This model balances user acquisition (generous trial), sustainable revenue (clear value prop), and market fit (proven in fitness category).

---

## UX14: Notification vs. Exercise Timeline Graph (Analysis)

**Problem Statement:**
Users have no visibility into whether they're responding to notifications promptly or delaying exercise logging. There's no correlation visualization between when notifications fire and when exercises are actually logged. This makes it hard to identify patterns like:
- Do users respond immediately to notifications?
- Is there a typical delay between notification and logging?
- Which times of day have the most responsive user behavior?
- Are certain notifications being consistently missed?

**Proposed Solution:**
A timeline visualization on the Today period showing two data series:
1. **Notification Dots** - Plot points showing when exercise reminder notifications fired
2. **Exercise Log Crosses** - Plot points showing when exercises were actually logged

**Visual Design Concept:**

```
Today Timeline - 24 Hour View
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      N = Notification fired (dot marker)
      X = Exercise logged (cross marker)

Notification Series ●●●●●●●
Exercise Series     ✕✕✕ ✕ ✕✕

9am        12pm       3pm        6pm        9pm
|----------|----------|----------|----------|
●        ✕ ●       ✕  ●          ✕   ●  ✕  ●

Legend: ● Notification  ✕ Exercise Logged
```

**Key Design Challenges & Solutions:**

| Challenge | Consideration | Proposed Solution |
|-----------|---|---|
| **Y-Axis Unit** | Two series need different vertical positions to be distinguishable | Use categorical Y-axis: top row = Notifications, bottom row = Exercises |
| **Time Resolution** | Notifications fire at scheduled intervals; exercises log at specific seconds | Group by minute (show multiple logs/notifications in same minute as stacked or overlapping) |
| **Time Range** | 24-hour view is wide; detail gets lost on watchOS screen | Option 1: Show last 12 hours. Option 2: Scrollable horizontal timeline |
| **Missing Notifications** | How to show notifications that fired but had no subsequent logs? | Mark notification dots differently (e.g., hollow vs. filled) if no log within 5-min window |
| **Multiple Logs** | What if user logs multiple exercises between notification times? | Each log gets its own marker; can stack vertically in same time slot |
| **No Logs Yet** | Today still in progress; some scheduled notifications haven't fired yet | Only show past notifications and logs |

**Data Structure Requirements:**

```swift
struct TimelineEvent: Identifiable {
    let id: UUID
    let timestamp: Date
    let type: TimelineEventType
    let metadata: TimelineEventMetadata
}

enum TimelineEventType {
    case notificationFired(exerciseType: ExerciseType)
    case exerciseLogged(exerciseItem: ExerciseItem, count: Int)
}

struct TimelineEventMetadata {
    let minuteOfDay: Int  // 0-1440 (for grouping)
    let secondOfMinute: Int  // for display precision
    let respondedWithinMinutes: Int?  // if notification → time until first log
}

// Helper to determine if notification was "answered"
func notificationAnswered(notification: TimelineEvent, 
                          withinMinutes: Int = 5) -> TimelineEvent? {
    guard notification.type case .notificationFired = notification.type else { return nil }
    // Find first exercise log within withinMinutes of notification
    return todaysEvents
        .filter { $0.type case .exerciseLogged = $0.type }
        .first { log in
            let timeElapsed = log.timestamp.timeIntervalSince(notification.timestamp)
            return timeElapsed > 0 && timeElapsed <= TimeInterval(withinMinutes * 60)
        }
}
```

**Implementation Phases:**

### Phase 1: Data Collection (Current State)
- Notifications are already logged via `willPresent` delegate
- Exercise logs already recorded with timestamp
- **Action needed**: Create helper methods to query today's notifications and logs by time

### Phase 2: UI Component (Proposed)
New file: `TimelineGraphView.swift`
- SwiftUI with custom Canvas or Charts framework
- Two parallel tracks (Notification row, Exercise row)
- Time axis (9 AM - 9 PM recommended for watch, or scrollable 24h)
- Interactive: tap dot to see notification details, tap cross to see exercise details

```swift
struct TimelineGraphView: View {
    let notifications: [TimelineEvent]
    let exercises: [TimelineEvent]
    @State var selectedEvent: TimelineEvent?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Today's Timeline")
                .font(.headline)
            
            // Time axis
            HStack(spacing: 2) {
                ForEach(timeMarkers, id: \.self) { time in
                    Text(time)
                        .font(.caption2)
                }
            }
            
            // Notification track
            NotificationTrack(events: notifications, selectedEvent: $selectedEvent)
            
            // Exercise track
            ExerciseTrack(events: exercises, selectedEvent: $selectedEvent)
            
            // Legend
            HStack(spacing: 12) {
                Label("Notification", systemImage: "bell.fill")
                Label("Exercised", systemImage: "checkmark.circle.fill")
            }
            .font(.caption)
        }
    }
}
```

### Phase 3: Integration
- Add to `ProgressReportView` when `.today` period selected
- Position above current "Stats Header" or below "Period Range"
- Hide on Week/Month periods (data would be too dense)

### Phase 4: Advanced Features (Future)
- **Response Time Visualization**: Draw connecting lines between notification → exercise log, color-coded by delay (green <2min, yellow <5min, red >5min)
- **Heat Map**: Show busiest exercise times (density of marks indicates concentration)
- **Notification Effectiveness**: Metric showing % of notifications that resulted in logs within 5 minutes
- **Smart Grouping**: Collapse multiple notifications of same exercise type into single marker with count badge

**Data Query Strategy:**

```swift
// Extend ReportingService
extension ReportingService {
    func getTodaysTimeline() -> (notifications: [TimelineEvent], exercises: [TimelineEvent]) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // Query notifications sent today
        // Note: Requires adding timestamp tracking to notification firing
        // Current limitation: We don't persist notification fire events
        // SOLUTION: Add optional field to ExerciseLog to mark if it followed a notification
        
        // For now, can infer:
        // - If log timestamp within X minutes of expected schedule, likely responded to notification
        
        let notifications = inferTodaysNotifications()
        let exercises = store.logs.filter { 
            $0.timestamp >= today && $0.timestamp < tomorrow 
        }
        
        return (notifications, exercises)
    }
    
    private func inferTodaysNotifications() -> [TimelineEvent] {
        // Reconstruct notification schedule for today
        // based on reminderIntervalMinutes and active hours
        let today = Calendar.current.startOfDay(for: Date())
        let now = Date()
        
        var notificationTimes: [Date] = []
        
        // Generate all scheduled notification times today
        let schedule = NotificationScheduleCalculator(
            intervalMinutes: store.reminderIntervalMinutes,
            activeHours: (store.startHour, store.endHour),
            activeDays: store.activeDays
        )
        
        for notificationTime in schedule.todaysSchedule {
            guard notificationTime <= now else { break }  // Only past notifications
            notificationTimes.append(notificationTime)
        }
        
        return notificationTimes.map { TimelineEvent(timestamp: $0, type: .notificationFired) }
    }
}
```

**Technical Architecture:**

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| `TimelineEvent` model | Represents point-in-time notification or exercise | Foundation |
| `TimelineGraphView` | Renders two-track timeline visualization | SwiftUI, Charts (optional) |
| `ReportingService.getTodaysTimeline()` | Aggregates notification and exercise events | ExerciseStore |
| `NotificationScheduleCalculator` | Reconstructs today's scheduled notification times | (see below) |

**Critical Implementation Gap:**
Currently, the app doesn't persist when notifications actually fired. We only know:
1. Scheduled times (calculated from interval + active hours)
2. Exercise logs (with timestamps)

**To accurately show "Notification Fired" events**, we need to either:

**Option A (Preferred): Add timestamp to notification delivery**
```swift
// In NotificationManager
func willPresent(notification: UNNotification) {
    let firedAt = Date()  // Capture actual delivery time
    // Store in a lightweight log (not persisted long-term, just today)
    NotificationFiredLog.shared.record(firedAt, exerciseType: ...)
}

// In ExerciseStore
@Published var todaysFiredNotifications: [Date] = []
```

**Option B: Infer from schedule**
Assume notifications fired at scheduled times. This works when users aren't missing notifications, but fails to show "missed" notifications (which is valuable data).

**Recommendation**: Go with Option A for better accuracy and deeper insight into notification behavior.

**Files to Create/Modify:**

| File | Action | Purpose |
|------|--------|---------|
| `TimelineGraphView.swift` | NEW | Timeline visualization component |
| `TimelineEvent.swift` | NEW | Data model for timeline events |
| `NotificationScheduleCalculator.swift` | NEW | Calculates expected notification times |
| `NotificationFiredLog.swift` | NEW | Lightweight store for today's notification fires |
| `ProgressReportView.swift` | MODIFY | Add TimelineGraphView when `.today` selected |
| `NotificationManager.swift` | MODIFY | Record notification fire timestamp |
| `ReportingService.swift` | EXTEND | Add `getTodaysTimeline()` method |
| `ExerciseStore.swift` | EXTEND | Add `todaysFiredNotifications` property |

**Success Metrics:**
- User can visualize correlation between notification times and exercise response
- Identifies peak response times (e.g., notifications sent at 3 PM have 80% response rate)
- Spots missed notifications (notification dots with no corresponding exercise log)
- Guides interval/schedule optimization (e.g., "you respond best to 2 PM reminders")

**Future Enhancements:**
1. **Weekly Timeline**: Show density heatmap across all days (e.g., "Mondays at 2 PM are your peak time")
2. **Response Analytics**: Dashboard showing average response time, effectiveness by time-of-day, etc.
3. **Adaptive Notifications**: Use timeline data to recommend optimal notification times based on historical response patterns

---

## UX13: Progress Report Crash (Complete)

**Problem:** App crashed when selecting Week or Month period in Progress Report view. The issue was that `weekPeriod` and `monthPeriod` were computed properties that recalculated on every access, creating new Date instances. Since `ReportPeriod` is `Hashable`, the hash changed on each access, breaking the picker's binding stability.

**Root Cause:** 
- Computed properties `weekPeriod` and `monthPeriod` calculated fresh dates each time
- `ReportPeriod` cases with associated Date values (`weekStarting`, `monthStarting`) would hash differently
- Picker binding depends on stable hashes to track selection state
- Crash occurred when picker tried to match the selected period

**Solution Implemented:**
- Added `@State` properties `cachedWeekPeriod` and `cachedMonthPeriod` to store computed periods
- Cache invalidates on `.onAppear` to refresh period boundaries across day/week/month changes
- Replaced forced unwraps with `guard let` for safe date calculations
- **Key fix: Added early-exit guards in `getStats()` when logs are empty** - prevents infinite loop in streak calculation
- Added iteration limit (1000) to `calculateStreak()` as secondary safety measure
- Cached periods ensure stable `Hashable` identity for picker binding

**Root Cause:** 
The infinite loop in `calculateStreak()` would occur when there were no logs to find, causing a stack overflow. The early-exit guards prevent this scenario entirely.

**Files Changed:**
- `ProgressReportView.swift` - Added period caching mechanism, cache invalidation
- `ExerciseStore.swift` - Added early-exit guards and iteration limit

---

## UX1: Silent Settings Changes (Complete)

**Problem:** When a user changes interval, active days, or active hours, the notification reschedules immediately with zero feedback. User has no idea their 2:55 PM reminder just moved to tomorrow.

**Solution Implemented:**
- Created `ReminderScheduleView.swift` - a dedicated view for schedule configuration
- Changes are staged locally and only applied when user taps "Save"
- Shows current schedule at top of view
- Shows live preview of new next reminder time when changes are pending
- Confirmation dialog before applying changes with summary of what will change
- Success haptic on save
- SettingsView now links to ReminderScheduleView instead of inline settings

**Files Changed:**
- `ReminderScheduleView.swift` (new)
- `SettingsView.swift` (simplified, now links to ReminderScheduleView)

---

## UX2: Missed Notifications / Dead Response Reset (Complete)

**Problem:** Uses non-repeating notification triggers. If a user dismisses or misses a notification, nothing reschedules it. They must manually tap "Reset Timer" or log an exercise.

**Solution Implemented:**
- Added `deadResponseEnabled` and `deadResponseMinutes` settings to ExerciseStore (default: enabled, 5 min)
- When a notification fires (`willPresent`), a follow-up notification is immediately scheduled
- If user responds (taps notification, logs exercise, or snoozes), the follow-up is cancelled
- If user doesn't respond, the follow-up fires after the configured timeout with message "Still there?"
- Follow-up uses same notification category so user can log/snooze from it too
- Configurable timeout options: 1, 2, 3, 5, 10, 15 minutes
- Setting integrated into ReminderScheduleView under "Missed Reminders" section

**Files Changed:**
- `ExerciseStore.swift` (added deadResponseEnabled, deadResponseMinutes settings)
- `NotificationManager.swift` (added scheduleFollowUpReminder, cancelFollowUpReminder methods)
- `StandFitApp.swift` (schedule follow-up on notification present, cancel on user action)
- `ReminderScheduleView.swift` (added UI for configuring dead response settings)

---

## UX3: Custom Exercises (Complete)

**Problem:** All 4 exercise types are hardcoded in an enum. Users cannot add their own exercises or select from available SF Symbols.

**Solution Implemented:**

### New Types & Models

Added to `Models.swift`:
- `ExerciseUnitType` enum (`.reps` or `.seconds`) - defines how exercise is measured
- `CustomExercise` struct - user-defined exercise with name, icon, unit type, default count
- `ExerciseItem` struct - unified representation for both built-in and custom exercises
- Updated `ExerciseLog` to support both built-in and custom exercises via optional fields

### Storage & Management

Updated `ExerciseStore.swift`:
- Added `customExercises: [CustomExercise]` published property
- Added `custom_exercises.json` file-based persistence
- Added `allExercises` computed property returning unified `[ExerciseItem]`
- Added CRUD methods: `addCustomExercise`, `updateCustomExercise`, `deleteCustomExercise`, `moveCustomExercise`
- Added `logExercise(item:count:)` for unified logging
- Updated statistics to handle both built-in and custom exercise summaries

### Icon Picker (Swipeable)

New file `IconPickerView.swift`:
- `IconPickerView` - Full-screen swipeable icon picker using TabView with page style
- 70+ curated exercise-appropriate SF Symbols organized in pages of 6
- `IconGridPage` - Single page showing 3x2 grid of icons
- `IconButton` - Individual icon button with selection state
- `IconPickerButton` - Inline button that opens full picker when tapped

### Exercise Creation/Editing

New file `CreateExerciseView.swift`:
- `CreateExerciseView` - Form for creating/editing custom exercises
  - Name text field
  - Icon picker button (opens swipeable picker)
  - Unit type picker (Reps vs Seconds)
  - Default count stepper with appropriate step amounts (1 for reps, 5 for seconds)
  - Live preview showing how exercise will appear
  - Delete option when editing
- `CustomExerciseListView` - List management view showing all exercises
  - Built-in exercises section (read-only)
  - Custom exercises section (editable, reorderable)
  - Add new exercise button

### Updated Components

`ExercisePickerView.swift`:
- Now accepts `ExerciseItem` instead of `ExerciseType`
- Shows all exercises (built-in + custom) from `store.allExercises`
- Custom exercises show with blue tint, built-in with green

`ExerciseLoggerView.swift`:
- Updated to use `ExerciseItem` for unified exercise handling
- Uses `exerciseItem.unitType` for proper unit display (reps/seconds)
- Appropriate step amounts: +1/-1 for reps, +5/-5 for seconds
- Quick increment buttons: +5/+10 for reps, +15/+30 for seconds
- **Changed "Cancel" to "Done"** per user request
- Backwards compatibility initializer for ExerciseType

`ContentView.swift`:
- Changed `selectedExercise: ExerciseType?` to `selectedExerciseItem: ExerciseItem?`
- Updated all related sheet presentations
- Today's stats shows both built-in and custom exercise summaries

`SettingsView.swift`:
- Added "Exercises" section linking to `CustomExerciseListView`
- Shows count of custom exercises

### User Flow

**Creating a custom exercise:**
1. Settings → Exercises
2. Tap "Add Exercise" under Custom section
3. Enter name (e.g., "Burpees")
4. Tap icon button → swipe through pages to select icon
5. Choose unit type (Reps or Seconds)
6. Adjust default count with +/- buttons
7. Preview shows how it will appear
8. Tap "Save Exercise"

**Using custom exercises:**
- Custom exercises appear in the Quick Log grid alongside built-in ones
- Custom exercises are blue, built-in are green
- Logging works identically - same count picker, same save flow
- Today's stats shows both types

**Editing/deleting:**
1. Settings → Exercises
2. Tap any custom exercise
3. Make changes or tap "Delete Exercise"

**Files Changed:**
- `Models.swift` - New types: ExerciseUnitType, CustomExercise, ExerciseItem; updated ExerciseLog
- `ExerciseStore.swift` - Custom exercise storage, CRUD, unified exercise list
- `IconPickerView.swift` (new) - Swipeable SF Symbol picker
- `CreateExerciseView.swift` (new) - Exercise creation/editing, list management
- `ExercisePickerView.swift` - Updated to use ExerciseItem
- `ExerciseLoggerView.swift` - Updated to use ExerciseItem, Cancel→Done
- `ContentView.swift` - ExerciseItem integration, custom summaries
- `SettingsView.swift` - Added Exercises section

---

## UX4: Additional Polish Items (Pending)

| Sub-Issue | Severity | Description |
|-----------|----------|-------------|
| No save confirmation | Low | Only haptic feedback when logging exercise - no visual confirmation |
| "Scheduling..." indefinitely | Medium | Shows forever if no valid slot exists - no error message |
| Confusing active hours | Medium | Unclear if 9 AM - 5 PM is inclusive or exclusive of 5 PM |
| Async state lag | Medium | UI may show stale notification times due to async updates |
| No snooze duration config | Low | Snooze action is hardcoded - not configurable |
| Version hardcoded | Low | Shows "1.0.0" instead of reading from Info.plist |

---

## UX5: Notification "Log Exercise" Deep Link (Complete)

**Problem:** When user taps "Log Exercise" from a notification, the app opens to the main ContentView. The user must then scroll down to the "Quick Log" section and tap an exercise. This is not intuitive and adds friction to the logging flow.

**Solution Implemented:**

Created reusable `ExercisePickerView` architecture:
- `ExercisePickerView` - Reusable grid of exercise buttons with `onSelect` callback
- `ExercisePickerButton` - Individual exercise button component
- `ExercisePickerFullScreenView` - Full-screen wrapper with navigation and title

Deep link flow:
1. User taps "Log Exercise" from notification
2. AppDelegate posts `.showExercisePicker` notification
3. ContentView receives notification and presents `ExercisePickerFullScreenView`
4. User selects exercise → `ExerciseLoggerView` opens
5. After save, dismisses back to ContentView

**Benefits Achieved:**
- Single source of truth for exercise selection UI
- ContentView's "Quick Log" section now uses `ExercisePickerView`
- No code duplication
- Future-proof for UX3 (custom exercises)

**Files Changed:**
- `ExercisePickerView.swift` (new) - Reusable picker components
- `ContentView.swift` - Uses ExercisePickerView, listens for deep link notification
- `StandFitApp.swift` - Posts notification on LOG_EXERCISE action

---

## UX6: Reset Timer Button Lacks Context (Pending)

**Problem:** The "Reset Timer" button in ContentView doesn't indicate what interval it will reset to. Users must remember their configured interval or check Settings to know what will happen.

**Current State:**
```
Button label: "Reset Timer"
Actual behavior: Schedules reminder for configured interval (e.g., 30 min)
```

**User's Suggestion:** Show "+30m" or similar to indicate the interval.

**UX Analysis:**

| Approach | Pros | Cons |
|----------|------|------|
| `Reset (+30m)` | Compact, shows interval | May be inaccurate if schedule pushes to next day |
| `Reset to 3:45 PM` | Accurate, shows actual time | Takes more space, needs calculation |
| `Reset` + post-tap feedback | Clean button, accurate info | Requires extra UI element |

**Important Consideration:**
The `nextValidReminderDate()` function respects active days and hours. If the user taps "Reset" at 4:55 PM with end hour at 5 PM and a 30-min interval, the actual next reminder might be **tomorrow at 9 AM**, not "+30m from now".

Showing "+30m" would be **misleading** in edge cases.

**Chosen Solution: Simple Interval Display**

Show the configured interval on the button. The timer card already displays the actual scheduled time after reset, providing accurate feedback for edge cases.

**Rationale:**
- Communicates the *intent* of the interval setting
- Timer card immediately shows *actual* scheduled time after tap
- Edge cases (outside active hours) are rare
- Simple to implement and maintain

**Proposed Implementation:**
```swift
// Current
Label("Reset Timer", systemImage: "arrow.clockwise")

// Proposed
Label("Reset (+\(formatInterval(store.reminderIntervalMinutes)))", systemImage: "arrow.clockwise")

// Examples: "Reset (+30m)", "Reset (+1h)", "Reset (+1h 30m)"
```

**Files to Change:**
- `ContentView.swift` (update button label)

---

## UX7: Focus Mode Notification Warning (Pending)

**Problem:** When the user has a Focus Mode active (e.g., "Personal", "Work", "Sleep") that doesn't explicitly allow StandFit notifications, reminders are silently blocked. The user has no indication that their reminders won't be delivered.

**Proposed Solution:**

Two-part approach:

### Part A: Settings Warning (Always Visible)
Add a persistent informational row in SettingsView explaining that Focus Modes may silence reminders. This is always shown regardless of Focus status.

```swift
// In SettingsView
Section {
    HStack {
        Image(systemName: "moon.fill")
            .foregroundStyle(.purple)
        VStack(alignment: .leading) {
            Text("Focus Modes")
                .font(.caption)
            Text("Reminders may be silenced when a Focus is active")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
} footer: {
    Text("Check Settings > Focus to allow StandFit notifications.")
}
```

### Part B: Active Focus Warning (ContentView Banner)
When Focus Mode is detected as active, show a warning banner at the top of ContentView.

**Technical Approach:**
```swift
import Intents

// Request authorization on app launch
INFocusStatusCenter.default.requestAuthorization { status in
    // Handle authorization
}

// Check focus status
let isFocused = INFocusStatusCenter.default.focusStatus.isFocused ?? false
```

**UI (ContentView):**
```swift
if isFocusActive {
    HStack {
        Image(systemName: "moon.fill")
            .foregroundStyle(.purple)
        Text("Focus Mode active - reminders may be silenced")
            .font(.caption2)
    }
    .padding(8)
    .frame(maxWidth: .infinity)
    .background(.purple.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
}
```

**Technical Limitations:**
| What We Can Detect | What We Cannot Detect |
|-------------------|----------------------|
| Focus Mode is active | Which Focus is active |
| (with user permission) | Whether our app is blocked |
| | If "Share Focus Status" is off |

**API Requirements:**
- `INFocusStatusCenter` from Intents framework
- iOS 15+ / watchOS 8+ (unconfirmed for watchOS)
- Requires user authorization
- User must have "Share Focus Status" enabled in Settings

**Fallback:**
If `INFocusStatusCenter` is not available on watchOS or authorization is denied, Part A (Settings warning) still provides value as a static reminder.

**Files to Change:**
- `SettingsView.swift` (add Focus Mode info section)
- `ContentView.swift` (add Focus Mode banner when active)
- `NotificationManager.swift` or new `FocusStatusManager.swift` (Focus detection logic)

---

## UX8: Progress Reporting View (Complete)

**Problem:** Users have no way to compare their exercise progress across different time periods. The current HistoryView only shows a flat list of logs without aggregation or visualization.

**Solution Implemented:**

**Proposed Solution:**

Create a dedicated `ProgressReportView` with interactive charts showing exercise data across day/week/month/year periods.

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

**Files to Create:**
- `ProgressReportView.swift` - Main reporting view with period picker and charts
- `ProgressChartView.swift` - Reusable chart component (or inline)

**Files to Modify:**
- `ExerciseStore.swift` - Add aggregation methods for reporting
- `HistoryView.swift` - Add navigation to ProgressReportView
- `ContentView.swift` - Optional: Add quick access to reports

**Dependencies:**
- Swift Charts framework (iOS 16+ / watchOS 9+)

---

## UX9: Automatic Progress Report Notifications (Complete)

**Problem:** Users don't receive any summary of their progress unless they manually open the app and check. There's no celebration of achievements or awareness of trends.

**Solution Implemented:**

**Proposed Solution:**

Add scheduled report notifications that summarize progress at configurable intervals.

### Report Types

| Report | Default Schedule | Content |
|--------|-----------------|---------|
| **Daily** | 8:00 PM | Today's total, comparison to yesterday, streak |
| **Weekly** | Sunday 8:00 PM | Week's total, best day, comparison to last week |
| **Monthly** | 1st of month, 8:00 AM | Month's total, trends, achievements |
| **Yearly** | Jan 1st, 10:00 AM | Year in review, total exercises, milestones |

### Notification Content Examples

**Daily Report:**
```
📊 Daily Report
Today: 87 points (↑15% vs yesterday)
🔥 5-day streak! Keep it up!
```

**Weekly Report:**
```
📊 Weekly Summary
This week: 423 points
Best day: Friday (120 pts)
↑8% vs last week
```

### Settings

```swift
// In ExerciseStore
@AppStorage("autoReportEnabled") var autoReportEnabled: Bool = true
@AppStorage("dailyReportEnabled") var dailyReportEnabled: Bool = true
@AppStorage("dailyReportHour") var dailyReportHour: Int = 20  // 8 PM
@AppStorage("weeklyReportEnabled") var weeklyReportEnabled: Bool = true
@AppStorage("weeklyReportDay") var weeklyReportDay: Int = 1   // Sunday
@AppStorage("monthlyReportEnabled") var monthlyReportEnabled: Bool = false
```

### UI (Settings)

```swift
Section {
    Toggle("Auto Reports", isOn: $store.autoReportEnabled)

    if store.autoReportEnabled {
        NavigationLink {
            ReportSettingsView(store: store)
        } label: {
            Label("Report Schedule", systemImage: "calendar.badge.clock")
        }
    }
} header: {
    Text("Progress Reports")
} footer: {
    Text("Receive notifications summarizing your exercise progress.")
}
```

### Notification Actions

```swift
// Report notification category
let viewReportAction = UNNotificationAction(
    identifier: "VIEW_REPORT",
    title: "View Details",
    options: [.foreground]
)

let disableReportsAction = UNNotificationAction(
    identifier: "DISABLE_REPORTS",
    title: "Turn Off Reports",
    options: [.destructive]
)

let reportCategory = UNNotificationCategory(
    identifier: "PROGRESS_REPORT",
    actions: [viewReportAction, disableReportsAction],
    intentIdentifiers: [],
    options: []
)
```

**Deep Link Behavior:**
- "View Details" → Opens ProgressReportView (UX8)
- "Turn Off Reports" → Opens Settings with report section highlighted

### Scheduling Logic

```swift
func scheduleReportNotifications(store: ExerciseStore) {
    guard store.autoReportEnabled else {
        cancelAllReportNotifications()
        return
    }

    if store.dailyReportEnabled {
        scheduleDailyReport(hour: store.dailyReportHour)
    }

    if store.weeklyReportEnabled {
        scheduleWeeklyReport(day: store.weeklyReportDay, hour: store.dailyReportHour)
    }
    // etc.
}
```

### Report Generation

Reports are generated at notification time by querying ExerciseStore:

```swift
func generateDailyReport() -> (title: String, body: String) {
    let todayScore = calculateScore(for: .today)
    let yesterdayScore = calculateScore(for: .yesterday)
    let streak = calculateStreak()

    let percentChange = yesterdayScore > 0
        ? Int(((Double(todayScore) / Double(yesterdayScore)) - 1) * 100)
        : 0

    let trend = percentChange >= 0 ? "↑\(percentChange)%" : "↓\(abs(percentChange))%"

    var body = "Today: \(todayScore) points (\(trend) vs yesterday)"
    if streak >= 3 {
        body += "\n🔥 \(streak)-day streak!"
    }

    return ("📊 Daily Report", body)
}
```

### Relationship to UX8

UX9 depends on UX8's data aggregation logic:
- Both need `calculateScore(for period:)` methods
- "View Details" action navigates to ProgressReportView
- Shared data structures for period calculations

**Implementation Order:**
1. UX8 first (establishes data layer and reporting view)
2. UX9 second (adds notification scheduling on top)

**Files to Create:**
- `ReportSettingsView.swift` - Configure report schedule
- `ReportNotificationManager.swift` (or extend NotificationManager)

**Files to Modify:**
- `ExerciseStore.swift` - Add report settings and score calculation
- `NotificationManager.swift` - Add report notification scheduling
- `SettingsView.swift` - Add Reports section
- `StandFitApp.swift` - Handle report notification actions

---

## UX10: Gamification System (Pending)

**Problem:** The app lacks motivation mechanics beyond raw exercise counts. Users have no sense of achievement, progression, or incentive to maintain consistency.

**Proposed Solution:**

Implement a comprehensive gamification system with streaks, achievements, milestones, and progression mechanics.

### Core Gamification Elements

| Element | Purpose | Psychological Driver |
|---------|---------|---------------------|
| **Streaks** | Reward consistency | Loss aversion, habit formation |
| **Achievements** | Celebrate milestones | Accomplishment, collection instinct |
| **Levels/XP** | Show progression | Growth mindset, mastery |
| **Challenges** | Short-term goals | Goal-gradient effect |
| **Badges** | Visual rewards | Status, identity |

---

### 1. Streak System

**Types of Streaks:**

| Streak Type | Definition | Example |
|-------------|------------|---------|
| **Daily Active** | Days with ≥1 exercise logged | "7-day streak!" |
| **Reminder Response** | Consecutive reminders responded to | "15 reminders in a row" |
| **Weekly Goal** | Weeks hitting target score | "4 weeks of 500+ points" |
| **Exercise-Specific** | Consecutive days doing specific exercise | "10-day pushup streak" |

**Streak Mechanics:**

```swift
struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var streakFreezeAvailable: Bool  // Grace period token

    mutating func recordActivity(on date: Date) {
        let calendar = Calendar.current
        guard let lastDate = lastActiveDate else {
            currentStreak = 1
            lastActiveDate = date
            return
        }

        if calendar.isDate(date, inSameDayAs: lastDate) {
            return  // Already counted today
        }

        let daysDiff = calendar.dateComponents([.day], from: lastDate, to: date).day ?? 0

        if daysDiff == 1 {
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysDiff == 2 && streakFreezeAvailable {
            streakFreezeAvailable = false  // Use freeze
            currentStreak += 1
        } else {
            currentStreak = 1  // Streak broken
        }

        lastActiveDate = date
    }
}
```

**Streak Protection:**
- **Streak Freeze**: Earn 1 freeze per 7-day streak (max 2 stored)
- **Rest Day**: Optionally designate 1 day/week that doesn't break streak
- **Vacation Mode**: Pause streaks temporarily (Settings)

**UI (ContentView streak badge):**
```swift
HStack(spacing: 4) {
    Image(systemName: "flame.fill")
        .foregroundStyle(.orange)
    Text("\(store.currentStreak)")
        .fontWeight(.bold)
}
.padding(.horizontal, 8)
.padding(.vertical, 4)
.background(.orange.opacity(0.2), in: Capsule())
```

---

### 2. Achievement System

**Achievement Categories:**

| Category | Examples |
|----------|----------|
| **Milestones** | First exercise, 100 total, 1000 total |
| **Consistency** | 7-day streak, 30-day streak, 365-day streak |
| **Volume** | 100 pushups lifetime, 1000 squats |
| **Variety** | All 4 exercises in one day, try every exercise |
| **Time-Based** | Early bird (before 7am), Night owl (after 9pm) |
| **Challenges** | Perfect week (7/7 days), Marathon (10+ exercises/day) |
| **Social** | Share first achievement, invite a friend |

**Achievement Data Model:**

```swift
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String  // SF Symbol
    let category: AchievementCategory
    let tier: AchievementTier  // bronze, silver, gold, platinum
    let requirement: AchievementRequirement
    var unlockedAt: Date?
    var progress: Int  // For progressive achievements

    var isUnlocked: Bool { unlockedAt != nil }
    var progressPercent: Double {
        guard case .count(let target) = requirement else { return isUnlocked ? 1.0 : 0.0 }
        return min(Double(progress) / Double(target), 1.0)
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case milestone, consistency, volume, variety, challenge, social
}

enum AchievementTier: String, Codable {
    case bronze, silver, gold, platinum

    var color: Color {
        switch self {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        }
    }
}

enum AchievementRequirement: Codable {
    case count(Int)           // Total count threshold
    case streak(Int)          // Streak length
    case unique(Int)          // Unique items (exercises, days, etc.)
    case timeWindow(String)   // Time-based (e.g., "before:07:00")
    case compound([String])   // Multiple conditions
}
```

**Sample Achievement Definitions:**

```swift
static let allAchievements: [Achievement] = [
    // Milestones
    Achievement(id: "first_exercise", name: "First Steps",
                description: "Log your first exercise",
                icon: "figure.walk", category: .milestone, tier: .bronze,
                requirement: .count(1)),

    Achievement(id: "century", name: "Century Club",
                description: "Log 100 total exercises",
                icon: "100.circle.fill", category: .milestone, tier: .silver,
                requirement: .count(100)),

    Achievement(id: "thousand", name: "The Grind",
                description: "Log 1,000 total exercises",
                icon: "star.circle.fill", category: .milestone, tier: .gold,
                requirement: .count(1000)),

    // Consistency
    Achievement(id: "week_streak", name: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "flame.fill", category: .consistency, tier: .bronze,
                requirement: .streak(7)),

    Achievement(id: "month_streak", name: "Monthly Master",
                description: "Maintain a 30-day streak",
                icon: "flame.circle.fill", category: .consistency, tier: .silver,
                requirement: .streak(30)),

    Achievement(id: "year_streak", name: "Unstoppable",
                description: "Maintain a 365-day streak",
                icon: "crown.fill", category: .consistency, tier: .platinum,
                requirement: .streak(365)),

    // Variety
    Achievement(id: "well_rounded", name: "Well Rounded",
                description: "Do all exercise types in one day",
                icon: "circle.hexagongrid.fill", category: .variety, tier: .bronze,
                requirement: .unique(4)),

    // Time-based
    Achievement(id: "early_bird", name: "Early Bird",
                description: "Log an exercise before 7 AM",
                icon: "sunrise.fill", category: .challenge, tier: .bronze,
                requirement: .timeWindow("before:07:00")),

    Achievement(id: "night_owl", name: "Night Owl",
                description: "Log an exercise after 10 PM",
                icon: "moon.stars.fill", category: .challenge, tier: .bronze,
                requirement: .timeWindow("after:22:00")),

    // Volume
    Achievement(id: "pushup_100", name: "Pushup Pro",
                description: "Complete 100 lifetime pushups",
                icon: "figure.strengthtraining.traditional", category: .volume, tier: .bronze,
                requirement: .count(100)),

    Achievement(id: "pushup_1000", name: "Pushup Master",
                description: "Complete 1,000 lifetime pushups",
                icon: "figure.strengthtraining.traditional", category: .volume, tier: .gold,
                requirement: .count(1000)),
]
```

**Achievement Notification:**

When unlocked, show celebration:
```swift
// In-app toast
struct AchievementUnlockedView: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.largeTitle)
                .foregroundStyle(achievement.tier.color)

            Text("Achievement Unlocked!")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(achievement.name)
                .font(.headline)

            Text(achievement.description)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Push notification for achievements:**
```
🏆 Achievement Unlocked!
"Week Warrior" - Maintain a 7-day streak
```

---

### 3. Achievements View

**AchievementsView.swift:**

```swift
struct AchievementsView: View {
    @ObservedObject var store: ExerciseStore
    @State private var selectedCategory: AchievementCategory?

    var body: some View {
        List {
            // Summary header
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(unlockedCount)/\(totalCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Achievements")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    // Tier breakdown
                    HStack(spacing: 4) {
                        tierBadge(.platinum, count: platinumCount)
                        tierBadge(.gold, count: goldCount)
                        tierBadge(.silver, count: silverCount)
                        tierBadge(.bronze, count: bronzeCount)
                    }
                }
            }

            // Category filter
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        categoryPill(nil, label: "All")
                        ForEach(AchievementCategory.allCases, id: \.self) { cat in
                            categoryPill(cat, label: cat.rawValue.capitalized)
                        }
                    }
                }
            }

            // Achievements list
            Section("Unlocked") {
                ForEach(unlockedAchievements) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }

            Section("In Progress") {
                ForEach(inProgressAchievements) { achievement in
                    AchievementRow(achievement: achievement, showProgress: true)
                }
            }

            Section("Locked") {
                ForEach(lockedAchievements) { achievement in
                    AchievementRow(achievement: achievement, isLocked: true)
                }
            }
        }
        .navigationTitle("Achievements")
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    var showProgress: Bool = false
    var isLocked: Bool = false

    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .foregroundStyle(isLocked ? .gray : achievement.tier.color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.caption)
                    .foregroundStyle(isLocked ? .secondary : .primary)

                if showProgress {
                    ProgressView(value: achievement.progressPercent)
                        .tint(achievement.tier.color)
                    Text("\(achievement.progress)/\(targetCount) (\(Int(achievement.progressPercent * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text(achievement.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}
```

---

### 4. Levels & XP System (Optional)

**Progression system for long-term engagement:**

```swift
struct LevelSystem {
    static let xpPerExercise = 10
    static let xpPerStreak = 5  // Bonus per day of streak
    static let xpPerAchievement = 50

    static func levelFor(xp: Int) -> Int {
        // Exponential curve: each level needs more XP
        // Level 1: 0 XP, Level 2: 100 XP, Level 3: 250 XP, etc.
        var level = 1
        var threshold = 0
        var increment = 100

        while xp >= threshold {
            level += 1
            threshold += increment
            increment = Int(Double(increment) * 1.5)
        }

        return level - 1
    }

    static func xpForNextLevel(currentXP: Int) -> (current: Int, needed: Int) {
        let level = levelFor(xp: currentXP)
        var threshold = 0
        var increment = 100

        for _ in 1...level {
            threshold += increment
            increment = Int(Double(increment) * 1.5)
        }

        let nextThreshold = threshold + increment
        return (currentXP - threshold + increment, increment)
    }
}
```

**Level display:**
```swift
HStack {
    Text("Lv.\(level)")
        .font(.caption)
        .fontWeight(.bold)
    ProgressView(value: levelProgress)
        .tint(.blue)
}
```

---

### 5. Daily/Weekly Challenges

**Short-term goals for engagement:**

```swift
struct Challenge: Identifiable, Codable {
    let id: UUID
    let type: ChallengeType
    let target: Int
    var progress: Int
    let expiresAt: Date
    let xpReward: Int

    var isComplete: Bool { progress >= target }
    var isExpired: Bool { Date() > expiresAt }
}

enum ChallengeType: String, Codable {
    case dailyExercises      // "Do 5 exercises today"
    case specificExercise    // "Do 20 pushups today"
    case varietyChallenge    // "Do 3 different exercises"
    case streakProtect       // "Don't break your streak"
    case earlyBird           // "Exercise before 8 AM"
}
```

**Challenge UI section in ContentView:**
```swift
Section("Today's Challenge") {
    if let challenge = store.activeChallenge {
        HStack {
            Image(systemName: "target")
                .foregroundStyle(.orange)
            VStack(alignment: .leading) {
                Text(challenge.description)
                    .font(.caption)
                ProgressView(value: Double(challenge.progress) / Double(challenge.target))
                    .tint(.orange)
            }
            Text("+\(challenge.xpReward) XP")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
```

---

### Navigation & Integration

**Access points:**
1. ContentView: Streak badge (tappable → AchievementsView)
2. Settings: "Achievements" row
3. HistoryView: Toolbar button
4. Achievement notifications → Deep link to AchievementsView

**Files to Create:**
- `AchievementsView.swift` - Main achievements browser
- `AchievementManager.swift` - Achievement tracking and unlocking logic
- `GamificationModels.swift` - Achievement, Streak, Challenge models

**Files to Modify:**
- `ExerciseStore.swift` - Add streak tracking, XP, achievement state
- `ContentView.swift` - Add streak badge, challenge section
- `ExerciseLoggerView.swift` - Trigger achievement checks on save
- `NotificationManager.swift` - Achievement unlock notifications

**Dependencies:**
- None (pure Swift, local storage)
- Optional: CloudKit for cross-device sync

---

## UX11: Social Features & Friends Integration (Pending)

**Problem:** Exercise is more motivating with accountability and social connection. Users can't share progress, compete with friends, or see how they compare.

**Proposed Solution:**

Add optional social features with privacy controls, enabling friend connections, activity sharing, and friendly competition.

### Strategic Considerations

**Privacy-First Approach:**
- All social features are opt-in
- Granular privacy controls
- No data shared without explicit consent
- Local-first with optional cloud sync

**Integration Options:**

| Approach | Pros | Cons | Complexity |
|----------|------|------|------------|
| **CloudKit** | Apple ecosystem, free tier, privacy-focused | Apple-only, limited querying | Medium |
| **Firebase** | Cross-platform, real-time, rich features | Google dependency, privacy concerns | Medium |
| **Custom Backend** | Full control, cross-platform | Maintenance, hosting costs, security | High |
| **SharePlay/Messages** | Native iOS integration, no backend | Limited features, iOS-only | Low |
| **Game Center** | Built-in leaderboards, achievements | Gaming-focused, limited customization | Low |

**Recommended: CloudKit + Game Center Hybrid**
- CloudKit for friend data and activity sharing
- Game Center for leaderboards (optional)
- No external accounts needed
- Privacy-compliant (Apple handles auth)

---

### 1. Friend System

**Friend Connection Methods:**

| Method | Description | Privacy Level |
|--------|-------------|---------------|
| **Share Code** | Unique code to share (like Among Us) | High - manual share only |
| **Contacts** | Find friends from contacts who use app | Medium - requires permission |
| **Nearby** | Discover friends via proximity | Medium - temporary exposure |
| **Apple ID** | Connect via iCloud contacts | Medium - Apple-managed |

**Friend Data Model:**

```swift
struct Friend: Identifiable, Codable {
    let id: String  // CloudKit record ID
    let displayName: String
    let avatarEmoji: String  // Simple emoji avatar
    var relationship: FriendRelationship
    var lastActivityDate: Date?
    var currentStreak: Int?
    var weeklyScore: Int?
    var privacyLevel: FriendPrivacyLevel
}

enum FriendRelationship: String, Codable {
    case pending      // Sent request, awaiting response
    case incoming     // Received request
    case accepted     // Mutual friends
    case blocked      // Blocked by user
}

enum FriendPrivacyLevel: String, Codable {
    case full         // See all activity details
    case summary      // See daily/weekly totals only
    case streakOnly   // Only see streak count
    case hidden       // Friend but no data sharing
}
```

**CloudKit Schema:**

```
// Users Record Type
Users {
    recordName: String (unique user ID)
    displayName: String
    avatarEmoji: String
    shareCode: String (unique, regeneratable)
    privacyDefault: String
    createdAt: Date
}

// Friendships Record Type
Friendships {
    userA: Reference(Users)
    userB: Reference(Users)
    status: String (pending/accepted/blocked)
    initiatedBy: Reference(Users)
    privacyLevelA: String  // What A shows to B
    privacyLevelB: String  // What B shows to A
    createdAt: Date
}

// SharedActivity Record Type
SharedActivity {
    user: Reference(Users)
    date: Date
    totalScore: Int
    exerciseCount: Int
    streak: Int
    // Note: No exercise details for privacy
}
```

---

### 2. Privacy Controls

**Settings → Privacy & Sharing:**

```swift
struct SocialPrivacyView: View {
    @ObservedObject var store: ExerciseStore

    var body: some View {
        List {
            Section {
                Toggle("Enable Social Features", isOn: $store.socialEnabled)
            } footer: {
                Text("When off, you won't appear in friend searches and won't see friends' activity.")
            }

            if store.socialEnabled {
                Section("What Friends Can See") {
                    Picker("Default Visibility", selection: $store.defaultPrivacy) {
                        Text("Full Activity").tag(FriendPrivacyLevel.full)
                        Text("Daily Totals").tag(FriendPrivacyLevel.summary)
                        Text("Streak Only").tag(FriendPrivacyLevel.streakOnly)
                        Text("Nothing").tag(FriendPrivacyLevel.hidden)
                    }
                }

                Section("Your Share Code") {
                    HStack {
                        Text(store.shareCode)
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                        Button("Copy") {
                            UIPasteboard.general.string = store.shareCode
                        }
                    }

                    Button("Regenerate Code") {
                        store.regenerateShareCode()
                    }
                    .foregroundStyle(.orange)
                } footer: {
                    Text("Share this code with friends so they can find you.")
                }

                Section {
                    Toggle("Appear in Nearby Search", isOn: $store.nearbyDiscoverable)
                    Toggle("Show in Contacts Search", isOn: $store.contactsDiscoverable)
                }
            }
        }
        .navigationTitle("Privacy & Sharing")
    }
}
```

**Per-Friend Privacy Override:**

```swift
struct FriendPrivacyView: View {
    @ObservedObject var friend: Friend

    var body: some View {
        List {
            Picker("This friend can see", selection: $friend.privacyLevel) {
                Text("Full Activity").tag(FriendPrivacyLevel.full)
                Text("Daily Totals").tag(FriendPrivacyLevel.summary)
                Text("Streak Only").tag(FriendPrivacyLevel.streakOnly)
                Text("Nothing").tag(FriendPrivacyLevel.hidden)
            }

            Section {
                Button("Remove Friend", role: .destructive) {
                    // Remove friend
                }
                Button("Block", role: .destructive) {
                    // Block user
                }
            }
        }
    }
}
```

---

### 3. Activity Feed

**FriendsActivityView.swift:**

```swift
struct FriendsActivityView: View {
    @ObservedObject var store: ExerciseStore
    @StateObject var socialManager = SocialManager.shared

    var body: some View {
        List {
            // Today's leaderboard
            Section("Today") {
                ForEach(socialManager.todayLeaderboard) { entry in
                    LeaderboardRow(entry: entry, isCurrentUser: entry.id == store.userId)
                }
            }

            // Recent activity
            Section("Recent Activity") {
                ForEach(socialManager.recentActivity) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .navigationTitle("Friends")
        .refreshable {
            await socialManager.refresh()
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            Text("\(entry.rank)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(entry.avatarEmoji)

            Text(entry.displayName)
                .font(.caption)
                .fontWeight(isCurrentUser ? .bold : .regular)

            Spacer()

            if let streak = entry.streak, streak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.caption2)
                    Text("\(streak)")
                        .font(.caption2)
                }
            }

            Text("\(entry.score) pts")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .listRowBackground(isCurrentUser ? Color.blue.opacity(0.1) : nil)
    }
}

struct ActivityRow: View {
    let activity: FriendActivity

    var body: some View {
        HStack {
            Text(activity.friend.avatarEmoji)

            VStack(alignment: .leading) {
                Text(activity.friend.displayName)
                    .font(.caption)
                Text(activity.summary)  // "Logged 5 exercises"
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(activity.timeAgo)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
```

---

### 4. Notifications & Sharing

**Friend Activity Notifications:**

```swift
// Settings
@AppStorage("friendActivityNotifications") var friendNotificationsEnabled = true
@AppStorage("notifyOnFriendStreak") var notifyOnStreak = true
@AppStorage("notifyOnFriendMilestone") var notifyOnMilestone = true
@AppStorage("notifyOnLeaderboardChange") var notifyOnLeaderboard = false

// Notification examples:
// "🔥 Sarah just hit a 30-day streak!"
// "💪 Mike completed 100 pushups this week"
// "📊 You moved to #2 on today's leaderboard"
```

**Share Sheet Integration:**

```swift
func shareAchievement(_ achievement: Achievement) {
    let text = "I just unlocked '\(achievement.name)' in StandFit! 💪"
    let activityVC = UIActivityViewController(
        activityItems: [text],
        applicationActivities: nil
    )
    // Present share sheet
}

func shareWeeklySummary() {
    let summary = """
    My StandFit Week:
    📊 \(weeklyScore) points
    🔥 \(currentStreak)-day streak
    💪 \(exerciseCount) exercises

    #StandFit
    """
    // Share via activity controller
}
```

---

### 5. Challenges & Competition

**Friend Challenges:**

```swift
struct FriendChallenge: Identifiable, Codable {
    let id: UUID
    let challengerID: String
    let challengedID: String
    let type: ChallengeType
    let target: Int
    let startDate: Date
    let endDate: Date
    var challengerProgress: Int
    var challengedProgress: Int
    var status: ChallengeStatus
}

enum ChallengeType: String, Codable {
    case dailyScore      // Most points in a day
    case weeklyTotal     // Most points in a week
    case streakLength    // Longest streak during period
    case specificCount   // Most of specific exercise
}

enum ChallengeStatus: String, Codable {
    case pending         // Awaiting acceptance
    case active          // In progress
    case completed       // Finished
    case declined        // Rejected
    case expired         // Not accepted in time
}
```

**Challenge UI:**

```swift
Section("Active Challenges") {
    ForEach(activeChallenges) { challenge in
        ChallengeRow(challenge: challenge)
    }
}

struct ChallengeRow: View {
    let challenge: FriendChallenge

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("vs \(challenge.opponentName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(challenge.timeRemaining)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                // Your progress
                VStack {
                    Text("\(challenge.yourProgress)")
                        .font(.headline)
                    Text("You")
                        .font(.caption2)
                }

                Spacer()

                Text("vs")
                    .foregroundStyle(.secondary)

                Spacer()

                // Opponent progress
                VStack {
                    Text("\(challenge.opponentProgress)")
                        .font(.headline)
                    Text(challenge.opponentName)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

### 6. Implementation Phases

**Phase 1: Foundation (Local)**
- Friend data models
- Privacy settings UI
- Share code generation
- Local storage for friend list

**Phase 2: CloudKit Integration**
- User profile sync
- Friend requests/acceptance
- Activity data sharing
- Basic leaderboards

**Phase 3: Real-Time Features**
- Push notifications for friend activity
- Live leaderboard updates
- Friend challenges

**Phase 4: Advanced Social**
- Groups/teams
- Weekly competitions
- Achievement sharing
- Activity feed

---

### Files to Create

- `SocialManager.swift` - CloudKit integration, friend management
- `FriendsListView.swift` - Friend list and management
- `FriendsActivityView.swift` - Activity feed and leaderboards
- `AddFriendView.swift` - Share code input, nearby search
- `SocialPrivacyView.swift` - Privacy settings
- `FriendChallengeView.swift` - Challenge UI
- `SocialModels.swift` - Friend, Activity, Challenge models

### Files to Modify

- `ExerciseStore.swift` - Add social settings, user ID, share code
- `SettingsView.swift` - Add Social section
- `ContentView.swift` - Add friends access point
- `NotificationManager.swift` - Friend activity notifications
- `StandFitApp.swift` - Handle social deep links

### Dependencies

- CloudKit (iOS/watchOS built-in)
- Optional: Game Center for leaderboards
- Background App Refresh for activity sync

### Privacy Considerations

1. **GDPR/CCPA Compliance**
   - Clear data collection disclosure
   - Export/delete user data option
   - Consent before any data sharing

2. **Minimal Data Collection**
   - Only share aggregated scores, not exercise details
   - No location data
   - No personal identifiers beyond display name

3. **User Control**
   - Easy opt-out at any time
   - Per-friend privacy settings
   - Immediate data deletion on request

---

## UX12: Snooze Button Notification Behavior (Pending)

**Problem:** When a user taps the "Snooze +5min" button on a notification, the behavior appears to reset the reminder schedule to the configured schedule period (e.g., the reminder interval set in Settings) instead of legitimately snoozing for just 5 minutes.

**Observed Behavior:**
- User receives notification at scheduled time (e.g., 2:30 PM for a 30-min interval reminder)
- User taps "Snooze +5min" button
- Expected: Next reminder should fire in 5 minutes (2:35 PM)
- Actual: Next reminder appears to fire at the next scheduled time based on configured interval (e.g., 3:00 PM for 30-min interval)

**Impact:**
- User's snooze action is ignored
- Feels like notification system ignored the snooze request
- Reduces trust in snooze feature
- Users may tap snooze multiple times expecting it to work

**Likely Root Cause:**
The snooze action likely triggers the standard reminder rescheduling logic instead of scheduling a temporary snooze notification. When the snooze is handled:
1. Notification is dismissed ✓
2. App reschedules using `scheduleReminderWithSchedule()` ❌
3. This respects active days/hours and configured interval ❌
4. Instead of snoozing for 5 minutes ✓

**Proposed Solution:**

Implement proper snooze handling with a separate code path:

```swift
// In NotificationManager
func snoozeReminder(minutes: Int) {
    // Snooze notifications are temporary and override the schedule
    // They should NOT respect active days/hours
    // They should fire in exactly N minutes
    
    let snoozeTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
    let trigger = UNCalendarNotificationTrigger(
        matching: Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: snoozeTime
        ),
        repeats: false
    )
    
    let snoozeRequest = UNNotificationRequest(
        identifier: "SNOOZE_REMINDER",
        content: snoozeContent,  // Copy of original notification with "snoozed" indicator
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(snoozeRequest) { error in
        if let error = error {
            print("Failed to schedule snooze: \(error)")
        }
    }
}
```

**Key Differences from Normal Reschedule:**
- Snooze schedules immediately without checking active days/hours
- Snooze doesn't respect schedule boundaries (e.g., can snooze past end-of-day)
- Snooze is explicitly temporary (user manually triggered)
- Snooze doesn't trigger dead response follow-up (user consciously snoozed)
- Snooze cancels any pending follow-up from missed notification (UX2)

**Notification Content for Snooze:**
```swift
// Should indicate this is a snoozed reminder
let snoozeContent = UNMutableNotificationContent()
snoozeContent.title = "Stand & Move" // Or append "(Snoozed)"
snoozeContent.body = "Time to exercise!" // Standard reminder text
snoozeContent.badge = NSNumber(value: 1)
snoozeContent.sound = .default
snoozeContent.categoryIdentifier = "STAND_FIT_REMINDERS"
// Optional: tag as snooze so it doesn't trigger another follow-up
```

**User Flow (Corrected):**
1. User receives reminder at 2:30 PM (configured 30-min interval)
2. Taps "Snooze +5min"
3. Notification dismisses
4. App schedules immediate re-notification for 2:35 PM (not respecting active hours)
5. At 2:35 PM, same reminder fires again
6. User can log exercise or snooze again

**Edge Cases to Handle:**
```swift
// What if user snoozes past midnight?
// Snooze should still fire (don't check active days)

// What if user snoozes past configured end hour (e.g., 5 PM)?
// Snooze should still fire (bypass active hours check)

// What if user snoozes then manually resets timer?
// Reset should cancel the pending snooze and schedule normally

// What if dead response timeout fires while snooze is pending?
// Snooze takes precedence (user explicitly snoozed)
// Cancel follow-up notification
```

**Files to Change:**
- `NotificationManager.swift`
  - Add `snoozeReminder(minutes:)` method
  - Update snooze action handler to call snooze method (not standard reschedule)
  - Add logic to cancel any pending follow-ups when snoozing
  - Ensure snooze ignores schedule boundaries
  
- `StandFitApp.swift`
  - Route snooze action to correct handler method
  - May need to verify snooze vs reset timer vs log exercise handlers

**Testing Checklist:**
- [ ] Tap snooze at configured end hour (e.g., 4:55 PM for 5 PM end) → fires at 5:00 PM (not next day)
- [ ] Tap snooze outside active days (e.g., Friday evening) → fires in 5 min regardless of day
- [ ] Snooze cancels pending dead response follow-up
- [ ] Multiple consecutive snoozes work (snooze, receive notification again, snooze again)
- [ ] Reset timer after snooze → next notification uses normal schedule
- [ ] Logging exercise while snoozed → clears snooze notification

**Related Issues:**
- UX2: Dead Response Reset (follow-ups should be cancelled on snooze)
- UX4: Snooze duration is hardcoded (could be made configurable)

**Priority:** Medium (affects user experience with notifications, but users can work around by logging exercise)

---

## UX9: Automatic Progress Report Notifications (Complete)

**Problem:** Users don't receive any automatic summaries of their progress. There's no celebration of achievements or awareness of trends without manually opening the app.

**Solution Implemented:**
Added comprehensive automatic progress report notifications with configurable frequency and schedule. Reports include exercise counts, comparisons to previous periods, and streak indicators.

### Features Implemented

**1. Core Infrastructure (ReportingModels.swift)**
- `NotificationType` enum - Centralized notification registry (exerciseReminder, deadResponseReminder, progressReport)
- `ReportPeriod` enum - Period calculations (today, yesterday, weekStarting, monthStarting, year)
- `ReportStats` struct - Comprehensive metrics with breakdown by exercise, comparison data, and streak tracking
- `ReportNotificationContent` - Smart content generation with pluralization, comparison arrows, streak emojis, and badge determination
- `ProgressReportSettings` struct - User settings (enabled, frequency, time) with Codable storage
- `ReportFrequency` enum - Daily and weekly frequencies with scheduling logic

**2. Data Aggregation (ExerciseStore.swift)**
- `ReportingService` struct - Unified statistics calculation engine:
  - `getStats(for period:)` - Calculates totals, breakdown, comparison, and streak for any period
  - `logsForPeriod()` - Filters exercise logs by date range
  - `exerciseBreakdown()` - Per-exercise totals with percentages
  - `previousPeriodStats()` - Recursive stats for comparison
  - `percentageChange()` - Calculates percentage delta
  - `calculateStreak()` - Counts consecutive active days
- `progressReportSettings` property - User preferences storage with Codable
- `updateAllNotificationSchedules()` - Central coordination method for all notification types

**3. Notification Scheduling (NotificationManager.swift)**
- Refactored to use `NotificationType` enum throughout (removed hardcoded ID strings)
- `setupNotificationCategories()` - Creates both exercise reminder and progress report notification categories
- `scheduleProgressReport(store:precachedStats:)` - Schedules report at configured time:
  - Automatic period determination (daily=today, weekly=weekStarting)
  - Stats calculation with ReportingService
  - Previous period comparison
  - ReportNotificationContent generation
  - UNCalendarNotificationTrigger scheduling at exact time
  - Error tracking with @Published lastNotificationError
- `cancelProgressReport()` - Removes scheduled progress report
- #if DEBUG utilities:
  - `triggerProgressReportNow()` - Fire report immediately for testing
  - `listScheduledNotifications()` - Debug output of all pending notifications

**4. Settings UI (ReminderScheduleView.swift)**
- "Progress Reports" section with:
  - Toggle to enable/disable
  - Frequency picker (Daily/Weekly)
  - Hour selector (0-23)
  - Minute selector (0, 15, 30, 45)
  - Next report time preview
- `calculateNextProgressReportTime()` - Shows user when next report will fire
- Integration with confirmation dialog showing what will change
- `updateAllNotificationSchedules()` call on save

**5. App Lifecycle Integration (StandFitApp.swift)**
- Enhanced `applicationDidFinishLaunching()` to:
  - Request notification permissions
  - Setup all notification categories
  - Call `updateAllNotificationSchedules()` on app launch
  - Ensure notifications are always scheduled

### Sample Notification Content

**Daily Report (8:00 PM):**
```
📊 Daily Report
Today: 87 points (↑15% vs yesterday)
🔥 5-day streak! Keep it up!
```

**Weekly Report (Sunday 8:00 PM):**
```
📊 Weekly Summary
This week: 423 points
Best day: Friday (120 pts)
↑8% vs last week
```

### Architecture Highlights

- **Scalable Design**: NotificationType enum makes adding UX10, UX11 notifications trivial
- **Shared Data Layer**: ReportingService used by both UX8 (charts) and UX9 (notifications)
- **Error Visibility**: @Published lastNotificationError surfaces issues in UI
- **User Control**: Full configuration in ReminderScheduleView with preview of next fire time
- **Privacy-Aware**: Only aggregated stats shared, no individual exercise details in notifications
- **Debuggable**: #if DEBUG utilities for testing without waiting for scheduled time

### Files Changed

- `ReportingModels.swift` (new) - 233 lines
- `ExerciseStore.swift` - Added ReportingService, progress settings, updateAllNotificationSchedules()
- `NotificationManager.swift` - Refactored with NotificationType enum, added scheduleProgressReport(), cancelProgressReport()
- `ReminderScheduleView.swift` - Added Progress Reports section with full UI and preview
- `StandFitApp.swift` - Enhanced app launch to schedule all notifications

---

## Completed

- **UX1**: Silent Settings Changes - 2026-01-01
- **UX2**: Dead Response Reset - 2026-01-01
- **UX3**: Custom Exercises with Icon Picker - 2026-01-01
- **UX5**: Log Exercise Deep Link - 2026-01-01
- **UX6**: Reset Timer Button Interval Display - 2026-01-02
- **UX9**: Automatic Progress Report Notifications - 2026-01-02

---

## Change Release Log

### 2026-01-02: UX9 - Automatic Progress Report Notifications

**Status:** ✅ Complete  
**Complexity:** High  
**Files Created:** 1 new file (ReportingModels.swift)  
**Files Modified:** 4 (ExerciseStore.swift, NotificationManager.swift, ReminderScheduleView.swift, StandFitApp.swift)  

**Summary:**
Implemented comprehensive automatic progress report notifications. Users now receive configurable daily/weekly summaries showing exercise counts, comparisons to previous periods, and streak tracking. Full settings UI in ReminderScheduleView with next-report preview. Follows scalable NotificationType enum pattern for future notification features (UX10, UX11).

**Key Components:**
- ReportingService for unified stats calculation (shared between UX8, UX9, UX10, UX11)
- NotificationType enum centralizes notification management
- ProgressReportSettings with Codable storage
- ReportNotificationContent smart formatting (pluralization, comparison arrows, streak emojis)
- scheduleProgressReport() with error tracking
- Full settings UI in ReminderScheduleView
- App lifecycle integration for always-scheduled notifications

**Testing Completed:**
- ✅ No compilation errors
- ✅ All new types follow existing patterns (Codable, Equatable)
- ✅ Notification categories properly configured
- ✅ Integration with existing notification system verified
- ✅ Settings UI connected to notification scheduling

**Blocking Issues:** None  
**Dependencies:** None (uses existing UserNotifications, Foundation)  
**Future Work:** UX8 (ProgressReportView) and UX10 (Gamification) leverage ReportingService

---

### Previous Updates

**2026-01-02:** UX6 - Reset Timer Button context added
**2026-01-01:** UX1, UX2, UX3, UX5 completed

---

## UX8 & UX9 Implementation Summary (2026-01-01)

### Critical Bug Fixes

**Issue 1: Non-Repeating Progress Report Notifications**
- **Bug**: Used `UNTimeIntervalNotificationTrigger` with `repeats: false`, causing reports to fire once and never again
- **Fix**: Changed to `UNCalendarNotificationTrigger` with `repeats: true` for automatic daily/weekly repetition
- **File**: [NotificationManager.swift:262-326](NotificationManager.swift#L262-L326)

**Issue 2: Settings Hidden in Wrong Location**
- **Bug**: Progress report settings buried in ReminderScheduleView (Settings → Schedule → scroll)
- **Fix**: Created dedicated `ProgressReportSettingsView.swift` with proper navigation from SettingsView
- **Files**:
  - [ProgressReportSettingsView.swift](ProgressReportSettingsView.swift) (new)
  - [SettingsView.swift:80-99](SettingsView.swift#L80-L99) (added Reports section)
  - [ReminderScheduleView.swift](ReminderScheduleView.swift) (removed progress report code)

### UX8: Progress Report View Implementation

Created complete progress reporting UI with charts and analytics:

**New Files Created:**
1. [ProgressReportView.swift](ProgressReportView.swift) - Main view with period selector (Today/Week/Month)
2. [StatsHeaderView.swift](StatsHeaderView.swift) - Summary stats with comparison arrows and streak badges
3. [ProgressChartsView.swift](ProgressChartsView.swift) - Swift Charts bar visualization + ExerciseBreakdownView

**Features:**
- Period selector (segmented picker): Today, Week, Month
- Total exercise count with comparison to previous period (↑15% vs last week)
- Streak indicator with visual badges (🔥 7-day streak ⭐)
- Bar charts showing daily activity breakdown
- Exercise breakdown by type with percentage bars
- Empty states for periods with no data
- Deep linking from notification "View Details" action

**Navigation:**
- Bottom toolbar button in ContentView: "Progress" with chart icon
- Deep link support via NotificationCenter.showProgressReport

### UX9: Automatic Progress Report Notifications Implementation

Implemented fully functional automatic progress reports:

**Features:**
- Calendar-based repeating notifications (daily/weekly)
- Daily reports: Fire at configured time every day (default: 8:00 PM)
- Weekly reports: Fire every Sunday at configured time
- Dynamic content generation from actual exercise data
- Comparison to previous period (yesterday/last week)
- Streak tracking and badges
- "View Details" action button that deep links to ProgressReportView

**Settings UI:**
- Dedicated ProgressReportSettingsView accessible from Settings → Progress Reports
- Toggle to enable/disable reports
- Frequency picker (Daily/Weekly)
- Time pickers (Hour/Minute with 15-min increments)
- Clear footer text explaining schedule

**Technical Implementation:**
- `UNCalendarNotificationTrigger` with `repeats: true` for automatic scheduling
- `ReportingService` in ExerciseStore for data aggregation
- `ReportNotificationContent.generate()` for dynamic notification text
- Proper notification category with "VIEW_REPORT" action
- Deep link handler in StandFitApp.swift

**Files Modified:**
- [NotificationManager.swift](NotificationManager.swift) - Fixed trigger, added VIEW_REPORT action
- [StandFitApp.swift:78-83](StandFitApp.swift#L78-L83) - Added VIEW_REPORT handler
- [ContentView.swift](ContentView.swift) - Added showProgressReport state and deep link listener

---

## UX13: Progress Report Crashes on Week/Month Selection 🔴 CRITICAL BUG

**Problem:** The Progress Report view immediately **crashes/freezes the application at runtime** when the user selects "Week" or "Month" from the Period picker. The app becomes unresponsive and must be force-quit.

**Severity:** 🔴 **CRITICAL** - Complete application crash requiring force quit. Renders 2/3 of the progress reporting feature unusable.

**Reproduction Steps:**
1. Open StandFit app
2. Navigate to Progress (bottom button or notification deep link)
3. Tap "Period" picker
4. Select "Week" → **App crashes/freezes**
5. OR select "Month" → **App crashes/freezes**

**Expected Behavior:**
- Selecting "Week" should show weekly progress chart and breakdown
- Selecting "Month" should show monthly progress chart and breakdown
- App should remain responsive and not crash

**Current Behavior:**
- App freezes immediately upon selection
- No error message shown
- App becomes completely unresponsive
- Must force quit to recover

**Attempted Fixes:**
- ✅ Fixed force-unwrapped optionals in `ReportingModels.swift` `startDate` and `endDate` properties
- ✅ Replaced `!` with `??` nil-coalescing operators
- ✅ Added fallback values for date calculations
- ✅ Changed from `.map` to `.compactMap` with `guard` statements in chart data calculation
- ✅ Fixed picker binding to use simple `PeriodType` enum instead of associated values
- ✅ Normalized all dates with `calendar.startOfDay()`
- ✅ Fixed deleted exercise handling to skip rather than fallback
- ❌ **CRASH PERSISTS** - None of these fixes resolved the issue

**Technical Analysis:**
The crash occurs when:
1. User selects Week or Month from the picker
2. `ProgressReportView` creates a `ReportPeriod` with associated value (`.weekStarting(Date)` or `.monthStarting(Date)`)
3. Some downstream code attempts to process this period
4. **App freezes/crashes** - exact crash point unknown

**Suspected Root Causes:**
1. **Infinite loop** in chart data calculation or stats aggregation
2. **Memory issue** from processing large date ranges
3. **Threading issue** causing UI freeze on main thread
4. **Hashable implementation** of `ReportPeriod` with associated values causing issues
5. **Date calculation edge case** not caught by guards

**Files Involved:**
- [ProgressReportView.swift](StandFit%20Watch%20App/ProgressReportView.swift) - Period picker and selection logic
- [ProgressChartsView.swift](StandFit%20Watch%20App/ProgressChartsView.swift) - Chart data calculation
- [ReportingModels.swift](StandFit%20Watch%20App/ReportingModels.swift) - `ReportPeriod` enum with date calculations
- [ExerciseStore.swift](StandFit%20Watch%20App/ExerciseStore.swift) - `ReportingService.getStats()` method

**Impact:**
- Users cannot view weekly progress
- Users cannot view monthly progress
- Only "Today" view is functional
- Major feature limitation for progress tracking

**Priority:** 🔴 **CRITICAL** - Must be fixed before any release

**Status:** ⚠️ **OPEN** - Multiple attempted fixes have failed to resolve the issue

**Next Steps:**
1. Add debug logging to identify exact crash point
2. Test with empty data sets to isolate data vs logic issues
3. Profile memory usage during Week/Month selection
4. Consider simplifying chart data calculation
5. Add error boundaries/try-catch around suspect code
6. Test on device vs simulator for platform-specific issues

---

## UX14: Notification vs. Exercise Timeline Visualization (Complete)

**Problem:** Users had no visibility into when notifications fired vs. when they actually logged exercises, making it impossible to identify response patterns or optimize notification timing.

**Solution Implemented:**
A comprehensive timeline visualization system that shows the correlation between notification delivery and exercise logging throughout the day.

**Features:**
- **Two-Track Timeline**: Visual representation with notification dots and exercise checkmarks
- **Dynamic Hour Range**: Automatically adjusts to show relevant time periods based on data
- **Response Analytics**: Shows average response time and response rate percentage
- **Smart Data Sources**: Uses actual notification fire timestamps when available, falls back to inferred schedule
- **Clean UI**: Minimal watchOS-optimized design with legends and empty states

**Technical Architecture:**

1. **TimelineModels.swift** (NEW) - Core data structures
   - `TimelineEvent`: Represents point-in-time notification or exercise event
   - `TimelineAnalysis`: Calculates response metrics (avg time, response rate, missed notifications)
   - `NotificationFiredLog`: Ephemeral storage for tracking actual notification delivery times

2. **NotificationScheduleCalculator.swift** (NEW) - Schedule inference
   - Calculates theoretical notification times based on user settings
   - Generates schedules for any date range
   - Fallback when actual fire data unavailable

3. **TimelineGraphView.swift** (NEW) - Visualization component
   - Modular two-track event visualization
   - `EventTrackView`: Reusable track component with dynamic positioning
   - Dynamic time axis with smart hour range calculation
   - Response metrics display in header and legend

4. **StandFitApp.swift** - Notification tracking
   - Added timestamp recording in `willPresent` delegate
   - Captures actual notification delivery times for accurate timeline data

5. **ExerciseStore.swift** - ReportingService extension
   - `getTodaysTimeline()`: Aggregates notifications and exercises
   - `getTodaysTimelineAnalysis()`: Provides analytics wrapper
   - Smart fallback between actual and inferred notification data

6. **ProgressReportView.swift** - Integration
   - Timeline view shown only for "Today" period (appropriate scope)
   - Positioned between stats header and charts for logical flow

**Design Principles Applied:**
✅ **Modularity**: Separate models, calculator, view components
✅ **Extensibility**: Easy to add weekly/monthly timeline views
✅ **Clarity**: Clear separation between data, logic, and presentation
✅ **Robustness**: Graceful fallbacks when data unavailable
✅ **Performance**: Lightweight ephemeral storage, efficient calculations

**Future Enhancements Ready:**
- Response time heatmap (busiest times)
- Connecting lines between notification → exercise with color-coded delay
- Weekly aggregated timeline showing patterns across days
- Smart notification time recommendations based on historical response data

**Files Created:**
- `TimelineModels.swift` - 150 lines
- `NotificationScheduleCalculator.swift` - 70 lines
- `TimelineGraphView.swift` - 280 lines

**Files Modified:**
- `StandFitApp.swift` - Added notification firing timestamp tracking
- `ExerciseStore.swift` - Extended ReportingService with timeline methods
- `ProgressReportView.swift` - Integrated timeline view for Today period

**Impact:**
- Users can now see when they're most responsive to notifications
- Identifies optimal notification times based on historical patterns
- Shows missed notifications clearly
- Foundation for smart adaptive notification scheduling

---

## UX16: User-Created Achievement Templates (Pending)

**Problem:** Users can create custom exercises, but there's no way to create achievement milestones for those exercises. Built-in exercises have volume achievements (e.g., "100 pushups"), but custom exercises lack this motivation layer. Additionally, there's no way to filter achievements by exercise type, making it hard to track progress toward exercise-specific goals.

**User Story:**
> "I created a custom 'Pull-ups' exercise. I want to set achievement goals like '50 pull-ups', '100 pull-ups', and '250 pull-ups' just like the built-in exercises have. I also want to see all my pull-up achievements in one place."

**Proposed Solution:**

Implement an **Achievement Template System** that allows users to create customizable achievement tiers for any exercise (built-in or custom), with filtering, templates, and automatic progression tracking.

---

### Design Philosophy

The system must be:
1. **Template-Based**: Users shouldn't recreate the same structure; they apply templates
2. **Modular**: Templates, tiers, and achievements are separate concerns
3. **Extensible**: Easy to add new template types beyond volume
4. **Automatic**: Achievements auto-generate from templates
5. **Persistent**: User templates survive exercise deletion (can be reapplied)

---

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User-Facing Layer                        │
│  ┌──────────────────┐  ┌──────────────────────────────┐   │
│  │ AchievementsView │  │ CreateAchievementTemplateView│   │
│  │ (with filters)   │  │ (template builder)           │   │
│  └──────────────────┘  └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Template System                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │ AchievementTemplate                                 │    │
│  │ - Exercise reference (UUID or name)                 │    │
│  │ - Template type (volume, streak, time-based)        │    │
│  │ - Tier definitions (targets + icons)                │    │
│  │ - Auto-generation rules                             │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                 Achievement Generation                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │ TemplateEngine                                      │    │
│  │ - Converts templates → concrete achievements        │    │
│  │ - Handles exercise deletion gracefully              │    │
│  │ - Merges with built-in achievements                 │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                Existing Achievement System                  │
│  GamificationStore.achievements[] (unified array)           │
└─────────────────────────────────────────────────────────────┘
```

---

### 1. Data Models

#### AchievementTemplate (New)

```swift
/// User-defined template for generating achievements
struct AchievementTemplate: Identifiable, Codable {
    let id: UUID
    var exerciseReference: ExerciseReference
    var templateType: AchievementTemplateType
    var tiers: [AchievementTemplateTier]
    var createdAt: Date
    var isActive: Bool  // Can be disabled without deletion

    enum ExerciseReference: Codable, Equatable {
        case builtIn(String)      // e.g., "Pushups"
        case custom(UUID)         // CustomExercise.id
        case any                  // Applies to all exercises (future)

        var displayName: String {
            switch self {
            case .builtIn(let name): return name
            case .custom(let id):
                // Look up in ExerciseStore
                return ExerciseStore.shared.customExercise(byId: id)?.name ?? "Unknown"
            case .any: return "Any Exercise"
            }
        }
    }
}

enum AchievementTemplateType: String, Codable, CaseIterable {
    case volume = "Volume"           // Total count achievements
    case streak = "Streak"           // Consecutive days with this exercise
    case daily = "Daily Goal"        // N reps/time in one day
    case weekly = "Weekly Goal"      // N reps/time in one week
    case speed = "Speed"             // N reps in M minutes

    var icon: String {
        switch self {
        case .volume: return "chart.bar.fill"
        case .streak: return "flame.fill"
        case .daily: return "calendar"
        case .weekly: return "calendar.badge.checkmark"
        case .speed: return "speedometer"
        }
    }

    var defaultTiers: [AchievementTemplateTier] {
        switch self {
        case .volume:
            return [
                AchievementTemplateTier(tier: .bronze, target: 50, name: "Novice"),
                AchievementTemplateTier(tier: .silver, target: 100, name: "Intermediate"),
                AchievementTemplateTier(tier: .gold, target: 500, name: "Advanced"),
                AchievementTemplateTier(tier: .platinum, target: 1000, name: "Master")
            ]
        case .streak:
            return [
                AchievementTemplateTier(tier: .bronze, target: 3, name: "Started"),
                AchievementTemplateTier(tier: .silver, target: 7, name: "Week Warrior"),
                AchievementTemplateTier(tier: .gold, target: 30, name: "Monthly Master")
            ]
        case .daily:
            return [
                AchievementTemplateTier(tier: .bronze, target: 20, name: "Daily Challenger"),
                AchievementTemplateTier(tier: .silver, target: 50, name: "Daily Grind"),
                AchievementTemplateTier(tier: .gold, target: 100, name: "Daily Dominator")
            ]
        case .weekly:
            return [
                AchievementTemplateTier(tier: .bronze, target: 100, name: "Weekly Warrior"),
                AchievementTemplateTier(tier: .silver, target: 250, name: "Weekly Crusher")
            ]
        case .speed:
            return [
                AchievementTemplateTier(tier: .bronze, target: 10, name: "Speed Starter"),
                AchievementTemplateTier(tier: .silver, target: 25, name: "Speed Demon")
            ]
        }
    }
}

struct AchievementTemplateTier: Codable, Identifiable {
    let id: UUID = UUID()
    var tier: AchievementTier
    var target: Int           // Target value (reps, days, seconds, etc.)
    var name: String          // Suffix for achievement name (e.g., "Novice", "Master")
    var customIcon: String?   // Optional override for default tier icon

    var effectiveIcon: String {
        customIcon ?? tier.defaultIcon
    }
}

extension AchievementTier {
    var defaultIcon: String {
        switch self {
        case .bronze: return "seal.fill"
        case .silver: return "medal.fill"
        case .gold: return "trophy.fill"
        case .platinum: return "crown.fill"
        }
    }
}
```

---

### 2. Template Engine

```swift
/// Converts templates into concrete achievements
struct TemplateEngine {

    /// Generate achievements from all active templates
    static func generateAchievements(
        from templates: [AchievementTemplate],
        existingAchievements: [Achievement],
        exerciseStore: ExerciseStore
    ) -> [Achievement] {
        var generated: [Achievement] = []

        for template in templates where template.isActive {
            let achievements = generateAchievements(
                from: template,
                exerciseStore: exerciseStore
            )
            generated.append(contentsOf: achievements)
        }

        // Merge with existing achievements, preserving progress
        return mergeAchievements(
            generated: generated,
            existing: existingAchievements
        )
    }

    /// Generate achievements from a single template
    private static func generateAchievements(
        from template: AchievementTemplate,
        exerciseStore: ExerciseStore
    ) -> [Achievement] {
        var achievements: [Achievement] = []

        // Get exercise details
        guard let exerciseName = getExerciseName(
            for: template.exerciseReference,
            from: exerciseStore
        ) else {
            // Exercise was deleted - skip but keep template
            return []
        }

        // Generate one achievement per tier
        for tier in template.tiers {
            let achievement = Achievement(
                id: generateID(template: template, tier: tier),
                name: "\(exerciseName) \(tier.name)",
                description: generateDescription(
                    template: template,
                    exerciseName: exerciseName,
                    target: tier.target
                ),
                icon: tier.effectiveIcon,
                category: template.templateType.category,
                tier: tier.tier,
                requirement: generateRequirement(
                    template: template,
                    exerciseName: exerciseName,
                    target: tier.target
                ),
                progress: 0
            )
            achievements.append(achievement)
        }

        return achievements
    }

    /// Generate stable achievement ID from template + tier
    private static func generateID(
        template: AchievementTemplate,
        tier: AchievementTemplateTier
    ) -> String {
        // Stable ID that survives app restart
        let exerciseKey: String
        switch template.exerciseReference {
        case .builtIn(let name):
            exerciseKey = name.lowercased().replacingOccurrences(of: " ", with: "_")
        case .custom(let id):
            exerciseKey = "custom_\(id.uuidString.prefix(8))"
        case .any:
            exerciseKey = "any"
        }

        let typeKey = template.templateType.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
        let tierKey = tier.tier.rawValue.lowercased()

        return "\(exerciseKey)_\(typeKey)_\(tierKey)_\(tier.target)"
    }

    /// Generate requirement from template type
    private static func generateRequirement(
        template: AchievementTemplate,
        exerciseName: String,
        target: Int
    ) -> AchievementRequirement {
        switch template.templateType {
        case .volume:
            return .specificExercise(exerciseName, target)
        case .streak:
            return .exerciseSpecificStreak(exerciseName, target)  // NEW requirement type
        case .daily:
            return .exerciseInDay(exerciseName, target)  // NEW requirement type
        case .weekly:
            return .exerciseInWeek(exerciseName, target)  // NEW requirement type
        case .speed:
            return .exerciseSpeed(exerciseName, reps: target, minutes: 10)  // NEW
        }
    }

    /// Generate human-readable description
    private static func generateDescription(
        template: AchievementTemplate,
        exerciseName: String,
        target: Int
    ) -> String {
        switch template.templateType {
        case .volume:
            return "Complete \(target) total \(exerciseName.lowercased())"
        case .streak:
            return "Do \(exerciseName.lowercased()) \(target) days in a row"
        case .daily:
            return "Complete \(target) \(exerciseName.lowercased()) in one day"
        case .weekly:
            return "Complete \(target) \(exerciseName.lowercased()) in one week"
        case .speed:
            return "Complete \(target) \(exerciseName.lowercased()) in 10 minutes"
        }
    }

    /// Merge generated achievements with existing, preserving progress
    private static func mergeAchievements(
        generated: [Achievement],
        existing: [Achievement]
    ) -> [Achievement] {
        var merged: [Achievement] = []
        let existingDict = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for achievement in generated {
            if let existing = existingDict[achievement.id] {
                // Preserve progress and unlock date
                var updated = achievement
                updated.progress = existing.progress
                updated.unlockedAt = existing.unlockedAt
                merged.append(updated)
            } else {
                merged.append(achievement)
            }
        }

        return merged
    }

    private static func getExerciseName(
        for reference: AchievementTemplate.ExerciseReference,
        from store: ExerciseStore
    ) -> String? {
        switch reference {
        case .builtIn(let name):
            return name
        case .custom(let id):
            return store.customExercise(byId: id)?.name
        case .any:
            return "Exercise"
        }
    }
}

extension AchievementTemplateType {
    var category: AchievementCategory {
        switch self {
        case .volume: return .volume
        case .streak: return .consistency
        case .daily, .weekly: return .challenge
        case .speed: return .challenge
        }
    }
}
```

---

### 3. New Achievement Requirement Types

Add to `AchievementRequirement` enum in `GamificationModels.swift`:

```swift
enum AchievementRequirement: Codable, Equatable {
    // ... existing cases ...

    // New requirement types for templates
    case exerciseSpecificStreak(String, Int)  // Exercise name, days
    case exerciseInDay(String, Int)           // Exercise name, count in one day
    case exerciseInWeek(String, Int)          // Exercise name, count in one week
    case exerciseSpeed(String, reps: Int, minutes: Int)  // Exercise, reps, time limit

    var targetValue: Int {
        switch self {
        // ... existing cases ...
        case .exerciseSpecificStreak(_, let days): return days
        case .exerciseInDay(_, let count): return count
        case .exerciseInWeek(_, let count): return count
        case .exerciseSpeed(_, let reps, _): return reps
        }
    }
}
```

Evaluation logic in `AchievementEngine`:

```swift
case .exerciseSpecificStreak(let exerciseName, let target):
    // Track consecutive days with this specific exercise
    // Would need StreakData per exercise (future enhancement)
    return (0, false)  // Placeholder

case .exerciseInDay(let exerciseName, let target):
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let todaysLogs = store.logs.filter {
        calendar.isDate($0.timestamp, inSameDayAs: today) &&
        matchesExercise($0, name: exerciseName, store: store)
    }
    let count = todaysLogs.reduce(0) { $0 + $1.count }
    return (count, count >= target)

case .exerciseInWeek(let exerciseName, let target):
    let calendar = Calendar.current
    let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    let weekLogs = store.logs.filter {
        $0.timestamp >= weekStart &&
        matchesExercise($0, name: exerciseName, store: store)
    }
    let count = weekLogs.reduce(0) { $0 + $1.count }
    return (count, count >= target)

case .exerciseSpeed(let exerciseName, let reps, let minutes):
    // Find if user ever did N reps in M minutes
    // Group logs by time windows
    let matchingLogs = store.logs.filter { matchesExercise($0, name: exerciseName, store: store) }
    // Complex logic to find windowed completions
    return (0, false)  // Placeholder

// Helper function
private func matchesExercise(_ log: ExerciseLog, name: String, store: ExerciseStore) -> Bool {
    if let exerciseType = log.exerciseType {
        return exerciseType.rawValue == name
    } else if let customId = log.customExerciseId,
              let custom = store.customExercise(byId: customId) {
        return custom.name == name
    }
    return false
}
```

---

### 4. UI Components

#### CreateAchievementTemplateView

```swift
struct CreateAchievementTemplateView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedExercise: ExerciseItem?
    @State private var selectedTemplateType: AchievementTemplateType = .volume
    @State private var tiers: [AchievementTemplateTier] = []

    var body: some View {
        Form {
            // Exercise selection
            Section("Exercise") {
                Picker("Choose Exercise", selection: $selectedExercise) {
                    Text("Select...").tag(nil as ExerciseItem?)
                    ForEach(exerciseStore.allExercises) { exercise in
                        HStack {
                            Image(systemName: exercise.icon)
                            Text(exercise.name)
                        }
                        .tag(exercise as ExerciseItem?)
                    }
                }
            }

            // Template type
            Section("Achievement Type") {
                Picker("Type", selection: $selectedTemplateType) {
                    ForEach(AchievementTemplateType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon)
                    }
                }
                .onChange(of: selectedTemplateType) { newType in
                    tiers = newType.defaultTiers
                }
            }

            // Tier configuration
            Section("Milestones") {
                ForEach($tiers) { $tier in
                    HStack {
                        Circle()
                            .fill(tier.tier.color)
                            .frame(width: 12, height: 12)
                        TextField("Name", text: $tier.name)
                        Spacer()
                        TextField("Target", value: $tier.target, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }
            }

            // Preview
            Section("Preview") {
                if let exercise = selectedExercise {
                    ForEach(tiers) { tier in
                        Text("\(exercise.name) \(tier.name)")
                            .font(.caption)
                        Text(TemplateEngine.generateDescription(
                            template: createTemplate(),
                            exerciseName: exercise.name,
                            target: tier.target
                        ))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Create Achievement Template")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createTemplate()
                    dismiss()
                }
                .disabled(selectedExercise == nil)
            }
        }
    }

    private func createTemplate() {
        guard let exercise = selectedExercise else { return }

        let reference: AchievementTemplate.ExerciseReference
        if exercise.isBuiltIn, let builtInType = exercise.builtInType {
            reference = .builtIn(builtInType.rawValue)
        } else if let customExercise = exercise.customExercise {
            reference = .custom(customExercise.id)
        } else {
            return
        }

        let template = AchievementTemplate(
            id: UUID(),
            exerciseReference: reference,
            templateType: selectedTemplateType,
            tiers: tiers,
            createdAt: Date(),
            isActive: true
        )

        gamificationStore.addTemplate(template)
    }
}
```

#### Exercise Filter in AchievementsView

Update `AchievementsView.swift`:

```swift
struct AchievementsView: View {
    @ObservedObject var gamificationStore: GamificationStore
    @ObservedObject var exerciseStore: ExerciseStore
    @State private var selectedCategory: AchievementCategory?
    @State private var selectedExercise: String?  // NEW: Exercise filter

    var body: some View {
        List {
            summarySection

            // Combined filter section
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // Category filters
                        categoryPill(nil, label: "All")
                        ForEach(AchievementCategory.allCases) { category in
                            categoryPill(category, label: category.rawValue)
                        }
                    }
                }

                // Exercise filter (if category is volume/consistency)
                if selectedCategory == .volume || selectedCategory == .consistency || selectedCategory == nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            exercisePill(nil, label: "All Exercises")
                            ForEach(getExercisesWithAchievements()) { exercise in
                                exercisePill(exercise, label: exercise.name)
                            }
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets())

            // Achievements list (now filtered by both category and exercise)
            // ... rest of view ...
        }
        .navigationTitle("Achievements")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateTemplate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateTemplate) {
            NavigationStack {
                CreateAchievementTemplateView(
                    gamificationStore: gamificationStore,
                    exerciseStore: exerciseStore
                )
            }
        }
    }

    private func exercisePill(_ exercise: ExerciseItem?, label: String) -> some View {
        let isSelected = (selectedExercise == nil && exercise == nil) ||
                         (selectedExercise == exercise?.name)

        return Button {
            withAnimation {
                selectedExercise = exercise?.name
            }
        } label: {
            HStack(spacing: 4) {
                if let exercise = exercise {
                    Image(systemName: exercise.icon)
                        .font(.caption2)
                }
                Text(label)
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.green : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func getExercisesWithAchievements() -> [ExerciseItem] {
        let exerciseNames = Set(
            gamificationStore.achievements
                .compactMap { achievement -> String? in
                    if case .specificExercise(let name, _) = achievement.requirement {
                        return name
                    }
                    return nil
                }
        )

        return exerciseStore.allExercises.filter { exerciseNames.contains($0.name) }
    }

    private var filteredAchievements: [Achievement] {
        gamificationStore.achievements.filter { achievement in
            // Category filter
            if let category = selectedCategory, achievement.category != category {
                return false
            }

            // Exercise filter
            if let exerciseName = selectedExercise {
                switch achievement.requirement {
                case .specificExercise(let name, _),
                     .exerciseSpecificStreak(let name, _),
                     .exerciseInDay(let name, _),
                     .exerciseInWeek(let name, _),
                     .exerciseSpeed(let name, _, _):
                    return name == exerciseName
                default:
                    return false
                }
            }

            return true
        }
    }
}
```

---

### 5. GamificationStore Integration

Update `GamificationStore.swift`:

```swift
@MainActor
class GamificationStore: ObservableObject {
    // ... existing properties ...
    @Published var templates: [AchievementTemplate] = []

    struct GamificationData: Codable {
        var achievements: [Achievement]
        var streak: StreakData
        var levelProgress: LevelProgress
        var activeChallenges: [Challenge]
        var templates: [AchievementTemplate]  // NEW
    }

    private func initializeAchievementsIfNeeded() {
        if achievements.isEmpty {
            // Load built-in achievements
            var all = AchievementDefinitions.all

            // Generate achievements from templates
            let templateGenerated = TemplateEngine.generateAchievements(
                from: templates,
                existingAchievements: [],
                exerciseStore: ExerciseStore.shared
            )

            all.append(contentsOf: templateGenerated)
            achievements = all
            saveData()
        }
    }

    // MARK: - Template Management

    func addTemplate(_ template: AchievementTemplate) {
        templates.append(template)
        regenerateAchievements()
        saveData()
    }

    func updateTemplate(_ template: AchievementTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            regenerateAchievements()
            saveData()
        }
    }

    func deleteTemplate(_ template: AchievementTemplate) {
        templates.removeAll { $0.id == template.id }
        // Remove generated achievements from this template
        achievements.removeAll { achievement in
            achievement.id.starts(with: template.id.uuidString)
        }
        saveData()
    }

    func toggleTemplate(_ template: AchievementTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index].isActive.toggle()
            regenerateAchievements()
            saveData()
        }
    }

    private func regenerateAchievements() {
        // Regenerate achievements from templates while preserving progress
        let builtIn = AchievementDefinitions.all
        let templateGenerated = TemplateEngine.generateAchievements(
            from: templates,
            existingAchievements: achievements,
            exerciseStore: ExerciseStore.shared
        )

        achievements = builtIn + templateGenerated
    }
}
```

---

### 6. Preset Template Library

Create common templates users can apply with one tap:

```swift
struct TemplatePresets {
    static let volumeBasic = AchievementTemplate(
        id: UUID(),
        exerciseReference: .any,  // Placeholder - user selects exercise
        templateType: .volume,
        tiers: [
            AchievementTemplateTier(tier: .bronze, target: 50, name: "Novice"),
            AchievementTemplateTier(tier: .silver, target: 100, name: "Intermediate"),
            AchievementTemplateTier(tier: .gold, target: 500, name: "Advanced"),
            AchievementTemplateTier(tier: .platinum, target: 1000, name: "Master")
        ],
        createdAt: Date(),
        isActive: false
    )

    static let streakBasic = AchievementTemplate(
        id: UUID(),
        exerciseReference: .any,
        templateType: .streak,
        tiers: [
            AchievementTemplateTier(tier: .bronze, target: 3, name: "Started"),
            AchievementTemplateTier(tier: .silver, target: 7, name: "Week Streak"),
            AchievementTemplateTier(tier: .gold, target: 30, name: "Month Streak")
        ],
        createdAt: Date(),
        isActive: false
    )

    static let all: [AchievementTemplate] = [
        volumeBasic,
        streakBasic
    ]
}

// UI for applying presets
struct TemplatePresetsView: View {
    @ObservedObject var gamificationStore: GamificationStore
    let exercise: ExerciseItem

    var body: some View {
        List(TemplatePresets.all) { preset in
            Button {
                var template = preset
                template.id = UUID()  // New ID for this instance

                // Set exercise reference
                if exercise.isBuiltIn, let builtInType = exercise.builtInType {
                    template.exerciseReference = .builtIn(builtInType.rawValue)
                } else if let customExercise = exercise.customExercise {
                    template.exerciseReference = .custom(customExercise.id)
                }

                template.isActive = true
                gamificationStore.addTemplate(template)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: preset.templateType.icon)
                        Text(preset.templateType.rawValue)
                            .fontWeight(.semibold)
                    }
                    Text("\(preset.tiers.count) milestones")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Apply Template")
    }
}
```

---

### 7. Exercise Deletion Handling

When a user deletes a custom exercise:

```swift
// In ExerciseStore.swift
func deleteCustomExercise(_ exercise: CustomExercise) {
    customExercises.removeAll { $0.id == exercise.id }

    // Update sort orders
    for i in 0..<customExercises.count {
        customExercises[i].sortOrder = i
    }
    saveCustomExercises()

    // Notify GamificationStore to handle orphaned achievements
    GamificationStore.shared.handleExerciseDeleted(exerciseId: exercise.id)
}

// In GamificationStore.swift
func handleExerciseDeleted(exerciseId: UUID) {
    // Option 1: Deactivate templates (preserve for potential re-activation)
    for i in 0..<templates.count {
        if case .custom(let id) = templates[i].exerciseReference, id == exerciseId {
            templates[i].isActive = false
        }
    }

    // Option 2: Keep achievements but mark as "archived" or hide from active list
    // This preserves user progress even if they delete and recreate the exercise

    regenerateAchievements()
    saveData()
}
```

---

### Implementation Recommendations

#### Phase 1: Foundation (Core Template System)
**Files to Create:**
- `AchievementTemplateModels.swift` - Template data structures
- `TemplateEngine.swift` - Template → Achievement generation logic
- `CreateAchievementTemplateView.swift` - Basic template creation UI

**Files to Modify:**
- `GamificationModels.swift` - Add new `AchievementRequirement` cases
- `GamificationStore.swift` - Add template management, regeneration logic
- `AchievementEngine.swift` - Add evaluation for new requirement types

**Estimated Scope:** 400-500 lines total

#### Phase 2: UI Enhancement (Filtering & Presets)
**Files to Modify:**
- `AchievementsView.swift` - Add exercise filtering, template creation button
- `CreateExerciseView.swift` - Add "Create Achievements" quick action

**Files to Create:**
- `TemplatePresetsView.swift` - Preset template library
- `ManageTemplatesView.swift` - View/edit/delete existing templates

**Estimated Scope:** 300-400 lines total

#### Phase 3: Advanced Features (Optional)
- Exercise-specific streak tracking (requires per-exercise `StreakData`)
- Speed achievements with time window detection
- Batch template application (apply template to all exercises)
- Template sharing (export/import JSON)

---

### Architectural Benefits

✅ **Modular**: Templates are separate from achievements (concerns separated)
✅ **Extensible**: New template types = add enum case + evaluation logic
✅ **Persistent**: Templates survive exercise deletion, can be reapplied
✅ **Automatic**: Achievements regenerate on template changes
✅ **Flexible**: Same template can create 1-10 achievements depending on tiers
✅ **User-Friendly**: Presets provide instant gratification
✅ **Maintainable**: Clear separation between built-in and generated achievements

---

### Data Flow Example

```
User creates custom "Pull-ups" exercise
    ↓
User taps "Create Achievements" → Opens CreateAchievementTemplateView
    ↓
Selects "Pull-ups" + "Volume" template type
    ↓
System auto-populates default tiers (50, 100, 500, 1000)
    ↓
User adjusts tiers (25, 50, 100, 250)
    ↓
User taps "Create"
    ↓
AchievementTemplate created with reference to Pull-ups custom exercise ID
    ↓
TemplateEngine.generateAchievements() runs
    ↓
4 achievements created:
- "Pull-ups Novice" (25 total)
- "Pull-ups Intermediate" (50 total)
- "Pull-ups Advanced" (100 total)
- "Pull-ups Master" (250 total)
    ↓
Achievements appear in AchievementsView
    ↓
User filters by "Pull-ups" → sees only pull-up achievements
    ↓
Progress tracked automatically via existing AchievementEngine
```

---

### Future Enhancements

1. **Template Marketplace**: Share templates with community
2. **Auto-Template Suggestions**: AI suggests templates based on usage patterns
3. **Progressive Template**: Automatically increase targets when achieved (infinite progression)
4. **Comparative Achievements**: "More than 75% of users" style benchmarks
5. **Time-Decay Templates**: Achievements that reset monthly/yearly
6. **Combo Templates**: Multi-exercise achievements (10 push-ups + 10 squats)

---

### Files to Create

1. **AchievementTemplateModels.swift** (~200 lines)
   - `AchievementTemplate`
   - `AchievementTemplateType`
   - `AchievementTemplateTier`
   - `TemplatePresets`

2. **TemplateEngine.swift** (~150 lines)
   - Achievement generation logic
   - Merging logic
   - ID generation
   - Description generation

3. **CreateAchievementTemplateView.swift** (~200 lines)
   - Template creation UI
   - Exercise picker
   - Tier editor
   - Preview section

4. **ManageTemplatesView.swift** (~150 lines)
   - List existing templates
   - Enable/disable toggles
   - Edit/delete actions

5. **TemplatePresetsView.swift** (~100 lines)
   - Preset library
   - One-tap application

### Files to Modify

1. **GamificationModels.swift**
   - Add new `AchievementRequirement` cases (~30 lines)

2. **GamificationStore.swift**
   - Add `templates` property
   - Template CRUD methods
   - Regeneration logic (~100 lines)

3. **AchievementsView.swift**
   - Exercise filter UI (~50 lines)
   - Template creation button

4. **AchievementEngine.swift** (in GamificationStore.swift)
   - Evaluation logic for new requirement types (~80 lines)

5. **ExerciseStore.swift**
   - Exercise deletion handler (~20 lines)

---

## UX17: Multi-Platform Deployment Strategy (iOS/WatchOS)

### Executive Summary

StandFit is currently built as a WatchOS-exclusive app. This analysis examines two deployment strategies:

**Strategy A (Recommended):** Release as standalone iOS app (primary) with optional companion WatchOS app  
**Strategy B:** Keep existing WatchOS app and add iOS as companion

Both leverage existing Swift/SwiftUI codebase. Strategy A reaches broader market; Strategy B maximizes current WatchOS user engagement.

---

## Core Architecture Assessment

**Current State:**
- App is 100% Swift/SwiftUI
- WatchOS-specific UI (compact layouts, Digital Crown support)
- Data persistence via UserDefaults/Core Data
- Background notifications using WatchKit framework
- No platform-specific APIs preventing iOS port

**Portability Analysis:**
- ✅ Data models are platform-agnostic
- ✅ Business logic (exercise tracking, gamification, achievements) is platform-independent
- ✅ SwiftUI views are largely adaptable (responsive to screen size)
- ⚠️ WatchKit components need abstraction
- ⚠️ WatchOS notification handling differs from iOS
- ⚠️ UI layouts need redesign for larger screens

---

## Strategy A: Standalone iOS App + Optional WatchOS Companion

### Overview

Release on iOS App Store as the primary platform, offering optional WatchOS companion for convenience.

### Pros

1. **Market Reach:** iOS app store has 100M+ daily users vs. limited WatchOS audience
2. **Revenue Potential:** iOS subscriptions convert better (5-7% vs 1-2% WatchOS)
3. **Feature Set:** iOS allows richer UI, home screen widgets, Siri shortcuts
4. **User Onboarding:** iPhone users easier to acquire via App Store rankings
5. **Shared Codebase:** Both apps share 90% of business logic
6. **Device Ecosystem:** Users check phones more than watches
7. **App Store Visibility:** iOS gets better recommendations than WatchOS

### Cons

1. **Larger Development Scope:** iOS UI redesign is substantial
2. **Wider Testing Surface:** More device sizes, iOS versions to test
3. **App Store Competition:** Fitness category is crowded on iOS
4. **Two Codebases to Maintain:** Different UI layers for each platform

### Implementation Plan

#### Phase 1: iOS App Foundation (4-6 weeks)

**New files to create:**

```
iOS/
  ├── Views/
  │   ├── iOS/
  │   │   ├── ContentView.swift              // Main tab navigation
  │   │   ├── DashboardView.swift            // Home screen
  │   │   ├── ExerciseListView.swift         // All exercises
  │   │   ├── LogExerciseView.swift          // Full-screen entry
  │   │   ├── StatsView.swift                // Charts + analytics
  │   │   ├── SettingsView.swift             // Comprehensive settings
  │   │   ├── OnboardingView.swift           // New user flow
  │   │   └── HomeWidgetView.swift           // Lock screen/home widget
  │   │
  │   └── Shared/                            // Reusable across platforms
  │       ├── ExerciseRow.swift
  │       ├── AchievementCard.swift
  │       ├── ProgressChart.swift
  │       └── NotificationPreview.swift
  │
  ├── Managers/
  │   └── iOSNotificationManager.swift       // UNUserNotification wrapper
  │
  └── App/
      └── iOSApp.swift                       // iOS entry point
```

**Core tasks:**

1. Extract platform-agnostic business logic into shared module
   - ExerciseStore
   - GamificationStore
   - AchievementEngine
   - Analytics

2. Create iOS-specific UI layer
   - Tab-based navigation (Home, Stats, Exercises, Settings)
   - Exercise logging form (full screen, not modal)
   - Dashboard with next notification countdown
   - Detailed statistics with filters

3. iOS notification handling
   - Replace WatchKit notifications with UNUserNotificationCenter
   - Add rich notifications with actions
   - Implement notification categories (snooze, log, mute)

4. iOS-specific features
   - Home screen widgets (next notification, streak counter)
   - Lock screen widgets (upcoming alert)
   - Siri Shortcuts integration

#### Phase 2: WatchOS Companion Enhancement (2-3 weeks)

**Refactor existing WatchOS app to reuse shared logic:**

```
WatchOS/
  ├── Views/
  │   ├── WatchOS/
  │   │   ├── ContentView.swift              // Existing compact nav
  │   │   ├── ExerciseLogView.swift          // Quick entry UI
  │   │   ├── NotificationView.swift         // Notification handler
  │   │   └── MiniStatsView.swift            // 3-4 key metrics
  │   │
  │   └── Shared/                            // Reference iOS/Shared
  │
  └── App/
      └── WatchOSApp.swift                   // WatchOS entry point
```

**Key enhancements:**

1. Sync data between iOS and WatchOS via iCloud or CloudKit
2. WatchOS app becomes quick-access companion
3. Add watchOS Complications for glances (complications)
4. Background task handling for WatchOS background refresh

#### Phase 3: Data Synchronization (2-3 weeks)

**Implement cross-device sync:**

```swift
// New SyncManager for handling iOS ↔ WatchOS data sync
class CrossPlatformSyncManager: NSObject, URLSessionDelegate {
    
    // Option 1: iCloud Core Data sync (recommended)
    // - Automatic bidirectional sync
    // - Built into iOS/WatchOS
    // - No backend infrastructure needed
    // - Limitation: only syncs between user's own devices
    
    // Option 2: CloudKit (if backend needed)
    // - More control
    // - Can add server-side analytics later
    // - Requires CloudKit setup
    
    // Option 3: Simple UserDefaults sync via WatchConnectivity (limited)
    // - Backup only
    // - WatchConnectivity framework
    // - Limited to ~15KB per sync
}
```

**Recommended approach:** iCloud Core Data sync (requires iOS 15+)

### Timeline & Effort Estimate

| Phase | Tasks | Effort | Timeline |
|-------|-------|--------|----------|
| Phase 1 | iOS app foundation + UI | 140-160 hours | 4-6 weeks |
| Phase 2 | WatchOS refactor | 30-40 hours | 2-3 weeks |
| Phase 3 | Cross-device sync | 40-50 hours | 2-3 weeks |
| Testing | QA, edge cases, devices | 40-60 hours | 2 weeks (parallel) |
| **Total** | | **250-310 hours** | **8-10 weeks** |

### Revenue Impact (Strategy A)

**Assumptions:**
- iOS app reaches 50K downloads Year 1 (10x WatchOS potential)
- 4% conversion to Premium (vs 2% WatchOS)
- WatchOS companion adds 20% retention bonus

**Year 1 Projections:**
- iOS Premium users: 2,000 ($95,760/year)
- WatchOS Premium users: 200 ($9,576/year)
- Total Year 1 revenue: $105,336 (+10% vs WatchOS-only)

**Year 2+ Growth:**
- iOS ecosystem growth drives WatchOS adoption
- Cross-device users convert at 6-8% rate
- Projected cumulative revenue: $350,000+

---

## Strategy B: WatchOS Primary + iOS Companion

### Overview

Keep existing WatchOS app as primary, add iOS companion for data management and optional exercise logging.

### Pros

1. **Faster to Market:** Only iOS secondary UI needed (~4-6 weeks)
2. **Lower Risk:** Leverages existing WatchOS user base
3. **Differentiation:** Unique WatchOS-first positioning
4. **Development Focus:** Maintain WatchOS excellence over broad iOS coverage
5. **Data Management:** iOS becomes management console for WatchOS

### Cons

1. **Limited Market:** WatchOS still niche (only smartwatch owners)
2. **Lower Revenue:** Companion apps typically convert at 1-2%
3. **Confusing Positioning:** "Why would I need iOS if my watch works?"
4. **App Store Visibility:** Companion apps get buried
5. **User Acquisition:** Can't grow beyond Apple Watch audience

### Implementation Plan

**Simpler scope:**

```
iOS-Companion/
  ├── Views/
  │   ├── DashboardView.swift              // Sync status, stats
  │   ├── ExerciseHistoryView.swift        // Detailed logs
  │   ├── AchievementsView.swift           // Unlock showcase
  │   ├── SettingsView.swift               // Notification scheduling
  │   └── SyncView.swift                   // Manual/auto sync
  │
  └── Managers/
      └── WatchConnectivityManager.swift   // WatchOS ↔ iOS bridge
```

**Effort:** 60-80 hours, 3-4 weeks

### Timeline & Effort Estimate

| Phase | Tasks | Effort | Timeline |
|-------|-------|--------|----------|
| iOS UI | Companion interface | 60-80 hours | 3-4 weeks |
| Sync | WatchConnectivity integration | 20-30 hours | 1 week |
| Testing | QA across devices | 20-30 hours | 1 week |
| **Total** | | **100-140 hours** | **5 weeks** |

### Revenue Impact (Strategy B)

**Assumptions:**
- iOS companion reaches 10K downloads (of 20K WatchOS users)
- 1% conversion to Premium ($3.99/mo)
- Only ~100 dual-platform users

**Year 1 Projections:**
- iOS companion users: 100 ($4,788/year)
- WatchOS users unchanged: 2,000 ($95,760/year)
- Total Year 1 revenue: $100,548 (-5% vs Strategy A)

**Year 2+ Growth:**
- Limited growth (capped by WatchOS market)
- Projected revenue: $120K-150K annually

---

## Comparative Analysis

| Factor | Strategy A (iOS Primary) | Strategy B (WatchOS Primary) |
|--------|--------------------------|------------------------------|
| **Time to Launch** | 8-10 weeks | 5 weeks |
| **Market Size** | 💰 Large (iOS 100M+) | 💰 Small (WatchOS 5M+) |
| **Revenue Potential** | 💰💰💰 High ($350K+/yr) | 💰 Low ($120K/yr) |
| **User Acquisition** | 💚 Good (App Store visibility) | ❌ Poor (niche market) |
| **Development Complexity** | ⚠️ High (parallel codebases) | ✅ Low (simple companion) |
| **Retention** | 💚 Better (phone is primary device) | ✅ Good (watch integration) |
| **Feature Richness** | 💚 Full ecosystem | ❌ Limited to companion role |
| **Competitive Landscape** | ⚠️ Crowded (many fitness apps) | ✅ Less crowded (WatchOS only) |
| **Subscription Conversion** | 💚 4-7% (standard iOS rate) | ❌ 1-2% (companion apps) |
| **Cross-Platform Sync** | 💚 Major value-add | ⚠️ Minor feature |

---

## Technical Architecture Comparison

### Strategy A: Shared Codebase Model

```
┌─────────────────────────────────────────┐
│        Shared Business Logic            │
│  (ExerciseStore, Gamification, etc.)    │
└─────────────────────────────────────────┘
           ↙                         ↘
┌──────────────────────┐    ┌──────────────────────┐
│   iOS App Layer      │    │   WatchOS App Layer  │
│  (Tab navigation)    │    │  (Compact views)     │
├──────────────────────┤    ├──────────────────────┤
│ Full-screen forms    │    │ Quick-access UI      │
│ Widgets              │    │ Complications        │
│ Rich notifications   │    │ Digital Crown        │
└──────────────────────┘    └──────────────────────┘
```

**Dependency flow:**
- Both iOS and WatchOS depend on Shared module
- Each platform has UI-specific implementations
- Notifications handled separately per platform
- Data layer completely shared

### Strategy B: Companion Model

```
┌──────────────────────┐
│   WatchOS App        │
│  (Primary)           │
│ Full functionality   │
└──────────────────────┘
          ↑
          │ WatchConnectivity
          │ (bidirectional sync)
          ↓
┌──────────────────────┐
│   iOS Companion      │
│  (Data management)   │
│ View-only interface  │
└──────────────────────┘
```

**Dependency flow:**
- iOS is read-mostly (depends on WatchOS for source of truth)
- WatchOS is independent
- Sync happens via WatchConnectivity framework
- Data conflicts possible (manual resolution)

---

## Recommendation

**Choose Strategy A if:**
- ✅ Long-term revenue growth is priority
- ✅ You can commit to 8-10 week iOS development
- ✅ Target audience includes non-Apple Watch users
- ✅ Want to compete with major fitness apps (Apple Health, Strava)

**Choose Strategy B if:**
- ✅ Quick market validation is priority
- ✅ Existing WatchOS user base is strong
- ✅ Companion features are sufficient for users
- ✅ Limited development resources (5 weeks max)

**Hybrid Approach:**
Start with Strategy B (5 weeks) to validate iOS market demand and WatchOS user satisfaction. Then pivot to Strategy A if conversion rates > 2% or user feedback requests iOS features.

---

## Implementation Checklist (Strategy A Recommended)

### Pre-Development
- [ ] Extract shared business logic into separate module
- [ ] Audit WatchKit dependencies in existing code
- [ ] Design iOS app navigation flow
- [ ] Plan data sync architecture (iCloud Core Data vs CloudKit)
- [ ] Create iOS Figma designs/mockups

### iOS Development
- [ ] Build iOS data models (reuse from WatchOS)
- [ ] Implement iOS views (DashboardView, ExerciseListView, etc.)
- [ ] iOS notification handling (UNUserNotificationCenter)
- [ ] Home/lock screen widgets
- [ ] Siri Shortcuts integration
- [ ] App Store metadata (screenshots, description)

### WatchOS Refactor
- [ ] Refactor to use shared business logic
- [ ] Add watchOS complications
- [ ] WatchConnectivity for iOS sync

### Testing & Launch
- [ ] iOS beta testing (TestFlight)
- [ ] Cross-device sync testing
- [ ] App Store review preparation
- [ ] Create launch marketing plan

---

## Notes

- UX17 added: 2026-01-02
- Analysis focuses on Swift/SwiftUI portability
- Assumes iOS 15+ and WatchOS 8+ support
- CloudKit alternative not detailed (requires backend work)
