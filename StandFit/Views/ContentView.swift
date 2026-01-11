//
//  ContentView.swift
//  StandFit iOS
//
//  Enhanced UI with modern card-based design
//

import SwiftUI
import Combine
import UserNotifications
import StandFitCore

struct ContentView: View {
    @StateObject private var exerciseStore = ExerciseStore.shared
    @StateObject private var gamificationStore = GamificationStore.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showExercisePicker = false
    @State private var selectedExerciseItem: ExerciseItem?
    @State private var showHistory = false
    @State private var showProgress = false
    @State private var showWeeklyInsights = false
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showCreateExercise = false
    @State private var showPaywall = false
    @State private var showOnboarding = false
    @State private var currentTime = Date()
    @State private var showingAchievementToast = false
    @State private var toastAchievement: Achievement?

    // Timer to update countdown every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Focus Mode Warning Banner
                        if #available(iOS 15.0, *), 
                           FocusStatusManager.shared.isFocusActive {
                            focusModeWarningBanner
                        }
                        
                        // Trial expiration banner
                        if shouldShowTrialBanner {
                            trialExpirationBanner
                        }
                        
                        // Hero section with streak and timer
                        heroSection

                        // Mascot message (motivational vs positive)
                        mascotMessageCard

                        // Quick action buttons
                        quickActionsGrid

                        // Stats overview cards
                        statsOverviewCards

                        // Exercise Logging Section
                        exerciseLoggingSection

