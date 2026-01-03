//
//  LocalizedString.swift
//  StandFitCore
//
//  Type-safe localized string keys for the entire app
//  All user-facing text should be defined here and use NSLocalizedString
//

import Foundation

/// Type-safe localized string definitions
/// Usage: LocalizedString.General.cancel
public enum LocalizedString {

    // MARK: - General

    public enum General {
        public static let appName = NSLocalizedString("app.name", comment: "App name")
        public static let cancel = NSLocalizedString("general.cancel", comment: "Cancel button")
        public static let save = NSLocalizedString("general.save", comment: "Save button")
        public static let delete = NSLocalizedString("general.delete", comment: "Delete button")
        public static let edit = NSLocalizedString("general.edit", comment: "Edit button")
        public static let done = NSLocalizedString("general.done", comment: "Done button")
        public static let close = NSLocalizedString("general.close", comment: "Close button")
        public static let ok = NSLocalizedString("general.ok", comment: "OK button")
        public static let yes = NSLocalizedString("general.yes", comment: "Yes button")
        public static let no = NSLocalizedString("general.no", comment: "No button")
        public static let back = NSLocalizedString("general.back", comment: "Back button")
        public static let next = NSLocalizedString("general.next", comment: "Next button")
        public static let refresh = NSLocalizedString("general.refresh", comment: "Refresh button")
        public static let share = NSLocalizedString("general.share", comment: "Share button")
    }

    // MARK: - Navigation

    public enum Navigation {
        public static let home = NSLocalizedString("nav.home", comment: "Home tab")
        public static let history = NSLocalizedString("nav.history", comment: "History tab")
        public static let progress = NSLocalizedString("nav.progress", comment: "Progress tab")
        public static let achievements = NSLocalizedString("nav.achievements", comment: "Achievements tab")
        public static let settings = NSLocalizedString("nav.settings", comment: "Settings tab")
        public static let profile = NSLocalizedString("nav.profile", comment: "Profile tab")
    }

    // MARK: - Exercise Types

    public enum Exercise {
        public static let squats = NSLocalizedString("exercise.squats", comment: "Squats exercise name")
        public static let pushups = NSLocalizedString("exercise.pushups", comment: "Pushups exercise name")
        public static let lunges = NSLocalizedString("exercise.lunges", comment: "Lunges exercise name")
        public static let plank = NSLocalizedString("exercise.plank", comment: "Plank exercise name")
        public static let custom = NSLocalizedString("exercise.custom", comment: "Custom exercise label")

        public static func exerciseName(_ name: String) -> String {
            // Return custom exercise name as-is (not localized)
            return name
        }
    }

    // MARK: - Units

    public enum Units {
        public static let reps = NSLocalizedString("units.reps", comment: "Repetitions unit")
        public static let seconds = NSLocalizedString("units.seconds", comment: "Seconds unit")
        public static let minutes = NSLocalizedString("units.minutes", comment: "Minutes unit")
        public static let hours = NSLocalizedString("units.hours", comment: "Hours unit")
        public static let days = NSLocalizedString("units.days", comment: "Days unit")
        public static let weeks = NSLocalizedString("units.weeks", comment: "Weeks unit")
        public static let months = NSLocalizedString("units.months", comment: "Months unit")
    }

    // MARK: - Time & Duration

    public enum Minutes {
        public static func duration(_ count: Int) -> String {
            String(format: NSLocalizedString("time.minutes", comment: "X minutes duration"), count)
        }
    }

    public enum Seconds {
        public static func duration(_ count: Int) -> String {
            String(format: NSLocalizedString("time.seconds", comment: "X seconds duration"), count)
        }
    }

    // MARK: - Main Screen

    public enum Main {
        public static let title = NSLocalizedString("main.title", comment: "Main screen title")
        public static let nextReminder = NSLocalizedString("main.next_reminder", comment: "Next reminder label")
        public static let logExercise = NSLocalizedString("main.log_exercise", comment: "Log exercise button")
        public static let quickLog = NSLocalizedString("main.quick_log", comment: "Quick log section title")
        public static let todayActivity = NSLocalizedString("main.today_activity", comment: "Today's activity section")
        public static let noActivityToday = NSLocalizedString("main.no_activity_today", comment: "No activity message")
    }

    // MARK: - Exercise Picker

