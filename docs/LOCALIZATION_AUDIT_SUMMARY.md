# View Localization Audit - Summary & Next Steps

## Audit Progress

### Files Completed (7 of 25)
✅ StatsHeaderView.swift
✅ HistoryView.swift  
✅ CreateExerciseView.swift
✅ SettingsView.swift
✅ AchievementsView.swift
✅ ProgressReportView.swift
✅ ExercisePickerView.swift

### Strings Added to .xcstrings Files

#### ✅ Stats.xcstrings
- Added `stats.vs_previous_period` - "vs previous period"

#### ✅ Errors.xcstrings
- Added `error.unknown_exercise` - "Unknown Exercise"

#### ✅ CreateExercise.xcstrings
Added 18 new keys:
- `create_exercise.measured_in` - "Measured In"
- `create_exercise.default_help` - "This is the starting value when logging"
- `create_exercise.exercise_name_placeholder` - "Exercise Name"
- `create_exercise.update_exercise` - "Update Exercise"
- `create_exercise.create_exercise` - "Create Exercise"
- `create_exercise.delete_button` - "Delete Exercise"
- `create_exercise.delete_confirmation_title` - "Delete Exercise?"
- `create_exercise.delete_warning` - "This will remove the exercise. Your logged data will be kept."
- `create_exercise.delete` - "Delete"
- `create_exercise.template_prompt_title` - "Create Achievement Template?"
- `create_exercise.not_now` - "Not Now"
- `create_exercise.learn_more` - "Learn More"
- `create_exercise.template_prompt_message` - Long template message
- `create_exercise.unit_desc_reps` - "Count repetitions (e.g., 10 pushups)"
- `create_exercise.unit_desc_seconds` - "Count seconds (e.g., 30 second plank)"
- `create_exercise.unit_desc_minutes` - "Count minutes (e.g., 15 minute walk)"
- `create_exercise.built_in` - "Built-in"
- `create_exercise.custom` - "Custom"
- `create_exercise.add_exercise` - "Add Exercise"
- `create_exercise.custom_footer` - "Tap + to create your own exercises"
- `create_exercise.exercises_title` - "Exercises"
- `create_exercise.new_exercise` - "New Exercise"

## Remaining Work

### Critical Strings Still Needing Localization

#### StatsHeaderView.swift
- **Pluralization Issue**: `"rep\(stats.totalCount == 1 ? "" : "s")"`
  - **Solution**: Needs proper .stringsdict pluralization or refactor to use Units.reps
  - **Action**: Modify to use `LocalizedString.Units.reps` (already exists)

#### SettingsView.swift
- `"Test Haptic"` → Add to Settings.xcstrings as `settings.test_haptic`
- `"Haptic Feedback"` → Add to Settings.xcstrings as `settings.haptic_feedback`
- `"Clear All Data"` → Add to Settings.xcstrings as `settings.clear_all_data`
- `"Data"` → Add to Settings.xcstrings as `settings.data`
- `"This will delete all exercise logs."` → Add as `settings.clear_data_warning`
- `"Version"` → Add to UI.xcstrings as `ui.version` (already exists)
- `"1.0.0"` → Should be dynamic, not hardcoded
- `"About"` → Add to UI.xcstrings as `ui.about` (already exists)
- `"Settings"` → Use LocalizedString.Settings.title (already exists)
- `"Done"` → Use LocalizedString.General.done (already exists)
- `"Every"`, `" min"`, `"1 hour"`, `" hours"`, etc. → Need time formatting localization
- `"\(store.customExercises.count) custom"` → Need formatted string with count
- `"On"` → Add to UI.xcstrings as `ui.on`

#### AchievementsView.swift
- `"All"` → Add to UI.xcstrings as `ui.all`
- `"Achievement Unlocked!"` → Add to Achievements.xcstrings as `achievements.unlocked_toast`

