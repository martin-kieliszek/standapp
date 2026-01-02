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
    @State private var showExercisePicker = false
    @State private var selectedExerciseItem: ExerciseItem?
    @State private var showHistory = false
    @State private var showProgress = false
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showCreateExercise = false
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
                        // Hero section with streak and timer
                        heroSection

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
            .navigationTitle("StandFit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
            .onReceive(NotificationCenter.default.publisher(for: .showProgressReport)) { _ in
                showProgress = true
            }
            .onReceive(timer) { time in
                currentTime = time
                checkForNewAchievements()
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Streak Card with gradient
            Button {
                showAchievements = true
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
                        Text("\(gamificationStore.streak.currentStreak) day streak")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Keep the momentum going!")
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
                            Text("Next Reminder")
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
                                Text(nextTime.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 16)

                        Divider()
                            .padding(.horizontal, -20)

                        // Reset button
                        Button {
                            NotificationManager.shared.scheduleReminderWithSchedule(store: exerciseStore)
                            NotificationManager.shared.playClickHaptic()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset Timer")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 12)

                        // Quick link to reminder schedule settings
                        NavigationLink {
                            ReminderScheduleView(store: exerciseStore)
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.caption)
                                Text("Edit Reminder Schedule")
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .opacity(0.6)
                            }
                            .foregroundStyle(.white)
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
                    Text("Scheduling...")
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
                    Text("Reminders Off")
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
                title: "Progress",
                color: .green,
                action: { showProgress = true }
            )

            QuickActionCard(
                icon: "clock.fill",
                title: "History",
                color: .orange,
                action: { showHistory = true }
            )

            QuickActionCard(
                icon: "trophy.fill",
                title: "Achievements",
                color: .cyan,
                action: { showAchievements = true }
            )

            QuickActionCard(
                icon: "star.fill",
                title: "Level \(gamificationStore.levelProgress.currentLevel)",
                color: .yellow,
                action: { showAchievements = true }
            )
        }
    }

    // MARK: - Stats Overview Cards

    private var statsOverviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    value: "\(exerciseStore.todaysLogs.count)",
                    label: "Today's Logs",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )

                StatCard(
                    value: "\(gamificationStore.unlockedAchievements.count)",
                    label: "Unlocked",
                    icon: "trophy.fill",
                    color: .purple
                )
            }

            // Level progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Level \(gamificationStore.levelProgress.currentLevel)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(gamificationStore.levelProgress.xpForNextLevel.current) / \(gamificationStore.levelProgress.xpForNextLevel.needed) XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    Text("Quick Log")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Tap an exercise to log it")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button {
                    showCreateExercise = true
                } label: {
                    Label("Create Custom", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
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
                    Text("Today's Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(exerciseStore.todaysLogs.count) exercise\(exerciseStore.todaysLogs.count == 1 ? "" : "s") logged")
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
            return "Now!"
        }

        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60

        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
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
