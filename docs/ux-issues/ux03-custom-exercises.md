# UX3: Custom Exercises (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-01

## Problem

All 4 exercise types are hardcoded in an enum. Users cannot add their own exercises or select from available SF Symbols.

## Solution Implemented

### New Types & Models

Added to `Models.swift`:
- `ExerciseUnitType` enum (`.reps` or `.seconds`) - defines how exercise is measured
- `CustomExercise` struct - user-defined exercise with name, icon, unit type, default count
- `ExerciseItem` struct - unified representation for both built-in and custom exercises
- Updated `ExerciseLog` to support both built-in and custom exercises via optional fields

### Storage & Management

Updated `ExerciseStore.swift`:
- Added `customExercises: [CustomExercise]` published property
- Added `custom_exercises.json` file-based persistence
- Added `allExercises` computed property returning unified `[ExerciseItem]`
- Added CRUD methods: `addCustomExercise`, `updateCustomExercise`, `deleteCustomExercise`, `moveCustomExercise`
- Added `logExercise(item:count:)` for unified logging
- Updated statistics to handle both built-in and custom exercise summaries

### Icon Picker (Swipeable)

New file `IconPickerView.swift`:
- `IconPickerView` - Full-screen swipeable icon picker using TabView with page style
- 70+ curated exercise-appropriate SF Symbols organized in pages of 6
- `IconGridPage` - Single page showing 3x2 grid of icons
- `IconButton` - Individual icon button with selection state
- `IconPickerButton` - Inline button that opens full picker when tapped

### Exercise Creation/Editing

New file `CreateExerciseView.swift`:
- `CreateExerciseView` - Form for creating/editing custom exercises
  - Name text field
  - Icon picker button (opens swipeable picker)
  - Unit type picker (Reps vs Seconds)
  - Default count stepper with appropriate step amounts (1 for reps, 5 for seconds)
  - Live preview showing how exercise will appear
  - Delete option when editing
- `CustomExerciseListView` - List management view showing all exercises
  - Built-in exercises section (read-only)
  - Custom exercises section (editable, reorderable)
  - Add new exercise button

### Updated Components

`ExercisePickerView.swift`:
- Now accepts `ExerciseItem` instead of `ExerciseType`
- Shows all exercises (built-in + custom) from `store.allExercises`
- Custom exercises show with blue tint, built-in with green

`ExerciseLoggerView.swift`:
- Updated to use `ExerciseItem` for unified exercise handling
- Uses `exerciseItem.unitType` for proper unit display (reps/seconds)
- Appropriate step amounts: +1/-1 for reps, +5/-5 for seconds
- Quick increment buttons: +5/+10 for reps, +15/+30 for seconds
- **Changed "Cancel" to "Done"** per user request
- Backwards compatibility initializer for ExerciseType

`ContentView.swift`:
- Changed `selectedExercise: ExerciseType?` to `selectedExerciseItem: ExerciseItem?`
- Updated all related sheet presentations
- Today's stats shows both built-in and custom exercise summaries

`SettingsView.swift`:
- Added "Exercises" section linking to `CustomExerciseListView`
- Shows count of custom exercises

### User Flow

**Creating a custom exercise:**
1. Settings → Exercises
2. Tap "Add Exercise" under Custom section
3. Enter name (e.g., "Burpees")
4. Tap icon button → swipe through pages to select icon
5. Choose unit type (Reps or Seconds)
6. Adjust default count with +/- buttons
7. Preview shows how it will appear
8. Tap "Save Exercise"

**Using custom exercises:**
- Custom exercises appear in the Quick Log grid alongside built-in ones
- Custom exercises are blue, built-in are green
- Logging works identically - same count picker, same save flow
- Today's stats shows both types

**Editing/deleting:**
1. Settings → Exercises
2. Tap any custom exercise
3. Make changes or tap "Delete Exercise"

## Files Changed

- `Models.swift` - New types: ExerciseUnitType, CustomExercise, ExerciseItem; updated ExerciseLog
- `ExerciseStore.swift` - Custom exercise storage, CRUD, unified exercise list
- `IconPickerView.swift` (new) - Swipeable SF Symbol picker
- `CreateExerciseView.swift` (new) - Exercise creation/editing, list management
- `ExercisePickerView.swift` - Updated to use ExerciseItem
- `ExerciseLoggerView.swift` - Updated to use ExerciseItem, Cancel→Done
- `ContentView.swift` - ExerciseItem integration, custom summaries
- `SettingsView.swift` - Added Exercises section
