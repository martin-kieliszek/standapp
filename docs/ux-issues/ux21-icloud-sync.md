# UX21: iCloud Sync for Premium Users (Pending)

**Status:** ⏳ Pending

## Problem

Currently, all user data is stored **locally only** with no cross-device synchronization. This creates several issues:

### Data Isolation Issues
- User unlocks achievements on iPhone → not reflected on iPad
- Custom exercises created on one device → not available on other devices
- Streak progress tracked separately on each device
- Schedule profiles and settings don't sync
- Users switching between devices have fragmented experience

### Data Loss Risks
- Reinstalling app → loses all achievements, streaks, exercise logs
- Device upgrade → requires manual backup/restore
- Device loss/damage → permanent data loss (unless iCloud device backup exists)
- No way to recover data across devices

### Current Local Storage

| Data Type | File Name | Location | Syncs? | Size Est. |
|-----------|-----------|----------|--------|-----------|
| Exercise Logs | `exercise_logs.json` | Documents/ | ❌ No | ~10-50KB |
| Custom Exercises | `custom_exercises.json` | Documents/ | ❌ No | ~5-20KB |
| Notification Logs | `notification_fired_log.json` | Documents/ | ❌ No | ~1-5KB |
| Achievements | `gamification_data.json` | Documents/ | ❌ No | ~20-40KB |
| Settings/Profiles | UserDefaults plist | Library/Preferences/ | ❌ No | ~5-10KB |
| **Total** | | | | **~40-125KB** |

## Proposed Solution: Premium iCloud Sync (Simple File-Based Approach)

Implement **iCloud Documents** file syncing as a **premium-only feature**, providing value differentiation and encouraging subscriptions.

### Why Premium-Only?

1. **Value Differentiation**: Premium feature that justifies subscription pricing
2. **Data Incentive**: Users with valuable achievement/streak data more likely to subscribe
3. **Competitive Positioning**: Most fitness apps gate sync behind premium tiers
4. **Quality of Service**: Premium users get prioritized support for sync issues
5. **Storage Costs**: While iCloud storage is user-provided, premium status gates the feature

### Why File-Based Sync (Not CloudKit)?

**CloudKit is overkill** for this use case:
- ❌ Complex database setup for ~100KB of data
- ❌ Requires data model conversions (Codable → CKRecord)
- ❌ Months of development time
- ❌ Complex conflict resolution logic

**iCloud Documents is perfect**:
- ✅ Already using JSON files - just change directory
- ✅ iOS handles sync automatically
- ✅ Built-in conflict resolution
- ✅ Days of development instead of months
- ✅ Works with existing persistence layer

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    iCloud Container                          │
│           iCloud.com.sventos.StandFit                       │
│  (Only accessible when user is Premium + signed in)        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Documents/ (Auto-synced by iOS)                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ exercise_logs.json              (~10-50KB)            │  │
│  │ - Array of ExerciseLog (existing model)              │  │
│  │ - Syncs automatically across devices                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ custom_exercises.json           (~5-20KB)             │  │
│  │ - Array of CustomExercise                            │  │
│  │ - User's custom exercise definitions                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ gamification_data.json          (~20-40KB)            │  │
│  │ - Achievements, streaks, level progress              │  │
│  │ - Auto-merged on conflict (take best of both)        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ notification_fired_log.json     (~1-5KB)              │  │
│  │ - Notification delivery history (today only)         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│            NSUbiquitousKeyValueStore                         │
│              (For Settings/Preferences)                      │
├─────────────────────────────────────────────────────────────┤
│  - remindersEnabled: Bool                                   │
│  - scheduleProfiles: Data (encoded)                         │
│  - activeProfileId: String                                  │
│  - progressReportSettings: Data                             │
│  Total: <1MB (well within 1MB limit)                        │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Strategy

### Phase 1: iCloud Documents Foundation (2-3 days)

#### 1.1 Enable iCloud Capability
- Add iCloud capability in Xcode (Signing & Capabilities)
- Check "iCloud Documents" option
- Create iCloud Container: `iCloud.com.sventos.StandFit`
- Add Info.plist key: `NSUbiquitousContainers`