    public enum Picker {
        public static let title = NSLocalizedString("picker.title", comment: "Exercise picker title")
        public static let builtIn = NSLocalizedString("picker.built_in", comment: "Built-in exercises section")
        public static let custom = NSLocalizedString("picker.custom", comment: "Custom exercises section")
        public static let createCustom = NSLocalizedString("picker.create_custom", comment: "Create custom exercise button")
        public static let noCustomExercises = NSLocalizedString("picker.no_custom", comment: "No custom exercises message")
    }

    // MARK: - Exercise Logger

    public enum Logger {
        public static let title = NSLocalizedString("logger.title", comment: "Exercise logger title")
        public static let count = NSLocalizedString("logger.count", comment: "Count label")
        public static let logButton = NSLocalizedString("logger.log_button", comment: "Log button")
        public static let cancelButton = NSLocalizedString("logger.cancel_button", comment: "Cancel button")

        public static func logged(_ exerciseName: String, count: Int) -> String {
            String(format: NSLocalizedString("logger.logged", comment: "Exercise logged confirmation"), count, exerciseName)
        }
    }

    // MARK: - History

    public enum History {
        public static let title = NSLocalizedString("history.title", comment: "History screen title")
        public static let today = NSLocalizedString("history.today", comment: "Today section")
        public static let yesterday = NSLocalizedString("history.yesterday", comment: "Yesterday section")
        public static let thisWeek = NSLocalizedString("history.this_week", comment: "This week section")
        public static let older = NSLocalizedString("history.older", comment: "Older section")
        public static let noHistory = NSLocalizedString("history.no_history", comment: "No history message")
        public static let deleteConfirm = NSLocalizedString("history.delete_confirm", comment: "Delete confirmation message")
    }

    // MARK: - Progress

    public enum Progress {
        public static let title = NSLocalizedString("progress.title", comment: "Progress screen title")
        public static let period = NSLocalizedString("progress.period", comment: "Period label")
        public static let day = NSLocalizedString("progress.day", comment: "Day period")
        public static let week = NSLocalizedString("progress.week", comment: "Week period")
        public static let month = NSLocalizedString("progress.month", comment: "Month period")
        public static let totalExercises = NSLocalizedString("progress.total_exercises", comment: "Total exercises")
        public static let totalReps = NSLocalizedString("progress.total_reps", comment: "Total reps")
        public static let dailyAverage = NSLocalizedString("progress.daily_average", comment: "Daily average")
        public static let currentStreak = NSLocalizedString("progress.current_streak", comment: "Current streak")
        public static let noData = NSLocalizedString("progress.no_data", comment: "No data message")

        public static func streakDays(_ days: Int) -> String {
            String(format: NSLocalizedString("progress.streak_days", comment: "X days streak"), days)
        }

        public static func comparedToPrevious(_ change: Int) -> String {
            if change > 0 {
                return String(format: NSLocalizedString("progress.increase", comment: "Increase from previous"), change)
            } else if change < 0 {
                return String(format: NSLocalizedString("progress.decrease", comment: "Decrease from previous"), abs(change))
            } else {
                return NSLocalizedString("progress.no_change", comment: "No change from previous")
            }
        }
    }

    // MARK: - Achievements

    public enum Achievements {
        public static let title = NSLocalizedString("achievements.title", comment: "Achievements screen title")
        public static let unlocked = NSLocalizedString("achievements.unlocked", comment: "Unlocked section")
        public static let inProgress = NSLocalizedString("achievements.in_progress", comment: "In progress section")
        public static let locked = NSLocalizedString("achievements.locked", comment: "Locked section")
        public static let viewAll = NSLocalizedString("achievements.view_all", comment: "View all button")

        public static func unlockedCount(_ count: Int, total: Int) -> String {
            String(format: NSLocalizedString("achievements.unlocked_count", comment: "X/Y achievements"), count, total)
        }

        public static func achievementUnlocked(_ name: String) -> String {
            String(format: NSLocalizedString("achievements.unlocked_message", comment: "Achievement unlocked"), name)
        }

        // Achievement Categories
        public static let categoryMilestone = NSLocalizedString("achievements.category.milestone", comment: "Milestone category")
        public static let categoryConsistency = NSLocalizedString("achievements.category.consistency", comment: "Consistency category")
        public static let categoryVolume = NSLocalizedString("achievements.category.volume", comment: "Volume category")
        public static let categoryVariety = NSLocalizedString("achievements.category.variety", comment: "Variety category")
        public static let categoryChallenge = NSLocalizedString("achievements.category.challenge", comment: "Challenge category")
        public static let categoryTemplate = NSLocalizedString("achievements.category.template", comment: "Template category")

