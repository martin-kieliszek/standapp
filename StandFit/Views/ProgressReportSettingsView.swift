//
//  ProgressReportSettingsView.swift
//  StandFit iOS
//
//  Configure automatic progress report notifications
//

import SwiftUI
import StandFitCore

/// Dedicated view for configuring progress report notifications
/// Simplified to just enable/disable weekly reports (Sundays at 9 AM)
struct ProgressReportSettingsView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    private let notificationManager = NotificationManager.shared

    @State private var isEnabled: Bool
    @State private var hasChanges = false

    init(store: ExerciseStore) {
        self.store = store
        _isEnabled = State(initialValue: store.progressReportSettings.enabled)
    }

    var body: some View {
        List {
            // Simple enabled toggle
            Section {
                Toggle(isOn: $isEnabled) {
                    Label(LocalizedString.ProgressReportSettings.enabledLabel, systemImage: "chart.bar.fill")
                }
                .onChange(of: isEnabled) { oldValue, newValue in
                    hasChanges = (newValue != store.progressReportSettings.enabled)
                }
            } footer: {
                Text(LocalizedString.ProgressReportSettings.enabledFooter)
            }
            
            // Info section showing fixed schedule
            if isEnabled {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                            Text(LocalizedString.ProgressReportSettings.weeklyScheduleDay)
                                .font(.body)
                        }
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.blue)
                            Text(formatHour(9))
                                .font(.body)
                        }
                    }
                } header: {
                    Text(LocalizedString.ProgressReportSettings.scheduleHeader)
                } footer: {
                    Text(LocalizedString.ProgressReportSettings.weeklyScheduleFooter)
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
    }

    private func saveChanges() {
        // Update settings with fixed weekly schedule
        var updatedSettings = store.progressReportSettings
        updatedSettings.enabled = isEnabled
        updatedSettings.frequency = .weekly
        updatedSettings.hour = 9
        updatedSettings.minute = 0
        
        store.progressReportSettings = updatedSettings
        
        // Update notification schedule
        store.updateAllNotificationSchedules(reason: "Progress report settings changed")
        
        notificationManager.playSuccessHaptic()
        hasChanges = false
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
        ProgressReportSettingsView(store: ExerciseStore.shared)
    }
}