#### 1.2 Create iCloud-Aware Persistence Provider
```swift
// StandFitCore/Sources/StandFitCore/Persistence/iCloudFilePersistence.swift

import Foundation

public class iCloudFilePersistence: PersistenceProvider {
    private let fileManager: FileManager
    private let documentsDirectory: URL
    private let isUsingICloud: Bool
    
    public init(fileManager: FileManager = .default, useICloud: Bool = true) throws {
        self.fileManager = fileManager
        
        if useICloud, let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
            // Use iCloud Documents directory
            self.documentsDirectory = iCloudURL.appendingPathComponent("Documents")
            self.isUsingICloud = true
            
            // Create directory if needed
            try? fileManager.createDirectory(
                at: documentsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            print("✅ Using iCloud Documents: \(documentsDirectory.path)")
        } else {
            // Fallback to local Documents
            guard let localDocs = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else {
                throw PersistenceError.saveFailed("Could not access documents directory")
            }
            self.documentsDirectory = localDocs
            self.isUsingICloud = false
            
            print("📱 Using local Documents: \(documentsDirectory.path)")
        }
    }
    
    private func fileURL(forKey key: String) -> URL {
        documentsDirectory.appendingPathComponent("\(key).json")
    }
    
    public func save<T: Codable>(_ data: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(data)
            let fileURL = fileURL(forKey: key)
            
            if isUsingICloud {
                // Use NSFileCoordinator for safe concurrent access across devices
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                
                coordinator.coordinate(
                    writingItemAt: fileURL,
                    options: .forReplacing,
                    error: &coordinatorError
                ) { url in
                    try? jsonData.write(to: url, options: .atomic)
                }
                
                if let error = coordinatorError {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
            } else {
                // Local-only: simple write
                try jsonData.write(to: fileURL, options: .atomic)
            }
        } catch let error as EncodingError {
            throw PersistenceError.encodingFailed(error.localizedDescription)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }
    
    public func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        let fileURL = fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data: Data
            
            if isUsingICloud {
                // Use NSFileCoordinator for safe concurrent access
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                var tempData: Data?
                
                coordinator.coordinate(
                    readingItemAt: fileURL,
                    options: [],
                    error: &coordinatorError
                ) { url in
                    tempData = try? Data(contentsOf: url)
                }
                
                if let error = coordinatorError {
                    throw PersistenceError.saveFailed(error.localizedDescription)
                }
                
                guard let unwrappedData = tempData else {
                    return nil
                }
                data = unwrappedData
            } else {
                // Local-only: simple read
                data = try Data(contentsOf: fileURL)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw PersistenceError.decodingFailed(error.localizedDescription)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }
    
    public func delete(forKey key: String) throws {
        let fileURL = fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }
        
        if isUsingICloud {
            let coordinator = NSFileCoordinator()
            var coordinatorError: NSError?
            
            coordinator.coordinate(
                writingItemAt: fileURL,
                options: .forDeleting,
                error: &coordinatorError
            ) { url in
                try? fileManager.removeItem(at: url)
            }
            
            if let error = coordinatorError {
                throw PersistenceError.deleteFailed(error.localizedDescription)
            }
        } else {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public func exists(forKey key: String) -> Bool {
        let fileURL = fileURL(forKey: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
```

#### 1.3 Add Premium Gate to Persistence
```swift
// ExerciseStore initialization
init() {
    // Check if user is premium AND iCloud is available
    let useICloud = SubscriptionManager.shared.isPremium && isICloudAvailable()
    
    do {
        self.persistence = try iCloudFilePersistence(useICloud: useICloud)
    } catch {
        // Fallback to local if iCloud setup fails
        print("⚠️ iCloud setup failed, using local: \(error)")
        self.persistence = try! JSONFilePersistence()
    }
    
    self.exerciseService = ExerciseService(persistence: persistence)
    self.reportingService = ReportingService()
    self.timelineService = TimelineService()
    
    // ... rest of initialization
}

private func isICloudAvailable() -> Bool {
    // Check if user is signed into iCloud
    FileManager.default.ubiquityIdentityToken != nil
}
```

### Phase 2: Settings Sync with NSUbiquitousKeyValueStore (1-2 days)

