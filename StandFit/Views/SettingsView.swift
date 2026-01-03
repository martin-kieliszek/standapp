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
                                Text(store.isPremium ? LocalizedString.Premium.premiumActive : LocalizedString.Premium.unlockPremium)
                                    .font(.headline)
                                if let trial = SubscriptionManager.shared.trialState, trial.isActive {
                                    Text(LocalizedString.Premium.daysRemaining(trial.daysRemaining))
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
                        Label(LocalizedString.Settings.reminders, systemImage: "bell.fill")
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
                            Label(LocalizedString.Schedule.schedule, systemImage: "calendar.badge.clock")
                            Spacer()
                            Text(schedulePreviewText)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .disabled(!store.remindersEnabled)
                } header: {
                    Text(LocalizedString.Schedule.reminderSchedule)
                } footer: {
                    if let nextTime = store.nextScheduledNotificationTime, store.remindersEnabled {
                        Text(LocalizedString.Schedule.nextReminder(formatDateTime(nextTime)))
                    } else if store.remindersEnabled {
                        Text(LocalizedString.Schedule.scheduling)
                    } else {
                        Text(LocalizedString.Settings.enableReminders)
                    }
                }

                // Exercises management
                Section {
                    NavigationLink {
                        CustomExerciseListView(store: store)
                    } label: {
                        HStack {
                            Label(LocalizedString.Picker.custom, systemImage: "figure.run")
                            Spacer()
                            Text("\(store.customExercises.count) custom")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text(LocalizedString.Picker.custom)
                } footer: {
                    Text(LocalizedString.Settings.manageExercises)
                }

                // Progress Reports
                Section {
                    NavigationLink {
                        ProgressReportSettingsView(store: store)
                    } label: {
                        HStack {
                            Label(LocalizedString.Settings.reports, systemImage: "chart.bar.fill")
                            Spacer()
                            if store.progressReportSettings.enabled {
                                Text(LocalizedString.Settings.on)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text(LocalizedString.Settings.reports)
                } footer: {
                    Text(LocalizedString.Settings.autoReports)
                }

                // Haptic test
                Section {
                    Button {
                        notificationManager.playReminderHaptic()
                    } label: {
                        Label(LocalizedString.Settings.testHaptic, systemImage: "hand.tap.fill")
                    }
                } header: {
                    Text(LocalizedString.Settings.hapticFeedback)
                }
                
                // Data management
                Section {
                    Button(role: .destructive) {
                        store.clearAllLogs()
                        notificationManager.playClickHaptic()
                    } label: {
                        Label(LocalizedString.Settings.clearAllData, systemImage: "trash.fill")
                    }
                } header: {
                    Text(LocalizedString.Settings.data)
                } footer: {
                    Text(LocalizedString.Settings.deleteConfirmation)
                }
                
                // About
                Section {
                    HStack {
                        Text(LocalizedString.Settings.version)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(LocalizedString.Settings.about)
                }
            }
            .navigationTitle(LocalizedString.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.Settings.done) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties

    private var schedulePreviewText: String {
        let interval = LocalizedString.Settings.formatInterval(store.reminderIntervalMinutes)
        return interval
    }

    // MARK: - Formatters

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return "\(LocalizedString.Settings.today) \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "h:mm a"
            return "\(LocalizedString.Settings.tomorrow) \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "EEE h:mm a"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    SettingsView(store: ExerciseStore())
}
