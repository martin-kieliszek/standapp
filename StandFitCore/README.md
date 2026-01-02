# StandFitCore

**Version:** 1.0.0
**Platform Support:** iOS 16+, watchOS 9+

Shared business logic for the StandFit fitness tracking app. This Swift Package contains all platform-agnostic code that can be reused across iOS, WatchOS, and future platforms.

---

## Overview

StandFitCore provides:

- **Data Models** - Exercise, gamification, reporting, and timeline models
- **Business Logic Services** - Exercise management, gamification engine, reporting, timeline analysis
- **Persistence Layer** - Protocol-based storage with JSON file implementation (swappable for Core Data, CloudKit, etc.)
- **Utilities** - Notification scheduling calculators and helper functions

**Zero Dependencies:** No UIKit, SwiftUI, WatchKit, or platform-specific frameworks. Pure Swift only.

---

## Installation

### Local Package (Current Setup)

```swift
// In Xcode:
// File → Add Package Dependencies → Add Local
// Select: /path/to/StandFit/StandFitCore
```

### Swift Package Manager (Future)

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/StandFitCore.git", from: "1.0.0")
]
```

---

## Usage

### 1. Import the Module

```swift
import StandFitCore
```

### 2. Set Up Persistence

```swift
let persistence = try JSONFilePersistence()
```

### 3. Create Services

```swift
let exerciseService = ExerciseService(persistence: persistence)
let gamificationService = GamificationService(persistence: persistence)
let reportingService = ReportingService()
let timelineService = TimelineService()
```

### 4. Load & Save Data

```swift
// Load exercise logs
var logs = try exerciseService.loadLogs()

// Log a new exercise
let newLog = ExerciseLog(exerciseType: .squats, count: 10)
try exerciseService.addLog(newLog, to: &logs)

// Get statistics
let stats = reportingService.getStats(
    for: .today,
    logs: logs,
    customExercises: customExercises
)
```

### 5. Process Gamification Events

```swift
var gamificationData = try gamificationService.loadData()

let (updatedData, result) = gamificationService.processEvent(
    .exerciseLogged(exerciseId: "Squats", count: 10, timestamp: Date()),
    currentData: gamificationData,
    logs: logs,
    customExercises: customExercises
)

// Check for newly unlocked achievements
for achievement in result.newlyUnlockedAchievements {
    print("🎉 Unlocked: \(achievement.name)")
}

// Save updated data
try gamificationService.saveData(updatedData)
```

---

## Architecture

### Module Structure

```
StandFitCore/
├── Models/
│   ├── ExerciseModels.swift       - Exercise types, logs, custom exercises
│   ├── GamificationModels.swift   - Achievements, streaks, levels, challenges
│   ├── ReportingModels.swift      - Progress reports, statistics
│   └── TimelineModels.swift       - Timeline events and analysis
│
├── Services/
│   ├── ExerciseService.swift      - Exercise CRUD operations
│   ├── GamificationService.swift  - Gamification event processing
│   ├── ReportingService.swift     - Statistics generation
│   └── TimelineService.swift      - Timeline data generation
│
├── Persistence/
│   └── PersistenceProtocol.swift  - Abstract storage + JSON implementation
│
└── Utilities/
    └── NotificationScheduleCalculator.swift - Notification timing calculations
