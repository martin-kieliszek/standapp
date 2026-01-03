# UX31: Exercise Notes/Comments

**Status**: ⏳ Pending  
**Created**: 2026-01-04  
**Category**: Feature Enhancement  
**Priority**: Low-Medium  
**Complexity**: Low (1-2 hours)

## Problem

No way to add context to exercise logs:
- Can't note "Felt great today!"
- Can't record "Used 20lb weights"
- Can't track "Right knee hurt"
- No qualitative data alongside quantitative

**User Impact**: Fitness tracking is purely numerical, missing valuable context for reflection and progress analysis.

## Solution

Add optional `note: String?` field to `ExerciseLog`:
- Text field during exercise logging
- Display notes in history view
- Search/filter by notes
- Export notes with data

## Implementation

### Update ExerciseLog Model

```swift
public struct ExerciseLog: Codable, Identifiable {
    public let id: UUID
    public let exerciseType: ExerciseType?
    public let customExerciseId: UUID?
    public let count: Int
    public let timestamp: Date
    public var note: String?  // NEW
}
```

### Add Note Field to Logger

```swift
struct ExerciseLoggerView: View {
    @State private var count: Int
    @State private var note: String = ""  // NEW
    @State private var showNoteField = false
    
    var body: some View {
        // ... existing UI ...
        
        // Add note section
        Section {
            if showNoteField {
                TextField("Add note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                showNoteField.toggle()
            } label: {
                Label(showNoteField ? "Hide Note" : "Add Note", 
                      systemImage: "note.text")
            }
        }
    }
    
    private func saveExercise() {
        var log = ExerciseLog(item: exerciseItem, count: storageCount)
        log.note = note.isEmpty ? nil : note
        store.logExercise(log)
    }
}
```

### Display Notes in History

```swift
struct HistoryRowView: View {
    let log: ExerciseLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Exercise name and count
            HStack {
                Text(exerciseName)
                Spacer()
                Text("\\(log.count) \\(unitLabel)")
            }
            
            // Note (if exists)
            if let note = log.note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            
            // Timestamp
            Text(formattedDate)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
```

## Use Cases

**Strength Training**: "Used 25lb dumbbells, felt easier than last week"  
**Injury Tracking**: "Left shoulder still sore, reduced reps"  
**Mood**: "Felt energized! Best workout this week"  
**Environmental**: "Gym was crowded, harder to focus"  
**PR Celebration**: "New personal record! 🎉"

## Benefits

- Richer data for progress analysis
- Personal reflection and journaling
- Track form improvements, equipment changes
- Remember workout context months later
- Share detailed progress with trainer/doctor

## Related Issues

- **UX22**: Data Export - Include notes in exports
- **UX33**: Progress Photos - Combine photos with notes
- **UX8**: Progress Reports - Show notable entries

## Conclusion

Simple **1-2 hour feature** that adds significant value for engaged users. Low implementation cost, high user satisfaction for those who use it.