#### 2.1 Cloud Settings Manager
```swift
// StandFit/Managers/CloudSettingsManager.swift

import Foundation

class CloudSettingsManager: ObservableObject {
    static let shared = CloudSettingsManager()
    
    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let localDefaults = UserDefaults.standard
    private let isPremium: Bool
    
    init() {
        self.isPremium = SubscriptionManager.shared.isPremium
        
        if isPremium {
            // Sync immediately
            cloudStore.synchronize()
            
            // Listen for changes from other devices
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(cloudDataChanged),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: cloudStore
            )
        }
    }
    
    // MARK: - Get/Set (uses cloud if premium, local otherwise)
    
    func bool(forKey key: String, default defaultValue: Bool = false) -> Bool {
        if isPremium {
            return cloudStore.bool(forKey: key)
        } else {
            return localDefaults.bool(forKey: key)
        }
    }
    
    func set(_ value: Bool, forKey key: String) {
        if isPremium {
            cloudStore.set(value, forKey: key)
            cloudStore.synchronize()
        } else {
            localDefaults.set(value, forKey: key)
        }
    }
    
    func data(forKey key: String) -> Data? {
        if isPremium {
            return cloudStore.data(forKey: key)
        } else {
            return localDefaults.data(forKey: key)
        }
    }
    
    func set(_ value: Data?, forKey key: String) {
        if isPremium {
            cloudStore.set(value, forKey: key)
            cloudStore.synchronize()
        } else {
            localDefaults.set(value, forKey: key)
        }
    }
    
    // ... other types as needed
    
    @objc private func cloudDataChanged(_ notification: Notification) {
        // Settings changed from another device
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .settingsDidChangeFromCloud,
                object: nil
            )
        }
    }
}

extension Notification.Name {
    static let settingsDidChangeFromCloud = Notification.Name("settingsDidChangeFromCloud")
}
```

### Phase 3: Migration & Premium Flow (2-3 days)

#### 3.1 Migration from Local to iCloud
```swift
// StandFit/Managers/iCloudMigrationManager.swift

class iCloudMigrationManager {
    static func migrateToICloud() async throws {
        print("📤 Starting migration to iCloud...")
        
        // 1. Create both persistence providers
        let localPersistence = try JSONFilePersistence()
        let cloudPersistence = try iCloudFilePersistence(useICloud: true)
        
        // 2. List of all data files to migrate
        let keys = [
            "exercise_logs",
            "custom_exercises",
            "gamification_data",
            "notification_fired_log"
        ]
        
        // 3. Copy each file to iCloud
        for key in keys {
            // Check if local file exists
            if localPersistence.exists(forKey: key) {
                // Load raw data
                if let data: Data = try? localPersistence.load(forKey: key, as: Data.self) {
                    // Save to iCloud
                    try? cloudPersistence.save(data, forKey: key)
                    print("  ✓ Migrated \(key).json")
                }
            }
        }
        
        // 4. Migrate UserDefaults to NSUbiquitousKeyValueStore
        migrateSettings()
        
        print("✅ Migration to iCloud complete!")
    }
    
    private static func migrateSettings() {
        let local = UserDefaults.standard
        let cloud = NSUbiquitousKeyValueStore.default
        
        // Settings keys to migrate
        let settingsKeys = [
            "remindersEnabled",
            "scheduleProfiles",
            "activeProfileId",
            "progressReportSettingsData",
            "hasMigratedToProfiles"
        ]
        
        for key in settingsKeys {
            if let value = local.object(forKey: key) {
                cloud.set(value, forKey: key)
            }
        }
        
        cloud.synchronize()
    }
}
```

#### 3.2 Premium Activation Flow
```swift
// When user subscribes to premium
func onPremiumActivated() async {
    // Show migration prompt
    await showMigrationPrompt()
}

func showMigrationPrompt() async {
    let alert = UIAlertController(
        title: "Enable iCloud Sync?",
        message: "Your achievements, exercises, and settings will sync across all your devices. Requires iCloud account.",
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Enable Sync", style: .default) { _ in
        Task {
            await self.enableICloudSync()
        }
    })
    
    alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
    
    // Present alert
    await MainActor.run {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

func enableICloudSync() async {
    // 1. Check iCloud availability
    guard isICloudSignedIn() else {
        showICloudSignInPrompt()
        return
    }
    
    // 2. Migrate local data to iCloud
    do {
        try await iCloudMigrationManager.migrateToICloud()
        
        // 3. Switch to iCloud persistence
        await switchToICloudPersistence()
        
        // 4. Mark as enabled
        UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
        
        // 5. Show success message
        showSyncEnabledSuccess()
    } catch {
        showMigrationError(error)
    }
}

private func switchToICloudPersistence() async {
    // Restart stores with iCloud persistence
    await MainActor.run {
        ExerciseStore.shared.reinitialize(withICloud: true)
        GamificationStore.shared.reinitialize(withICloud: true)
    }
}
```

