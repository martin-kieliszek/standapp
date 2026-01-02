# UX13: Progress Report Crash (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-02

## Problem

App crashed when selecting Week or Month period in Progress Report view. The issue was that `weekPeriod` and `monthPeriod` were computed properties that recalculated on every access, creating new Date instances. Since `ReportPeriod` is `Hashable`, the hash changed on each access, breaking the picker's binding stability.

## Root Cause

- Computed properties `weekPeriod` and `monthPeriod` calculated fresh dates each time
- `ReportPeriod` cases with associated Date values (`weekStarting`, `monthStarting`) would hash differently
- Picker binding depends on stable hashes to track selection state
- Crash occurred when picker tried to match the selected period
- The infinite loop in `calculateStreak()` would occur when there were no logs to find, causing a stack overflow

## Solution Implemented

- Added `@State` properties `cachedWeekPeriod` and `cachedMonthPeriod` to store computed periods
- Cache invalidates on `.onAppear` to refresh period boundaries across day/week/month changes
- Replaced forced unwraps with `guard let` for safe date calculations
- **Key fix: Added early-exit guards in `getStats()` when logs are empty** - prevents infinite loop in streak calculation
- Added iteration limit (1000) to `calculateStreak()` as secondary safety measure
- Cached periods ensure stable `Hashable` identity for picker binding

## Files Changed

- `ProgressReportView.swift` - Added period caching mechanism, cache invalidation
- `ExerciseStore.swift` - Added early-exit guards and iteration limit