#### ProgressReportView.swift
- `"Period"` → Add to Progress.xcstrings as `progress.period`
- `"Today"`, `"Week"`, `"Month"` → Use existing or add to Progress.xcstrings
- `"Week 🔒"`, `"Month 🔒"` → Add formatted locked versions
- `"Progress"` → Use LocalizedString.Progress.title (already exists)
- `"Done"` → Use LocalizedString.General.done (already exists)
- `"No activity logged"` → Add to Progress.xcstrings as `progress.no_activity`
- Empty state messages → Add period-specific messages

#### ExercisePickerView.swift
- `"Custom Exercises"` → Use LocalizedString.UI.customExercises (already exists)
- `"No exercises found"` → Add to Picker.xcstrings as `picker.no_results`
- `"Try adjusting your search"` → Add to Picker.xcstrings as `picker.adjust_search`
- `"What did you do?"` → Add to Picker.xcstrings as `picker.prompt_title`
- `"Select an exercise to log your activity"` → Add as `picker.prompt_subtitle`
- `"Select Exercise"` → Add as `picker.select_exercise`

### Files Still To Audit (18 remaining)
1. DayActivityHeatmapView.swift
2. TimelineGraphView.swift
3. ReminderScheduleView.swift
4. ProgressReportSettingsView.swift
5. PaywallView.swift
6. SubscriptionSettingsView.swift
7. IconPickerView.swift
8. CreateAchievementTemplateView.swift
9. ExerciseLoggerView.swift
10. TimelineVisualizationView.swift
11. ScheduleProfilePickerView.swift
12. ProfileBadgeView.swift
13. TimeBlockEditorSheet.swift
14. ContentView.swift (partially reviewed)
15. DayScheduleEditorView.swift
16. ManageTemplatesView.swift
17. ProgressChartsView.swift
18. ExerciseBreakdownView.swift (if exists)
... plus any others

## Next Steps

### Immediate Actions
1. ✅ Add missing strings to Settings.xcstrings (~10 keys)
2. ✅ Add missing strings to Progress.xcstrings (~8 keys)
3. ✅ Add missing strings to Picker.xcstrings (~5 keys)
4. ✅ Add missing strings to Achievements.xcstrings (~2 keys)
5. ✅ Add missing strings to UI.xcstrings (~3 keys)

### After Adding Strings
1. Update LocalizedString.swift with new properties for all added keys
2. Refactor the 7 audited view files to use LocalizedString references
3. Continue audit of remaining 18 view files
4. Repeat process: audit → add strings → update LocalizedString.swift → refactor

### Special Cases to Address

#### Pluralization
The `"rep\(stats.totalCount == 1 ? "" : "s")"` pattern needs proper pluralization:
- Option 1: Use .stringsdict file for proper plural rules
- Option 2: Refactor to use existing `LocalizedString.Units.reps` with count parameter
- **Recommendation**: Use Units.reps with count-aware formatting

#### Dynamic Formatting
Time intervals like `"Every \(interval)"`, `"1 hour"`, `"\(hours)h \(minutes)m"` need:
- Locale-aware time formatting
- Consider using DateComponentsFormatter
- Or add specific localization keys for each pattern

#### Version Number
`"1.0.0"` should be:
- Read from Bundle.main.infoDictionary
- Use `CFBundleShortVersionString` key
- No localization needed (version numbers are universal)

## Summary Statistics

- **Hardcoded Strings Found**: ~80+ across 7 files
- **Strings Added to .xcstrings**: 21 keys (3 files)
- **Strings Still Needing Addition**: ~60+ keys
- **Files Audited**: 7 of 25 (28%)
- **Estimated Remaining Hardcoded Strings**: 150-200 total

## Priority Order

### High Priority (Visible to users frequently)
1. Settings.xcstrings additions
2. Progress.xcstrings additions
3. Picker.xcstrings additions
4. ContentView.swift audit (main screen)

### Medium Priority
1. Remaining view files audit
2. LocalizedString.swift updates
3. View file refactoring

### Low Priority (Edge cases)
1. Pluralization edge cases
2. Dynamic formatting improvements
3. Error message coverage

## Status: IN PROGRESS
**Last Updated**: [Timestamp]
**Next Action**: Add remaining strings to Settings, Progress, Picker, Achievements, UI .xcstrings files