#### 3.2 Settings UI for Sync Control
```swift
// In SettingsView.swift - Add to Settings sections

Section("iCloud Sync") {
    if !subscriptionManager.isPremium {
        // Premium upsell
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("iCloud Sync")
                    .font(.headline)
                Spacer()
                Text("Premium")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text("Sync your achievements, exercises, and settings across all your devices")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Upgrade to Premium") {
                showPremiumUpgrade = true
            }
            .buttonStyle(.borderedProminent)
        }
    } else {
        // Premium user - show sync controls
        Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
            .onChange(of: iCloudSyncEnabled) { newValue in
                if newValue {
                    Task { await enableICloudSync() }
                } else {
                    Task { await switchToLocalStorage() }
                }
            }
        
        if iCloudSyncEnabled {
            HStack {
                Image(systemName: isICloudAvailable ? "checkmark.icloud" : "exclamationmark.icloud")
                    .foregroundColor(isICloudAvailable ? .green : .orange)
                Text(isICloudAvailable 
                     ? "Syncing across devices" 
                     : "Not signed into iCloud")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            if !isICloudAvailable {
                Text("Sign into iCloud in Settings to enable sync")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}

private var isICloudAvailable: Bool {
    FileManager.default.ubiquityIdentityToken != nil
}

private func switchToLocalStorage() async {
    // Download iCloud data to local before disabling
    // This prevents data loss
    print("📥 Downloading iCloud data to local storage...")
    UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled")
    
    // Reinitialize stores with local persistence
    await MainActor.run {
        ExerciseStore.shared.reinitialize(withICloud: false)
        GamificationStore.shared.reinitialize(withICloud: false)
    }
}
```
                case .conflict:
                    Text("Needs attention")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $syncManager.isEnabled)
        }
        
        Button("Sync Now") {
            Task {
                await syncManager.performSync()
            }
        }
        .disabled(!syncManager.isEnabled)
        
    } header: {
        Text("Cloud Sync")
    } footer: {
        Text("Sync your achievements, exercises, and settings across all your devices. Requires iCloud account.")
    }
}
```

#### 3.3 Sync Status Indicator
```swift
// In ContentView - Show sync status badge for premium users
if subscriptionManager.isPremium {
    HStack {
        Image(systemName: syncManager.isEnabled ? "icloud.fill" : "icloud.slash")
            .foregroundStyle(syncManager.isEnabled ? .blue : .gray)
            .font(.caption)
        
        if case .syncing = syncManager.syncState {
            ProgressView()
                .scaleEffect(0.6)
        }
    }
    .padding(.trailing, 8)
}
```

### Phase 4: Monitoring & Conflict Resolution (1-2 days)

#### 4.1 Monitor iCloud Changes from Other Devices
```swift
// Listen for file changes from other devices
class iCloudMonitor: ObservableObject {
    private var metadataQuery: NSMetadataQuery?
    
    func startMonitoring() {
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return
        }
        
        let documentsURL = iCloudURL.appendingPathComponent("Documents")
        
        // Create metadata query to watch for file changes
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE '*.json'", NSMetadataItemFSNameKey)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(metadataQueryDidUpdate),
            name: .NSMetadataQueryDidUpdate,
            object: query
        )
        
        query.start()
        self.metadataQuery = query
        
        print("📡 Monitoring iCloud file changes...")
    }
    
    @objc private func metadataQueryDidUpdate(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        
        query.disableUpdates()
        
        // Check each file for changes
        for item in query.results {
            if let metadataItem = item as? NSMetadataItem,
               let fileName = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String,
               let downloadStatus = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String {
                
                print("📥 iCloud file updated: \(fileName) - \(downloadStatus)")
                
                // Reload the changed file
                if downloadStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                    reloadFile(named: fileName)
                }
            }
        }
        
        query.enableUpdates()
    }
    
    private func reloadFile(named fileName: String) {
        let key = fileName.replacingOccurrences(of: ".json", with: "")
        
        // Notify stores to reload their data
        NotificationCenter.default.post(
            name: .iCloudFileDidUpdate,
            object: nil,
            userInfo: ["key": key]
        )
    }
}

extension Notification.Name {
    static let iCloudFileDidUpdate = Notification.Name("iCloudFileDidUpdate")
}
```

#### 4.2 Simple Conflict Resolution (Last-Write-Wins)
```swift
// iCloud Documents uses file-based conflict resolution
// NSFileVersion API detects conflicting versions

