//
//  ProgressReportSettingsView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/01/2026.
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
                    Label("Progress Reports", systemImage: "chart.bar.fill")
                }
            } footer: {
                Text("Receive automatic summaries of your exercise progress.")
            }

            if pendingSettings.enabled {
                // Frequency picker 
                Section {
                    Picker("Frequency", selection: $pendingSettings.frequency) {
                        ForEach(ReportFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                } header: {
                    Text("Schedule")
                }

                // Time pickers
                Section {
                    Picker("Hour", selection: $pendingSettings.hour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }

                    Picker("Minute", selection: $pendingSettings.minute) {
                        ForEach([0, 15, 30, 45], id: \.self) { min in
                            Text(String(format: "%02d", min)).tag(min)
                        }
                    }
                } header: {
                    Text("Time")
                } footer: {
                    Text("Reports will be sent at \(formatHour(pendingSettings.hour)):\(String(format: "%02d", pendingSettings.minute)) \(pendingSettings.frequency.displayName.lowercased()).")
                }
            }
        }
        .navigationTitle("Progress Reports")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!hasChanges)
            }
        }
        .onChange(of: pendingSettings.enabled) { _, _ in updateHasChanges() }
        .onChange(of: pendingSettings.frequency) { _, _ in updateHasChanges() }
        .onChange(of: pendingSettings.hour) { _, _ in updateHasChanges() }
        .onChange(of: pendingSettings.minute) { _, _ in updateHasChanges() }
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
