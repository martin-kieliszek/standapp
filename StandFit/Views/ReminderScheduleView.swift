//
//  ReminderScheduleView.swift
//  StandFit iOS
//
//  Profile-based reminder schedule view
//

import SwiftUI
import StandFitCore
import Combine
/// A dedicated view for configuring reminder schedule with profile management.
struct ReminderScheduleView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    private let notificationManager = NotificationManager.shared

    // UI state
    @State private var showingProfilePicker = false
    @State private var showingProfileEditor = false

    init(store: ExerciseStore) {
        self.store = store
    }

    var body: some View {
        List {
            // Active Profile Section
            activeProfileSection
            
            // Current schedule info
            currentScheduleSection
        }
        .navigationTitle(LocalizedString.ReminderSchedule.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingProfilePicker) {
            ScheduleProfilePickerView(store: store)
        }
        .sheet(isPresented: $showingProfileEditor) {
            if store.activeProfile != nil {
                NavigationStack {
                    DayScheduleEditorView(
                        store: store,
                        profile: Binding(
                            get: { store.activeProfile! },
                            set: { 
                                store.updateProfile($0)
                                store.objectWillChange.send()
                            }
                        )
                    )
                }
            }
        }
    }

    // MARK: - Sections
    
    private var activeProfileSection: some View {
        Section {
            if let profile = store.activeProfile {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.name)
                                .font(.headline)
                            Text(profile.summaryDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Button {
                        showingProfileEditor = true
                    } label: {
                        Label(LocalizedString.ReminderSchedule.editSchedule, systemImage: "slider.horizontal.3")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .foregroundStyle(.white)
                }
                .padding(.vertical, 4)
                
                Button {
                    showingProfilePicker = true
                } label: {
                    Label(LocalizedString.ReminderSchedule.switchProfile, systemImage: "arrow.left.arrow.right")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundStyle(.white)
            } else {
                Button {
                    showingProfilePicker = true
                } label: {
                    Label(LocalizedString.ReminderSchedule.createScheduleProfile, systemImage: "plus.circle.fill")
                }
            }
        } header: {
            Text(LocalizedString.ReminderSchedule.activeScheduleProfile)
        } footer: {
            Text(LocalizedString.ReminderSchedule.profileFooter)
        }
    }

    private var currentScheduleSection: some View {
        Section {
            if let nextTime = store.nextScheduledNotificationTime {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedString.ReminderSchedule.nextReminder)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDateTime(nextTime))
                            .font(.headline)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .foregroundStyle(.secondary)
                    Text(LocalizedString.ReminderSchedule.noReminderScheduled)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let profile = store.activeProfile {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text(LocalizedString.ReminderSchedule.scheduleSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label(LocalizedString.ReminderSchedule.activeDays, systemImage: "calendar")
                            .font(.subheadline)
                        Spacer()
                        Text(LocalizedString.ReminderSchedule.daysCount(profile.activeDays.count))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label(LocalizedString.ReminderSchedule.avgDailyReminders, systemImage: "bell.badge")
                            .font(.subheadline)
                        Spacer()
                        Text("\(profile.estimatedDailyAverage)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label(LocalizedString.ReminderSchedule.deadResponse, systemImage: "arrow.clockwise")
                            .font(.subheadline)
                        Spacer()
                        Text(profile.deadResponseEnabled ? LocalizedString.ReminderSchedule.minutesFormat(profile.deadResponseMinutes) : LocalizedString.ReminderSchedule.off)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text(LocalizedString.ReminderSchedule.currentSchedule)
        } footer: {
            Text(LocalizedString.ReminderSchedule.scheduleFooter)
        }
    }

    // MARK: - Formatters

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'\(LocalizedString.ReminderSchedule.todayAt)' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'\(LocalizedString.ReminderSchedule.tomorrowAt)' h:mm a"
        } else {
            formatter.dateFormat = "EEE '\(LocalizedString.ReminderSchedule.weekdayAt)' h:mm a"
        }

        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ReminderScheduleView(store: ExerciseStore())
    }
}