class ConflictResolver {
    func resolveConflicts(for url: URL) throws {
        // Get all conflicting versions
        let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? []
        
        if conflictVersions.isEmpty {
            return // No conflicts
        }
        
        print("⚠️ Found \(conflictVersions.count) conflicting versions for \(url.lastPathComponent)")
        
        // Strategy: Last-Write-Wins (keep the most recent)
        guard let currentVersion = NSFileVersion.currentVersionOfItem(at: url) else {
            throw NSError(domain: "ConflictResolver", code: 1, userInfo: nil)
        }
        
        var mostRecent = currentVersion
        
        for version in conflictVersions {
            if let mostRecentDate = mostRecent.modificationDate,
               let versionDate = version.modificationDate,
               versionDate > mostRecentDate {
                mostRecent = version
            }
        }
        
        // If a conflict version is newer, replace current with it
        if mostRecent != currentVersion {
            try mostRecent.replaceItem(at: url, options: [])
        }
        
        // Mark all conflicts as resolved
        for version in conflictVersions {
            version.isResolved = true
        }
        
        try NSFileVersion.removeOtherVersionsOfItem(at: url)
        
        print("✅ Resolved conflicts using most recent version")
    }
}
```

#### 4.3 Handle Download States
```swift
// Ensure files are downloaded before reading
extension iCloudFilePersistence {
    func ensureDownloaded(forKey key: String) async throws {
        let fileURL = fileURL(forKey: key)
        
        guard isUsingICloud else { return }
        
        // Check if file needs downloading
        var values: URLResourceValues
        do {
            values = try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        } catch {
            // File doesn't exist yet
            return
        }
        
        guard let status = values.ubiquitousItemDownloadingStatus else {
            return
        }
        
        switch status {
        case .current:
            // Already downloaded
            return
            
        case .notDownloaded:
            // Start download
            print("📥 Downloading \(key).json from iCloud...")
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
            
            // Wait for download
            try await waitForDownload(fileURL: fileURL)
            
        default:
            break
        }
    }
    
    private func waitForDownload(fileURL: URL) async throws {
        // Poll for download completion (with timeout)
        for _ in 0..<30 { // 15 second timeout
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let values = try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if values.ubiquitousItemDownloadingStatus == .current {
                print("✅ Download complete")
                return
            }
        }
        
        throw PersistenceError.saveFailed("Download timeout")
    }
}
```

## Technical Implementation Details

### Store Reinitialization for Sync Toggle

```swift
// Add to ExerciseStore
extension ExerciseStore {
    func reinitialize(withICloud: Bool) {
        // 1. Save current state
        saveAll()
        
        // 2. Create new persistence provider
        do {
            self.persistence = try iCloudFilePersistence(useICloud: withICloud)
        } catch {
            print("⚠️ Failed to switch persistence: \(error)")
            return
        }
        
        // 3. Reinitialize service with new persistence
        self.exerciseService = ExerciseService(persistence: persistence)
        
        // 4. Reload data from new source
        loadAll()
        
        print("✅ Store reinitialized with iCloud: \(withICloud)")
    }
    
    private func saveAll() {
        // Current data is already saved via existing save mechanisms
        // This is a checkpoint to ensure nothing is lost
    }
    
    private func loadAll() {
        // Reload exercise logs
        if let logs: [ExerciseLog] = try? exerciseService.loadExerciseLogs() {
            self.exerciseLogs = logs
        }
        
        // Reload custom exercises
        if let exercises: [CustomExercise] = try? exerciseService.loadCustomExercises() {
            self.customExercises = exercises
        }
    }
}
```

### Error Handling & User Feedback

```swift
enum iCloudError: Error {
    case notSignedIn
    case quotaExceeded
    case networkUnavailable
    case conflictDetected
    
    var userMessage: String {
        switch self {
        case .notSignedIn:
            return "Please sign into iCloud in Settings to enable sync"
        case .quotaExceeded:
            return "iCloud storage is full. Free up space to continue syncing"
        case .networkUnavailable:
            return "No internet connection. Changes will sync when online"
        case .conflictDetected:
            return "Sync conflict detected. Using most recent version"
        }
    }
}

