# UX24: User Onboarding - Guide New Users Through Setup

**Status**: ⏳ Pending  
**Created**: 2026-01-03  
**Category**: User Experience & Retention  
**Priority**: High

## Problem

StandFit currently lacks a first-run onboarding experience to guide new users through initial setup and key features. Users are dropped into the app without:

1. **Profile Setup Guidance**: No introduction to schedule profiles or how to configure reminders
2. **Feature Discovery**: Key features (gamification, custom exercises, progress reports) remain hidden
3. **Permission Prompts**: Notification permissions requested without context
4. **Best Practices**: No guidance on optimal reminder intervals or active hours
5. **Value Communication**: Users don't understand the app's full capabilities

This leads to:
- **Poor First Impressions**: Users confused by empty screens and complex settings
- **Low Engagement**: Users don't configure reminders properly, leading to abandonment
- **Feature Blindness**: Premium features and capabilities remain undiscovered
- **Higher Churn**: Users uninstall before experiencing the app's value
- **Support Burden**: Common questions that could be answered during onboarding

### Current User Journey (Problematic)

1. User opens app for first time
2. Sees "Enable Reminders" toggle in settings
3. No guidance on what to configure
4. Schedule profile system appears overwhelming
5. No explanation of gamification, achievements, or streaks
6. User enables notifications without understanding scheduling
7. Gets generic reminders without proper configuration
8. Becomes frustrated and abandons app

## Solution Overview

Implement a comprehensive, multi-step onboarding flow that:

1. **Welcomes Users**: Engaging introduction to StandFit's value proposition
2. **Requests Permissions**: Contextual explanation before requesting notifications
3. **Guides Profile Setup**: Step-by-step schedule profile creation
4. **Introduces Features**: Highlights gamification, custom exercises, progress tracking
5. **Demonstrates Value**: Shows what users can achieve with the app
6. **Enables Quick Start**: Gets users to first exercise quickly
7. **Progressive Disclosure**: Reveals advanced features over time

The onboarding should be:
- **Skippable**: Allow power users to skip ahead
- **Resumable**: Can be paused and continued later
- **Localized**: Supports all 7 languages
- **Adaptive**: Different for free vs. premium users
- **Minimal**: 3-5 screens maximum before reaching main app

## Onboarding Flow Design

### Phase 1: Welcome & Value Proposition (1 screen)

**Screen 1: Welcome to StandFit**

**Visual Design**:
- Large app icon with gradient background
- Animated figure.stand icon
- Concise value proposition
- "Get Started" CTA button

**Content**:
```swift
Title: "Welcome to StandFit"
Subtitle: "Build healthy habits, one stand at a time"

Benefits:
• Smart reminders throughout your day
• Track progress with gamification
• Build streaks and unlock achievements
• Create custom exercises for your routine

CTA: "Get Started"
Skip: "Skip for now" (subtle text link)
```

**Implementation**:
```swift
struct OnboardingWelcomeView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: .blue.opacity(0.4), radius: 20)
                
                Image(systemName: "figure.stand")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }
            
            // Title and subtitle
            VStack(spacing: 12) {
                Text(LocalizedString.Onboarding.welcomeTitle)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.Onboarding.welcomeSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            // Benefits list
            VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                    icon: "bell.badge.fill",
                    text: LocalizedString.Onboarding.benefitReminders,
                    color: .orange
                )
                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: LocalizedString.Onboarding.benefitTracking,
                    color: .blue
                )
                BenefitRow(
                    icon: "trophy.fill",
                    text: LocalizedString.Onboarding.benefitAchievements,
                    color: .yellow
                )
                BenefitRow(
                    icon: "figure.walk",
                    text: LocalizedString.Onboarding.benefitCustom,
                    color: .green
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // CTA button
            Button {
                onContinue()
            } label: {
                Text(LocalizedString.Onboarding.getStarted)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            
            // Skip button
            Button {
                onSkip()
            } label: {
                Text(LocalizedString.Onboarding.skipForNow)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(text)
                .font(.body)
        }
    }
}
```

### Phase 2: Notification Permission (1 screen)

**Screen 2: Enable Notifications**

**Visual Design**:
- Large notification bell icon
- Clear explanation of why notifications are needed
- Preview of what notifications look like
- "Enable Notifications" CTA

