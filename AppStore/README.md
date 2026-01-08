# Upio App Store Preparation - Complete Guide

## Overview

This directory contains all the materials needed for launching **Upio** (formerly StandFit) on the iOS App Store with full localization support for 7 languages.

## ✅ Completed Tasks

### 1. App Name Configuration
- **Production Name**: Upio
- **Fully localized** in all 7 languages
- **Japanese version**: Includes phonetic アピオ (Apio) for clarity
- **Location**: `/StandFit/Localizable.xcstrings` → `app.name`

### 2. Mascot System
- **Mascot names by language**:
  - 🇺🇸 English: **Upi**
  - 🇩🇪 German: **Upi**
  - 🇪🇸 Spanish: **Upi**
  - 🇫🇷 French: **Upi**
  - 🇯🇵 Japanese: **あぴくん** (Apikun)
  - 🇧🇷 Portuguese: **Upi**
  - 🇨🇳 Chinese: **阿动** (Ā Dòng)

- **Localized strings added**:
  - `mascot.name` - Mascot's name
  - `mascot.greeting` - "Hi! I'm Upi!" / "こんにちは！あぴくんだよ！" / "你好！我是阿动！"
  - `mascot.encouragement` - "You got this!" / "がんばって！" / "加油！"

- **Code access**: `LocalizedString.General.mascotName`, `.mascotGreeting`, `.mascotEncouragement`

### 3. App Store Content (All 7 Languages)
**File**: `APP_STORE_CONTENT.md`

Complete marketing materials including:
- **App Name & Subtitle** (30 char limit)
- **Full Description** (~4000 characters with features, benefits, key points)
- **Keywords** (optimized for App Store search)
- **Promotional Text** (170 char limit for featuring)
- **What's New** (release notes)

All content emphasizes:
- Privacy-first approach (no account, no tracking, no ads)
- Smart reminders with flexible scheduling
- Gamification with achievements and streaks
- Progress tracking and analytics
- Custom exercise creation

### 4. Privacy Policy (All 7 Languages)
**File**: `PRIVACY_POLICY.md`

Comprehensive privacy policy covering:
- **No data collection** - Everything stays on device
- **No account required** - Works completely offline
- **No third-party services** - No analytics, ads, or tracking
- **Local notifications only** - No server communication
- **Optional iCloud backup** - Controlled by iOS, not the app
- **COPPA compliant** - Safe for all ages

### 5. Mascot Design Guide
**File**: `MASCOT_GUIDE.md`

Complete mascot implementation guide including:
- Character design specifications
- Cultural considerations for JP/CN markets
- Usage guidelines (onboarding, empty states, achievements)
- Asset naming conventions
- Code implementation examples
- Design tool recommendations

## File Structure

```
AppStore/
├── README.md                    # This file
├── APP_STORE_CONTENT.md        # Marketing copy (7 languages)
├── PRIVACY_POLICY.md           # Legal privacy policy (7 languages)
└── MASCOT_GUIDE.md             # Character design & implementation guide
```

## App Store Submission Checklist

### Required Information

- [ ] **App Name**: Upio
- [ ] **Subtitle**: Varies by language (see APP_STORE_CONTENT.md)
- [ ] **Primary Category**: Health & Fitness
- [ ] **Secondary Category**: Productivity (optional)
- [ ] **Age Rating**: 4+ (no sensitive content)
- [ ] **Privacy Policy URL**: _(needs to be hosted)_
- [ ] **Support URL**: _(needs to be created)_
- [ ] **Marketing URL**: _(optional)_

### Localization Status

All 7 languages have complete content:
- ✅ English (en)
- ✅ German (de)
- ✅ Spanish (es)
- ✅ French (fr)
- ✅ Japanese (ja)
- ✅ Portuguese, Brazilian (pt-BR)
- ✅ Simplified Chinese (zh-Hans)

### Required Assets (Still Needed)

#### App Icon
- [ ] 1024x1024px App Icon (all variants if needed)

#### Screenshots (per language, per device size)
Minimum required:
- [ ] 6.7" Display (iPhone 15 Pro Max, 14 Pro Max) - **1290 x 2796 px**
- [ ] 6.5" Display (iPhone 11 Pro Max, XS Max) - **1242 x 2688 px**
- [ ] 5.5" Display (iPhone 8 Plus, 7 Plus) - **1242 x 2208 px**

Recommended screenshots to showcase:
1. Main screen with timer and quick actions
2. Exercise picker with built-in and custom exercises
3. Progress report with charts and timeline
4. Achievement system with unlocked tiers
5. Flexible reminder scheduling
6. GitHub-style activity heatmap (optional 6th screenshot)

#### App Preview Videos (Optional but Recommended)
- [ ] 15-30 second videos showing key features
- Required per device size if included

#### Promotional Artwork (for featuring)
- [ ] App Preview screenshots optimized for featuring

### Mascot Assets (To Be Created)

Based on MASCOT_GUIDE.md specifications:
- [ ] Mascot_Small.imageset (44x44pt) - @1x, @2x, @3x
- [ ] Mascot_Medium.imageset (120x120pt) - @1x, @2x, @3x
- [ ] Mascot_Large.imageset (256x256pt) - @1x, @2x, @3x
- [ ] Mascot_Waving.imageset (greeting pose)
- [ ] Mascot_Celebrating.imageset (achievement pose)
- [ ] Mascot_Thinking.imageset (tutorial/help pose)

**Note**: Consider regional variants for Japanese (あぴくん) and Chinese (阿动) markets

### App Store Connect Setup

1. **Create App Record**
   - Bundle ID: `com.sventos.StandFit` (or new bundle ID for Upio)
   - SKU: Choose unique identifier

2. **Pricing & Availability**
   - [ ] Free with In-App Purchases (Premium features)
   - [ ] Select countries/regions for release