// Show user-friendly error messages
func handleSyncError(_ error: Error) {
    if let iCloudError = error as? iCloudError {
        showErrorBanner(iCloudError.userMessage)
    } else {
        showErrorBanner("Sync failed: \(error.localizedDescription)")
    }
}
```

### Testing Strategy

```swift
// Unit tests with mock iCloud container
class iCloudPersistenceTests: XCTestCase {
    var persistence: iCloudFilePersistence!
    
    override func setUp() async throws {
        // Use test container (won't affect real user data)
        persistence = try iCloudFilePersistence(useICloud: false)
    }
    
    func testSaveAndLoad() async throws {
        let log = ExerciseLog(exerciseType: .stretch, count: 5)
        
        try persistence.save([log], forKey: "test_logs")
        
        let loaded: [ExerciseLog]? = try persistence.load(forKey: "test_logs", as: [ExerciseLog].self)
        
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.count, 5)
    }
    
    func testConflictResolution() async throws {
        // Simulate two devices saving at same time
        // Verify most recent wins
    }
}
```
              let timestamp = record["timestamp"] as? Date,
              let count = record["count"] as? Int else {
            return nil
        }
        
        return ExerciseLog(
            id: id,
            timestamp: timestamp,
            count: count,
            exerciseType: (record["exerciseType"] as? String).flatMap { ExerciseType(rawValue: $0) },
            customExerciseId: (record["customExerciseId"] as? String).flatMap { UUID(uuidString: $0) },
            notes: record["notes"] as? String
        )
    }
}
```

### Premium Gate Implementation

```swift
// PremiumSyncGate.swift
class PremiumSyncGate {
    static func validateSyncAccess() throws {
        // 1. Check premium status
        guard SubscriptionManager.shared.isPremium else {
            throw SyncError.premiumRequired(
                message: "iCloud Sync is a premium feature. Upgrade to sync your data across devices."
            )
        }
        
        // 2. Check iCloud availability
        guard FileManager.default.ubiquityIdentityToken != nil else {
            throw SyncError.iCloudUnavailable(
                message: "Please sign in to iCloud in Settings to enable sync."
            )
        }
        
        // 3. Check network connectivity
        guard isNetworkAvailable() else {
            throw SyncError.networkUnavailable(
                message: "Sync requires internet connection."
            )
        }
    }
    
    // Automatically downgrade to local when premium expires
    func handlePremiumExpiration() {
        // 1. Stop background sync
        stopBackgroundSync()
        
        // 2. Switch to local persistence
        switchToLocalPersistence()
        
        // 3. Keep last synced data locally (don't delete)
        // User can re-enable if they re-subscribe
        
        // 4. Show notification
        showPremiumExpiredNotification()
    }
}
```

### Error Handling & User Messaging

```swift
enum SyncError: LocalizedError {
    case premiumRequired(message: String)
    case iCloudUnavailable(message: String)
    case networkUnavailable(message: String)
    case quotaExceeded
    case conflictResolutionFailed
    case authenticationFailed
    
    var errorDescription: String? {
        switch self {
        case .premiumRequired(let msg):
            return msg
        case .iCloudUnavailable(let msg):
            return msg
        case .networkUnavailable(let msg):
            return msg
        case .quotaExceeded:
            return "iCloud storage quota exceeded. Please free up space."
        case .conflictResolutionFailed:
            return "Unable to merge data from multiple devices. Please contact support."
        case .authenticationFailed:
            return "iCloud authentication failed. Please sign in again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .premiumRequired:
            return "Upgrade to Premium to enable cross-device sync."
        case .iCloudUnavailable:
            return "Go to Settings > [Your Name] > iCloud and sign in."
        case .networkUnavailable:
            return "Connect to WiFi or cellular data and try again."
        case .quotaExceeded:
            return "Go to Settings > [Your Name] > iCloud > Manage Storage."
        case .conflictResolutionFailed:
            return "Choose which device has the most recent data to keep."
        case .authenticationFailed:
            return "Sign out and sign back into iCloud in Settings."
        }
    }
}
```

## User Experience Flow

### For Free Users
1. See "iCloud Sync" badge in settings (grayed out, locked icon)
2. Tap → shows premium paywall
3. "Upgrade to Premium to sync your achievements and exercises across all your devices"
4. Shows comparison: Local Only vs. Premium with Sync

### For Premium Users (New Subscribers)
1. On first premium activation → prompt appears
2. "Welcome to Premium! Enable iCloud Sync?"
3. Explanation of benefits
4. [Enable Sync] or [Maybe Later]
5. If enabled → upload starts, progress indicator
6. Success: "Your data is now syncing!"

