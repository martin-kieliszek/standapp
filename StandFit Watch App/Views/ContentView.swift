//
//  ContentView.swift
//  StandFit Watch App
//
//  Created by Marty Kieliszek on 31/12/2025.
//
// ContentView.swift
import SwiftUI
import WatchKit
import Combine
import StandFitCore

struct ContentView: View {
    @StateObject private var store = ExerciseStore.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var gamificationStore = GamificationStore.shared

    @State private var nextReminderTime: Date?
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingExercisePicker = false
    @State private var showingProgressReport = false
    @State private var showingAchievements = false
    @State private var selectedExerciseItem: ExerciseItem?
    @State private var currentTime = Date()
    @State private var showingAchievementToast = false
    @State private var toastAchievement: Achievement?
    // Timer to update countdown
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Streak & Level Badge
                    streakLevelCard

                    // Countdown Timer Card
                    timerCard

                    // Quick Exercise Buttons
                    quickExerciseSection

                    // Today's Stats
                    if !store.todaysSummaries.isEmpty || !store.todaysCustomSummaries.isEmpty {
                        todayStatsSection
                    }

                    // Progress Button
                    progressButton

                    // Achievements Button
                    achievementsButton
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("StandFit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(store: store)
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(store: store)
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerFullScreenView(
                    store: store,
                    selectedExerciseItem: $selectedExerciseItem
                )
            }
            .sheet(item: $selectedExerciseItem) { item in
                ExerciseLoggerView(
                    store: store,
                    exerciseItem: item
                )
            }
            .sheet(isPresented: $showingProgressReport) {
                NavigationStack {
                    ProgressReportView(store: store)
                }
            }
            .sheet(isPresented: $showingAchievements) {
                NavigationStack {
                    AchievementsView(
                        gamificationStore: gamificationStore,
                        exerciseStore: store
                    )
                }
            }
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
        .onReceive(NotificationCenter.default.publisher(for: .showExercisePicker)) { _ in
            showingExercisePicker = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showProgressReport)) { _ in
            showingProgressReport = true
        }
        .onAppear {
            Task {
                await requestNotificationPermission()
                await updateNextReminderTime()
            }
        }
        .onReceive(timer) { time in
            currentTime = time  // Forces re-render every second
            checkForNewAchievements()
        }
    }
    
    // MARK: - Streak & Level Card

    private var streakLevelCard: some View {
        VStack(spacing: 8) {
            // Top row: Streak
            Button {
                showingAchievements = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.body)
                        .foregroundStyle(gamificationStore.streak.currentStreak > 0 ? .orange : .gray)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(gamificationStore.streak.currentStreak) day\(gamificationStore.streak.currentStreak == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Current streak")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            // Bottom row: Level & Achievements
            HStack(spacing: 6) {
                // Level Badge
                Button {
                    showingAchievements = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("Lv.\(gamificationStore.levelProgress.currentLevel)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                // Achievement Count Badge
                Button {
                    showingAchievements = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        Text("\(gamificationStore.unlockedAchievements.count)/\(gamificationStore.achievements.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.cyan.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Timer Card

    private var timerCard: some View {
        VStack(spacing: 8) {
            if store.remindersEnabled {
                if let nextTime = store.nextScheduledNotificationTime {
                    Text("Next reminder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(timeUntil(nextTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    
                    Text("at \(nextTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Scheduling...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Reminders Off")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                if store.remindersEnabled {
                    // Reset timer
//                    notificationManager.scheduleReminder(
//                        inMinutes: store.reminderIntervalMinutes
//                    )
                    notificationManager.scheduleReminderWithSchedule(store: store)
                    notificationManager.playClickHaptic()
                    Task {
                        await updateNextReminderTime()
                    }
                }
            } label: {
                Label(
                    store.remindersEnabled ? "Reset (+\(ExerciseStore.formatInterval(store.reminderIntervalMinutes)))" : "Enable in Settings",
                    systemImage: store.remindersEnabled ? "arrow.clockwise" : "bell.slash"
                )
                .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Quick Exercise Section

    private var quickExerciseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Log")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            ExercisePickerView(store: store) { item in
                selectedExerciseItem = item
            }
        }
    }
    
    // MARK: - Today's Stats Section

    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                // Built-in exercise summaries
                ForEach(store.todaysSummaries, id: \.type.id) { summary in
                    HStack {
                        Image(systemName: summary.type.icon)
                            .foregroundStyle(.blue)
                        Text(summary.type.rawValue)
                        Spacer()
                        Text(formatSummaryCount(summary.totalCount, unitType: summary.type.unitType))
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                }

                // Custom exercise summaries
                ForEach(store.todaysCustomSummaries, id: \.customExercise.id) { summary in
                    HStack {
                        Image(systemName: summary.customExercise.icon)
                            .foregroundStyle(.green)
                        Text(summary.customExercise.name)
                        Spacer()
                        Text(formatSummaryCount(summary.totalCount, unitType: summary.customExercise.unitType))
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Progress Button Section

    private var progressButton: some View {
        Button {
            showingProgressReport = true
        } label: {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text("View Progress")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Achievements Button Section

    private var achievementsButton: some View {
        Button {
            showingAchievements = true
        } label: {
            HStack {
                Image(systemName: "trophy.fill")
                Text("Achievements")
                Spacer()
                if gamificationStore.inProgressAchievements.count > 0 {
                    Text("\(gamificationStore.inProgressAchievements.count) in progress")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helper Functions
    
    private func formatSummaryCount(_ count: Int, unitType: ExerciseUnitType) -> String {
        switch unitType {
        case .reps:
            return "\(count)"
        case .seconds:
            // Show seconds if < 60, otherwise show as minutes
            if count >= 60 {
                let minutes = count / 60
                let seconds = count % 60
                if seconds > 0 {
                    return "\(minutes)m \(seconds)s"
                } else {
                    return "\(minutes)m"
                }
            } else {
                return "\(count)s"
            }
        case .minutes:
            return "\(count)m"
        }
    }
    
    private func requestNotificationPermission() async {
        let granted = await notificationManager.requestAuthorization()
        print("Notification permission granted: \(granted)")  // Check this
        if granted && store.remindersEnabled {
            notificationManager.scheduleReminderWithSchedule(
                store: store
            )
        }
    }
    
    private func updateNextReminderTime() async {
        nextReminderTime = await notificationManager.getNextReminderTime()
    }
    
    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(currentTime)
        if interval <= 0 {
            return "Now!"
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

    private func checkForNewAchievements() {
        // Check if there are newly unlocked achievements
        if let newAchievement = gamificationStore.recentlyUnlockedAchievements.first {
            toastAchievement = newAchievement
            withAnimation(.spring()) {
                showingAchievementToast = true
            }

            // Clear after showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gamificationStore.clearRecentUnlocks()
            }

            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring()) {
                    showingAchievementToast = false
                }
            }
        }
    }
}

// MARK: - Notification for Deep Link

extension Notification.Name {
    static let showExercisePicker = Notification.Name("showExercisePicker")
    static let showProgressReport = Notification.Name("showProgressReport")
}

#Preview {
    ContentView()
}