3. **In-App Purchases**
   - [ ] Set up Premium subscription tiers
   - [ ] Localize subscription descriptions
   - [ ] Configure trial period (if offering)

4. **Privacy Information**
   - [ ] Data Collection: None
   - [ ] Data Types: None
   - [ ] Data Usage: None
   - [ ] Third-party SDKs: None

5. **App Review Information**
   - [ ] Contact information
   - [ ] Demo account (if needed - not required for this app)
   - [ ] Notes for reviewer

## Implementation Next Steps

### 1. Integrate Mascot into Onboarding
**Priority**: High
**File**: `StandFit/Views/OnboardingView.swift`

Add mascot to welcome screen with localized greeting:
```swift
Image("Mascot_Large")
    .resizable()
    .scaledToFit()
    .frame(width: 200, height: 200)

Text(LocalizedString.General.mascotGreeting)
    .font(.title)
```

### 2. Add Mascot to Empty States
**Priority**: Medium
**Files**: Various views with empty states

Replace generic empty state icons with mascot:
- No exercises today
- No achievements yet
- No custom exercises

### 3. Create Mascot Assets
**Priority**: High for launch

Options:
1. **Design in-house**: Use Figma/Illustrator per MASCOT_GUIDE.md specs
2. **Commission designer**: Provide MASCOT_GUIDE.md as brief
3. **Use AI generation**: Midjourney/DALL-E with detailed prompts

### 4. App Screenshots
**Priority**: Critical for launch

Use iPhone simulator to capture:
1. Light mode AND dark mode versions
2. All required device sizes
3. Clean data (good examples of usage)
4. Localized UI for each language

### 5. Host Privacy Policy
**Priority**: Required for launch

Options:
1. GitHub Pages (free, simple)
2. Custom domain
3. Include in app as static content + web version

Example URL structure:
- `https://upio.app/privacy`
- `https://upio.app/privacy/de` (German)
- `https://upio.app/privacy/ja` (Japanese)
- etc.

## Brand Identity Summary

### Name
**Upio** - Neutral, soft, easy to localize
- Japanese: アピオ (Apio)
- Phonetically similar across languages

### Mascot
**Upi / あぴくん / 阿动**
- Friendly, encouraging character
- Embodies movement and positivity
- Cultural variants for JP/CN markets

### Positioning
"Smart fitness companion that keeps you moving throughout the day"

### Key Differentiators
1. **Privacy-first**: No account, no tracking, no ads
2. **Flexible scheduling**: Time blocks, randomization, Focus Mode awareness
3. **Gamification**: 4-tier achievements, streaks, XP system
4. **Insights**: Timeline visualization, response rate analytics
5. **Customization**: Unlimited custom exercises

### Target Audience
- Remote workers and office professionals
- Health-conscious individuals
- People who sit for long periods
- Habit-building enthusiasts
- Gamification lovers

### Tone of Voice
- Encouraging, not demanding
- Supportive, not judgmental
- Friendly, approachable
- Clear, concise
- Culturally sensitive

## Technical Notes

### Localization Implementation
- **System**: String Catalogs (.xcstrings)
- **Table**: "General" for app/mascot strings
- **Access**: `LocalizedString.General.appName`, etc.
- **Fallback**: English (en) as base language

### Bundle ID Considerations
Current: `com.sventos.StandFit`
Consider: `com.sventos.Upio` or new domain

If keeping current bundle ID:
- Update display name in Info.plist
- App Store shows "Upio" regardless of bundle ID

### Version Strategy
- **Launch Version**: 1.0.0
- **Build Number**: Start at 1, increment for each submission

## Marketing Strategy (Post-Launch)

### App Store Optimization (ASO)
- Monitor keyword rankings
- A/B test screenshots
- Update "What's New" regularly
- Encourage reviews (in-app prompt after positive actions)

### Social Media
- Create accounts: @UpioApp or similar
- Share user success stories
- Post tips and tricks
- Showcase mascot character

### Content Marketing
- Blog posts about desk exercise benefits
- Scientific research on movement breaks
- User testimonials and case studies

## Contact & Support

### Support Channels (To Set Up)
- [ ] Support email: support@upio.app
- [ ] Help documentation
- [ ] FAQ page
- [ ] Community forum or Discord (optional)

### Feedback Collection
- In-app feedback form
- App Store reviews monitoring
- Direct email communication
- Analytics (privacy-respecting, optional)

## Legal Checklist

- [x] Privacy Policy created (all languages)
- [ ] Terms of Service (if needed)
- [ ] COPPA compliance verified (app is safe for all ages)
- [ ] GDPR compliance (no data collection = compliant)
- [ ] CCPA compliance (no data collection = compliant)
- [ ] App Store Review Guidelines compliance
- [ ] Trademark search for "Upio" name

## Success Metrics (Post-Launch)

### Key Performance Indicators
1. **Downloads**: Track by country/language
2. **Retention**: Day 1, Day 7, Day 30
3. **Engagement**: Daily active users, exercises logged
4. **Monetization**: Premium conversion rate
5. **Ratings**: Average star rating, review sentiment
6. **Streaks**: Average streak length (indicates sticky habits)

### Analytics Strategy
- Use privacy-respecting analytics only
- Focus on aggregate metrics, not individuals
- Be transparent about any data collection
- Maintain "privacy-first" brand promise

## Resources

- **App Store Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/
- **App Store Connect Help**: https://developer.apple.com/help/app-store-connect/
- **Localization Best Practices**: https://developer.apple.com/localization/

---

**Status**: Ready for asset creation and App Store submission
**Last Updated**: January 2026
**Prepared by**: Claude (AI Assistant)
**Next Action**: Create mascot assets and app screenshots
