# UX22: Data Export

**Status:** ⏳ Pending  
**Priority:** Medium  
**Effort:** 2-3 days

## Problem

Users have no way to export their data from StandFit. This creates several concerns:

1. **Data Portability**: Users cannot back up their exercise history, achievements, and custom exercises
2. **Privacy/Transparency**: No way to see all data the app has collected
3. **Analysis**: Power users cannot export data for external analysis (spreadsheets, charting tools)
4. **Migration**: No backup before major app updates or device changes
5. **Trust**: Lack of export reduces user confidence in data ownership

Common user requests:
- "How do I backup my data?"
- "Can I export my exercise history to Excel?"
- "I want to keep a copy of my data before updating"
- "How do I see all my achievements in one place?"

## Proposed Solution

Add a **Data Export** feature in Settings that allows users to download their complete data as a JSON file (and optionally CSV for exercise logs).

### Export Options

**What to Export:**
- ✅ Exercise Logs (all logged exercises with timestamps)
- ✅ Custom Exercises (user-created exercises)
- ✅ Achievements (unlocked achievements and progress)
- ✅ Gamification Data (streaks, level, XP)
- ✅ Notification History (fired notification log)
- ✅ Settings (notification schedules, profiles, preferences)
- ⚠️ **Exclude**: StoreKit purchase data (handled by Apple)

**Export Formats:**
1. **JSON** (default): Complete data dump, preserves all relationships and structure
2. **CSV** (exercise logs only): For spreadsheet analysis

**Access Level:**
- ✅ **Free for all users** - This is a privacy/transparency feature, not premium
- GDPR/CCPA compliance: Users have right to access their data

## User Experience Flow

### Settings UI

```swift
// In SettingsView
Section("Data & Privacy") {
    Button {
        showExportSheet = true
    } label: {
        HStack {
            Image(systemName: "arrow.down.doc")
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text("Export My Data")
                    .font(.body)
                Text("Download all your exercises, achievements, and settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
.sheet(isPresented: $showExportSheet) {
    DataExportView()
}
```

### Export Sheet

```
┌─────────────────────────────────────┐
│  Export Your Data                   │
│  ───────────────────────────────────│
│                                      │
│  ✓ Exercise Logs (247 entries)      │
│  ✓ Custom Exercises (3 exercises)   │
│  ✓ Achievements (12/50 unlocked)    │
│  ✓ Gamification Data                │
│  ✓ Notification History             │
│  ✓ Settings & Preferences           │
│                                      │
│  ───────────────────────────────────│
│                                      │
│  Format: [JSON ▼] [CSV]             │
│                                      │
│  Estimated size: ~125 KB            │
│                                      │
│  ┌───────────────────────────────┐  │
│  │   Export Data                 │  │
│  └───────────────────────────────┘  │
│                                      │
│  [ Cancel ]                          │
└─────────────────────────────────────┘
```

After tapping "Export Data":
1. Show activity indicator: "Preparing export..."
2. Generate file(s)
3. Present iOS Share Sheet
4. User can: Save to Files, AirDrop, Email, Save to iCloud Drive, etc.

### Share Sheet Integration

```swift
// Use UIActivityViewController
let activityVC = UIActivityViewController(
    activityItems: [exportFileURL],
    applicationActivities: nil
)
activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
```

## Implementation Strategy

### Phase 1: Core Export Service (1 day)