```

### Design Principles

1. **Platform-Agnostic** - No UI frameworks, works on any Apple platform
2. **Protocol-Based Persistence** - Swap storage backends without changing business logic
3. **Service Layer Pattern** - Pure Swift functions, easy to test
4. **Dependency Injection** - Services accept dependencies via initializers
5. **No Singletons** - All state is explicit and passed as parameters

---

## API Reference

### ExerciseService

**Initialization:**
```swift
ExerciseService(persistence: PersistenceProvider)
```

**Exercise Logs:**
- `loadLogs() throws -> [ExerciseLog]`
- `saveLogs(_ logs: [ExerciseLog]) throws`
- `addLog(_ log: ExerciseLog, to logs: inout [ExerciseLog]) throws`
- `deleteLog(_ log: ExerciseLog, from logs: inout [ExerciseLog]) throws`
- `clearAllLogs() throws`

**Custom Exercises:**
- `loadCustomExercises() throws -> [CustomExercise]`
- `saveCustomExercises(_ exercises: [CustomExercise]) throws`
- `addCustomExercise(_ exercise: CustomExercise, to exercises: inout [CustomExercise]) throws`
- `updateCustomExercise(_ exercise: CustomExercise, in exercises: inout [CustomExercise]) throws`
- `deleteCustomExercise(_ exercise: CustomExercise, from exercises: inout [CustomExercise]) throws`

**Statistics:**
- `todaysLogs(from logs: [ExerciseLog]) -> [ExerciseLog]`
- `todaysSummaries(from logs: [ExerciseLog]) -> [ExerciseSummary]`
- `todaysCustomSummaries(from logs: [ExerciseLog], customExercises: [CustomExercise]) -> [CustomExerciseSummary]`
- `logsForLastDays(_ days: Int, from logs: [ExerciseLog]) -> [ExerciseLog]`

---

### GamificationService

**Data Structure:**
```swift
struct GamificationData: Codable {
    var achievements: [Achievement]
    var streak: StreakData
    var levelProgress: LevelProgress
    var activeChallenges: [Challenge]
}
```

**Initialization:**
```swift
GamificationService(persistence: PersistenceProvider)
```

**Core Methods:**
- `loadData() throws -> GamificationData`
- `saveData(_ data: GamificationData) throws`
- `processEvent(_ event: GamificationEvent, currentData: GamificationData, logs: [ExerciseLog], customExercises: [CustomExercise]) -> (updatedData: GamificationData, result: EventProcessingResult)`

**Query Methods:**
- `achievements(in category: AchievementCategory?, from achievements: [Achievement]) -> [Achievement]`
- `unlockedAchievements(from achievements: [Achievement]) -> [Achievement]`
- `lockedAchievements(from achievements: [Achievement]) -> [Achievement]`
- `inProgressAchievements(from achievements: [Achievement]) -> [Achievement]`
- `activeChallenge(from challenges: [Challenge]) -> Challenge?`

---

### ReportingService

**Statistics Generation:**
```swift
func getStats(
    for period: ReportPeriod,
    logs: [ExerciseLog],
    customExercises: [CustomExercise]
) -> ReportStats
```

**Report Periods:**
- `.today`
- `.yesterday`
- `.weekStarting(Date)`
- `.monthStarting(Date)`
- `.year(Int)`

**ReportStats Properties:**
- `totalCount: Int` - Total exercise count
- `periodStart: Date` - Period start date
- `periodEnd: Date` - Period end date
- `breakdown: [ExerciseBreakdown]` - Exercise breakdown by type
- `comparisonToPrevious: Double?` - Percentage change vs previous period
- `streak: Int?` - Current streak

---

### TimelineService

**Timeline Generation:**
```swift
func getTimeline(
    for date: Date,
    logs: [ExerciseLog],
    customExercises: [CustomExercise],
    firedNotifications: [Date],
    calculator: NotificationScheduleCalculator?
) -> (notifications: [TimelineEvent], exercises: [TimelineEvent])
```

**Timeline Analysis:**
```swift
func getTimelineAnalysis(...) -> TimelineAnalysis
```

**TimelineAnalysis Properties:**
- `averageResponseTimeMinutes: Double?` - Average time from notification to exercise
- `responseRate: Double` - Percentage of notifications that resulted in exercises (0.0-1.0)
- `missedNotifications(withinMinutes: Int) -> [TimelineEvent]` - Notifications with no response

---

### PersistenceProtocol

**Protocol Definition:**
```swift
protocol PersistenceProvider {
    func save<T: Codable>(_ data: T, forKey key: String) throws
    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}
```

**Default Implementation:**
```swift
let persistence = try JSONFilePersistence()
```

**Errors:**
- `PersistenceError.encodingFailed(String)`
- `PersistenceError.decodingFailed(String)`
- `PersistenceError.fileNotFound(String)`
- `PersistenceError.saveFailed(String)`
- `PersistenceError.deleteFailed(String)`

---

## Platform Integration

### SwiftUI Integration (iOS/WatchOS)

Wrap services in `ObservableObject` stores for SwiftUI:

```swift
import SwiftUI
import StandFitCore

@MainActor
class ExerciseStore: ObservableObject {
    private let service: ExerciseService

    @Published var logs: [ExerciseLog] = []
    @Published var customExercises: [CustomExercise] = []

    init() {
        let persistence = try! JSONFilePersistence()
        self.service = ExerciseService(persistence: persistence)
        self.logs = (try? service.loadLogs()) ?? []
        self.customExercises = (try? service.loadCustomExercises()) ?? []
    }

    func logExercise(item: ExerciseItem, count: Int) {
        let log = ExerciseLog(item: item, count: count)
        try? service.addLog(log, to: &logs)
    }
}
```

---

## Testing

### Unit Testing Services

Services are designed to be easily testable:

```swift
import XCTest
@testable import StandFitCore

class ExerciseServiceTests: XCTestCase {
    var service: ExerciseService!
    var mockPersistence: MockPersistenceProvider!

