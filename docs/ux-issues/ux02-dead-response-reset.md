# UX2: Missed Notifications / Dead Response Reset (Complete)

**Status:** ✅ Complete
**Completion Date:** 2026-01-01

## Problem

Uses non-repeating notification triggers. If a user dismisses or misses a notification, nothing reschedules it. They must manually tap "Reset Timer" or log an exercise.

## Solution Implemented

- Added `deadResponseEnabled` and `deadResponseMinutes` settings to ExerciseStore (default: enabled, 5 min)
- When a notification fires (`willPresent`), a follow-up notification is immediately scheduled
- If user responds (taps notification, logs exercise, or snoozes), the follow-up is cancelled
- If user doesn't respond, the follow-up fires after the configured timeout with message "Still there?"
- Follow-up uses same notification category so user can log/snooze from it too
- Configurable timeout options: 1, 2, 3, 5, 10, 15 minutes
- Setting integrated into ReminderScheduleView under "Missed Reminders" section

## Files Changed

- `ExerciseStore.swift` (added deadResponseEnabled, deadResponseMinutes settings)
- `NotificationManager.swift` (added scheduleFollowUpReminder, cancelFollowUpReminder methods)
- `StandFitApp.swift` (schedule follow-up on notification present, cancel on user action)
- `ReminderScheduleView.swift` (added UI for configuring dead response settings)