```swift
// StandFitCore/Sources/StandFitCore/Services/DataExportService.swift

import Foundation

public struct ExportedData: Codable {
    public let exportDate: Date
    public let appVersion: String
    public let exerciseLogs: [ExerciseLog]
    public let customExercises: [CustomExercise]
    public let achievements: [Achievement]
    public let gamificationData: GamificationData
    public let notificationHistory: [NotificationFiredLog]
    public let settings: ExportedSettings
    
    public struct ExportedSettings: Codable {
        public let remindersEnabled: Bool
        public let scheduleProfiles: [ScheduleProfile]
        public let activeProfileId: UUID?
        public let progressReportSettings: ProgressReportSettings?
    }
}

public class DataExportService {
    private let exerciseService: ExerciseService
    private let gamificationService: GamificationService
    
    public init(exerciseService: ExerciseService, gamificationService: GamificationService) {
        self.exerciseService = exerciseService
        self.gamificationService = gamificationService
    }
    
    /// Generate complete data export
    public func generateExport() throws -> ExportedData {
        // 1. Load all data from persistence
        let exerciseLogs = try exerciseService.loadExerciseLogs()
        let customExercises = try exerciseService.loadCustomExercises()
        let achievements = gamificationService.achievements
        let gamificationData = try gamificationService.loadGamificationData()
        let notificationHistory = try loadNotificationHistory()
        
        // 2. Load settings from UserDefaults
        let settings = loadSettings()
        
        // 3. Package everything
        return ExportedData(
            exportDate: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            exerciseLogs: exerciseLogs,
            customExercises: customExercises,
            achievements: achievements,
            gamificationData: gamificationData,
            notificationHistory: notificationHistory,
            settings: settings
        )
    }
    
    /// Save export data as JSON file
    public func exportToJSON() throws -> URL {
        let exportData = try generateExport()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        // Save to temporary directory
        let fileName = "StandFit_Export_\(Date().ISO8601Format()).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try jsonData.write(to: tempURL)
        
        return tempURL
    }
    
    /// Save exercise logs as CSV file
    public func exportExerciseLogsToCSV() throws -> URL {
        let logs = try exerciseService.loadExerciseLogs()
        
        var csvString = "Date,Time,Exercise Type,Custom Exercise Name,Count,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        for log in logs.sorted(by: { $0.timestamp < $1.timestamp }) {
            let date = dateFormatter.string(from: log.timestamp)
            let time = timeFormatter.string(from: log.timestamp)
            let exerciseType = log.exerciseType?.displayName ?? "Custom"
            let customName = log.customExerciseId != nil ? getCustomExerciseName(log.customExerciseId!) : ""
            let count = "\(log.count)"
            let notes = log.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            
            csvString += "\"\(date)\",\"\(time)\",\"\(exerciseType)\",\"\(customName)\",\(count),\"\(notes)\"\n"
        }
        
        let fileName = "StandFit_Exercises_\(Date().ISO8601Format()).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
        
        return tempURL
    }
    
    private func loadNotificationHistory() throws -> [NotificationFiredLog] {
        // Load from NotificationFiredLog persistence
        let persistence = try JSONFilePersistence()
        return try persistence.load(forKey: "notification_fired_log", as: [NotificationFiredLog].self) ?? []
    }
    
    private func loadSettings() -> ExportedData.ExportedSettings {
        let defaults = UserDefaults.standard
        
        return ExportedData.ExportedSettings(
            remindersEnabled: defaults.bool(forKey: "remindersEnabled"),
            scheduleProfiles: loadScheduleProfiles(),
            activeProfileId: defaults.string(forKey: "activeProfileId").flatMap { UUID(uuidString: $0) },
            progressReportSettings: loadProgressReportSettings()
        )
    }
    
    private func loadScheduleProfiles() -> [ScheduleProfile] {
        guard let data = UserDefaults.standard.data(forKey: "scheduleProfiles") else {
            return []
        }
        return (try? JSONDecoder().decode([ScheduleProfile].self, from: data)) ?? []
    }
    
    private func loadProgressReportSettings() -> ProgressReportSettings? {
        guard let data = UserDefaults.standard.data(forKey: "progressReportSettingsData") else {
            return nil
        }
        return try? JSONDecoder().decode(ProgressReportSettings.self, from: data)
    }
    
    private func getCustomExerciseName(_ id: UUID) -> String {
        guard let customExercises = try? exerciseService.loadCustomExercises(),
              let exercise = customExercises.first(where: { $0.id == id }) else {
            return "Unknown"
        }
        return exercise.name
    }
}
```

### Phase 2: SwiftUI Export View (1 day)