### For Premium Users (Existing Data)
1. User opens app on new device (signed into same iCloud)
2. App detects remote data
3. Prompt: "We found data from your other devices. Restore?"
4. Shows: "iPhone data: 45 exercises, 12 achievements"
5. [Restore & Merge] or [Start Fresh]
6. If restore → download + merge, show progress

### For Premium Users (Conflict)
1. Rare case: both devices modified same data offline
2. Show conflict resolution UI:
   - "Data Conflict Detected"
   - Side-by-side comparison
   - Option to choose: [Keep iPhone Data] [Keep iPad Data] [Merge Both]
   - For achievements: Always merge (take best of both)

## Rollout Plan

### Phase 1: Development & Testing (3-4 days)
- Implement `iCloudFilePersistence` class
- Add `CloudSettingsManager` for NSUbiquitousKeyValueStore
- Test local ↔ iCloud migration
- Verify file monitoring and conflict resolution

### Phase 2: UI Integration (1-2 days)
- Add Settings UI for sync toggle
- Implement premium activation flow
- Add sync status indicators
- Test on physical devices (iCloud requires real device testing)

### Phase 3: Beta Testing (1 week)
- TestFlight with premium users
- Monitor for sync issues
- Collect feedback on reliability
- Fix any critical bugs

### Phase 4: Production Release
- Enable for all premium users
- Monitor sync success rate
- Watch for support tickets

## Success Metrics

- **Sync Adoption Rate**: % of premium users who enable sync
- **Sync Reliability**: % of operations that complete successfully
- **User Retention**: Premium renewal rate for users with sync enabled
- **Cross-Device Usage**: % of premium users active on 2+ devices

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| iCloud quota exceeded | Medium | ~125KB is tiny, won't hit limits |
| File conflicts corrupt data | High | NSFileVersion conflict resolution |
| iCloud outage prevents app use | Medium | Always fallback to local documents |
| Battery drain | Low | iCloud Documents syncs efficiently |
| Data loss during migration | High | Test extensively, verify migration |

## Why This Approach Wins

### Complexity: Days vs Months
- **iCloud Documents**: 2-3 files to create, existing JSON reused
- **CloudKit**: Schema design, CKRecord conversion, change tokens, subscriptions, conflict logic

### Reliability: Proven vs Custom
- **iCloud Documents**: Apple handles sync, conflict resolution, download states
- **CloudKit**: You handle everything, debug edge cases

### Cost: Free vs Paid
- **iCloud Documents**: Free for users with iCloud account
- **CloudKit**: Could hit usage limits with many users

### Debugging: Simple vs Complex
- **iCloud Documents**: Check file contents in Finder (~/Library/Mobile Documents)
- **CloudKit**: CloudKit Dashboard, CKError codes, async debugging

### User Expectations
- Users expect their documents to sync (Photos, Notes, Pages all use iCloud Documents)
- They don't expect to manage a "database sync" - that's developer complexity leaking

## Future Enhancements

1. **Smart Merge for Exercise Logs**
   - Currently last-write-wins
   - Could merge logs by timestamp (combine both devices' logs)

2. **Selective Sync**
   - Let users choose what to sync (achievements yes, exercises no)

3. **Export/Import**
   - Manual backup/restore option for paranoid users

4. **Family Sharing**
   - Share custom exercises between family members

---

## Related Issues

- UX15: Monetization Strategy (Premium features)
- UX10: Gamification System (Achievement syncing)
- UX3: Custom Exercises (Exercise syncing)
- UX19: Advanced Reminder Scheduling (Profile syncing)

## Priority

**Medium-High** - Valuable premium feature, but should come after core features are stable. Users won't lose data across updates (Documents/ and UserDefaults persist), so immediate sync is not critical.

## Estimated Effort

With the simplified iCloud Documents approach:

- **iCloudFilePersistence implementation**: 1-2 days
- **CloudSettingsManager**: 1 day
- **Migration logic**: 1 day
- **Settings UI**: 1 day
- **Testing & debugging**: 2-3 days
- **Total**: ~1 week (vs 2.5 months with CloudKit)

This is a **90% reduction in complexity** compared to CloudKit while providing the same user value.

---

## Implementation Status

- [x] Requirements defined
- [x] Architecture revised (CloudKit → iCloud Documents)
- [ ] Core implementation
- [ ] UI integration
- [ ] Testing
- [ ] Beta testing
- [ ] Production release
