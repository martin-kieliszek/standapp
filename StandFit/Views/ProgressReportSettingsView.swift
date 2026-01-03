//
//  ProgressReportSettingsView.swift
//  StandFit iOS
//
//  Configure automatic progress report notifications
//

import SwiftUI
import StandFitCore

/// Dedicated view for configuring progress report settings
struct ProgressReportSettingsView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    private let notificationManager = NotificationManager.shared

    @State private var pendingSettings: ProgressReportSettings
    @State private var hasChanges = false

    init(store: ExerciseStore) {
        self.store = store
        _pendingSettings = State(initialValue: store.progressReportSettings)
    }

    var body: some View {
        List {
            // Enabled toggle
            Section {
                Toggle(isOn: $pendingSettings.enabled) {
                    Label(LocalizedString.ProgressReportSettings.enabledLabel, systemImage: "chart.bar.fill")
                }
            } footer: {
                Text(LocalizedString.ProgressReportSettings.enabledFooter)
            }

            if pendingSettings.enabled {
                // Frequency picker 
                Section {
                    Picker(LocalizedString.ProgressReportSettings.frequencyLabel, selection: $pendingSettings.frequency) {
                        ForEach(ReportFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text(LocalizedString.ProgressReportSettings.scheduleHeader)
                }

                // Time pickers
                Section {
                    Picker(LocalizedString.ProgressReportSettings.hourLabel, selection: $pendingSettings.hour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker(LocalizedString.ProgressReportSettings.minuteLabel, selection: $pendingSettings.minute) {
                        ForEach([0, 15, 30, 45], id: \.self) { min in
                            Text(String(format: "%02d", min)).tag(min)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text(LocalizedString.ProgressReportSettings.timeHeader)
                } footer: {
                    Text(LocalizedString.ProgressReportSettings.timeFooter(hour: formatHour(pendingSettings.hour), minute: String(format: "%02d", pendingSettings.minute), frequency: pendingSettings.frequency.displayName.lowercased()))
                }
            }
        }
        .navigationTitle(LocalizedString.ProgressReportSettings.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(LocalizedString.ProgressReportSettings.saveButton) {
                    saveChanges()
                }
                .disabled(!hasChanges)
            }
        }
        .onChange(of: pendingSettings.enabled) { _ in updateHasChanges() }
        .onChange(of: pendingSettings.frequency) { _ in updateHasChanges() }
        .onChange(of: pendingSettings.hour) { _ in updateHasChanges() }
        .onChange(of: pendingSettings.minute) { _ in updateHasChanges() }
    }

    private func updateHasChanges() {
        hasChanges = pendingSettings != store.progressReportSettings
    }

    private func saveChanges() {
        store.progressReportSettings = pendingSettings
        store.updateAllNotificationSchedules(reason: "Progress report settings changed")
        notificationManager.playSuccessHaptic()
        dismiss()
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ProgressReportSettingsView(store: ExerciseStore())
    }
}
