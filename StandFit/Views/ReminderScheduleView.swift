//
//  ReminderScheduleView.swift
//  StandFit iOS
//
//  iOS-adapted schedule view with larger controls and confirmation dialog
//

import SwiftUI
import StandFitCore

/// A dedicated view for configuring reminder schedule with confirmation before applying changes.
struct ReminderScheduleView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    private let notificationManager = NotificationManager.shared

    // Local state for pending changes (not applied until confirmed)
    @State private var pendingInterval: Int
    @State private var pendingActiveDays: Set<Int>
    @State private var pendingStartHour: Int
    @State private var pendingEndHour: Int
    @State private var pendingDeadResponseEnabled: Bool
    @State private var pendingDeadResponseMinutes: Int

    // UI state
    @State private var showingConfirmation = false
    @State private var hasChanges = false

    // Available interval options in minutes
    private let intervalOptions = [1, 15, 20, 30, 45, 60, 90, 120]

    // Day names for display
    private let dayNames = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]

    init(store: ExerciseStore) {
        self.store = store
        // Initialize pending values from current store values
        _pendingInterval = State(initialValue: store.reminderIntervalMinutes)
        _pendingActiveDays = State(initialValue: store.activeDays)
        _pendingStartHour = State(initialValue: store.startHour)
        _pendingEndHour = State(initialValue: store.endHour)
        _pendingDeadResponseEnabled = State(initialValue: store.deadResponseEnabled)
        _pendingDeadResponseMinutes = State(initialValue: store.deadResponseMinutes)
    }

    var body: some View {
        List {
            // Current schedule info
            currentScheduleSection

            // Interval picker
            intervalSection

            // Active days
            activeDaysSection

            // Active hours
            activeHoursSection

            // Dead response reset
            deadResponseSection

            // Preview of new schedule (only shown if changes pending)
            if hasChanges {
                newSchedulePreviewSection
            }
        }
        .navigationTitle("Reminder Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    showingConfirmation = true
                }
                .disabled(!hasChanges)
            }
        }
        .confirmationDialog(
            "Update Schedule?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Update Schedule") {
                applyChanges()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(confirmationMessage)
        }
        .onChange(of: pendingInterval) { _ in updateHasChanges() }
        .onChange(of: pendingActiveDays) { _ in updateHasChanges() }
        .onChange(of: pendingStartHour) { _ in updateHasChanges() }
        .onChange(of: pendingEndHour) { _ in updateHasChanges() }
        .onChange(of: pendingDeadResponseEnabled) { _ in updateHasChanges() }
        .onChange(of: pendingDeadResponseMinutes) { _ in updateHasChanges() }
    }

    // MARK: - Sections

    private var currentScheduleSection: some View {
        Section {
            if let nextTime = store.nextScheduledNotificationTime {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    VStack(alignment: .leading) {
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
        } header: {
            Text("Current Schedule")
        }
    }

    private var intervalSection: some View {
        Section {
            Picker("Interval", selection: $pendingInterval) {
                ForEach(intervalOptions, id: \.self) {
                    minutes in
                    Text(formatInterval(minutes))
                        .tag(minutes)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Remind me every")
        }
    }

    private var activeDaysSection: some View {
        Section {
            ForEach(dayNames, id: \.0) { day in
                Button {
                    toggleDay(day.0)
                    notificationManager.playClickHaptic()
                } label: {
                    HStack {
                        Text(day.1)
                        Spacer()
                        if pendingActiveDays.contains(day.0) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Active Days")
        }
    }

    private var activeHoursSection: some View {
        Section {
            Picker("Start", selection: $pendingStartHour) {
                ForEach(0..<24, id: \.self) {
                    hour in
                    Text(formatHour(hour)).tag(hour)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: pendingStartHour) { newValue in
                if newValue >= pendingEndHour {
                    pendingEndHour = min(newValue + 1, 23)
                }
            }

            Picker("End", selection: $pendingEndHour) {
                ForEach(0..<24, id: \.self) {
                    hour in
                    Text(formatHour(hour)).tag(hour)
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: pendingEndHour) { newValue in
                if newValue <= pendingStartHour {
                    pendingStartHour = max(newValue - 1, 0)
                }
            }
        } header: {
            Text("Active Hours")
        } footer: {
            Text("Reminders between \(formatHour(pendingStartHour)) – \(formatHour(pendingEndHour))")
        }
    }

    private var deadResponseSection: some View {
        Section {
            Toggle(isOn: $pendingDeadResponseEnabled) {
                Label("Auto-Retry", systemImage: "arrow.clockwise")
            }

            if pendingDeadResponseEnabled {
                Picker("Retry after", selection: $pendingDeadResponseMinutes) {
                    ForEach(ExerciseStore.deadResponseOptions, id: \.self) {
                        minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        } header: {
            Text("Missed Reminders")
        } footer: {
            if pendingDeadResponseEnabled {
                Text("If you don't respond within \(pendingDeadResponseMinutes) min, a follow-up reminder will fire.")
            } else {
                Text("Missed reminders won't automatically retry.")
            }
        }
    }


    private var newSchedulePreviewSection: some View {
        Section {
            if let previewTime = calculateNewNextReminderTime() {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("New Next Reminder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDateTime(previewTime))
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                        .font(.title2)
                    Text("No valid time slot found")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Preview")
        } footer: {
            Text("This is when your next reminder will be scheduled after saving.")
        }
    }

    // MARK: - Helpers

    private func toggleDay(_ day: Int) {
        if pendingActiveDays.contains(day) {
            pendingActiveDays.remove(day)
        } else {
            pendingActiveDays.insert(day)
        }
    }

    private func updateHasChanges() {
        hasChanges = pendingInterval != store.reminderIntervalMinutes ||
                     pendingActiveDays != store.activeDays ||
                     pendingStartHour != store.startHour ||
                     pendingEndHour != store.endHour ||
                     pendingDeadResponseEnabled != store.deadResponseEnabled ||
                     pendingDeadResponseMinutes != store.deadResponseMinutes
    }

    private func calculateNewNextReminderTime() -> Date? {
        // Temporarily calculate what the next reminder would be with pending settings
        let calendar = Calendar.current
        var proposedTime = Date().addingTimeInterval(TimeInterval(pendingInterval * 60))

        for _ in 0..<(7 * 24) {
            let weekday = calendar.component(.weekday, from: proposedTime)
            let hour = calendar.component(.hour, from: proposedTime)

            if pendingActiveDays.contains(weekday) && hour >= pendingStartHour && hour < pendingEndHour {
                return proposedTime
            }

            if !pendingActiveDays.contains(weekday) {
                proposedTime = calendar.nextDate(
                    after: proposedTime,
                    matching: DateComponents(hour: pendingStartHour, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? proposedTime.addingTimeInterval(3600)
            } else if hour < pendingStartHour {
                proposedTime = calendar.date(
                    bySettingHour: pendingStartHour,
                    minute: 0,
                    second: 0,
                    of: proposedTime
                ) ?? proposedTime
            } else {
                proposedTime = calendar.nextDate(
                    after: proposedTime,
                    matching: DateComponents(hour: pendingStartHour, minute: 0),
                    matchingPolicy: .nextTime
                ) ?? proposedTime.addingTimeInterval(3600)
            }
        }

        return nil
    }

    private var confirmationMessage: String {
        var changes: [String] = []

        if pendingInterval != store.reminderIntervalMinutes {
            changes.append("Interval: \(formatInterval(store.reminderIntervalMinutes)) → \(formatInterval(pendingInterval))")
        }

        if pendingActiveDays != store.activeDays {
            changes.append("Active days updated")
        }

        if pendingStartHour != store.startHour || pendingEndHour != store.endHour {
            changes.append("Hours: \(formatHour(store.startHour))-\(formatHour(store.endHour)) → \(formatHour(pendingStartHour))-\(formatHour(pendingEndHour))")
        }

        if pendingDeadResponseEnabled != store.deadResponseEnabled {
            changes.append("Auto-retry: \(pendingDeadResponseEnabled ? "On" : "Off")")
        } else if pendingDeadResponseEnabled && pendingDeadResponseMinutes != store.deadResponseMinutes {
            changes.append("Retry after: \(store.deadResponseMinutes) min → \(pendingDeadResponseMinutes) min")
        }

        if let newTime = calculateNewNextReminderTime() {
            changes.append("Next reminder: \(formatDateTime(newTime))")
        }

        return changes.joined(separator: "\n")
    }

    private func applyChanges() {
        // Apply all pending changes
        store.reminderIntervalMinutes = pendingInterval
        store.activeDays = pendingActiveDays
        store.startHour = pendingStartHour
        store.endHour = pendingEndHour
        store.deadResponseEnabled = pendingDeadResponseEnabled
        store.deadResponseMinutes = pendingDeadResponseMinutes

        // Reschedule notifications with new settings
        if store.remindersEnabled {
            notificationManager.scheduleReminderWithSchedule(store: store)
        }

        // Update all notification schedules
        store.updateAllNotificationSchedules(reason: "Reminder schedule settings changed")

        notificationManager.playSuccessHaptic()
        dismiss()
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

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return formatter.string(from: date)
    }

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