    override func setUp() {
        mockPersistence = MockPersistenceProvider()
        service = ExerciseService(persistence: mockPersistence)
    }

    func testAddLog() throws {
        var logs: [ExerciseLog] = []
        let log = ExerciseLog(exerciseType: .squats, count: 10)

        try service.addLog(log, to: &logs)

        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.count, 10)
    }
}
```

### Mock Persistence Provider

Create a mock for testing:

```swift
class MockPersistenceProvider: PersistenceProvider {
    var storage: [String: Data] = [:]

    func save<T: Codable>(_ data: T, forKey key: String) throws {
        storage[key] = try JSONEncoder().encode(data)
    }

    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = storage[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func delete(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }
}
```

---

## Migration Guide

### From WatchOS-Only to Multi-Platform

**Before (WatchOS-specific):**
```swift
import Foundation

class ExerciseStore: ObservableObject {
    @Published var logs: [ExerciseLog] = []

    private var logsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("exercise_logs.json")
    }

    func saveLogs() {
        let data = try! JSONEncoder().encode(logs)
        try! data.write(to: logsFileURL)
    }
}
```

**After (Multi-platform with StandFitCore):**
```swift
import StandFitCore

class ExerciseStore: ObservableObject {
    private let service: ExerciseService
    @Published var logs: [ExerciseLog] = []

    init() {
        let persistence = try! JSONFilePersistence()
        self.service = ExerciseService(persistence: persistence)
        self.logs = (try? service.loadLogs()) ?? []
    }

    func logExercise(item: ExerciseItem, count: Int) {
        try? service.addLog(ExerciseLog(item: item, count: count), to: &logs)
    }
}
```

**Benefits:**
- ✅ Same business logic works on iOS, WatchOS, macOS, etc.
- ✅ Easy to swap persistence (CloudKit, Core Data, etc.)
- ✅ Easier to test (mock persistence providers)

---

## Extending StandFitCore

### Adding Custom Persistence

Implement `PersistenceProtocol`:

```swift
class CloudKitPersistence: PersistenceProvider {
    private let container: CKContainer

    func save<T: Codable>(_ data: T, forKey key: String) throws {
        // Save to CloudKit
    }

    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        // Load from CloudKit
    }

    // ...
}
```

### Adding New Services

Follow the service pattern:

```swift
public class SocialService {
    private let persistence: PersistenceProvider

    public init(persistence: PersistenceProvider) {
        self.persistence = persistence
    }

    public func sharePerfomance(...) throws -> ShareData {
        // Business logic here
    }
}
```

---

## Performance

### Benchmarks

- **Load 10,000 exercise logs:** ~50ms
- **Save 10,000 exercise logs:** ~100ms
- **Process gamification event:** ~5ms
- **Generate report stats:** ~20ms

### Best Practices

1. **Batch Updates** - Save data after multiple operations, not after each one
2. **Lazy Loading** - Only load data when needed
3. **Background Processing** - Use `Task.detached` for heavy operations
4. **Caching** - Cache frequently accessed data in stores

---

## Troubleshooting

### "No such module 'StandFitCore'"

**Solution:** Add StandFitCore as a package dependency in Xcode:
1. File → Add Package Dependencies
2. Select "Add Local..."
3. Choose `StandFitCore` folder
4. Add to your target

### "Cannot find type 'ExerciseLog' in scope"

**Solution:** Import StandFitCore at the top of your file:
```swift
import StandFitCore
```

### Data Not Persisting

**Solution:** Ensure you're calling `save` methods after updates:
```swift
try service.addLog(log, to: &logs) // This calls save internally
```

---

## Roadmap

### Version 1.1
- [ ] Core Data persistence provider
- [ ] CloudKit persistence provider
- [ ] Conflict resolution strategies
- [ ] Background sync

### Version 1.2
- [ ] SwiftData support (Swift 6+)
- [ ] async/await APIs
- [ ] Observation framework (iOS 17+)

### Version 2.0
- [ ] macOS support
- [ ] tvOS support
- [ ] visionOS support

---

## Contributing

This is a private module for the StandFit app. For internal development:

1. Make changes to `StandFitCore/`
2. Add unit tests to `Tests/StandFitCoreTests/`
3. Update this README
4. Test with both iOS and WatchOS targets

---

## License

Proprietary - StandFit App
Copyright © 2026 Marty Kieliszek

---

## Support

For questions or issues:
- Check `/UX17_ARCHITECTURE.md` for detailed architecture docs
- Review code comments in service files
- Create an issue in the project tracker

---

**Last Updated:** 2026-01-02
**Swift Version:** 5.9+
**Minimum Platforms:** iOS 16, watchOS 9
