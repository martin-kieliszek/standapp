# Hardcoded Strings Audit - UX20 Localization

## Purpose
Systematic audit of all View files to identify hardcoded Text strings that bypass the localization system.

## Files Audited

### ✅ StatsHeaderView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/StatsHeaderView.swift`

**Hardcoded Strings Found**:
1. Line 21: `"rep\(stats.totalCount == 1 ? "" : "s")"` - Pluralization logic
   - **Action**: Need proper pluralization support
   - **Target**: Units.xcstrings - add `units.reps_count` with stringsdict
   
2. Line 37: `"vs previous period"` - Comparison label  
   - **Action**: Add to Stats.xcstrings
   - **Key**: `stats.vs_previous_period`
   
3. Line 50: `"\(streak)-day streak"` - Streak display
   - **Action**: Add to Stats.xcstrings with formatting
   - **Key**: `stats.day_streak` (already exists, need to use it)

### ✅ HistoryView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/HistoryView.swift`

**Hardcoded Strings Found**:
1. Line 192: `"Unknown Exercise"` - Fallback exercise name
   - **Action**: Add to Errors.xcstrings
   - **Key**: `error.unknown_exercise`

### ✅ CreateExerciseView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/CreateExerciseView.swift`

**Hardcoded Strings Found**:
1. Line 94: `"Measured In"` - Picker label (accessibility)
2. Line 137: `"Default Count"` - Section header
3. Line 169: `"This is the starting value when logging"` - Help text
4. Line 172: `"Preview"` - Section header
5. Line 181: `"Exercise Name"` - Placeholder text
6. Line 193: `"\(isEditing ? "Update" : "Create") Exercise"` - Button label
7. Line 201: `"Delete Exercise"` - Button label
8. Line 211: `"Edit Exercise" : "New Exercise"` - Navigation title
9. Line 214, 223: `"Cancel"` - Button labels (multiple instances)
10. Line 218: `"Delete Exercise?"` - Confirmation dialog title
11. Line 222: `"Delete"` - Confirmation button
12. Line 225: `"This will remove the exercise. Your logged data will be kept."` - Warning message
13. Line 229: `"Create Achievement Template?"` - Alert title
14. Line 231: `"Not Now"` - Alert button
15. Line 234: `"Learn More"` - Alert button
16. Line 240: `"Premium users can create achievement templates..."` - Long message
17. Lines 247-251: Unit type descriptions (3 strings)
18. Line 323: `"Cancel"` - Another cancel button
19. Line 333: `"Built-in"` - Section header
20. Line 351, 400: `"Custom"` - Section headers
21. Line 356: `"\(store.customExercises.count) custom"` - Count display
22. Line 394: `"Add Exercise"` - Button label
23. Line 403: `"Tap + to create your own exercises"` - Footer text

### ✅ SettingsView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/SettingsView.swift`

**Hardcoded Strings Found**:
1. Line 87: `"\(store.customExercises.count) custom"` - Count display
2. Line 107: `"On"` - Status indicator
3. Line 125: `"Test Haptic"` - Button label
4. Line 128: `"Haptic Feedback"` - Section header
5. Line 136: `"Clear All Data"` - Button label
6. Line 141: `"Data"` - Section header
7. Line 143: `"This will delete all exercise logs."` - Footer text
8. Line 149: `"Version"` - Label
9. Line 152: `"1.0.0"` - Version number (consider dynamic)
10. Line 155: `"About"` - Section header
11. Line 159: `"Settings"` - Navigation title
12. Line 163: `"Done"` - Button label
13. Lines 172-184: Time interval formatting (`" min"`, `"1 hour"`, `" hours"`, `"h "`, `"m"`, `"Every"`)
14. Lines 193-197: Date formatting patterns (`"'Today' h:mm a"`, `"'Tomorrow' h:mm a"`, `"EEE h:mm a"`)

### ✅ AchievementsView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/AchievementsView.swift`

**Hardcoded Strings Found**:
1. Line 145: `"All"` - Category filter label
2. Line 312: `"Achievement Unlocked!"` - Toast text

### ✅ ProgressReportView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/ProgressReportView.swift`

**Hardcoded Strings Found**:
1. Line 71: `"Period"` - Picker label (accessibility)
2. Line 72: `"Today"` - Period option
3. Line 74: `"Week"` - Period option
4. Line 75: `"Month"` - Period option
5. Line 77: `"Week 🔒"` - Locked period option
6. Line 78: `"Month 🔒"` - Locked period option
7. Line 130: `"Progress"` - Navigation title
8. Line 136: `"Done"` - Button label
9. Line 169: `"No activity logged"` - Empty state title
10. Lines 177-181: Empty state messages for different periods
11. Line 145: Date range formatting (`"MMM d"`, `" – "`)

### ✅ ExercisePickerView.swift
**Location**: `/Users/marty/xcode/ios/StandFit/StandFit/Views/ExercisePickerView.swift`

**Hardcoded Strings Found**:
1. Line 161: `"Custom Exercises"` - Section header
2. Line 201: `"No exercises found"` - Empty state title
3. Line 204: `"Try adjusting your search"` - Empty state message
4. Line 290: `"What did you do?"` - Prompt title
5. Line 294: `"Select an exercise to log your activity"` - Prompt subtitle
6. Line 302: `"Select Exercise"` - Section header

## Summary Statistics
- **Files Audited**: 7 of 25
- **Hardcoded Strings Found**: ~80+
- **Primary Categories**:
  - UI labels and section headers (~30%)
  - Button labels (~20%)
  - Help text and descriptions (~20%)
  - Empty state messages (~10%)
  - Pluralization and formatting (~10%)
  - Confirmation dialogs (~10%)

## Action Plan

### Phase 1: Add Missing Keys to .xcstrings Files
1. **Stats.xcstrings** - Add `vs_previous_period`
2. **Units.xcstrings** - Add `reps_count` with pluralization
3. **Errors.xcstrings** - Add `unknown_exercise`
4. **CreateExercise.xcstrings** - Add ~20 missing keys
5. **Settings.xcstrings** - Add ~10 missing keys
6. **UI.xcstrings** - Add common labels
7. **Progress.xcstrings** - Add period labels and messages
8. **Picker.xcstrings** - Add picker-specific strings

### Phase 2: Update LocalizedString.swift
Add computed properties and static variables for all new keys

### Phase 3: Refactor View Files
Replace hardcoded strings with LocalizedString references

### Phase 4: Continue Audit
Need to check remaining ~18 view files

## Status: IN PROGRESS
- Current: Documenting findings from first 7 files
- Next: Add missing keys to .xcstrings files
- Then: Refactor views to use localized strings
- Finally: Complete audit of remaining files