                        // Recent Activities
                        if !exerciseStore.todaysLogs.isEmpty {
                            recentActivitiesSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(LocalizedString.General.appName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showOnboarding = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(item: $selectedExerciseItem) { item in
                ExerciseLoggerView(
                    store: exerciseStore,
                    exerciseItem: item
                )
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(store: exerciseStore)
            }
            .sheet(isPresented: $showProgress) {
                ProgressReportView(store: exerciseStore, gamificationStore: gamificationStore)
            }
            .sheet(isPresented: $showWeeklyInsights) {
                WeeklyInsightsView(store: exerciseStore, gamificationStore: gamificationStore)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(store: exerciseStore)
            }
            .sheet(isPresented: $showAchievements) {
                NavigationStack {
                    AchievementsView(
                        gamificationStore: gamificationStore,
                        exerciseStore: exerciseStore
                    )
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView { item in
                    selectedExerciseItem = item
                    showExercisePicker = false
                }
            }
            .sheet(isPresented: $showCreateExercise) {
                CreateExerciseView(store: exerciseStore)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(subscriptionManager: SubscriptionManager.shared)
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView(store: exerciseStore, isInitialOnboarding: false)
            }
            .overlay {
                if showingAchievementToast, let achievement = toastAchievement {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showingAchievementToast = false
                            }

                        AchievementUnlockedToast(
                            achievement: achievement,
                            isPresented: $showingAchievementToast
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                Task {
                    await requestNotificationPermission()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showExercisePicker)) { _ in
                showExercisePicker = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showWeeklyInsights)) { _ in
                showWeeklyInsights = true
            }
            .onReceive(timer) { time in
                currentTime = time
                checkForNewAchievements()
            }
        }
    }

    // MARK: - Mascot Message Card

    private var mascotMessageCard: some View {
        let hasLoggedToday = !exerciseStore.todaysLogs.isEmpty
        let message = MascotMessagePicker.message(hasLoggedToday: hasLoggedToday, date: currentTime)
        let imageName = MascotMessagePicker.imageName(hasLoggedToday: hasLoggedToday)

        return HStack(spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityHidden(true)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Streak Card with gradient
            Button {
                if exerciseStore.isPremium {
                    showAchievements = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: streakGradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: streakGradientColors.first?.opacity(0.4) ?? .clear, radius: 8, x: 0, y: 4)

                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        ZStack {
                            Text(LocalizedString.Stats.dayStreak(gamificationStore.streak.currentStreak))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if !exerciseStore.isPremium {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                    Text(LocalizedString.UI.premium)
                                        .font(.caption.bold())
                                }
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                )
                            }
                        }
                        // .blur(radius: !exerciseStore.isPremium ? 3 : 0)
                        
                        Text(gamificationStore.streak.currentStreak == 0 ? LocalizedString.Schedule.editSchedule : LocalizedString.Stats.keepMomentum)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            }
            .buttonStyle(.plain)

            // Timer Card
            timerCard
        }
    }

    private var streakGradientColors: [Color] {
        let streak = gamificationStore.streak.currentStreak
        switch streak {
        case 0...2: return [.gray, .gray.opacity(0.6)]
        case 3...6: return [.orange, .orange.opacity(0.7)]
        case 7...29: return [.red, .orange]
        default: return [.purple, .pink]
        }
    }

    // MARK: - Timer Card

    private var timerCard: some View {
        VStack(spacing: 0) {
            if exerciseStore.remindersEnabled {
                if let nextTime = exerciseStore.nextScheduledNotificationTime {
                    VStack(spacing: 12) {
                        // Time display
                        VStack(spacing: 6) {
                            Text(LocalizedString.Main.nextReminder)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            Text(timeUntil(nextTime))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                Text(formatNextReminderDateTime(nextTime))
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 16)

                        Divider()
                            .padding(.horizontal, -20)

                        // Quick ad-hoc reminder buttons
                        HStack(spacing: 8) {
                            // +1 min button - schedule quick reminder 1 minute from now
                            Button {
                                NotificationManager.shared.snoozeReminder(seconds: 60, store: exerciseStore)
                                NotificationManager.shared.playClickHaptic()
                            } label: {
                                Text(LocalizedString.Notifications.snooze1Min)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundStyle(.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            // +5 min button - schedule quick reminder 5 minutes from now
                            Button {
                                NotificationManager.shared.snoozeReminder(seconds: 300, store: exerciseStore)
                                NotificationManager.shared.playClickHaptic()
                            } label: {
                                Text(LocalizedString.Notifications.snooze5Min)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundStyle(.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.top, 12)

                        // Reset button
                        Button {
                            NotificationManager.shared.rebuildNotificationQueue(store: exerciseStore)
                            NotificationManager.shared.playClickHaptic()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(LocalizedString.Notifications.resetTimer)
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 8)

                        // Quick link to reminder schedule settings
                        NavigationLink {
                            ReminderScheduleView(store: exerciseStore)
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.caption)
                                Text(LocalizedString.Schedule.editSchedule)
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .opacity(0.6)
                            }
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                } else {
                    Text(LocalizedString.Schedule.scheduling)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(LocalizedString.Settings.remindersOff)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            QuickActionCard(
                icon: "chart.line.uptrend.xyaxis",
                title: LocalizedString.Progress.title,
                color: .green,
                action: {
                    if exerciseStore.isPremium {
                        showProgress = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            QuickActionCard(
                icon: "clock.fill",
                title: LocalizedString.History.title,
                color: .orange,
                action: {
                    if exerciseStore.isPremium {
                        showHistory = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            QuickActionCard(
                icon: "trophy.fill",
                title: LocalizedString.Achievements.title,
                color: .cyan,
                action: {
                    if exerciseStore.isPremium {
                        showAchievements = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            QuickActionCard(
                icon: "star.fill",
                title: "\(LocalizedString.Stats.level) \(gamificationStore.levelProgress.currentLevel)",
                color: .yellow,
                action: {
                    if exerciseStore.isPremium {
                        showAchievements = true
                    } else {
                        showPaywall = true
                    }
                }
            )
        }
    }

    // MARK: - Stats Overview Cards

    private var statsOverviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    value: "\(exerciseStore.todaysLogs.count)",
                    label: LocalizedString.Stats.todaysLogs,
                    icon: "checkmark.circle.fill",
                    color: .blue,
                    showLock: !exerciseStore.isPremium
                )

                StatCard(
                    value: "\(gamificationStore.unlockedAchievements.count)",
                    label: LocalizedString.Stats.unlocked,
                    icon: "trophy.fill",
                    color: .purple,
                    showLock: !exerciseStore.isPremium
                )
            }

            // Level progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    
                    ZStack {
                        Text(LocalizedString.Stats.levelFormat(gamificationStore.levelProgress.currentLevel))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if !exerciseStore.isPremium {
                            HStack(spacing: 3) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text(LocalizedString.UI.premium)
                                    .font(.caption2.bold())
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .blur(radius: !exerciseStore.isPremium ? 3 : 0)
                    
                    Spacer()
                    
                    ZStack {
                        Text(LocalizedString.Stats.xpFormat(gamificationStore.levelProgress.xpForNextLevel.current, gamificationStore.levelProgress.xpForNextLevel.needed))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if !exerciseStore.isPremium {
                            Text("•••")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .blur(radius: !exerciseStore.isPremium ? 2 : 0)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * gamificationStore.levelProgress.levelProgressPercent, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }

    // MARK: - Exercise Logging Section

    private var exerciseLoggingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.Stats.quickLog)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(LocalizedString.UI.tapToLog)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button {
                    showCreateExercise = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.semibold))
                        Text(LocalizedString.UI.custom)
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundStyle(.white)
                    .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }

            ExercisePickerView { item in
                selectedExerciseItem = item
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Recent Activities Section

    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.Stats.todayActivity)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(LocalizedString.Stats.exercisesLogged(exerciseStore.todaysLogs.count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(Array(exerciseStore.todaysLogs.enumerated()), id: \.offset) { index, log in
                    let item = log.isBuiltIn
                        ? ExerciseItem(builtIn: log.exerciseType!)
                        : ExerciseItem(custom: exerciseStore.customExercise(byId: log.customExerciseId!)!)

                    RecentActivityRow(item: item, log: log)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Helpers

    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(currentTime)
        if interval <= 0 {
            return LocalizedString.Stats.now
        }

        let totalSeconds = Int(interval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        // Show days if >= 1 day
        if days > 0 {
            if hours > 0 {
                return "\(days)d \(hours)h"
            } else {
                return "\(days)d"
            }
        }
        
        // Show hours if >= 1 hour
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        }
        
        // Show minutes:seconds for < 1 hour
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
    
    private func formatNextReminderDateTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDateInToday(date) {
            return LocalizedString.Stats.todayAt(date.formatted(date: .omitted, time: .shortened))
        }
        
        // Check if it's tomorrow
        if calendar.isDateInTomorrow(date) {
            return LocalizedString.Stats.tomorrowAt(date.formatted(date: .omitted, time: .shortened))
        }
        
        // Check if it's within the next week
        let daysUntil = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        if daysUntil >= 0 && daysUntil < 7 {
            let weekday = date.formatted(.dateTime.weekday(.wide))
            return LocalizedString.Stats.weekdayAt(weekday, date.formatted(date: .omitted, time: .shortened))
        }
        
        // For dates further out, show full date
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted && exerciseStore.remindersEnabled {
                NotificationManager.shared.scheduleReminderWithSchedule(store: exerciseStore)
            }
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    private func checkForNewAchievements() {
        if let newAchievement = gamificationStore.recentlyUnlockedAchievements.first {
            toastAchievement = newAchievement
            withAnimation(.spring()) {
                showingAchievementToast = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gamificationStore.clearRecentUnlocks()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring()) {
                    showingAchievementToast = false
                }
            }
        }
    }
    
    // MARK: - Trial Banner
    
    private var shouldShowTrialBanner: Bool {
        guard let trial = subscriptionManager.trialState,
              trial.isActive,
              !trial.hasExpired else {
            return false
        }
        // Show banner when 3 or fewer days remaining
        return trial.daysRemaining <= 3 && trial.daysRemaining > 0
    }
    
    private var trialExpirationBanner: some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedString.Stats.trialEndingSoon)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        if let trial = subscriptionManager.trialState {
                            Text(LocalizedString.Premium.daysRemainingInTrial(trial.daysRemaining))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                Text(LocalizedString.Premium.upgradeKeepAchievements)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        Color.orange,
                        Color.red
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    @available(iOS 15.0, *)
    private var focusModeWarningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .foregroundStyle(.purple)
                .font(.title3)
            
            Text(LocalizedString.Settings.focusActiveBanner)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.purple.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private enum MascotMessagePicker {
    static func imageName(hasLoggedToday: Bool) -> String {
        hasLoggedToday ? "Upi_Stretching" : "Upi_Squating"
    }

    static func message(hasLoggedToday: Bool, date: Date) -> String {
        let messages = hasLoggedToday ? positiveMessages : motivationalMessages
        guard !messages.isEmpty else { return "" }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        let index = abs(dayOfYear) % messages.count
        return messages[index]
    }

    private static var positiveMessages: [String] {
        [
            LocalizedString.Main.mascotPositive01,
            LocalizedString.Main.mascotPositive02,
            LocalizedString.Main.mascotPositive03,
            LocalizedString.Main.mascotPositive04,
            LocalizedString.Main.mascotPositive05,
            LocalizedString.Main.mascotPositive06,
            LocalizedString.Main.mascotPositive07,
            LocalizedString.Main.mascotPositive08,
            LocalizedString.Main.mascotPositive09,
            LocalizedString.Main.mascotPositive10
        ]
    }

    private static var motivationalMessages: [String] {
        [
            LocalizedString.Main.mascotMotivation01,
            LocalizedString.Main.mascotMotivation02,
            LocalizedString.Main.mascotMotivation03,
            LocalizedString.Main.mascotMotivation04,
            LocalizedString.Main.mascotMotivation05
        ]
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    var showLock: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                if showLock {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .offset(x: 8, y: -8)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                ZStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if showLock {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text(LocalizedString.UI.premium)
                                .font(.caption.bold())
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                .blur(radius: showLock ? 3 : 0)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct RecentActivityRow: View {
    let item: ExerciseItem
    let log: ExerciseLog

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ExerciseColorPalette.color(for: item).opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(ExerciseColorPalette.color(for: item))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(log.count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ExerciseColorPalette.color(for: item))

            Text(item.unitType.unitLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview {
    ContentView()
}
