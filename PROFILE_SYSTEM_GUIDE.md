# Schedule Profile System - Quick Reference

## Overview

The advanced scheduling profile system has been successfully implemented for the iOS app. This brings powerful, flexible scheduling capabilities that allow users to customize their reminder schedule with granular control.

## Core Components

### Data Models (StandFitCore)

1. **ScheduleProfile** - A complete schedule with per-day settings
2. **DailySchedule** - Schedule configuration for one day
3. **TimeBlock** - A time range with specific interval settings
4. **FixedReminder** - A reminder at a specific time
5. **ScheduleTemplate** - Pre-defined schedule templates

### UI Components (StandFit)

1. **ScheduleProfilePickerView** - Switch between profiles and create new ones
2. **DayScheduleEditorView** - Edit schedule for each day of the week
3. **TimeBlockEditorSheet** - Create/edit time blocks with all options
4. **ProfileBadgeView** - Display active profile information

### Templates

Seven built-in templates are available:

- **Office Worker** - Mon-Fri work hours with breaks
- **Remote Worker** - Flexible schedule with weekend support
- **Training Mode** - Intensive every-day schedule
- **Recovery Mode** - Gentle reminders for rest
- **Weekend Warrior** - Active weekends only
- **Minimalist** - Just 3 fixed reminders per day
- **Every Day** - Consistent daily routine

## Key Features

### 1. Per-Day Customization
- Different schedules for each day of the week
- Monday work hours ≠ Saturday hours
- Enable/disable specific days

### 2. Time Blocks
- Define multiple time blocks per day
- Each block has its own interval
- Example: 20min during work, 60min in evening
- Optional randomization to prevent habituation

### 3. Multiple Profiles
- Create unlimited profiles
- Switch between them instantly
- Examples: "Training Week", "Recovery", "Vacation"

### 4. Flexible Schedule Types
Per day, choose from:
- **Time Blocks** - Interval-based within ranges
- **Fixed Times** - Specific times (9am, 1pm, 6pm)
- **Use Fallback** - Simple interval all day

### 5. Advanced Options
- Interval randomization (±5 minutes)
- Notification styles (Standard, Gentle, Urgent)
- Icons for time blocks
- Named blocks (e.g., "Morning Focus")

## How to Use

### For Users

1. **Open Settings** → Tap "Reminder Schedule"
2. **View Active Profile** at the top
3. **Switch Profile** - Tap to choose different profile
4. **Customize** - Tap to edit days and time blocks
5. **Create New** - Use templates or start from scratch

### Quick Actions in Day Editor

- Copy weekdays to weekends
- Set all days to Monday's schedule
- Clear all schedules

### Backward Compatibility

The system automatically migrates legacy settings:
- Old interval → Profile fallback interval
- Old active days → Daily schedules with time blocks
- Old hours → Time block start/end

Legacy properties still work - they now read/write to the active profile.

## Technical Details

### Migration

On first launch after update:
1. Creates "Default" profile from existing settings
2. Converts active days to daily schedules
3. Creates single time block per day with old hours
4. Sets migration flag to prevent re-running

### Notification Scheduling

The NotificationManager now:
1. Checks active profile first
2. Finds current time block
3. Calculates next reminder within block
4. Handles block boundaries and day transitions
5. Falls back to legacy system if no profile

### Data Persistence

Profiles stored in AppStorage as JSON:
- `scheduleProfiles` - Array of all profiles
- `activeProfileId` - UUID of active profile
- `hasMigratedToProfiles` - Migration flag

## Examples

### Example 1: Office Worker with Lunch Break

```swift
Morning Block:    9:00 AM - 12:00 PM, every 20 min
Lunch Break:     12:00 PM -  1:00 PM, paused
Afternoon Block:  1:00 PM -  5:00 PM, every 30 min
Evening Block:    6:00 PM -  9:00 PM, every 60 min (gentle)
```

### Example 2: Shift Worker

```swift
Monday:    6:00 AM -  2:00 PM, every 30 min
Tuesday:   2:00 PM - 10:00 PM, every 30 min
Wednesday: 6:00 AM -  2:00 PM, every 30 min
Thursday:  2:00 PM - 10:00 PM, every 30 min
Friday:    Off
Saturday:  Off
Sunday:   10:00 AM -  4:00 PM, every 60 min
```

### Example 3: Training Week

All days: 6:00 AM - 8:00 PM, every 15 min with ±3 min randomization

## Future Enhancements (Not Implemented Yet)

These are documented in UX19 but not implemented:

- Context-aware rules (Focus Mode, Calendar, Location)
- Adaptive AI scheduling
- Schedule preview/export
- Profile sharing
- Fixed-time smart spacing

## Testing

To test the profile system:

1. **Migration**: Delete app, reinstall to test migration
2. **Templates**: Create profile from each template
3. **Time Blocks**: Add multiple blocks, test overlaps
4. **Day Customization**: Set different schedule per day
5. **Profile Switching**: Switch profiles, verify notifications update

## Files Modified/Created

### StandFitCore
- `Models/ScheduleProfile.swift` ✨ NEW
- `Models/DailySchedule.swift` ✨ NEW
- `Models/TimeBlock.swift` ✨ NEW
- `Models/FixedReminder.swift` ✨ NEW
- `Models/ScheduleTemplate.swift` ✨ NEW

### StandFit (iOS)
- `Stores/ExerciseStore.swift` - Added profile management
- `Managers/NotificationManager.swift` - Updated scheduling algorithm
- `Views/ScheduleProfilePickerView.swift` ✨ NEW
- `Views/DayScheduleEditorView.swift` ✨ NEW
- `Views/TimeBlockEditorSheet.swift` ✨ NEW
- `Views/ProfileBadgeView.swift` ✨ NEW
- `Views/ReminderScheduleView.swift` - Integrated profile UI

## Support

For issues or questions:
- Check migration completed: Look for "✅ Migration complete" in logs
- Verify active profile: Should appear in ReminderScheduleView
- Test notification: Switch profiles and check next scheduled time