```swift
// StandFit/Views/DataExportView.swift

import SwiftUI

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var exerciseStore: ExerciseStore
    @EnvironmentObject private var gamificationStore: GamificationStore
    
    @State private var selectedFormat: ExportFormat = .json
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showShareSheet = false
    @State private var exportFileURL: URL?
    
    enum ExportFormat {
        case json
        case csv
        
        var displayName: String {
            switch self {
            case .json: return "JSON"
            case .csv: return "CSV (Exercise Logs Only)"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DataSummaryRow(
                        icon: "list.bullet",
                        title: "Exercise Logs",
                        detail: "\(exerciseStore.exerciseLogs.count) entries"
                    )
                    
                    DataSummaryRow(
                        icon: "figure.walk",
                        title: "Custom Exercises",
                        detail: "\(exerciseStore.customExercises.count) exercises"
                    )
                    
                    DataSummaryRow(
                        icon: "trophy",
                        title: "Achievements",
                        detail: "\(unlockedAchievements)/\(totalAchievements) unlocked"
                    )
                    
                    DataSummaryRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Gamification Data",
                        detail: "Level \(gamificationStore.currentLevel), \(gamificationStore.currentStreak)-day streak"
                    )
                    
                    DataSummaryRow(
                        icon: "bell.badge",
                        title: "Notification History",
                        detail: "All logged notifications"
                    )
                    
                    DataSummaryRow(
                        icon: "gear",
                        title: "Settings & Preferences",
                        detail: "Schedules and profiles"
                    )
                } header: {
                    Text("Data to Export")
                }
                
                Section {
                    Picker("Format", selection: $selectedFormat) {
                        Text("JSON").tag(ExportFormat.json)
                        Text("CSV").tag(ExportFormat.csv)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedFormat == .csv {
                        Text("CSV format only includes exercise logs. For complete data, use JSON.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Export Format")
                }
                
                Section {
                    HStack {
                        Text("Estimated Size")
                        Spacer()
                        Text(estimatedSize)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Export Your Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        performExport()
                    } label: {
                        if isExporting {
                            ProgressView()
                        } else {
                            Text("Export")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isExporting)
                }
            }
            .alert("Export Failed", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                if let error = exportError {
                    Text(error)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private var unlockedAchievements: Int {
        gamificationStore.achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalAchievements: Int {
        gamificationStore.achievements.count
    }
    
    private var estimatedSize: String {
        // Rough estimate based on data counts
        let logSize = exerciseStore.exerciseLogs.count * 200 // ~200 bytes per log
        let customSize = exerciseStore.customExercises.count * 500 // ~500 bytes per custom exercise
        let achievementSize = gamificationStore.achievements.count * 300
        let totalBytes = logSize + customSize + achievementSize + 10_000 // +10KB for overhead
        
        if totalBytes < 1024 {
            return "\(totalBytes) bytes"
        } else if totalBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalBytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(totalBytes) / (1024.0 * 1024.0))
        }
    }
    
    private func performExport() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                let exportService = DataExportService(
                    exerciseService: exerciseStore.exerciseService,
                    gamificationService: gamificationStore.gamificationService
                )
                
                let fileURL: URL
                switch selectedFormat {
                case .json:
                    fileURL = try exportService.exportToJSON()
                case .csv:
                    fileURL = try exportService.exportExerciseLogsToCSV()
                }
                
                await MainActor.run {
                    self.exportFileURL = fileURL
                    self.isExporting = false
                    self.showShareSheet = true
                }
            } catch {
                await MainActor.run {
                    self.exportError = error.localizedDescription
                    self.isExporting = false
                }
            }
        }
    }
}

struct DataSummaryRow: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// Share Sheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
```

### Phase 3: Import Support (Optional, 1 day)

While not in the initial scope, consider adding import capability:

```swift
// Future: Data Import
public func importFromJSON(fileURL: URL) throws {
    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let importedData = try decoder.decode(ExportedData.self, from: data)
    
    // Merge imported data with existing data
    // Options: Replace all, Merge (keep both), Replace if newer
}
```

## Technical Considerations

### Data Privacy & Security

1. **No Cloud Storage**: Export files are created locally, never uploaded
2. **User Control**: User chooses where to save via iOS Share Sheet
3. **Temporary Files**: Clean up temp directory after export
4. **No Sensitive Data**: Don't include StoreKit receipts or payment info

