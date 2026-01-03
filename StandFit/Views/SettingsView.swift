//
//  SettingsView.swift
//  StandFit iOS
//
//  Settings view with reminder configuration, exercise management, and progress reports
//

import SwiftUI
import Combine
import StandFitCore

struct SettingsView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    private let notificationManager = NotificationManager.shared

    var body: some View {
        NavigationStack {
            List {
                // Subscription section
                Section {
                    NavigationLink {
                        SubscriptionSettingsView(subscriptionManager: SubscriptionManager.shared)
                    } label: {
                        HStack {
                            Image(systemName: store.isPremium ? "star.circle.fill" : "star.circle")
                                .foregroundStyle(store.isPremium ? .yellow : .secondary)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.isPremium ? "Premium Active" : "Upgrade to Premium")
                                    .font(.headline)
                                if let trial = SubscriptionManager.shared.trialState, trial.isActive {
                                    Text("\(trial.daysRemaining) days remaining")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Reminders toggle
                Section {
                    Toggle(isOn: $store.remindersEnabled) {
                        Label("Reminders", systemImage: "bell.fill")
                    }
                    .onChange(of: store.remindersEnabled) { enabled in
                        if enabled {
                            notificationManager.scheduleReminderWithSchedule(store: store)
                        } else {
                            notificationManager.cancelAllReminders()
                        }
                        notificationManager.playClickHaptic()
                    }
                }

                // Schedule configuration (navigates to dedicated view)
                Section {
                    NavigationLink {
                        ReminderScheduleView(store: store)
                    } label: {
                        HStack {
                            Label("Schedule", systemImage: "calendar.badge.clock")
                            Spacer()
                            Text(schedulePreviewText)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .disabled(!store.remindersEnabled)
                } header: {
                    Text("Reminder Schedule")
                } footer: {
                    if let nextTime = store.nextScheduledNotificationTime, store.remindersEnabled {
                        Text("Next: \(formatDateTime(nextTime))")
                    } else if store.remindersEnabled {
                        Text("Scheduling...")
                    } else {
                        Text("Enable reminders to configure schedule")
                    }
                }

                // Exercises management
                Section {
                    NavigationLink {
                        CustomExerciseListView(store: store)
                    } label: {
                        HStack {
                            Label("Exercises", systemImage: "figure.run")
                            Spacer()
                            Text("\(store.customExercises.count) custom")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Exercises")
                } footer: {
                    Text("Create and manage custom exercises")
                }

                // Progress Reports
                Section {
                    NavigationLink {
                        ProgressReportSettingsView(store: store)
                    } label: {
                        HStack {
                            Label("Progress Reports", systemImage: "chart.bar.fill")
                            Spacer()
                            if store.progressReportSettings.enabled {
                                Text("On")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text("Reports")
                } footer: {
                    Text("Automatic summaries of your exercise progress")
                }

                // Haptic test
                Section {
                    Button {
                        notificationManager.playReminderHaptic()
                    } label: {
                        Label("Test Haptic", systemImage: "hand.tap.fill")
                    }
                } header: {
                    Text("Haptic Feedback")
                }
                
                // Data management
                Section {
                    Button(role: .destructive) {
                        store.clearAllLogs()
                        notificationManager.playClickHaptic()
                    } label: {
                        Label("Clear All Data", systemImage: "trash.fill")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This will delete all exercise logs.")
                }
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties

    private var schedulePreviewText: String {
        let interval = formatInterval(store.reminderIntervalMinutes)
        return "Every \(interval)"
    }

    // MARK: - Formatters

    private func formatInterval(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else if minutes == 60 {
            return "1 hour"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hours"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Tomorrow' h:mm a"
        } else {
            formatter.dateFormat = "EEE h:mm a"
        }

        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView(store: ExerciseStore())
}