        // Achievement Tiers
        public static let tierBronze = NSLocalizedString("achievements.tier.bronze", comment: "Bronze tier")
        public static let tierSilver = NSLocalizedString("achievements.tier.silver", comment: "Silver tier")
        public static let tierGold = NSLocalizedString("achievements.tier.gold", comment: "Gold tier")
        public static let tierPlatinum = NSLocalizedString("achievements.tier.platinum", comment: "Platinum tier")
    }

    // MARK: - Achievement Templates

    public enum Templates {
        public static let title = NSLocalizedString("templates.title", comment: "Achievement templates screen")
        public static let manage = NSLocalizedString("templates.manage", comment: "Manage templates button")
        public static let create = NSLocalizedString("templates.create", comment: "Create template button")
        public static let edit = NSLocalizedString("templates.edit", comment: "Edit template button")
        public static let delete = NSLocalizedString("templates.delete", comment: "Delete template button")
        public static let deleteConfirm = NSLocalizedString("templates.delete_confirm", comment: "Delete template confirmation")
        public static let noTemplates = NSLocalizedString("templates.no_templates", comment: "No templates message")
        public static let refreshAchievements = NSLocalizedString("templates.refresh", comment: "Refresh achievements button")

        public static let templateName = NSLocalizedString("templates.name", comment: "Template name field")
        public static let templateType = NSLocalizedString("templates.type", comment: "Template type field")
        public static let exercise = NSLocalizedString("templates.exercise", comment: "Exercise field")
        public static let tiers = NSLocalizedString("templates.tiers", comment: "Tiers field")
        public static let active = NSLocalizedString("templates.active", comment: "Active status")
        public static let inactive = NSLocalizedString("templates.inactive", comment: "Inactive status")

        // Template Types
        public static let typeVolume = NSLocalizedString("templates.type.volume", comment: "Volume template type")
        public static let typeDailyGoal = NSLocalizedString("templates.type.daily_goal", comment: "Daily goal template type")
        public static let typeWeeklyGoal = NSLocalizedString("templates.type.weekly_goal", comment: "Weekly goal template type")
        public static let typeStreak = NSLocalizedString("templates.type.streak", comment: "Streak template type")
        public static let typeSpeed = NSLocalizedString("templates.type.speed", comment: "Speed template type")
    }

    // MARK: - Settings

    public enum Settings {
        public static let title = NSLocalizedString("settings.title", comment: "Settings screen title")

        // Reminders
        public static let reminders = NSLocalizedString("settings.reminders", comment: "Reminders section")
        public static let reminderInterval = NSLocalizedString("settings.reminder_interval", comment: "Reminder interval")
        public static let activeHours = NSLocalizedString("settings.active_hours", comment: "Active hours")
        public static let activeDays = NSLocalizedString("settings.active_days", comment: "Active days")
        public static let deadResponse = NSLocalizedString("settings.dead_response", comment: "Dead response recovery")
        public static let deadResponseTimeout = NSLocalizedString("settings.dead_response_timeout", comment: "Dead response timeout")

        // Reports
        public static let reports = NSLocalizedString("settings.reports", comment: "Reports section")
        public static let autoReports = NSLocalizedString("settings.auto_reports", comment: "Automatic reports")
        public static let dailyReport = NSLocalizedString("settings.daily_report", comment: "Daily report")
        public static let dailyReportTime = NSLocalizedString("settings.daily_report_time", comment: "Daily report time")

        // Custom Exercises
        public static let customExercises = NSLocalizedString("settings.custom_exercises", comment: "Custom exercises section")
        public static let manageExercises = NSLocalizedString("settings.manage_exercises", comment: "Manage custom exercises")
        public static let createExercise = NSLocalizedString("settings.create_exercise", comment: "Create custom exercise")

        // App
        public static let app = NSLocalizedString("settings.app", comment: "App section")
        public static let language = NSLocalizedString("settings.language", comment: "Language")
        public static let notifications = NSLocalizedString("settings.notifications", comment: "Notifications")
        public static let about = NSLocalizedString("settings.about", comment: "About")
        public static let version = NSLocalizedString("settings.version", comment: "Version")
    }