### File Cleanup

```swift
// Clean up temporary exports after 1 hour
func cleanupOldExports() {
    let tempDir = FileManager.default.temporaryDirectory
    let hourAgo = Date().addingTimeInterval(-3600)
    
    if let files = try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: [.creationDateKey]) {
        for file in files where file.lastPathComponent.hasPrefix("StandFit_Export_") {
            if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
               creationDate < hourAgo {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
```

### Localization

All export UI strings should be localized:

```json
// Settings.xcstrings
{
  "export_my_data": {
    "extractionState": "manual",
    "localizations": {
      "en": { "stringUnit": { "state": "translated", "value": "Export My Data" } },
      "de": { "stringUnit": { "state": "translated", "value": "Meine Daten exportieren" } },
      "es": { "stringUnit": { "state": "translated", "value": "Exportar mis datos" } },
      "fr": { "stringUnit": { "state": "translated", "value": "Exporter mes données" } }
    }
  }
}
```

## Testing Strategy

### Unit Tests

```swift
class DataExportServiceTests: XCTestCase {
    func testJSONExport() throws {
        let service = DataExportService(...)
        let url = try service.exportToJSON()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        
        // Verify JSON is valid
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ExportedData.self, from: data)
        XCTAssertNotNil(decoded.exportDate)
    }
    
    func testCSVExport() throws {
        let service = DataExportService(...)
        let url = try service.exportExerciseLogsToCSV()
        
        let csvContent = try String(contentsOf: url)
        XCTAssertTrue(csvContent.contains("Date,Time,Exercise Type"))
    }
}
```

### Manual Testing

1. **Empty Data**: Export with no exercise logs → should still create valid file
2. **Large Data**: Export with 1000+ logs → should complete without timeout
3. **Share Sheet**: Verify all save options work (Files, iCloud, AirDrop)
4. **File Naming**: Check filename includes timestamp
5. **Localization**: Test in different languages

## User Education

### In-App Help

Add a "What's in my export?" info button:

```
Your export includes:
• All exercise logs with dates and times
• Custom exercises you've created
• Achievement progress and unlocked achievements
• Streak and gamification data
• Notification schedules and settings

Your export does NOT include:
• Payment or subscription information
• System-level notification settings
• StandFit app data (handled by iOS backup)
```

## Success Metrics

- **Export Usage**: % of users who export their data
- **Format Preference**: JSON vs CSV usage ratio
- **Support Reduction**: Decrease in "how to backup" support tickets
- **User Retention**: Users who export more likely to keep using app
- **Privacy Trust**: Increased App Store ratings mentioning "privacy" or "data ownership"

## Related Issues

- **UX21**: iCloud Sync - Export provides alternative backup method for free users
- **UX15**: Monetization - Export is free to build trust and transparency
- **UX20**: Localization - All export UI must be translated

## Priority Justification

**Medium Priority** because:
- ✅ Builds user trust and transparency (privacy)
- ✅ Low implementation effort (2-3 days)
- ✅ GDPR/CCPA compliance feature
- ✅ Reduces support burden
- ⚠️ Not immediately needed for core functionality
- ⚠️ iCloud sync (UX21) may reduce backup urgency for premium users

## Future Enhancements

1. **Scheduled Exports**: Automatic weekly/monthly exports to iCloud Drive
2. **Selective Export**: Choose which data types to include
3. **Data Import**: Restore from exported file
4. **PDF Reports**: Human-readable achievement certificates
5. **Email Export**: Send export directly to email
6. **Export History**: Track when exports were created

---

## Implementation Checklist

- [ ] Create `DataExportService.swift` in StandFitCore
- [ ] Add `ExportedData` models
- [ ] Implement `exportToJSON()` method
- [ ] Implement `exportToCSV()` method
- [ ] Create `DataExportView.swift` UI
- [ ] Add export button to SettingsView
- [ ] Implement `ShareSheet` wrapper
- [ ] Add file cleanup logic
- [ ] Write unit tests
- [ ] Add localized strings
- [ ] Test on physical device
- [ ] Update privacy policy documentation
- [ ] Add to release notes
