//
//  ContentView.swift
//  StandFit iOS
//
//  Main view - Phase 1: Basic structure
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
    @State private var currentTime = Date()
    @State private var showingAchievementToast = false
    @State private var toastAchievement: Achievement?
    
    // Timer to update countdown every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak & Level Badge
                    streakLevelCard

                    // Countdown Timer Card
                    timerCard
                    
                    // Navigation buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            Button(action: { showHistory = true }) {
                                Label("History", systemImage: "clock.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: { showProgress = true }) {
                                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: { showAchievements = true }) {
                                Label("Achievements", systemImage: "trophy.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: { showSettings = true }) {
                                Label("Settings", systemImage: "gear")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    // Quick Stats
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Today's Logs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(exerciseStore.todaysLogs.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Achievements")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(gamificationStore.unlockedAchievements.count)/\(gamificationStore.achievements.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Level")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(gamificationStore.levelProgress.currentLevel)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Exercise Logging Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Log Exercise")
                            .font(.headline)
                            .fontWeight(.semibold)

                        ExercisePickerView { item in
                            selectedExerciseItem = item
                        }
                    }

                    // Recent Activities
                    if !exerciseStore.todaysLogs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Activity")
                                .font(.headline)
                                .fontWeight(.semibold)

                            VStack(spacing: 8) {
                                ForEach(Array(exerciseStore.todaysLogs.enumerated()), id: \.offset) { index, log in
                                    let item = log.isBuiltIn 
                                        ? ExerciseItem(builtIn: log.exerciseType!)
                                        : ExerciseItem(custom: exerciseStore.customExercise(byId: log.customExerciseId!)!)
                                    
                                    HStack {
                                        Image(systemName: item.icon)
                                            .foregroundStyle(ExerciseColorPalette.color(for: item))
                                            .frame(width: 32)
                                        
                                        VStack(alignment: .leading) {
                                            Text(item.name)
                                                .fontWeight(.semibold)
                                            Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(log.count) \(item.unitType.unitLabel)")
                                            .font(.headline)
                                            .foregroundStyle(.blue)
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("StandFit")
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
                ProgressReportView(store: exerciseStore)
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
                currentTime = time  // Forces re-render every second
                checkForNewAchievements()
            }
        }
    }
    
    // MARK: - Streak & Level Card
    
    private var streakLevelCard: some View {
        VStack(spacing: 12) {
            // Top row: Streak
            Button {
                showAchievements = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundStyle(gamificationStore.streak.currentStreak > 0 ? .orange : .gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(gamificationStore.streak.currentStreak) day\(gamificationStore.streak.currentStreak == 1 ? "" : "s")")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Current streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Bottom row: Level & Achievements
            HStack(spacing: 12) {
                // Level Badge
                Button {
                    showAchievements = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .foregroundStyle(.yellow)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lv.\(gamificationStore.levelProgress.currentLevel)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Level")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Achievement Count Badge
                Button {
                    showAchievements = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(.body)
                            .foregroundStyle(.cyan)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(gamificationStore.unlockedAchievements.count)/\(gamificationStore.achievements.count)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Achievements")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(.cyan.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Timer Card
    
    private var timerCard: some View {
        VStack(spacing: 12) {
            if exerciseStore.remindersEnabled {
                if let nextTime = exerciseStore.nextScheduledNotificationTime {
                    VStack(spacing: 8) {
                        Text("Next Reminder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(timeUntil(nextTime))
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .monospacedDigit()
                        
                        Text("at \(nextTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    
                    Button {
                        NotificationManager.shared.scheduleReminderWithSchedule(store: exerciseStore)
                        NotificationManager.shared.playClickHaptic()
                    } label: {
                        Label("Reset", systemImage: "bell.badge.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    Text("Scheduling...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            } else {
                Text("Reminders Off")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
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

#Preview {
    ContentView()
}