**Content**:
```swift
Title: "Stay on Track"
Subtitle: "Get gentle reminders throughout your day"

Explanation:
"StandFit sends smart reminders to help you build a consistent exercise habit. 
You control when and how often you receive them."

Examples:
• "Time to stand! Log your exercise" (with preview)
• Fully customizable schedule
• Works with your daily routine

CTA: "Enable Notifications"
Skip: "I'll do this later"
```

**Implementation**:
```swift
struct OnboardingNotificationView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Notification icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .orange.opacity(0.4), radius: 20)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            
            // Title and explanation
            VStack(spacing: 16) {
                Text(LocalizedString.Onboarding.notificationTitle)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.Onboarding.notificationSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.Onboarding.notificationExplanation)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            // Notification preview
            NotificationPreviewCard()
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Enable button
            Button {
                requestNotificationPermission()
                onContinue()
            } label: {
                Text(LocalizedString.Onboarding.enableNotifications)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            
            // Skip button
            Button {
                onSkip()
            } label: {
                Text(LocalizedString.Onboarding.laterButton)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification permission: \(granted)")
        }
    }
}

struct NotificationPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.stand")
                    .foregroundStyle(.blue)
                Text("StandFit")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("now")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(LocalizedString.Onboarding.notificationPreviewTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(LocalizedString.Onboarding.notificationPreviewBody)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Phase 3: Schedule Profile Setup (1 screen)

**Screen 3: Create Your Schedule**

**Visual Design**:
- Template picker with visual previews
- Quick setup vs. custom setup options
- Clear explanation of what profile does

**Content**:
```swift
Title: "Create Your Schedule"
Subtitle: "Choose a template that fits your routine"

Templates:
• Office Worker (9 AM - 5 PM, every 60 min)
• Active Lifestyle (7 AM - 10 PM, every 30 min)
• Custom (set your own schedule)

Footer: "You can change this anytime in Settings"

CTA: "Create Schedule"
```

**Implementation**:
```swift
struct OnboardingScheduleView: View {
    @ObservedObject var store: ExerciseStore
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var selectedTemplate: ScheduleTemplate?
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text(LocalizedString.Onboarding.scheduleTitle)
                    .font(.system(size: 28, weight: .bold))
                
                Text(LocalizedString.Onboarding.scheduleSubtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            
            // Template picker
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(ScheduleTemplate.allTemplates, id: \.name) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate?.name == template.name,
                            onTap: {
                                selectedTemplate = template
                            }
                        )
                    }
                    
                    // Custom option
                    CustomScheduleCard(
                        isSelected: selectedTemplate == nil,
                        onTap: {
                            selectedTemplate = nil
                        }
                    )
                }
                .padding(.horizontal, 32)
            }
            
            // Footer and CTA
            VStack(spacing: 16) {
                Text(LocalizedString.Onboarding.scheduleFooter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    createScheduleAndContinue()
                } label: {
                    Text(LocalizedString.Onboarding.createSchedule)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedTemplate == nil)
                
                Button {
                    onSkip()
                } label: {
                    Text(LocalizedString.Onboarding.skipButton)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }
    
    private func createScheduleAndContinue() {
        if let template = selectedTemplate {
            let profile = store.createProfile(name: template.name, basedOn: template)
            store.switchToProfile(profile)
            store.remindersEnabled = true
            store.updateAllNotificationSchedules(reason: "Onboarding schedule created")
        }
        onContinue()
    }
}

