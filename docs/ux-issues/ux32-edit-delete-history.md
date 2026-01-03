# UX32: Edit/Delete Exercise History

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Core Functionality  
**Priority**: Medium  
**Complexity**: Low (2 hours)

## Problem

Users cannot edit or delete logged exercises:
- Logged wrong count (30 instead of 20)
- Duplicate entries from notification + app logging
- Accidental logs
- Cannot fix mistakes

**User Impact**: Permanent, uncorrectable data errors frustrate users and reduce trust in accuracy.

## Solution

Add edit and delete capabilities to exercise history:
1. **Delete**: Swipe-to-delete in history view
2. **Edit**: Tap log → edit count and timestamp
3. **Undo**: Optional undo for deletions

## Implementation

### Delete Functionality

```swift
struct HistoryView: View {
    @ObservedObject var store: ExerciseStore
    
    var body: some View {
        List {
            ForEach(store.logs) { log in
                HistoryRowView(log: log)
            }
            .onDelete(perform: deleteLogs)
        }
    }
    
    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = store.logs[index]
            store.deleteLog(log)
        }
    }
}

// In ExerciseStore
func deleteLog(_ log: ExerciseLog) {
    try? exerciseService.deleteLog(log, from: &logs)
    
    // Recalculate gamification (streaks, XP)
    GamificationStore.shared.recalculateStats(from: logs)
}
```

### Edit Functionality

```swift
struct EditExerciseLogView: View {
    @ObservedObject var store: ExerciseStore
    let log: ExerciseLog
    @Environment(\.dismiss) private var dismiss
    
    @State private var count: Int
    @State private var timestamp: Date
    
    init(store: ExerciseStore, log: ExerciseLog) {
        self.store = store
        self.log = log
        _count = State(initialValue: log.count)
        _timestamp = State(initialValue: log.timestamp)
    }
    
    var body: some View {
        Form {
            Section("Exercise") {
                Text(exerciseName)
                    .foregroundStyle(.secondary)
            }
            
            Section("Count") {
                Stepper("\\(count) \\(unitLabel)", value: $count, in: 1...1000)
            }
            
            Section("Date & Time") {
                DatePicker("Logged at", selection: $timestamp)
            }
            
            Button("Save Changes") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Edit Log")
    }
    
    private func saveChanges() {
        var updatedLog = log
        updatedLog.count = count
        updatedLog.timestamp = timestamp
        
        store.updateLog(updatedLog)
        dismiss()
    }
}
```

### Gamification Recalculation

When logs are edited/deleted, recalculate stats:

```swift
// In GamificationStore
func recalculateStats(from logs: [ExerciseLog]) {
    // Recalculate streak
    currentStreak = calculateStreak(from: logs)
    
    // Recalculate XP
    totalXP = logs.reduce(0) { total, log in
        total + calculateXP(for: log)
    }
    
    // Recalculate level
    currentLevel = LevelSystem.level(for: totalXP)
    
    // Recheck achievements
    recheckAllAchievements(logs: logs)
}
```

## User Experience

### History View with Edit

```
┌──────────────────────────────┐
│ Today                        │
│ ┌──────────────────────────┐ │
│ │ Squats           20 reps │ │ → Tap to edit
│ │ 2:30 PM                  │ │
│ └──────────────────────────┘ │
│                              │
│ ← Swipe to delete            │
└──────────────────────────────┘
```

### Edit Modal

```
┌──────────────────────────────┐
│ Edit Log                  ✕  │
├──────────────────────────────┤
│ Exercise                     │
│ Squats                       │
│                              │
│ Count                        │
│ 20 reps         [- ][+]     │
│                              │
│ Date & Time                  │
│ Jan 4, 2026  2:30 PM        │
│                              │
│     [Save Changes]           │
└──────────────────────────────┘
```

## Edge Cases

**Deleting Log That Broke Streak**:
- Recalculate streak without that log
- May restore previous streak

**Editing Timestamp to Different Day**:
- May affect daily stats
- May affect streaks
- Recalculate all time-dependent metrics

**Deleting Achievement-Earning Log**:
- Option 1: Keep achievement (earned is earned)
- Option 2: Revoke achievement (strict accuracy)
- Recommendation: Keep achievements

## Undo Support

```swift
struct HistoryView: View {
    @State private var deletedLog: ExerciseLog?
    
    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            deletedLog = store.logs[index]
            store.deleteLog(store.logs[index])
        }
        
        showUndoSnackbar()
    }
    
    private func undoDelete() {
        if let log = deletedLog {
            store.restoreLog(log)
            deletedLog = nil
        }
    }
}
```

## Technical Requirements

- Update ExerciseService with update/delete methods
- Recalculation logic for stats
- UI for editing (modal or navigation)
- Confirmation dialogs for destructive actions

## Related Issues

- **UX10**: Gamification - Recalculate XP/streaks
- **UX22**: Data Export - Export should reflect edits
- **UX31**: Notes - Edit notes too

## Conclusion

**Essential feature** missing from current app. Users will make mistakes and need to correct them. **2-hour implementation** that prevents significant user frustration.