    // MARK: - Notifications

    public enum Notifications {
        public static let exerciseReminder = NSLocalizedString("notification.exercise_reminder", comment: "Exercise reminder title")
        public static let timeToExercise = NSLocalizedString("notification.time_to_exercise", comment: "Time to exercise message")
        public static let stillThere = NSLocalizedString("notification.still_there", comment: "Dead response follow-up")
        public static let actionLog = NSLocalizedString("notification.action_log", comment: "Log exercise action")
        public static let actionSnooze = NSLocalizedString("notification.action_snooze", comment: "Snooze action")
        public static let actionDismiss = NSLocalizedString("notification.action_dismiss", comment: "Dismiss action")
        public static let actionView = NSLocalizedString("notification.action_view", comment: "View action")

        public static let progressReport = NSLocalizedString("notification.progress_report", comment: "Progress report title")
        public static let achievementUnlocked = NSLocalizedString("notification.achievement_unlocked", comment: "Achievement unlocked title")

        public static func dailyReport(_ totalExercises: Int) -> String {
            String(format: NSLocalizedString("notification.daily_report", comment: "Daily report message"), totalExercises)
        }
    }

    // MARK: - Errors

    public enum Errors {
        public static let generic = NSLocalizedString("error.generic", comment: "Generic error message")
        public static let saveFailed = NSLocalizedString("error.save_failed", comment: "Save failed error")
        public static let loadFailed = NSLocalizedString("error.load_failed", comment: "Load failed error")
        public static let deleteFailed = NSLocalizedString("error.delete_failed", comment: "Delete failed error")
        public static let notificationPermission = NSLocalizedString("error.notification_permission", comment: "Notification permission error")
        public static let noData = NSLocalizedString("error.no_data", comment: "No data error")

        public static func customMessage(_ message: String) -> String {
            String(format: NSLocalizedString("error.custom", comment: "Custom error format"), message)
        }
    }

    // MARK: - Custom Exercise Creation

    public enum CreateExercise {
        public static let title = NSLocalizedString("create_exercise.title", comment: "Create exercise screen")
        public static let editTitle = NSLocalizedString("create_exercise.edit_title", comment: "Edit exercise screen")
        public static let name = NSLocalizedString("create_exercise.name", comment: "Exercise name field")
        public static let namePlaceholder = NSLocalizedString("create_exercise.name_placeholder", comment: "Exercise name placeholder")
        public static let icon = NSLocalizedString("create_exercise.icon", comment: "Exercise icon field")
        public static let unitType = NSLocalizedString("create_exercise.unit_type", comment: "Unit type field")
        public static let defaultCount = NSLocalizedString("create_exercise.default_count", comment: "Default count field")
        public static let color = NSLocalizedString("create_exercise.color", comment: "Color field")
        public static let preview = NSLocalizedString("create_exercise.preview", comment: "Preview section")
        public static let saveButton = NSLocalizedString("create_exercise.save", comment: "Save button")
        public static let cancelButton = NSLocalizedString("create_exercise.cancel", comment: "Cancel button")
    }

    // MARK: - Timeline

    public enum Timeline {
        public static let title = NSLocalizedString("timeline.title", comment: "Timeline screen title")
        public static let notifications = NSLocalizedString("timeline.notifications", comment: "Notifications label")
        public static let exercises = NSLocalizedString("timeline.exercises", comment: "Exercises label")
        public static let correlation = NSLocalizedString("timeline.correlation", comment: "Correlation label")
        public static let noData = NSLocalizedString("timeline.no_data", comment: "No timeline data")
    }

    // MARK: - Premium/Paywall

    public enum Premium {
        public static let title = NSLocalizedString("premium.title", comment: "Premium screen title")
        public static let unlockPremium = NSLocalizedString("premium.unlock", comment: "Unlock premium button")
        public static let restore = NSLocalizedString("premium.restore", comment: "Restore purchases button")
        public static let featureCustomExercises = NSLocalizedString("premium.feature.custom_exercises", comment: "Custom exercises feature")
        public static let featureTemplates = NSLocalizedString("premium.feature.templates", comment: "Achievement templates feature")
        public static let featureAdvancedStats = NSLocalizedString("premium.feature.advanced_stats", comment: "Advanced statistics feature")
    }
}