struct TemplateCard: View {
    let template: ScheduleTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(template.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundStyle(template.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(template.shortDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
```

### Phase 4: Feature Highlights (1 screen)

**Screen 4: Discover Features**

**Visual Design**:
- Horizontal page view with swipeable cards
- Each card highlights one key feature
- Visual icons and animations
- Progress dots at bottom

**Features to Highlight**:

1. **Gamification**
   - Icon: Trophy
   - Title: "Earn XP & Level Up"
   - Description: "Gain experience points for each exercise and unlock achievements"

2. **Streaks**
   - Icon: Flame
   - Title: "Build Daily Streaks"
   - Description: "Stay consistent and watch your streak grow day after day"

3. **Custom Exercises**
   - Icon: Plus circle
   - Title: "Create Custom Exercises"
   - Description: "Add your own exercises with custom icons and units"

4. **Progress Reports**
   - Icon: Chart
   - Title: "Track Your Progress"
   - Description: "Get automatic summaries of your weekly and monthly activity"

**Implementation**:
```swift
struct OnboardingFeaturesView: View {
    let onContinue: () -> Void
    
    @State private var currentPage = 0
    
    private let features: [OnboardingFeature] = [
        OnboardingFeature(
            icon: "trophy.fill",
            color: .yellow,
            title: LocalizedString.Onboarding.featureGamificationTitle,
            description: LocalizedString.Onboarding.featureGamificationDesc
        ),
        OnboardingFeature(
            icon: "flame.fill",
            color: .orange,
            title: LocalizedString.Onboarding.featureStreakTitle,
            description: LocalizedString.Onboarding.featureStreakDesc
        ),
        OnboardingFeature(
            icon: "plus.circle.fill",
            color: .green,
            title: LocalizedString.Onboarding.featureCustomTitle,
            description: LocalizedString.Onboarding.featureCustomDesc
        ),
        OnboardingFeature(
            icon: "chart.line.uptrend.xyaxis",
            color: .blue,
            title: LocalizedString.Onboarding.featureProgressTitle,
            description: LocalizedString.Onboarding.featureProgressDesc
        )
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Text(LocalizedString.Onboarding.featuresTitle)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)
            
            // Swipeable feature cards
            TabView(selection: $currentPage) {
                ForEach(features.indices, id: \.self) { index in
                    FeatureCard(feature: features[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Continue button
            Button {
                onContinue()
            } label: {
                Text(currentPage == features.count - 1 
                    ? LocalizedString.Onboarding.finish
                    : LocalizedString.Onboarding.next)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }
}

struct OnboardingFeature {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

struct FeatureCard: View {
    let feature: OnboardingFeature
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [feature.color, feature.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: feature.color.opacity(0.4), radius: 20)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
```

### Phase 5: Completion & First Exercise (1 screen)

**Screen 5: You're All Set!**

**Visual Design**:
- Celebration graphics (confetti, checkmark)
- Summary of what was configured
- Quick action to log first exercise
- Link to settings for customization

**Content**:
```swift
Title: "You're All Set!"
Subtitle: "Your StandFit journey begins now"

Summary:
✓ Notifications enabled
✓ Schedule created: [Profile Name]
✓ Ready to track progress

CTA: "Log Your First Exercise"
Secondary: "Explore Settings"
```

**Implementation**:
```swift
struct OnboardingCompletionView: View {
    @ObservedObject var store: ExerciseStore
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Celebration icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .green.opacity(0.4), radius: 20)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            // Title and subtitle
            VStack(spacing: 12) {
                Text(LocalizedString.Onboarding.completionTitle)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.Onboarding.completionSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            // Summary
            VStack(alignment: .leading, spacing: 12) {
                CompletionCheckmark(text: LocalizedString.Onboarding.summaryNotifications)
                CompletionCheckmark(text: LocalizedString.Onboarding.summarySchedule(store.activeProfile?.name ?? "Default"))
                CompletionCheckmark(text: LocalizedString.Onboarding.summaryReady)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // CTAs
            VStack(spacing: 12) {
                Button {
                    markOnboardingComplete()
                    onComplete()
                } label: {
                    Text(LocalizedString.Onboarding.logFirstExercise)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    markOnboardingComplete()
                    // Navigate to settings
                } label: {
                    Text(LocalizedString.Onboarding.exploreSettings)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }
    
    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(Date(), forKey: "onboardingCompletedDate")
    }
}

struct CompletionCheckmark: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
            
            Text(text)
                .font(.body)
        }
    }
}
```

## Technical Implementation

### Onboarding Coordinator

```swift
// MARK: - Onboarding Coordinator

class OnboardingCoordinator: ObservableObject {
    @Published var currentStep = 0
    @Published var isComplete = false
    
    private let steps: [OnboardingStep] = [
        .welcome,
        .notifications,
        .schedule,
        .features,
        .completion
    ]
    
    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(Date(), forKey: "onboardingCompletedDate")
        isComplete = true
    }
}

enum OnboardingStep {
    case welcome
    case notifications
    case schedule
    case features
    case completion
}

// MARK: - Onboarding Container View

struct OnboardingContainerView: View {
    @StateObject private var coordinator = OnboardingCoordinator()
    @ObservedObject var store: ExerciseStore
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            switch coordinator.currentStep {
            case 0:
                OnboardingWelcomeView(
                    onContinue: { coordinator.nextStep() },
                    onSkip: { coordinator.skipOnboarding() }
                )
            case 1:
                OnboardingNotificationView(
                    onContinue: { coordinator.nextStep() },
                    onSkip: { coordinator.nextStep() }
                )
            case 2:
                OnboardingScheduleView(
                    store: store,
                    onContinue: { coordinator.nextStep() },
                    onSkip: { coordinator.nextStep() }
                )
            case 3:
                OnboardingFeaturesView(
                    onContinue: { coordinator.nextStep() }
                )
            case 4:
                OnboardingCompletionView(
                    store: store,
                    onComplete: { onComplete() }
                )
            default:
                EmptyView()
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        ))
        .animation(.easeInOut, value: coordinator.currentStep)
    }
}
```

### App Integration

```swift
// MARK: - StandFitApp.swift Integration

@main
struct StandFitApp: App {
    @StateObject private var store = ExerciseStore.shared
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingContainerView(
                    store: store,
                    onComplete: {
                        showOnboarding = false
                    }
                )
            } else {
                MainTabView(store: store)
            }
        }
    }
}
```

## Progressive Onboarding (Post-Installation)

Beyond the initial onboarding, implement progressive feature discovery:

### 1. First Exercise Logged
- Show tooltip: "Great! Keep your streak alive tomorrow"
- Highlight streak counter

### 2. First Achievement Unlocked
- Full-screen celebration animation
- Explain achievement system
- Prompt to share (UX23 integration)

### 3. Day 7 Streak
- Congratulations message
- Introduce progress reports
- Suggest enabling automatic reports

### 4. Week 2 Usage
- Prompt to create custom exercise
- Show custom exercise benefits
- Premium feature callout

### 5. Premium Users
- Additional feature walkthroughs
- Advanced scheduling options
- Custom achievement templates

## Localization

All onboarding strings must be localized in `Onboarding.xcstrings`:

```swift
// LocalizedString.swift extension

public enum Onboarding {
    private static let table = "Onboarding"
    
    // Welcome screen
    public static let welcomeTitle = NSLocalizedString("onboarding.welcome_title", tableName: table, comment: "")
    public static let welcomeSubtitle = NSLocalizedString("onboarding.welcome_subtitle", tableName: table, comment: "")
    public static let benefitReminders = NSLocalizedString("onboarding.benefit_reminders", tableName: table, comment: "")
    public static let benefitTracking = NSLocalizedString("onboarding.benefit_tracking", tableName: table, comment: "")
    public static let benefitAchievements = NSLocalizedString("onboarding.benefit_achievements", tableName: table, comment: "")
    public static let benefitCustom = NSLocalizedString("onboarding.benefit_custom", tableName: table, comment: "")
    public static let getStarted = NSLocalizedString("onboarding.get_started", tableName: table, comment: "")
    public static let skipForNow = NSLocalizedString("onboarding.skip_for_now", tableName: table, comment: "")
    
    // Notification screen
    public static let notificationTitle = NSLocalizedString("onboarding.notification_title", tableName: table, comment: "")
    public static let notificationSubtitle = NSLocalizedString("onboarding.notification_subtitle", tableName: table, comment: "")
    public static let notificationExplanation = NSLocalizedString("onboarding.notification_explanation", tableName: table, comment: "")
    public static let enableNotifications = NSLocalizedString("onboarding.enable_notifications", tableName: table, comment: "")
    public static let laterButton = NSLocalizedString("onboarding.later_button", tableName: table, comment: "")
    
    // Schedule screen
    public static let scheduleTitle = NSLocalizedString("onboarding.schedule_title", tableName: table, comment: "")
    public static let scheduleSubtitle = NSLocalizedString("onboarding.schedule_subtitle", tableName: table, comment: "")
    public static let createSchedule = NSLocalizedString("onboarding.create_schedule", tableName: table, comment: "")
    public static let scheduleFooter = NSLocalizedString("onboarding.schedule_footer", tableName: table, comment: "")
    
    // Features screen
    public static let featuresTitle = NSLocalizedString("onboarding.features_title", tableName: table, comment: "")
    public static let next = NSLocalizedString("onboarding.next", tableName: table, comment: "")
    public static let finish = NSLocalizedString("onboarding.finish", tableName: table, comment: "")
    
    // Completion screen
    public static let completionTitle = NSLocalizedString("onboarding.completion_title", tableName: table, comment: "")
    public static let completionSubtitle = NSLocalizedString("onboarding.completion_subtitle", tableName: table, comment: "")
    public static let logFirstExercise = NSLocalizedString("onboarding.log_first_exercise", tableName: table, comment: "")
    public static let exploreSettings = NSLocalizedString("onboarding.explore_settings", tableName: table, comment: "")
    
    public static func summarySchedule(_ name: String) -> String {
        String(format: NSLocalizedString("onboarding.summary_schedule", tableName: table, comment: ""), name)
    }
}
```

## Analytics & Metrics

Track onboarding completion and drop-off:

```swift
enum OnboardingAnalytics {
    static func trackStepViewed(_ step: OnboardingStep) {
        // Analytics: Track which steps users reach
    }
    
    static func trackStepCompleted(_ step: OnboardingStep) {
        // Analytics: Track completion rate per step
    }
    
    static func trackOnboardingSkipped(atStep step: OnboardingStep) {
        // Analytics: Track where users skip
    }
    
    static func trackOnboardingCompleted(duration: TimeInterval) {
        // Analytics: Track total onboarding time
    }
}
```

**Key Metrics**:
- Onboarding completion rate
- Average time to complete
- Drop-off points
- Skip rate per screen
- First exercise logged rate (within 24 hours)
- 7-day retention for onboarded vs. non-onboarded users

## A/B Testing Opportunities

1. **Number of Screens**: 3 vs. 5 screens
2. **Template Selection**: Present templates vs. skip directly to custom
3. **Feature Highlights**: Show features vs. skip to completion
4. **CTA Text**: "Get Started" vs. "Begin Your Journey"
5. **Skip Placement**: Prominent vs. subtle skip button

## Success Criteria

**Immediate Metrics**:
- 70%+ complete onboarding flow
- 50%+ enable notifications during onboarding
- 60%+ create schedule profile
- 40%+ log first exercise within 1 hour

**Retention Metrics**:
- 50%+ 7-day retention (onboarded users)
- 30%+ 30-day retention (onboarded users)
- 20%+ active users after 90 days

**Engagement Metrics**:
- 2x higher engagement for onboarded users
- 3x higher feature discovery rate
- Lower support ticket volume for setup questions

## Implementation Phases

### Phase 1: Core Onboarding Flow (Week 1)
- [ ] Build OnboardingCoordinator
- [ ] Create welcome screen
- [ ] Create notification permission screen
- [ ] Create completion screen
- [ ] Add to StandFitApp entry point
- [ ] Test happy path flow

### Phase 2: Schedule Setup (Week 2)
- [ ] Build schedule template picker
- [ ] Integrate with existing ScheduleProfile system
- [ ] Add template previews
- [ ] Handle profile creation
- [ ] Test with various templates

### Phase 3: Feature Highlights (Week 3)
- [ ] Design feature cards
- [ ] Implement swipeable TabView
- [ ] Add animations
- [ ] Create feature descriptions
- [ ] Test transitions

### Phase 4: Localization & Polish (Week 4)
- [ ] Create Onboarding.xcstrings
- [ ] Translate all 7 languages
- [ ] Add animations and haptics
- [ ] Implement analytics tracking
- [ ] User testing and refinement

### Phase 5: Progressive Onboarding (Week 5)
- [ ] First exercise tooltip
- [ ] Achievement unlock celebration
- [ ] Streak milestone prompts
- [ ] Custom exercise suggestion
- [ ] Premium feature callouts

## Related Issues

- **UX1**: Settings changes feedback (explain during onboarding)
- **UX7**: Focus Mode warning (show during notification setup)
- **UX10**: Gamification (introduce during features screen)
- **UX15**: Monetization (premium callouts in onboarding)
- **UX19**: Advanced scheduling (introduce after basic profile setup)
- **UX20**: Internationalization (all onboarding content localized)

## Future Enhancements

1. **Video Tutorials**: Short explainer videos for complex features
2. **Interactive Demo**: Let users try features before setup
3. **Personalization Quiz**: Ask about user's goals and routines
4. **Social Onboarding**: Connect with friends during setup
5. **Health Data Integration**: Request HealthKit permissions
6. **Adaptive Flow**: Different onboarding for different user types
7. **Re-onboarding**: Periodic feature discovery for long-term users

## Conclusion

A well-designed onboarding experience is crucial for:
- **First Impressions**: Set the tone for quality and care
- **User Activation**: Get users to "aha moment" quickly
- **Feature Discovery**: Showcase app capabilities
- **Retention**: Build habit formation from day one
- **Conversion**: Drive premium subscriptions through value demonstration

By guiding new users through profile setup, notification configuration, and feature discovery, we can dramatically improve activation rates, reduce churn, and set users up for long-term success with StandFit.
