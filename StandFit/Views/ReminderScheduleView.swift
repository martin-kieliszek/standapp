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
        .navigationTitle("Reminder Schedule")
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
                        Label("Edit Schedule", systemImage: "slider.horizontal.3")
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
                    Label("Switch Profile", systemImage: "arrow.left.arrow.right")
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
                    Label("Create Schedule Profile", systemImage: "plus.circle.fill")
                }
            }
        } header: {
            Text("Active Schedule Profile")
        } footer: {
            Text("Use profiles for advanced scheduling with time blocks, per-day customization, and more")
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
                        Text("Next Reminder")
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
                    Text("No reminder scheduled")
                        .foregroundStyle(.secondary)
                }
            }
            
            if let profile = store.activeProfile {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Schedule Summary")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label("Active Days", systemImage: "calendar")
                            .font(.subheadline)
                        Spacer()
                        Text("\(profile.activeDays.count) days")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Avg. Daily Reminders", systemImage: "bell.badge")
                            .font(.subheadline)
                        Spacer()
                        Text("\(profile.estimatedDailyAverage)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Dead Response", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                        Spacer()
                        Text(profile.deadResponseEnabled ? "\(profile.deadResponseMinutes) min" : "Off")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Current Schedule")
        } footer: {
            Text("Use 'Edit' to modify time blocks, intervals, and per-day settings")
        }
    }

    // MARK: - Formatters

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        } else {
            formatter.dateFormat = "EEE 'at' h:mm a"
        }

        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ReminderScheduleView(store: ExerciseStore())
    }
}

