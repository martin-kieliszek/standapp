# Localization Process

## Quick Reference for Adding Localized Strings

### 1. Identify Strings to Localize
Look for hardcoded strings in Swift files:
- `Text("...")`
- `Label("...", ...)`
- `Section(header: Text("..."))`
- `.navigationTitle("...")`
- String literals in UI components

### 2. Choose/Create Appropriate .xcstrings File
Location: `StandFit/Resources/Localizations/`

**Strategy:** Group by translation context (features), not code structure (files)

Common files by feature:
- `Common.xcstrings` - Shared UI: save, cancel, done, delete, add, edit, yes, no, ok
- `Stats.xcstrings` - Statistics, activity, timeline (~1500 lines)
- `Schedule.xcstrings` - Scheduling, time blocks, reminders (~4500 lines - consider splitting)
- `Premium.xcstrings` - Paywall, subscription, premium features (~800 lines)
- `Progress.xcstrings` - Charts, progress tracking (~600 lines)
- `Settings.xcstrings` - App settings
- `Templates.xcstrings` - Achievement templates
- `ExerciseLogger.xcstrings` - Exercise logging

**File Size Guidelines:**
- Optimal: 500-2000 lines per file (fast LLM processing, clear feature boundaries)
- Split if: File exceeds 2500 lines (split by sub-features)
- Avoid: One .xcstrings per Swift file (causes massive duplication)

### 3. Add Translation Entry to .xcstrings
Before closing `}` and `"version" : "1.0"`:

```json
"feature.key_name" : {
  "comment" : "English description",
  "extractionState" : "manual",
  "localizations" : {
    "de" : { "stringUnit" : { "state" : "translated", "value" : "German" } },
    "en" : { "stringUnit" : { "state" : "translated", "value" : "English" } },
    "es" : { "stringUnit" : { "state" : "translated", "value" : "Spanish" } },
    "fr" : { "stringUnit" : { "state" : "translated", "value" : "French" } },
    "ja" : { "stringUnit" : { "state" : "translated", "value" : "Japanese" } },
    "pt-BR" : { "stringUnit" : { "state" : "translated", "value" : "Portuguese" } },
    "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "Chinese" } }
  }
}
```

**Format strings:** Use `%@` for strings, `%d` for integers, `%lld` for Int64
**Day abbreviations:** Create individual keys (e.g., `schedule.day_mon`, `schedule.day_tue`) for proper i18n

### 4. Update LocalizedString.swift
Location: `StandFitCore/Sources/StandFitCore/Localization/LocalizedString.swift`

Add to appropriate enum (e.g., `Stats`, `Schedule`, `Premium`):

```swift
public enum FeatureName {
    private static let table = "FeatureName"  // matches .xcstrings filename
    
    // Static strings
    public static let keyName = NSLocalizedString("feature.key_name", tableName: table, comment: "Description")
    
    // Format strings - create helper functions
    public static func formatExample(_ value: Int) -> String {
        String(format: NSLocalizedString("feature.format_key", tableName: table, comment: "%d example"), value)
    }
}
```

### 5. Update Swift File to Use LocalizedString
Replace:
```swift
Text("Hello")
```

With:
```swift
Text(LocalizedString.FeatureName.keyName)
```

For format strings:
```swift
Text(LocalizedString.FeatureName.formatExample(42))
```

## Important Notes

- **iOS Only:** Do NOT add localizations to Watch App files (per project requirements)
- **Seven Languages:** All strings must have translations in: en, de, es, fr, ja, pt-BR, zh-Hans
- **Naming Convention:** Use `feature.snake_case` for keys (e.g., `stats.timeline`, `schedule.time_block`)
- **Day/Time Formatting:** Use individual localized strings for days of week, not DateFormatter
- **Testing:** Format strings must preserve placeholders (`%@`, `%d`) in all translations
- **Consistency:** Keep related strings in the same .xcstrings file
- **LLM Optimization:** For large files (>2000 lines), read only the end before inserting:
  ```bash
  wc -l file.xcstrings              # Get total line count
  read_file lines N-50 to N         # Read last 50 lines to find insertion point
  ```

## Scaling Strategy

**When to Create New .xcstrings File:**
- New major feature area (e.g., a new tab or major workflow)
- Existing file exceeds 2500 lines (split by sub-features)
- Shared UI strings → add to `Common.xcstrings`

**When to Use Existing File:**
- String relates to existing feature (even if new Swift file)
- Maintains translation consistency
- Avoids duplication

**Translation Context > Code Structure:** A translator working on "scheduling" needs all schedule strings together, regardless of which Swift file displays them.

## Common Patterns

### Toggle Labels
```swift
Toggle(LocalizedString.Settings.enableFeature, isOn: $enabled)
```

### Section Headers/Footers
```swift
Section {
    // content
} header: {
    Text(LocalizedString.Feature.headerText)
} footer: {
    Text(LocalizedString.Feature.footerText)
}
```

### Navigation Titles
```swift
.navigationTitle(LocalizedString.Feature.title)
```

### Button Text
```swift
Button(LocalizedString.Common.save) { ... }
Button(LocalizedString.Common.cancel) { ... }
```
