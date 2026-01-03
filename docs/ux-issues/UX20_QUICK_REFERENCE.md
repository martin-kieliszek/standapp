# Quick Reference: Continuing UX20 Localization

This guide helps you quickly continue the internationalization work.

---

## Current Status

✅ **Completed** (7 views):
- ContentView.swift
- AchievementsView.swift  
- SettingsView.swift
- PaywallView.swift
- ExercisePickerView.swift
- CreateExerciseView.swift
- HistoryView.swift

⏳ **Remaining** (15 views):
Priority order listed in [UX20_IMPLEMENTATION_PROGRESS.md](./UX20_IMPLEMENTATION_PROGRESS.md)

---

## Quick Start: Converting a View

### 1. Open the view file
Example: `StandFit/Views/ExampleView.swift`

### 2. Find hardcoded strings
Search for: `Text("Some Hardcoded String")`

### 3. Replace with LocalizedString
```swift
// Before:
Text("Settings")
Text("Save Changes")
Text("\(count) items")

// After:
Text(LocalizedString.Settings.title)
Text(LocalizedString.General.save)
Text(LocalizedString.UI.itemCount(count))  // For parameterized strings
```

### 4. If string key doesn't exist, add it

**In `LocalizedString.swift`**:
```swift
public enum Settings {
    public static let title = NSLocalizedString("settings.title", comment: "Settings screen title")
}
```

### 5. Build the project
Xcode will automatically extract the strings to `Localizable.xcstrings`

---

## Common Patterns

### Simple Text
```swift
Text(LocalizedString.General.cancel)
Text(LocalizedString.Achievements.title)
```

### Parameterized Text
```swift
// With count
Text(LocalizedString.Stats.dayStreak(5))  // "5 day streak"

// With string
Text(LocalizedString.Schedule.nextReminder(timeString))  // "Next: 2:30 PM"
```

### Section Headers
```swift
Section {
    // content
} header: {
    Text(LocalizedString.Settings.reminders)
}
```

### Buttons
```swift
Button(LocalizedString.General.save) {
    // action
}
```

---

## Adding New String Categories

If you need a new category of strings:

### 1. Add enum to LocalizedString.swift

```swift
// MARK: - YourCategory

public enum YourCategory {
    public static let someKey = NSLocalizedString(
        "category.some_key", 
        comment: "Description of what this string is used for"
    )
    
    // For parameterized strings
    public static func parameterized(_ value: Int) -> String {
        String(format: NSLocalizedString(
            "category.parameterized", 
            comment: "String with %d parameter"
        ), value)
    }
}
```

### 2. Use in views

```swift
Text(LocalizedString.YourCategory.someKey)
Text(LocalizedString.YourCategory.parameterized(42))
```

---

## Naming Conventions

### Key Format
Use lowercase with dots: `category.subcategory.key_name`

**Examples**:
- `general.cancel`
- `settings.reminders`
- `premium.start_free_trial`
- `stats.day_streak`

### Comment Guidelines
Provide context for translators:
```swift
NSLocalizedString(
    "settings.enable_reminders",
    comment: "Footer text explaining how to enable reminders"
)
```

---

## Testing

### Test Language Switching in Xcode

1. **Edit Scheme**:
   ```
   Xcode → Product → Scheme → Edit Scheme
   → Run → Options → App Language
   → Select: Spanish, French, German, etc.
   ```

2. **Run app**: Cmd+R

3. **Verify**:
   - All text appears in selected language
   - UI doesn't break with longer strings (German)
   - Numbers format correctly (1,234 vs 1.234)

### Test on Simulator

1. Open Simulator
2. Settings → General → Language & Region
3. Add Spanish (or other language)
4. Relaunch StandFit
5. Verify translations

---

## Common Issues

### "Cannot find 'LocalizedString' in scope"
**Fix**: Add import at top of file:
```swift
import StandFitCore
```

### String not translating
**Check**:
1. Did you use `NSLocalizedString()` in LocalizedString.swift?
2. Did you build the project after adding the string?
3. Is the key in Localizable.xcstrings?

### Layout breaks with long strings
**Fix**: Use flexible layouts:
```swift
Text("Long German String")
    .lineLimit(2)  // Allow text to wrap
    .minimumScaleFactor(0.8)  // Shrink if needed
```

---

## Next View to Convert

**Recommended**: `DayScheduleEditorView.swift`
- Most strings to convert
- Core user feature
- Good practice for complex views

**Location**: `StandFit/Views/DayScheduleEditorView.swift`

**Estimated Time**: 45-60 minutes

---

## Resources

- [Full Implementation Progress](./UX20_IMPLEMENTATION_PROGRESS.md)
- [UX20 Specification](./UX20_INTERNATIONAL_LANGUAGES.md)
- [Apple Localization Guide](https://developer.apple.com/localization/)

---

## Quick Commands

```bash
# Find remaining hardcoded strings in a view
grep -n 'Text("' StandFit/Views/YourView.swift

# Count remaining hardcoded strings
grep -c 'Text("' StandFit/Views/*.swift

# Search for specific string in codebase
grep -r "Settings" StandFit/
```

---

**Last Updated**: 2026-01-03
