# UX11: Social Features & Friends Integration (Pending)

**Status:** ⏳ Pending

## Problem

Exercise is more motivating with accountability and social connection. Users can't share progress, compete with friends, or see how they compare.

## Proposed Solution

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

## Core Features

### 1. Friend System

**Friend Connection Methods:**
- Share Code: Unique code to share (high privacy)
- Contacts: Find friends from contacts who use app
- Nearby: Discover friends via proximity
- Apple ID: Connect via iCloud contacts

**Friend Data Model:**
```swift
struct Friend: Identifiable, Codable {
    let id: String  // CloudKit record ID
    let displayName: String
    let avatarEmoji: String
    var relationship: FriendRelationship
    var lastActivityDate: Date?
    var currentStreak: Int?
    var weeklyScore: Int?
    var privacyLevel: FriendPrivacyLevel
}
```

### 2. Privacy Controls

**Settings → Privacy & Sharing:**
- Toggle: Enable Social Features
- Default Visibility: Full Activity, Daily Totals, Streak Only, Nothing
- Share Code: Unique regeneratable code
- Appear in Nearby Search toggle
- Show in Contacts Search toggle

**Per-Friend Privacy Override:**
- Customize visibility for each friend individually
- Remove friend or block user options

### 3. Activity Feed

**FriendsActivityView:**
- Today's leaderboard showing friend rankings
- Recent activity feed (friend logged exercises, earned achievements)
- Refresh to update
- Visual indicators for current user

### 4. Notifications & Sharing

**Friend Activity Notifications:**
- Friend hits milestone or achievement
- Leaderboard position changes
- Friend breaks streak (encouragement)

**Share Sheet Integration:**
- Share achievements to social media
- Share weekly summary

### 5. Challenges & Competition

**Friend Challenges:**
- Daily score competition
- Weekly total challenge
- Streak length race
- Specific exercise count challenge

**Challenge Status:**
- Pending (awaiting acceptance)
- Active (in progress)
- Completed (finished)
- Declined or Expired

## Implementation Phases

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

## Files to Create

- `SocialManager.swift` - CloudKit integration, friend management
- `FriendsListView.swift` - Friend list and management
- `FriendsActivityView.swift` - Activity feed and leaderboards
- `AddFriendView.swift` - Share code input, nearby search
- `SocialPrivacyView.swift` - Privacy settings
- `FriendChallengeView.swift` - Challenge UI
- `SocialModels.swift` - Friend, Activity, Challenge models

## Files to Modify

- `ExerciseStore.swift` - Add social settings, user ID, share code
- `SettingsView.swift` - Add Social section
- `ContentView.swift` - Add friends access point
- `NotificationManager.swift` - Friend activity notifications
- `StandFitApp.swift` - Handle social deep links

## Dependencies

- CloudKit (iOS/watchOS built-in)
- Optional: Game Center for leaderboards
- Background App Refresh for activity sync

## Privacy Considerations

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
