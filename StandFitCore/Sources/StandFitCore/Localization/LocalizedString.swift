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
        private static let table = "General"
        
        public static let appName = NSLocalizedString("app.name", tableName: table, comment: "App name")
        public static let cancel = NSLocalizedString("general.cancel", tableName: table, comment: "Cancel button")
        public static let save = NSLocalizedString("general.save", tableName: table, comment: "Save button")
        public static let delete = NSLocalizedString("general.delete", tableName: table, comment: "Delete button")
        public static let edit = NSLocalizedString("general.edit", tableName: table, comment: "Edit button")
        public static let done = NSLocalizedString("general.done", tableName: table, comment: "Done button")
        public static let close = NSLocalizedString("general.close", tableName: table, comment: "Close button")
        public static let ok = NSLocalizedString("general.ok", tableName: table, comment: "OK button")
        public static let yes = NSLocalizedString("general.yes", tableName: table, comment: "Yes button")
        public static let no = NSLocalizedString("general.no", tableName: table, comment: "No button")
        public static let back = NSLocalizedString("general.back", tableName: table, comment: "Back button")
        public static let next = NSLocalizedString("general.next", tableName: table, comment: "Next button")
        public static let refresh = NSLocalizedString("general.refresh", tableName: table, comment: "Refresh button")
        public static let share = NSLocalizedString("general.share", tableName: table, comment: "Share button")
    }

    // MARK: - Navigation

    public enum Navigation {
        private static let table = "Navigation"
        
        public static let home = NSLocalizedString("nav.home", tableName: table, comment: "Home tab")
        public static let history = NSLocalizedString("nav.history", tableName: table, comment: "History tab")
        public static let progress = NSLocalizedString("nav.progress", tableName: table, comment: "Progress tab")
        public static let achievements = NSLocalizedString("nav.achievements", tableName: table, comment: "Achievements tab")
        public static let settings = NSLocalizedString("nav.settings", tableName: table, comment: "Settings tab")
        public static let profile = NSLocalizedString("nav.profile", tableName: table, comment: "Profile tab")
    }

    // MARK: - Exercise Types

    public enum Exercise {
        private static let table = "Exercise"
        
        public static let squats = NSLocalizedString("exercise.squats", tableName: table, comment: "Squats exercise name")
        public static let pushups = NSLocalizedString("exercise.pushups", tableName: table, comment: "Pushups exercise name")
        public static let lunges = NSLocalizedString("exercise.lunges", tableName: table, comment: "Lunges exercise name")
        public static let plank = NSLocalizedString("exercise.plank", tableName: table, comment: "Plank exercise name")
        public static let custom = NSLocalizedString("exercise.custom", tableName: table, comment: "Custom exercise label")

        public static func exerciseName(_ name: String) -> String {
            // Return custom exercise name as-is (not localized)
            return name
        }
    }

    // MARK: - Units

    public enum Units {
        private static let table = "Units"
        
        public static let reps = NSLocalizedString("units.reps", tableName: table, comment: "Repetitions unit")
        public static let seconds = NSLocalizedString("units.seconds", tableName: table, comment: "Seconds unit")
        public static let minutes = NSLocalizedString("units.minutes", tableName: table, comment: "Minutes unit")
        public static let hours = NSLocalizedString("units.hours", tableName: table, comment: "Hours unit")
        public static let days = NSLocalizedString("units.days", tableName: table, comment: "Days unit")
        public static let weeks = NSLocalizedString("units.weeks", tableName: table, comment: "Weeks unit")
        public static let months = NSLocalizedString("units.months", tableName: table, comment: "Months unit")
    }

    // MARK: - Time & Duration

    public enum Minutes {
        private static let table = "Units"
        
        public static func duration(_ count: Int) -> String {
            String(format: NSLocalizedString("time.minutes", tableName: table, comment: "X minutes duration"), count)
        }
    }

    public enum Seconds {
        private static let table = "Units"
        
        public static func duration(_ count: Int) -> String {
            String(format: NSLocalizedString("time.seconds", tableName: table, comment: "X seconds duration"), count)
        }
    }

    // MARK: - Main Screen

    public enum Main {
        private static let table = "Main"
        
        public static let title = NSLocalizedString("main.title", tableName: table, comment: "Main screen title")
        public static let nextReminder = NSLocalizedString("main.next_reminder", tableName: table, comment: "Next reminder label")
        public static let logExercise = NSLocalizedString("main.log_exercise", tableName: table, comment: "Log exercise button")
        public static let quickLog = NSLocalizedString("main.quick_log", tableName: table, comment: "Quick log section title")
        public static let todayActivity = NSLocalizedString("main.today_activity", tableName: table, comment: "Today's activity section")
        public static let noActivityToday = NSLocalizedString("main.no_activity_today", tableName: table, comment: "No activity message")
    }

    // MARK: - Exercise Picker

    public enum Picker {
        private static let table = "Picker"
        
        public static let title = NSLocalizedString("picker.title", tableName: table, comment: "Exercise picker title")
        public static let builtIn = NSLocalizedString("picker.built_in", tableName: table, comment: "Built-in exercises section")
        public static let custom = NSLocalizedString("picker.custom", tableName: table, comment: "Custom exercises section")
        public static let createCustom = NSLocalizedString("picker.create_custom", tableName: table, comment: "Create custom exercise button")
        public static let noCustomExercises = NSLocalizedString("picker.no_custom", tableName: table, comment: "No custom exercises message")
    }

    // MARK: - Exercise Logger

    public enum Logger {
        private static let table = "Logger"
        
        public static let title = NSLocalizedString("logger.title", tableName: table, comment: "Exercise logger title")
        public static let count = NSLocalizedString("logger.count", tableName: table, comment: "Count label")
        public static let logButton = NSLocalizedString("logger.log_button", tableName: table, comment: "Log button")
        public static let cancelButton = NSLocalizedString("logger.cancel_button", tableName: table, comment: "Cancel button")

        public static func logged(_ exerciseName: String, count: Int) -> String {
            String(format: NSLocalizedString("logger.logged", tableName: table, comment: "Exercise logged confirmation"), count, exerciseName)
        }
    }

    // MARK: - Exercise Logger View

    public enum ExerciseLogger {
        private static let table = "ExerciseLogger"
        
        public static let navigationTitle = NSLocalizedString("exercise_logger.navigation_title", tableName: table, comment: "Navigation title for exercise logger")
        public static let adjustCountInstruction = NSLocalizedString("exercise_logger.adjust_count_instruction", tableName: table, comment: "Instruction text for exercise logger")
        public static let quickAddHeader = NSLocalizedString("exercise_logger.quick_add_header", tableName: table, comment: "Header for quick add section")
        public static let saveButtonLabel = NSLocalizedString("exercise_logger.save_button_label", tableName: table, comment: "Save button label")
        public static let doneButton = NSLocalizedString("exercise_logger.done_button", tableName: table, comment: "Done button in exercise logger")
        public static let loggedSuccess = NSLocalizedString("exercise_logger.logged_success", tableName: table, comment: "Success message when exercise is logged")
        
        public static func saveButton(count: Int, unit: String) -> String {
            String(format: NSLocalizedString("exercise_logger.save_button", tableName: table, comment: "Save button with count and unit"), count, unit)
        }
        
        public static func loggedSuccessDetail(count: Int, unit: String, exerciseName: String) -> String {
            String(format: NSLocalizedString("exercise_logger.logged_success_detail", tableName: table, comment: "Success detail message with count, unit and exercise name"), count, unit, exerciseName)
        }
    }

    // MARK: - History

    public enum History {
        private static let table = "History"
        
        public static let title = NSLocalizedString("history.title", tableName: table, comment: "History screen title")
        public static let today = NSLocalizedString("history.today", tableName: table, comment: "Today section")
        public static let yesterday = NSLocalizedString("history.yesterday", tableName: table, comment: "Yesterday section")
        public static let thisWeek = NSLocalizedString("history.this_week", tableName: table, comment: "This week section")
        public static let older = NSLocalizedString("history.older", tableName: table, comment: "Older section")
        public static let noHistory = NSLocalizedString("history.no_history", tableName: table, comment: "No history message")
        public static let deleteConfirm = NSLocalizedString("history.delete_confirm", tableName: table, comment: "Delete confirmation message")
    }

    // MARK: - Progress

    public enum Progress {
        private static let table = "Progress"
        
        public static let title = NSLocalizedString("progress.title", tableName: table, comment: "Progress screen title")
        public static let period = NSLocalizedString("progress.period", tableName: table, comment: "Period label")
        public static let day = NSLocalizedString("progress.day", tableName: table, comment: "Day period")
        public static let week = NSLocalizedString("progress.week", tableName: table, comment: "Week period")
        public static let month = NSLocalizedString("progress.month", tableName: table, comment: "Month period")
        public static let totalExercises = NSLocalizedString("progress.total_exercises", tableName: table, comment: "Total exercises")
        public static let totalReps = NSLocalizedString("progress.total_reps", tableName: table, comment: "Total reps")
        public static let dailyAverage = NSLocalizedString("progress.daily_average", tableName: table, comment: "Daily average")
        public static let currentStreak = NSLocalizedString("progress.current_streak", tableName: table, comment: "Current streak")
        public static let noData = NSLocalizedString("progress.no_data", tableName: table, comment: "No data message")

        public static func streakDays(_ days: Int) -> String {
            String(format: NSLocalizedString("progress.streak_days", tableName: table, comment: "X days streak"), days)
        }

        public static func comparedToPrevious(_ change: Int) -> String {
            if change > 0 {
                return String(format: NSLocalizedString("progress.increase", tableName: table, comment: "Increase from previous"), change)
            } else if change < 0 {
                return String(format: NSLocalizedString("progress.decrease", tableName: table, comment: "Decrease from previous"), abs(change))
            } else {
                return NSLocalizedString("progress.no_change", tableName: table, comment: "No change from previous")
            }
        }
        
        // ProgressChartsView
        public static let activityTitle = NSLocalizedString("progress.activity_title", tableName: table, comment: "Activity chart title")
        public static let breakdownTitle = NSLocalizedString("progress.breakdown_title", tableName: table, comment: "Breakdown section title")
        public static let noActivityLogged = NSLocalizedString("progress.no_activity_logged", tableName: table, comment: "No activity logged message")
        
        // Day abbreviations (one letter) for charts
        public static let daySunday = NSLocalizedString("progress.day_sunday", tableName: table, comment: "Sunday abbreviation (one letter)")
        public static let dayMonday = NSLocalizedString("progress.day_monday", tableName: table, comment: "Monday abbreviation (one letter)")
        public static let dayTuesday = NSLocalizedString("progress.day_tuesday", tableName: table, comment: "Tuesday abbreviation (one letter)")
        public static let dayWednesday = NSLocalizedString("progress.day_wednesday", tableName: table, comment: "Wednesday abbreviation (one letter)")
        public static let dayThursday = NSLocalizedString("progress.day_thursday", tableName: table, comment: "Thursday abbreviation (one letter)")
        public static let dayFriday = NSLocalizedString("progress.day_friday", tableName: table, comment: "Friday abbreviation (one letter)")
        public static let daySaturday = NSLocalizedString("progress.day_saturday", tableName: table, comment: "Saturday abbreviation (one letter)")
        
        public static func weekNumber(_ week: Int) -> String {
            String(format: NSLocalizedString("progress.week_number", tableName: table, comment: "Week number format (W1, W2, etc.)"), week)
        }
    }

    // MARK: - Achievements

    public enum Achievements {
        private static let table = "Achievements"
        
        public static let title = NSLocalizedString("achievements.title", tableName: table, comment: "Achievements screen title")
        public static let unlocked = NSLocalizedString("achievements.unlocked", tableName: table, comment: "Unlocked section")
        public static let inProgress = NSLocalizedString("achievements.in_progress", tableName: table, comment: "In progress section")
        public static let locked = NSLocalizedString("achievements.locked", tableName: table, comment: "Locked section")
        public static let viewAll = NSLocalizedString("achievements.view_all", tableName: table, comment: "View all button")

        public static func unlockedCount(_ count: Int, total: Int) -> String {
            String(format: NSLocalizedString("achievements.unlocked_count", comment: "X/Y achievements"), count, total)
        }

        public static func achievementUnlocked(_ name: String) -> String {
            String(format: NSLocalizedString("achievements.unlocked_message", comment: "Achievement unlocked"), name)
        }

        // Achievement Categories
        public static let categoryMilestone = NSLocalizedString("achievements.category.milestone", tableName: table, comment: "Milestone category")
        public static let categoryConsistency = NSLocalizedString("achievements.category.consistency", tableName: table, comment: "Consistency category")
        public static let categoryVolume = NSLocalizedString("achievements.category.volume", tableName: table, comment: "Volume category")
        public static let categoryVariety = NSLocalizedString("achievements.category.variety", tableName: table, comment: "Variety category")
        public static let categoryChallenge = NSLocalizedString("achievements.category.challenge", tableName: table, comment: "Challenge category")
        public static let categoryTemplate = NSLocalizedString("achievements.category.template", tableName: table, comment: "Template category")

        // Achievement Tiers
        public static let tierBronze = NSLocalizedString("achievements.tier.bronze", tableName: table, comment: "Bronze tier")
        public static let tierSilver = NSLocalizedString("achievements.tier.silver", tableName: table, comment: "Silver tier")
        public static let tierGold = NSLocalizedString("achievements.tier.gold", tableName: table, comment: "Gold tier")
        public static let tierPlatinum = NSLocalizedString("achievements.tier.platinum", tableName: table, comment: "Platinum tier")

        // Filter & Toast
        public static let all = NSLocalizedString("achievements.all", tableName: table, comment: "All category filter")
        public static let unlockedToast = NSLocalizedString("achievements.unlocked_toast", tableName: table, comment: "Achievement Unlocked!")
        public static let awesome = NSLocalizedString("achievements.awesome", tableName: table, comment: "Awesome! button")
    }

    // MARK: - Achievement Templates

    public enum Templates {
        private static let table = "Templates"
        
        public static let title = NSLocalizedString("templates.title", tableName: table, comment: "Achievement templates screen")
        public static let manage = NSLocalizedString("templates.manage", tableName: table, comment: "Manage templates button")
        public static let create = NSLocalizedString("templates.create", tableName: table, comment: "Create template button")
        public static let edit = NSLocalizedString("templates.edit", tableName: table, comment: "Edit template button")
        public static let delete = NSLocalizedString("templates.delete", tableName: table, comment: "Delete template button")
        public static let deleteConfirm = NSLocalizedString("templates.delete_confirm", tableName: table, comment: "Delete template confirmation")
        public static let noTemplates = NSLocalizedString("templates.no_templates", tableName: table, comment: "No templates message")
        public static let refreshAchievements = NSLocalizedString("templates.refresh", tableName: table, comment: "Refresh achievements button")

        public static let templateName = NSLocalizedString("templates.name", tableName: table, comment: "Template name field")
        public static let templateType = NSLocalizedString("templates.type", tableName: table, comment: "Template type field")
        public static let exercise = NSLocalizedString("templates.exercise", tableName: table, comment: "Exercise field")
        public static let tiers = NSLocalizedString("templates.tiers", tableName: table, comment: "Tiers field")
        public static let active = NSLocalizedString("templates.active", tableName: table, comment: "Active status")
        public static let inactive = NSLocalizedString("templates.inactive", tableName: table, comment: "Inactive status")

        // Template Types
        public static let typeVolume = NSLocalizedString("templates.type.volume", tableName: table, comment: "Volume template type")
        public static let typeDailyGoal = NSLocalizedString("templates.type.daily_goal", tableName: table, comment: "Daily goal template type")
        public static let typeWeeklyGoal = NSLocalizedString("templates.type.weekly_goal", tableName: table, comment: "Weekly goal template type")
        public static let typeStreak = NSLocalizedString("templates.type.streak", tableName: table, comment: "Streak template type")
        public static let typeSpeed = NSLocalizedString("templates.type.speed", tableName: table, comment: "Speed template type")

        // Premium Prompt
        public static let premiumPromptTitle = NSLocalizedString("templates.premium_prompt.title", tableName: table, comment: "Create Custom Achievement Templates")
        public static let premiumPromptSubtitle = NSLocalizedString("templates.premium_prompt.subtitle", tableName: table, comment: "Design personalized achievements for your custom exercises")
        public static let premiumPromptBenefitTargets = NSLocalizedString("templates.premium_prompt.benefit_targets", tableName: table, comment: "Set your own achievement targets and goals")
        public static let premiumPromptBenefitTrack = NSLocalizedString("templates.premium_prompt.benefit_track", tableName: table, comment: "Track progress automatically as you exercise")
        public static let premiumPromptBenefitTypes = NSLocalizedString("templates.premium_prompt.benefit_types", tableName: table, comment: "Choose from 5 template types: Volume, Daily, Weekly, Streak, and Speed")
        public static let premiumPromptBenefitUnlimited = NSLocalizedString("templates.premium_prompt.benefit_unlimited", tableName: table, comment: "Create unlimited templates with Premium")
        public static let premiumPromptCTA = NSLocalizedString("templates.premium_prompt.cta", tableName: table, comment: "Start Free Trial")
        public static let premiumPromptTrialInfo = NSLocalizedString("templates.premium_prompt.trial_info", tableName: table, comment: "14-day free trial • Cancel anytime")
        
        // Create/Edit Template
        public static let templateNameSection = NSLocalizedString("templates.template_name", tableName: table, comment: "Template Name section")
        public static let enterName = NSLocalizedString("templates.enter_name", tableName: table, comment: "Enter a name")
        public static let builtIn = NSLocalizedString("templates.built_in", tableName: table, comment: "Built-in")
        public static let custom = NSLocalizedString("templates.custom", tableName: table, comment: "Custom")
        public static let change = NSLocalizedString("templates.change", tableName: table, comment: "Change")
        public static let selectExercise = NSLocalizedString("templates.select_exercise", tableName: table, comment: "Select Exercise")
        public static let achievementType = NSLocalizedString("templates.achievement_type", tableName: table, comment: "Achievement Type")
        public static let achievementTiers = NSLocalizedString("templates.achievement_tiers", tableName: table, comment: "Achievement Tiers")
        public static let addTier = NSLocalizedString("templates.add_tier", tableName: table, comment: "Add Tier")
        public static let tierFooter = NSLocalizedString("templates.tier_footer", tableName: table, comment: "Each tier creates a separate achievement")
        public static let templateActive = NSLocalizedString("templates.template_active", tableName: table, comment: "Template Active")
        public static let inactiveFooter = NSLocalizedString("templates.inactive_footer", tableName: table, comment: "Inactive templates won't generate achievements")
        public static let updateTemplate = NSLocalizedString("templates.update_template", tableName: table, comment: "Update Template")
        public static let createTemplate = NSLocalizedString("templates.create_template", tableName: table, comment: "Create Template")
        public static let editTemplate = NSLocalizedString("templates.edit_template", tableName: table, comment: "Edit Template")
        public static let newTemplate = NSLocalizedString("templates.new_template", tableName: table, comment: "New Template")
        public static let cancel = NSLocalizedString("templates.cancel", tableName: table, comment: "Cancel")
        public static let target = NSLocalizedString("templates.target", tableName: table, comment: "Target:")
        public static let timeWindow = NSLocalizedString("templates.time_window", tableName: table, comment: "Time Window:")
        public static let labelOptional = NSLocalizedString("templates.label_optional", tableName: table, comment: "Label (optional)")
        public static let perDay = NSLocalizedString("templates.per_day", tableName: table, comment: "per day")
        public static let perWeek = NSLocalizedString("templates.per_week", tableName: table, comment: "per week")
        public static let daySingular = NSLocalizedString("templates.day_singular", tableName: table, comment: "day")
        public static let daysPlural = NSLocalizedString("templates.days_plural", tableName: table, comment: "days")
        public static let builtInExercises = NSLocalizedString("templates.built_in_exercises", tableName: table, comment: "Built-in Exercises")
        public static let customExercises = NSLocalizedString("templates.custom_exercises", tableName: table, comment: "Custom Exercises")
        
        // ManageTemplatesView
        public static let navigationTitle = NSLocalizedString("templates.navigation_title", tableName: table, comment: "Achievement Templates navigation title")
        public static let templatesCreated = NSLocalizedString("templates.templates_created", tableName: table, comment: "Templates created label")
        public static let refreshFooter = NSLocalizedString("templates.refresh_footer", tableName: table, comment: "Refresh achievements footer text")
        public static let noTemplatesTitle = NSLocalizedString("templates.no_templates_title", tableName: table, comment: "No templates title")
        public static let noTemplatesDescription = NSLocalizedString("templates.no_templates_description", tableName: table, comment: "No templates description text")
        public static let deleteTemplate = NSLocalizedString("templates.delete_template", tableName: table, comment: "Delete template confirmation title")
        public static let deleteMessage = NSLocalizedString("templates.delete_message", tableName: table, comment: "Delete template confirmation message")
        public static let exerciseDeleted = NSLocalizedString("templates.exercise_deleted", tableName: table, comment: "Exercise deleted message")
        
        public static func minutesFormat(_ minutes: Int) -> String {
            String(format: NSLocalizedString("templates.minutes_format", tableName: table, comment: "X minutes"), minutes)
        }
        
        public static func tiersCount(_ count: Int) -> String {
            String(format: NSLocalizedString("templates.tiers_count", tableName: table, comment: "Tier count format"), count)
        }
    }

    // MARK: - Settings

    public enum Settings {
        private static let table = "Settings"
        
        public static let title = NSLocalizedString("settings.title", tableName: table, comment: "Settings screen title")

        // Reminders
        public static let reminders = NSLocalizedString("settings.reminders", tableName: table, comment: "Reminders section")
        public static let reminderInterval = NSLocalizedString("settings.reminder_interval", tableName: table, comment: "Reminder interval")
        public static let activeHours = NSLocalizedString("settings.active_hours", tableName: table, comment: "Active hours")
        public static let activeDays = NSLocalizedString("settings.active_days", tableName: table, comment: "Active days")
        public static let deadResponse = NSLocalizedString("settings.dead_response", tableName: table, comment: "Dead response recovery")
        public static let deadResponseTimeout = NSLocalizedString("settings.dead_response_timeout", tableName: table, comment: "Dead response timeout")
        public static let remindersOff = NSLocalizedString("settings.reminders_off", tableName: table, comment: "Reminders Off label")
        public static let enableReminders = NSLocalizedString("settings.enable_reminders", tableName: table, comment: "Enable reminders to configure schedule")

        // Reports
        public static let reports = NSLocalizedString("settings.reports", tableName: table, comment: "Reports section")
        public static let autoReports = NSLocalizedString("settings.auto_reports", tableName: table, comment: "Automatic reports")
        public static let dailyReport = NSLocalizedString("settings.daily_report", tableName: table, comment: "Daily report")
        public static let dailyReportTime = NSLocalizedString("settings.daily_report_time", tableName: table, comment: "Daily report time")

        // Custom Exercises
        public static let customExercises = NSLocalizedString("settings.custom_exercises", tableName: table, comment: "Custom exercises section")
        public static let manageExercises = NSLocalizedString("settings.manage_exercises", tableName: table, comment: "Manage custom exercises")
        public static let createExercise = NSLocalizedString("settings.create_exercise", tableName: table, comment: "Create custom exercise")

        // App
        public static let app = NSLocalizedString("settings.app", tableName: table, comment: "App section")
        public static let language = NSLocalizedString("settings.language", tableName: table, comment: "Language")
        public static let notifications = NSLocalizedString("settings.notifications", tableName: table, comment: "Notifications")
        public static let about = NSLocalizedString("settings.about", tableName: table, comment: "About")
        public static let version = NSLocalizedString("settings.version", tableName: table, comment: "Version")
        
        // Haptics & Data
        public static let on = NSLocalizedString("settings.on", tableName: table, comment: "On")
        public static let testHaptic = NSLocalizedString("settings.test_haptic", tableName: table, comment: "Test Haptic")
        public static let hapticFeedback = NSLocalizedString("settings.haptic_feedback", tableName: table, comment: "Haptic Feedback")
        public static let clearAllData = NSLocalizedString("settings.clear_all_data", tableName: table, comment: "Clear All Data")
        public static let data = NSLocalizedString("settings.data", tableName: table, comment: "Data")
        public static let deleteConfirmation = NSLocalizedString("settings.delete_confirmation", tableName: table, comment: "This will delete all exercise logs.")
        public static let done = NSLocalizedString("settings.done", tableName: table, comment: "Done")
        
        // Time formatting
        public static let every = NSLocalizedString("settings.every", tableName: table, comment: "Every (time interval prefix)")
        public static let timeMin = NSLocalizedString("settings.time_min", tableName: table, comment: "min (minutes abbreviation)")
        public static let timeHour = NSLocalizedString("settings.time_hour", tableName: table, comment: "hour (singular)")
        public static let timeHours = NSLocalizedString("settings.time_hours", tableName: table, comment: "hours (plural)")
        public static let timeH = NSLocalizedString("settings.time_h", tableName: table, comment: "h (hours abbreviation)")
        public static let timeM = NSLocalizedString("settings.time_m", tableName: table, comment: "m (minutes abbreviation)")
        
        // Date formatting
        public static let today = NSLocalizedString("settings.today", tableName: table, comment: "Today")
        public static let tomorrow = NSLocalizedString("settings.tomorrow", tableName: table, comment: "Tomorrow")
        
        // Helper functions for time interval formatting
        public static func formatInterval(_ minutes: Int) -> String {
            if minutes < 60 {
                return "\(every) \(minutes) \(timeMin)"
            } else if minutes == 60 {
                return "\(every) 1 \(timeHour)"
            } else if minutes % 60 == 0 {
                let hours = minutes / 60
                return "\(every) \(hours) \(timeHours)"
            } else {
                let hours = minutes / 60
                let mins = minutes % 60
                return "\(every) \(hours)\(timeH) \(mins)\(timeM)"
            }
        }
    }

    // MARK: - Notifications

    public enum Notifications {
        private static let table = "Notifications"
        
        public static let exerciseReminder = NSLocalizedString("notification.exercise_reminder", tableName: table, comment: "Exercise reminder title")
        public static let timeToExercise = NSLocalizedString("notification.time_to_exercise", tableName: table, comment: "Time to exercise message")
        public static let stillThere = NSLocalizedString("notification.still_there", tableName: table, comment: "Dead response follow-up")
        public static let actionLog = NSLocalizedString("notification.action_log", tableName: table, comment: "Log exercise action")
        public static let actionSnooze = NSLocalizedString("notification.action_snooze", tableName: table, comment: "Snooze action")
        public static let actionDismiss = NSLocalizedString("notification.action_dismiss", tableName: table, comment: "Dismiss action")
        public static let actionView = NSLocalizedString("notification.action_view", tableName: table, comment: "View action")
        public static let resetTimer = NSLocalizedString("notification.reset_timer", tableName: table, comment: "Reset Timer button")

        public static let progressReport = NSLocalizedString("notification.progress_report", tableName: table, comment: "Progress report title")
        public static let achievementUnlocked = NSLocalizedString("notification.achievement_unlocked", tableName: table, comment: "Achievement unlocked title")

        public static func dailyReport(_ totalExercises: Int) -> String {
            String(format: NSLocalizedString("notification.daily_report", tableName: table, comment: "Daily report message"), totalExercises)
        }
    }
    
    // MARK: - Schedule Editor
    
    public enum ScheduleEditor {
        private static let table = "ScheduleEditor"
        
        // Weekday names
        public static let sunday = NSLocalizedString("schedule_editor.sunday", tableName: table, comment: "Sunday")
        public static let monday = NSLocalizedString("schedule_editor.monday", tableName: table, comment: "Monday")
        public static let tuesday = NSLocalizedString("schedule_editor.tuesday", tableName: table, comment: "Tuesday")
        public static let wednesday = NSLocalizedString("schedule_editor.wednesday", tableName: table, comment: "Wednesday")
        public static let thursday = NSLocalizedString("schedule_editor.thursday", tableName: table, comment: "Thursday")
        public static let friday = NSLocalizedString("schedule_editor.friday", tableName: table, comment: "Friday")
        public static let saturday = NSLocalizedString("schedule_editor.saturday", tableName: table, comment: "Saturday")
        
        // Description strings
        public static let noTimeBlocksShort = NSLocalizedString("schedule_editor.no_time_blocks_short", tableName: table, comment: "No time blocks")
        public static let timeBlocksOption = NSLocalizedString("schedule_editor.time_blocks_option", tableName: table, comment: "Time Blocks")
        public static let fixedTimesOption = NSLocalizedString("schedule_editor.fixed_times_option", tableName: table, comment: "Fixed Times")
        public static let useDefaultOption = NSLocalizedString("schedule_editor.use_default_option", tableName: table, comment: "Use Default")
        
        // Picker labels
        public static let hour = NSLocalizedString("schedule_editor.hour", tableName: table, comment: "Hour")
        public static let minute = NSLocalizedString("schedule_editor.minute", tableName: table, comment: "Minute")
        
        // Format strings
        public static func timeBlocksCount(_ count: Int) -> String {
            String(format: NSLocalizedString("schedule_editor.time_blocks_count", tableName: table, comment: "%d time blocks"), count)
        }
        
        public static func fixedRemindersCount(_ count: Int) -> String {
            String(format: NSLocalizedString("schedule_editor.fixed_reminders_count", tableName: table, comment: "%d fixed reminders"), count)
        }
        
        public static func usingDefaultInterval(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule_editor.using_default_interval", tableName: table, comment: "Using default interval"), minutes)
        }
        
        public static func timeBlockDetail(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, interval: Int) -> String {
            String(format: NSLocalizedString("schedule_editor.time_block_detail", tableName: table, comment: "Time block detail format"), startHour, startMinute, endHour, endMinute, interval)
        }
    }

    // MARK: - Errors

    public enum Errors {
        private static let table = "Errors"
        
        public static let generic = NSLocalizedString("error.generic", tableName: table, comment: "Generic error message")
        public static let saveFailed = NSLocalizedString("error.save_failed", tableName: table, comment: "Save failed error")
        public static let loadFailed = NSLocalizedString("error.load_failed", tableName: table, comment: "Load failed error")
        public static let deleteFailed = NSLocalizedString("error.delete_failed", tableName: table, comment: "Delete failed error")
        public static let notificationPermission = NSLocalizedString("error.notification_permission", tableName: table, comment: "Notification permission error")
        public static let noData = NSLocalizedString("error.no_data", tableName: table, comment: "No data error")

        public static func customMessage(_ message: String) -> String {
            String(format: NSLocalizedString("error.custom", tableName: table, comment: "Custom error format"), message)
        }
    }

    // MARK: - Custom Exercise Creation

    public enum CreateExercise {
        private static let table = "CreateExercise"
        
        public static let title = NSLocalizedString("create_exercise.title", tableName: table, comment: "Create exercise screen")
        public static let editTitle = NSLocalizedString("create_exercise.edit_title", tableName: table, comment: "Edit exercise screen")
        public static let name = NSLocalizedString("create_exercise.name", tableName: table, comment: "Exercise name field")
        public static let namePlaceholder = NSLocalizedString("create_exercise.name_placeholder", tableName: table, comment: "Exercise name placeholder")
        public static let icon = NSLocalizedString("create_exercise.icon", tableName: table, comment: "Exercise icon field")
        public static let unitType = NSLocalizedString("create_exercise.unit_type", tableName: table, comment: "Unit type field")
        public static let defaultCount = NSLocalizedString("create_exercise.default_count", tableName: table, comment: "Default count field")
        public static let color = NSLocalizedString("create_exercise.color", tableName: table, comment: "Color field")
        public static let preview = NSLocalizedString("create_exercise.preview", tableName: table, comment: "Preview section")
        public static let saveButton = NSLocalizedString("create_exercise.save", tableName: table, comment: "Save button")
        public static let cancelButton = NSLocalizedString("create_exercise.cancel", tableName: table, comment: "Cancel button")
        
        // Premium
        public static let unlimitedCustom = NSLocalizedString("create_exercise.unlimited_custom", tableName: table, comment: "Create unlimited custom exercises")
        
        // Form Fields
        public static let measuredIn = NSLocalizedString("create_exercise.measured_in", tableName: table, comment: "Measured In")
        public static let exerciseNamePlaceholder = NSLocalizedString("create_exercise.exercise_name_placeholder", tableName: table, comment: "Exercise Name placeholder")
        public static let startingValue = NSLocalizedString("create_exercise.starting_value", tableName: table, comment: "This is the starting value when logging")
        
        // Unit Type Descriptions
        public static let unitTypeReps = NSLocalizedString("create_exercise.unit_type_reps", tableName: table, comment: "Count repetitions (e.g., 10 pushups)")
        public static let unitTypeSeconds = NSLocalizedString("create_exercise.unit_type_seconds", tableName: table, comment: "Count seconds (e.g., 30 second plank)")
        public static let unitTypeMinutes = NSLocalizedString("create_exercise.unit_type_minutes", tableName: table, comment: "Count minutes (e.g., 15 minute walk)")
        
        // Buttons
        public static let updateExercise = NSLocalizedString("create_exercise.update_exercise", tableName: table, comment: "Update Exercise")
        public static let createExercise = NSLocalizedString("create_exercise.create_exercise", tableName: table, comment: "Create Exercise")
        public static let deleteExercise = NSLocalizedString("create_exercise.delete_exercise", tableName: table, comment: "Delete Exercise")
        public static let delete = NSLocalizedString("create_exercise.delete", tableName: table, comment: "Delete button in confirmation")
        
        // Delete Confirmation
        public static let deleteConfirmationTitle = NSLocalizedString("create_exercise.delete_confirmation_title", tableName: table, comment: "Delete Exercise? confirmation title")
        public static let deleteMessage = NSLocalizedString("create_exercise.delete_message", tableName: table, comment: "This will remove the exercise. Your logged data will be kept.")
        
        // Template Prompt
        public static let templatePromptTitle = NSLocalizedString("create_exercise.template_prompt_title", tableName: table, comment: "Create Achievement Template? alert title")
        public static let templateMessage = NSLocalizedString("create_exercise.template_message", tableName: table, comment: "Premium users can create achievement templates...")
        public static let notNow = NSLocalizedString("create_exercise.not_now", tableName: table, comment: "Not Now button")
        public static let learnMore = NSLocalizedString("create_exercise.learn_more", tableName: table, comment: "Learn More button")
        
        // Exercise List
        public static let exercises = NSLocalizedString("create_exercise.exercises", tableName: table, comment: "Exercises (navigation title)")
        public static let newExercise = NSLocalizedString("create_exercise.new_exercise", tableName: table, comment: "New Exercise (navigation title)")
        public static let builtIn = NSLocalizedString("create_exercise.built_in", tableName: table, comment: "Built-in section header")
        public static let custom = NSLocalizedString("create_exercise.custom", tableName: table, comment: "Custom section header")
        public static let addExercise = NSLocalizedString("create_exercise.add_exercise", tableName: table, comment: "Add Exercise button")
        public static let tapPlusCreate = NSLocalizedString("create_exercise.tap_plus_create", tableName: table, comment: "Tap + to create your own exercises")
    }

    // MARK: - Timeline

    public enum Timeline {
        private static let table = "Timeline"
        
        public static let title = NSLocalizedString("timeline.title", tableName: table, comment: "Timeline screen title")
        public static let notifications = NSLocalizedString("timeline.notifications", tableName: table, comment: "Notifications label")
        public static let exercises = NSLocalizedString("timeline.exercises", tableName: table, comment: "Exercises label")
        public static let correlation = NSLocalizedString("timeline.correlation", tableName: table, comment: "Correlation label")
        public static let noData = NSLocalizedString("timeline.no_data", tableName: table, comment: "No timeline data")
    }

    // MARK: - Premium/Paywall

    public enum Premium {
        private static let table = "Premium"
        
        public static let title = NSLocalizedString("premium.title", tableName: table, comment: "Premium screen title")
        public static let unlockPremium = NSLocalizedString("premium.unlock", tableName: table, comment: "Unlock premium button")
        public static let startFreeTrial = NSLocalizedString("premium.start_free_trial", tableName: table, comment: "Start free trial button")
        public static let restore = NSLocalizedString("premium.restore", tableName: table, comment: "Restore purchases button")
        public static let upgradeNow = NSLocalizedString("premium.upgrade_now", tableName: table, comment: "Upgrade now button")
        public static let premiumActive = NSLocalizedString("premium.active", tableName: table, comment: "Premium active status")
        public static let trialActive = NSLocalizedString("premium.trial_active", tableName: table, comment: "Trial active status")
        public static let limitedFeatures = NSLocalizedString("premium.limited_features", tableName: table, comment: "Limited features label")
        public static let allFeaturesUnlocked = NSLocalizedString("premium.all_features_unlocked", tableName: table, comment: "All features unlocked")
        
        // Features
        public static let featureCustomExercises = NSLocalizedString("premium.feature.custom_exercises", tableName: table, comment: "Custom exercises feature")
        public static let featureTemplates = NSLocalizedString("premium.feature.templates", tableName: table, comment: "Achievement templates feature")
        public static let featureAdvancedStats = NSLocalizedString("premium.feature.advanced_stats", tableName: table, comment: "Advanced statistics feature")
        public static let featureAchievementSystem = NSLocalizedString("premium.feature.achievement_system", tableName: table, comment: "Full Achievement System")
        public static let featureAdvancedAnalytics = NSLocalizedString("premium.feature.advanced_analytics", tableName: table, comment: "Advanced Analytics")
        public static let featureTimelineViz = NSLocalizedString("premium.feature.timeline", tableName: table, comment: "Timeline Visualization")
        public static let featureUnlimitedCustom = NSLocalizedString("premium.feature.unlimited_custom", tableName: table, comment: "Unlimited Custom Exercises")
        public static let featureExportData = NSLocalizedString("premium.feature.export", tableName: table, comment: "Export Your Data")
        public static let featureiCloudSync = NSLocalizedString("premium.feature.icloud", tableName: table, comment: "iCloud Sync")
        
        // Descriptions
        public static let featureAchievementSystemDesc = NSLocalizedString("premium.feature.achievement_system.desc", tableName: table, comment: "Unlock all badges, streaks, and challenges")
        public static let featureAdvancedAnalyticsDesc = NSLocalizedString("premium.feature.advanced_analytics.desc", tableName: table, comment: "30/60/90-day trends and insights")
        public static let featureTimelineVizDesc = NSLocalizedString("premium.feature.timeline.desc", tableName: table, comment: "See your response patterns over time")
        public static let featureUnlimitedCustomDesc = NSLocalizedString("premium.feature.unlimited_custom.desc", tableName: table, comment: "Create as many exercises as you need")
        public static let featureExportDataDesc = NSLocalizedString("premium.feature.export.desc", tableName: table, comment: "Download activity reports anytime")
        public static let featureiCloudSyncDesc = NSLocalizedString("premium.feature.icloud.desc", tableName: table, comment: "Backup and sync across devices")
        
        // Trial info
        public static let trialDuration = NSLocalizedString("premium.trial_duration", tableName: table, comment: "14-day free trial")
        public static let trialNoPayment = NSLocalizedString("premium.trial_no_payment", tableName: table, comment: "No payment required • Cancel anytime")
        public static let trialFreeDescription = NSLocalizedString("premium.trial_free_desc", tableName: table, comment: "14-day free trial • Cancel anytime")
        public static let subscriptionRenewNote = NSLocalizedString("premium.subscription_renew_note", tableName: table, comment: "Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
        
        // Trial status
        public static func daysRemaining(_ days: Int) -> String {
            String(format: NSLocalizedString("premium.days_remaining", tableName: table, comment: "X days remaining"), days)
        }
        
        public static func daysRemainingInTrial(_ days: Int) -> String {
            String(format: NSLocalizedString("premium.days_remaining_in_trial", tableName: table, comment: "X days remaining in trial"), days)
        }
        
        // Pricing
        public static let bestValue = NSLocalizedString("premium.best_value", tableName: table, comment: "BEST VALUE badge")
        public static let perMonth = NSLocalizedString("premium.per_month", tableName: table, comment: "/ month")
        public static let perYear = NSLocalizedString("premium.per_year", tableName: table, comment: "/ year")
        
        public static func saveAmount(_ amount: String) -> String {
            String(format: NSLocalizedString("premium.save_amount", tableName: table, comment: "Save X%"), amount)
        }
        
        // Unlock features
        public static let unlockAllFeatures = NSLocalizedString("premium.unlock_all_features", tableName: table, comment: "Unlock all features")
        public static let maximizeJourney = NSLocalizedString("premium.maximize_journey", tableName: table, comment: "Unlock all features and maximize your fitness journey")
        public static let upgradeKeepAchievements = NSLocalizedString("premium.upgrade_keep_achievements", tableName: table, comment: "Upgrade now to keep your achievements & stats")
        
        // PaywallView
        public static let navigationTitle = NSLocalizedString("premium.navigation_title", tableName: table, comment: "Premium navigation title")
        public static let closeButton = NSLocalizedString("premium.close_button", tableName: table, comment: "Close button")
        public static let bestValueBadge = NSLocalizedString("premium.best_value_badge", tableName: table, comment: "Best value badge text")
        public static let savePercentage = NSLocalizedString("premium.save_percentage", tableName: table, comment: "Save percentage text")
        public static let purchaseFailed = NSLocalizedString("premium.purchase_failed", tableName: table, comment: "Purchase failed error message")
        public static let premiumFeature = NSLocalizedString("premium.premium_feature", tableName: table, comment: "Premium feature title")
        
        // SubscriptionSettingsView
        public static let subscriptionStatus = NSLocalizedString("premium.subscription_status", tableName: table, comment: "Subscription Status")
        public static let getMore = NSLocalizedString("premium.get_more", tableName: table, comment: "Get More")
        public static let upgradeToPremium = NSLocalizedString("premium.upgrade_to_premium", tableName: table, comment: "Upgrade to Premium")
        public static let subscriptionNavigation = NSLocalizedString("premium.subscription_navigation", tableName: table, comment: "Subscription")
        public static let devModeTesting = NSLocalizedString("premium.dev_mode_testing", tableName: table, comment: "🧪 Developer Testing")
        public static let devModeFooter = NSLocalizedString("premium.dev_mode_footer", tableName: table, comment: "Dev mode simulates subscription states without real purchases. Perfect for testing paywalls and premium features during development.")
        public static let enableDevMode = NSLocalizedString("premium.enable_dev_mode", tableName: table, comment: "Enable Dev Mode")
        public static let simulateTier = NSLocalizedString("premium.simulate_tier", tableName: table, comment: "Simulate Tier")
        public static let freeTier = NSLocalizedString("premium.free_tier", tableName: table, comment: "Free")
        public static let premiumTier = NSLocalizedString("premium.premium_tier", tableName: table, comment: "Premium")
        public static let activeTrial = NSLocalizedString("premium.active_trial", tableName: table, comment: "Active Trial")
        
        public static func trialDaysFormat(_ days: Int) -> String {
            String(format: NSLocalizedString("premium.trial_days_format", tableName: table, comment: "Trial: %d days"), days)
        }
        
        public static func trialEnds(_ date: String) -> String {
            String(format: NSLocalizedString("premium.trial_ends", tableName: table, comment: "Trial ends: %@"), date)
        }
    }
    
    // MARK: - Schedule & Reminders
    
    public enum Schedule {
        private static let table = "Schedule"
        
        public static let title = NSLocalizedString("schedule.title", tableName: table, comment: "Schedule screen title")
        public static let reminderSchedule = NSLocalizedString("schedule.reminder_schedule", tableName: table, comment: "Reminder Schedule")
        public static let editSchedule = NSLocalizedString("schedule.edit_schedule", tableName: table, comment: "Edit Schedule")
        public static let schedule = NSLocalizedString("schedule.schedule", tableName: table, comment: "Schedule")
        public static let profiles = NSLocalizedString("schedule.profiles", tableName: table, comment: "Schedule Profiles")
        public static let everyday = NSLocalizedString("schedule.everyday", tableName: table, comment: "Everyday")
        public static let individualDays = NSLocalizedString("schedule.individual_days", tableName: table, comment: "Individual Days (Premium)")
        public static let timeBlocks = NSLocalizedString("schedule.time_blocks", tableName: table, comment: "Time Blocks")
        public static let fixedTimes = NSLocalizedString("schedule.fixed_times", tableName: table, comment: "Fixed Reminder Times")
        public static let addTimeBlock = NSLocalizedString("schedule.add_time_block", tableName: table, comment: "Add Time Block")
        public static let addFixedTime = NSLocalizedString("schedule.add_fixed_time", tableName: table, comment: "Add Fixed Time")
        public static let reminderInterval = NSLocalizedString("schedule.reminder_interval", tableName: table, comment: "Reminder Interval")
        public static let randomness = NSLocalizedString("schedule.randomness", tableName: table, comment: "Add Randomness")
        public static let startTime = NSLocalizedString("schedule.start_time", tableName: table, comment: "Start Time")
        public static let endTime = NSLocalizedString("schedule.end_time", tableName: table, comment: "End Time")
        public static let noReminders = NSLocalizedString("schedule.no_reminders", tableName: table, comment: "No reminders")
        public static let noTimeBlocks = NSLocalizedString("schedule.no_time_blocks", tableName: table, comment: "No Time Blocks")
        public static let noFixedTimes = NSLocalizedString("schedule.no_fixed_times", tableName: table, comment: "No Fixed Times")
        public static let preview = NSLocalizedString("schedule.preview", tableName: table, comment: "Preview")
        public static let createProfile = NSLocalizedString("schedule.create_profile", tableName: table, comment: "Create Profile")
        public static let newProfile = NSLocalizedString("schedule.new_profile", tableName: table, comment: "New Profile")
        public static let profileName = NSLocalizedString("schedule.profile_name", tableName: table, comment: "Profile Name")
        public static let switchProfile = NSLocalizedString("schedule.switch_profile", tableName: table, comment: "Switch Profile")
        public static let yourProfiles = NSLocalizedString("schedule.your_profiles", tableName: table, comment: "Your Profiles")
        public static let noProfiles = NSLocalizedString("schedule.no_profiles", tableName: table, comment: "No Profiles")
        public static let scheduling = NSLocalizedString("schedule.scheduling", tableName: table, comment: "Scheduling...")
        public static let activeProfile = NSLocalizedString("schedule.active_profile", tableName: table, comment: "Active Schedule Profile")
        public static let currentSchedule = NSLocalizedString("schedule.current_schedule", tableName: table, comment: "Current Schedule")
        
        // Day Schedule Editor
        public static let configureDailyReminder = NSLocalizedString("schedule.configure_daily_reminder", tableName: table, comment: "Configure your daily reminder schedule")
        public static let individualDaysPremium = NSLocalizedString("schedule.individual_days_premium", tableName: table, comment: "Individual Days (Premium)")
        public static let quickActions = NSLocalizedString("schedule.quick_actions", tableName: table, comment: "Quick Actions")
        public static let copyWeekdaysToWeekends = NSLocalizedString("schedule.copy_weekdays_to_weekends", tableName: table, comment: "Copy Weekdays to Weekends")
        public static let setAllDaysToMonday = NSLocalizedString("schedule.set_all_days_to_monday", tableName: table, comment: "Set All Days to Monday")
        public static let clearAllSchedules = NSLocalizedString("schedule.clear_all_schedules", tableName: table, comment: "Clear All Schedules")
        public static let weekOverview = NSLocalizedString("schedule.week_overview", tableName: table, comment: "Week Overview")
        public static let darkerBlueMoreFrequent = NSLocalizedString("schedule.darker_blue_more_frequent", tableName: table, comment: "Darker blue indicates more frequent reminders")
        public static let save = NSLocalizedString("schedule.save", tableName: table, comment: "Save")
        public static let cancel = NSLocalizedString("schedule.cancel", tableName: table, comment: "Cancel")
        
        // Time Block Editor
        public static let blockNamePlaceholder = NSLocalizedString("schedule.block_name_placeholder", tableName: table, comment: "Block Name (optional)")
        public static let nameSection = NSLocalizedString("schedule.name_section", tableName: table, comment: "Name")
        public static let nameExamples = NSLocalizedString("schedule.name_examples", tableName: table, comment: "e.g., 'Morning Focus', 'Work Hours', 'Evening Wind-Down'")
        public static let timeRange = NSLocalizedString("schedule.time_range", tableName: table, comment: "Time Range")
        public static let endAfterStartError = NSLocalizedString("schedule.end_after_start_error", tableName: table, comment: "End time must be after start time")
        public static let interval = NSLocalizedString("schedule.interval", tableName: table, comment: "Interval")
        public static let estimatedReminders = NSLocalizedString("schedule.estimated_reminders", tableName: table, comment: "Estimated Reminders")
        public static let notificationPeriodsPreview = NSLocalizedString("schedule.notification_periods_preview", tableName: table, comment: "Notification Periods (Preview)")
        public static let notificationPreview = NSLocalizedString("schedule.notification_preview", tableName: table, comment: "Notification Preview")
        public static let visualRepresentationFooter = NSLocalizedString("schedule.visual_representation_footer", tableName: table, comment: "Visual representation of when reminders will fire during this time block. Darker blue = more frequent.")
        public static let addRandomness = NSLocalizedString("schedule.add_randomness", tableName: table, comment: "Add Randomness")
        public static let preventsHabituation = NSLocalizedString("schedule.prevents_habituation", tableName: table, comment: "Prevents habituation by varying reminder times slightly")
        public static let advanced = NSLocalizedString("schedule.advanced", tableName: table, comment: "Advanced")
        public static let style = NSLocalizedString("schedule.style", tableName: table, comment: "Style")
        public static let notificationStyle = NSLocalizedString("schedule.notification_style", tableName: table, comment: "Notification Style")
        public static let standard = NSLocalizedString("schedule.standard", tableName: table, comment: "Standard")
        public static let gentleSilent = NSLocalizedString("schedule.gentle_silent", tableName: table, comment: "Gentle (Silent)")
        public static let urgent = NSLocalizedString("schedule.urgent", tableName: table, comment: "Urgent")
        public static let iconOptional = NSLocalizedString("schedule.icon_optional", tableName: table, comment: "Icon (Optional)")
        public static let none = NSLocalizedString("schedule.none", tableName: table, comment: "None")
        public static let timeBlock = NSLocalizedString("schedule.time_block", tableName: table, comment: "Time Block")
        
        public static let noRemindersConfigured = NSLocalizedString("schedule.no_reminders_configured", tableName: table, comment: "No reminders configured")
        public static let enableReminders = NSLocalizedString("schedule.enable_reminders", tableName: table, comment: "Enable Reminders")
        public static let whenEnabledFooter = NSLocalizedString("schedule.when_enabled_footer", tableName: table, comment: "When enabled, reminders will be active")
        public static let scheduleType = NSLocalizedString("schedule.schedule_type", tableName: table, comment: "Schedule Type")
        public static let timeBlocksOption = NSLocalizedString("schedule.time_blocks_option", tableName: table, comment: "Time Blocks option")
        public static let fixedTimesOption = NSLocalizedString("schedule.fixed_times_option", tableName: table, comment: "Fixed Times option")
        public static let useDefault = NSLocalizedString("schedule.use_default", tableName: table, comment: "Use Default")
        public static let everyDay = NSLocalizedString("schedule.every_day", tableName: table, comment: "Every Day")
        public static let dailyOverview = NSLocalizedString("schedule.daily_overview", tableName: table, comment: "Daily Overview")
        public static let appliesAllDays = NSLocalizedString("schedule.applies_all_days", tableName: table, comment: "This schedule will apply to all 7 days")
        public static let everydaySchedule = NSLocalizedString("schedule.everyday_schedule", tableName: table, comment: "Everyday Schedule")
        public static let time = NSLocalizedString("schedule.time", tableName: table, comment: "Time")
        public static let reminderTime = NSLocalizedString("schedule.reminder_time", tableName: table, comment: "Reminder Time")
        public static let setExactTime = NSLocalizedString("schedule.set_exact_time", tableName: table, comment: "Set the exact time")
        public static let add = NSLocalizedString("schedule.add", tableName: table, comment: "Add")
        public static let addTimeBlocksToDefine = NSLocalizedString("schedule.add_time_blocks_to_define", tableName: table, comment: "Add time blocks to define when reminders should occur")
        public static let addSpecificTimes = NSLocalizedString("schedule.add_specific_times", tableName: table, comment: "Add specific times for reminders")
        public static let defaultInterval = NSLocalizedString("schedule.default_interval", tableName: table, comment: "Default Interval")
        public static let noRemindersLabel = NSLocalizedString("schedule.no_reminders_label", tableName: table, comment: "No reminders")
        public static let dayOverview = NSLocalizedString("schedule.day_overview", tableName: table, comment: "Day Overview")
        public static let visualRepresentation = NSLocalizedString("schedule.visual_representation", tableName: table, comment: "Visual representation of your time blocks")
        
        public static func enableDayFormat(_ day: String) -> String {
            String(format: NSLocalizedString("schedule.enable_day_format", tableName: table, comment: "Enable X"), day)
        }
        
        public static func everyXMinutes(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule.every_x_m", tableName: table, comment: "Every X m"), minutes)
        }
        
        // Additional UI strings
        public static let fixedReminderTimes = NSLocalizedString("schedule.fixed_reminder_times", tableName: table, comment: "Fixed Reminder Times")
        public static let remindersOnlyDuringBlocks = NSLocalizedString("schedule.reminders_only_during_blocks", tableName: table, comment: "Reminders only during blocks")
        public static let whenEnabledRemindersActive = NSLocalizedString("schedule.when_enabled_reminders_active", tableName: table, comment: "When enabled reminders active")
        public static let upgradePremiumCustomDays = NSLocalizedString("schedule.upgrade_premium_custom_days", tableName: table, comment: "Upgrade to Premium")
        public static let visualRepresentationBlocks = NSLocalizedString("schedule.visual_representation_blocks", tableName: table, comment: "Visual representation")
        public static let darkerBlueTapCustomize = NSLocalizedString("schedule.darker_blue_tap_customize", tableName: table, comment: "Darker blue tap to customize")
        
        // Helper text
        public static let reminderIntervalFooter = NSLocalizedString("schedule.reminder_interval_footer", tableName: table, comment: "Reminders will use the profile's default interval throughout the day")
        public static let timeBlocksFooter = NSLocalizedString("schedule.time_blocks_footer", tableName: table, comment: "Reminders will only fire during these time blocks")
        public static let randomnessFooter = NSLocalizedString("schedule.randomness_footer", tableName: table, comment: "Prevents habituation by varying reminder times slightly")
        public static let individualDaysFooter = NSLocalizedString("schedule.individual_days_footer", tableName: table, comment: "Upgrade to Premium to customize each day individually with different time blocks and intervals.")
        public static let createFirstProfile = NSLocalizedString("schedule.create_first_profile", tableName: table, comment: "Create your first schedule profile to get started")
        public static let customizeAfterCreating = NSLocalizedString("schedule.customize_after_creating", tableName: table, comment: "You can customize the schedule after creating the profile")
        
        public static func nextReminder(_ time: String) -> String {
            String(format: NSLocalizedString("schedule.next_reminder", tableName: table, comment: "Next: X"), time)
        }
        
        public static func estimatedReminders(_ count: String) -> String {
            String(format: NSLocalizedString("schedule.estimated_reminders", tableName: table, comment: "Estimated Reminders"), count)
        }
        
        // Time Block Editor format strings
        public static func durationFormat(_ duration: String) -> String {
            String(format: NSLocalizedString("schedule.duration_format", tableName: table, comment: "Duration: %@"), duration)
        }
        
        public static func intervalMinFormat(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule.interval_min_format", tableName: table, comment: "%d min"), minutes)
        }
        
        public static func randomnessRangeFormat(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule.randomness_range_format", tableName: table, comment: "± %d minutes"), minutes)
        }
        
        public static func randomnessFooterFormat(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule.randomness_footer_format", tableName: table, comment: "Reminders will vary by ±%d minutes from the base interval"), minutes)
        }
        
        // Timeline Visualization strings
        public static let less = NSLocalizedString("schedule.less", tableName: table, comment: "Less")
        public static let more = NSLocalizedString("schedule.more", tableName: table, comment: "More")
        
        // Day abbreviations for timeline
        public static let daySun = NSLocalizedString("schedule.day_sun", tableName: table, comment: "Sun (Sunday abbreviation)")
        public static let dayMon = NSLocalizedString("schedule.day_mon", tableName: table, comment: "Mon (Monday abbreviation)")
        public static let dayTue = NSLocalizedString("schedule.day_tue", tableName: table, comment: "Tue (Tuesday abbreviation)")
        public static let dayWed = NSLocalizedString("schedule.day_wed", tableName: table, comment: "Wed (Wednesday abbreviation)")
        public static let dayThu = NSLocalizedString("schedule.day_thu", tableName: table, comment: "Thu (Thursday abbreviation)")
        public static let dayFri = NSLocalizedString("schedule.day_fri", tableName: table, comment: "Fri (Friday abbreviation)")
        public static let daySat = NSLocalizedString("schedule.day_sat", tableName: table, comment: "Sat (Saturday abbreviation)")
        
        public static func dayAbbreviation(_ index: Int) -> String {
            switch index {
            case 0: return daySun
            case 1: return dayMon
            case 2: return dayTue
            case 3: return dayWed
            case 4: return dayThu
            case 5: return dayFri
            case 6: return daySat
            default: return ""
            }
        }
    }
    
    // MARK: - Stats & Quick Actions
    
    public enum Stats {
        private static let table = "Stats"
        
        public static let todayActivity = NSLocalizedString("stats.today_activity", tableName: table, comment: "Today's Activity")
        public static let quickActions = NSLocalizedString("stats.quick_actions", tableName: table, comment: "Quick Actions")
        public static let quickLog = NSLocalizedString("stats.quick_log", tableName: table, comment: "Quick Log")
        public static let recentActivities = NSLocalizedString("stats.recent_activities", tableName: table, comment: "Recent Activities")
        public static let noActivityToday = NSLocalizedString("stats.no_activity_today", tableName: table, comment: "No activity today")
        public static let responseRate = NSLocalizedString("stats.response_rate", tableName: table, comment: "Response rate")
        public static let avgDaily = NSLocalizedString("stats.avg_daily", tableName: table, comment: "Avg. Daily Reminders")
        public static let currentStreak = NSLocalizedString("stats.current_streak", tableName: table, comment: "Current Streak")
        public static let level = NSLocalizedString("stats.level", tableName: table, comment: "Level")
        public static let keepMomentum = NSLocalizedString("stats.keep_momentum", tableName: table, comment: "Keep the momentum going!")
        public static let awesome = NSLocalizedString("stats.awesome", tableName: table, comment: "Awesome!")
        public static let trialEndingSoon = NSLocalizedString("stats.trial_ending_soon", tableName: table, comment: "Trial Ending Soon!")
        
        // ContentView strings
        public static let todaysLogs = NSLocalizedString("stats.todays_logs", tableName: table, comment: "Today's Logs")
        public static let unlocked = NSLocalizedString("stats.unlocked", tableName: table, comment: "Unlocked achievements")
        public static let now = NSLocalizedString("stats.now", tableName: table, comment: "Now!")
        
        // Heatmap strings
        public static let todaysActivity = NSLocalizedString("stats.todays_activity", tableName: table, comment: "Today's Activity")
        public static let notifications = NSLocalizedString("stats.notifications", tableName: table, comment: "Notifications")
        public static let exercises = NSLocalizedString("stats.exercises", tableName: table, comment: "Exercises")
        public static let none = NSLocalizedString("stats.none", tableName: table, comment: "None")
        public static let low = NSLocalizedString("stats.low", tableName: table, comment: "Low")
        public static let medium = NSLocalizedString("stats.medium", tableName: table, comment: "Medium")
        public static let high = NSLocalizedString("stats.high", tableName: table, comment: "High")
        
        public static func dayStreak(_ days: Int) -> String {
            String(format: NSLocalizedString("stats.day_streak", tableName: table, comment: "X day streak"), days)
        }
        
        public static func exercisesLogged(_ count: Int) -> String {
            String(format: NSLocalizedString("stats.exercises_logged", tableName: table, comment: "X exercise(s) logged"), count)
        }
        
        public static func totalExercises(_ count: Int) -> String {
            String(format: NSLocalizedString("stats.total_exercises", tableName: table, comment: "Total: X exercises"), count)
        }
        
        public static func levelFormat(_ level: Int) -> String {
            String(format: NSLocalizedString("stats.level_format", tableName: table, comment: "Level X"), level)
        }
        
        public static func xpFormat(_ current: Int, _ needed: Int) -> String {
            String(format: NSLocalizedString("stats.xp_format", tableName: table, comment: "X / Y XP"), current, needed)
        }
        
        public static func todayAt(_ time: String) -> String {
            String(format: NSLocalizedString("stats.today_at", tableName: table, comment: "Today at"), time)
        }
        
        public static func tomorrowAt(_ time: String) -> String {
            String(format: NSLocalizedString("stats.tomorrow_at", tableName: table, comment: "Tomorrow at"), time)
        }
        
        public static func weekdayAt(_ weekday: String, _ time: String) -> String {
            String(format: NSLocalizedString("stats.weekday_at", tableName: table, comment: "Weekday at"), weekday, time)
        }
        
        // StatsHeaderView strings
        public static let rep = NSLocalizedString("stats.rep", tableName: table, comment: "rep (singular)")
        public static let reps = NSLocalizedString("stats.reps", tableName: table, comment: "reps (plural)")
        public static let vsPreviousPeriod = NSLocalizedString("stats.vs_previous_period", tableName: table, comment: "vs previous period")
        
        // TimelineGraphView strings
        public static let timeline = NSLocalizedString("stats.timeline", tableName: table, comment: "Timeline")
        
        public static func minAvg(_ minutes: Int) -> String {
            String(format: NSLocalizedString("stats.min_avg", tableName: table, comment: "%dmin avg"), minutes)
        }
        
        public static func responseRatePercent(_ percent: Int) -> String {
            String(format: NSLocalizedString("stats.response_rate_percent", tableName: table, comment: "%d%% response rate"), percent)
        }
    }
    
    // MARK: - Progress Report
    
    public enum ProgressReport {
        private static let table = "ProgressReport"
        
        public static let periodLabel = NSLocalizedString("progress_report.period_label", tableName: table, comment: "Label for period picker")
        public static let today = NSLocalizedString("progress_report.today", tableName: table, comment: "Today period option")
        public static let week = NSLocalizedString("progress_report.week", tableName: table, comment: "Week period option")
        public static let month = NSLocalizedString("progress_report.month", tableName: table, comment: "Month period option")
        public static let weekLocked = NSLocalizedString("progress_report.week_locked", tableName: table, comment: "Week period option (locked)")
        public static let monthLocked = NSLocalizedString("progress_report.month_locked", tableName: table, comment: "Month period option (locked)")
        public static let navigationTitle = NSLocalizedString("progress_report.navigation_title", tableName: table, comment: "Navigation title for progress report")
        public static let doneButton = NSLocalizedString("progress_report.done_button", tableName: table, comment: "Done button text")
        public static let noActivityLogged = NSLocalizedString("progress_report.no_activity_logged", tableName: table, comment: "Empty state title")
        public static let emptyToday = NSLocalizedString("progress_report.empty_today", tableName: table, comment: "Empty state message for today")
        public static let emptyWeek = NSLocalizedString("progress_report.empty_week", tableName: table, comment: "Empty state message for week")
        public static let emptyMonth = NSLocalizedString("progress_report.empty_month", tableName: table, comment: "Empty state message for month")
    }
    
    // MARK: - Progress Report Settings
    
    public enum ProgressReportSettings {
        private static let table = "ProgressReportSettings"
        
        public static let enabledLabel = NSLocalizedString("progress_report_settings.enabled_label", tableName: table, comment: "Label for progress reports toggle")
        public static let enabledFooter = NSLocalizedString("progress_report_settings.enabled_footer", tableName: table, comment: "Footer text explaining progress reports")
        public static let frequencyLabel = NSLocalizedString("progress_report_settings.frequency_label", tableName: table, comment: "Label for frequency picker")
        public static let scheduleHeader = NSLocalizedString("progress_report_settings.schedule_header", tableName: table, comment: "Section header for schedule settings")
        public static let hourLabel = NSLocalizedString("progress_report_settings.hour_label", tableName: table, comment: "Label for hour picker")
        public static let minuteLabel = NSLocalizedString("progress_report_settings.minute_label", tableName: table, comment: "Label for minute picker")
        public static let timeHeader = NSLocalizedString("progress_report_settings.time_header", tableName: table, comment: "Section header for time settings")
        public static let navigationTitle = NSLocalizedString("progress_report_settings.navigation_title", tableName: table, comment: "Navigation title for progress report settings screen")
        public static let saveButton = NSLocalizedString("progress_report_settings.save_button", tableName: table, comment: "Save button text")
        
        public static func timeFooter(hour: String, minute: String, frequency: String) -> String {
            String(format: NSLocalizedString("progress_report_settings.time_footer", tableName: table, comment: "Footer text showing when reports will be sent"), hour, minute, frequency)
        }
    }
    
    // MARK: - Reminder Schedule
    
    public enum ReminderSchedule {
        private static let table = "ReminderSchedule"
        
        public static let navigationTitle = NSLocalizedString("reminder_schedule.navigation_title", tableName: table, comment: "Navigation title for reminder schedule view")
        public static let editSchedule = NSLocalizedString("reminder_schedule.edit_schedule", tableName: table, comment: "Edit schedule button label")
        public static let switchProfile = NSLocalizedString("reminder_schedule.switch_profile", tableName: table, comment: "Switch profile button label")
        public static let createScheduleProfile = NSLocalizedString("reminder_schedule.create_schedule_profile", tableName: table, comment: "Create schedule profile button label")
        public static let activeScheduleProfile = NSLocalizedString("reminder_schedule.active_schedule_profile", tableName: table, comment: "Active schedule profile section header")
        public static let profileFooter = NSLocalizedString("reminder_schedule.profile_footer", tableName: table, comment: "Profile section footer text")
        public static let nextReminder = NSLocalizedString("reminder_schedule.next_reminder", tableName: table, comment: "Next reminder label")
        public static let noReminderScheduled = NSLocalizedString("reminder_schedule.no_reminder_scheduled", tableName: table, comment: "No reminder scheduled message")
        public static let scheduleSummary = NSLocalizedString("reminder_schedule.schedule_summary", tableName: table, comment: "Schedule summary label")
        public static let activeDays = NSLocalizedString("reminder_schedule.active_days", tableName: table, comment: "Active days label")
        public static let avgDailyReminders = NSLocalizedString("reminder_schedule.avg_daily_reminders", tableName: table, comment: "Average daily reminders label")
        public static let deadResponse = NSLocalizedString("reminder_schedule.dead_response", tableName: table, comment: "Dead response label")
        public static let off = NSLocalizedString("reminder_schedule.off", tableName: table, comment: "Off status")
        public static let currentSchedule = NSLocalizedString("reminder_schedule.current_schedule", tableName: table, comment: "Current schedule section header")
        public static let scheduleFooter = NSLocalizedString("reminder_schedule.schedule_footer", tableName: table, comment: "Schedule section footer text")
        public static let todayAt = NSLocalizedString("reminder_schedule.today_at", tableName: table, comment: "Today at time format")
        public static let tomorrowAt = NSLocalizedString("reminder_schedule.tomorrow_at", tableName: table, comment: "Tomorrow at time format")
        public static let weekdayAt = NSLocalizedString("reminder_schedule.weekday_at", tableName: table, comment: "Weekday at time format")
        public static let yourProfiles = NSLocalizedString("reminder_schedule.your_profiles", tableName: table, comment: "Your profiles section header")
        public static let noProfiles = NSLocalizedString("reminder_schedule.no_profiles", tableName: table, comment: "No profiles title")
        public static let createFirstProfile = NSLocalizedString("reminder_schedule.create_first_profile", tableName: table, comment: "Create first profile description")
        public static let createCustomProfile = NSLocalizedString("reminder_schedule.create_custom_profile", tableName: table, comment: "Create custom profile button")
        public static let createFromTemplate = NSLocalizedString("reminder_schedule.create_from_template", tableName: table, comment: "Create from template button")
        public static let addNewProfile = NSLocalizedString("reminder_schedule.add_new_profile", tableName: table, comment: "Add new profile section header")
        public static let scheduleProfiles = NSLocalizedString("reminder_schedule.schedule_profiles", tableName: table, comment: "Schedule profiles navigation title")
        public static let doneButton = NSLocalizedString("reminder_schedule.done_button", tableName: table, comment: "Done button")
        public static let lastUsed = NSLocalizedString("reminder_schedule.last_used", tableName: table, comment: "Last used label")
        public static let ago = NSLocalizedString("reminder_schedule.ago", tableName: table, comment: "Ago suffix for relative time")
        public static let chooseTemplate = NSLocalizedString("reminder_schedule.choose_template", tableName: table, comment: "Choose template navigation title")
        public static let cancelButton = NSLocalizedString("reminder_schedule.cancel_button", tableName: table, comment: "Cancel button")
        public static let profileName = NSLocalizedString("reminder_schedule.profile_name", tableName: table, comment: "Profile name text field placeholder")
        public static let nameYourProfile = NSLocalizedString("reminder_schedule.name_your_profile", tableName: table, comment: "Name your profile section header")
        public static let preview = NSLocalizedString("reminder_schedule.preview", tableName: table, comment: "Preview label")
        public static let createProfile = NSLocalizedString("reminder_schedule.create_profile", tableName: table, comment: "Create profile navigation title")
        public static let createButton = NSLocalizedString("reminder_schedule.create_button", tableName: table, comment: "Create button")
        public static let profileDetails = NSLocalizedString("reminder_schedule.profile_details", tableName: table, comment: "Profile details section header")
        public static let customizeAfterCreating = NSLocalizedString("reminder_schedule.customize_after_creating", tableName: table, comment: "Customize after creating footer")
        public static let newProfile = NSLocalizedString("reminder_schedule.new_profile", tableName: table, comment: "New profile navigation title")
        
        public static func daysCount(_ count: Int) -> String {
            String(format: NSLocalizedString("reminder_schedule.days_count", tableName: table, comment: "Days count format"), count)
        }
        
        public static func minutesFormat(_ minutes: Int) -> String {
            String(format: NSLocalizedString("reminder_schedule.minutes_format", tableName: table, comment: "Minutes format"), minutes)
        }
        
        public static func basedOnTemplate(_ name: String) -> String {
            String(format: NSLocalizedString("reminder_schedule.based_on_template", tableName: table, comment: "Based on template footer format"), name)
        }
    }
    
    // MARK: - Common UI Elements
    
    public enum UI {
        private static let table = "UI"
        
        public static let search = NSLocalizedString("ui.search", tableName: table, comment: "Search")
        public static let searchExercises = NSLocalizedString("ui.search_exercises", tableName: table, comment: "Search exercises...")
        public static let selectExercise = NSLocalizedString("ui.select_exercise", tableName: table, comment: "Select Exercise")
        public static let selectIcon = NSLocalizedString("ui.select_icon", tableName: table, comment: "Select Icon")
        public static let changeIcon = NSLocalizedString("ui.change_icon", tableName: table, comment: "Change Icon")
        public static let whatDidYouDo = NSLocalizedString("ui.what_did_you_do", tableName: table, comment: "What did you do?")
        public static let adjustCountAndSave = NSLocalizedString("ui.adjust_count_save", tableName: table, comment: "Adjust count and save")
        public static let tapToLog = NSLocalizedString("ui.tap_to_log", tableName: table, comment: "Tap an exercise to log it")
        public static let selectToLog = NSLocalizedString("ui.select_to_log", tableName: table, comment: "Select an exercise to log your activity")
        public static let noExercisesYet = NSLocalizedString("ui.no_exercises_yet", tableName: table, comment: "No Exercises Yet")
        public static let tapPlusCreate = NSLocalizedString("ui.tap_plus_create", tableName: table, comment: "Tap + to create your own exercises")
        public static let tryAdjustSearch = NSLocalizedString("ui.try_adjust_search", tableName: table, comment: "Try adjusting your search")
        public static let noExercisesFound = NSLocalizedString("ui.no_exercises_found", tableName: table, comment: "No exercises found")
        public static let recent = NSLocalizedString("ui.recent", tableName: table, comment: "Recent")
        public static let builtInExercises = NSLocalizedString("ui.built_in_exercises", tableName: table, comment: "Built-in Exercises")
        public static let customExercises = NSLocalizedString("ui.custom_exercises", tableName: table, comment: "Custom Exercises")
        public static let icon = NSLocalizedString("ui.icon", tableName: table, comment: "Icon")
        public static let iconOptional = NSLocalizedString("ui.icon_optional", tableName: table, comment: "Icon (Optional)")
        public static let name = NSLocalizedString("ui.name", tableName: table, comment: "Name")
        public static let count = NSLocalizedString("ui.count", tableName: table, comment: "Count")
        public static let logged = NSLocalizedString("ui.logged", tableName: table, comment: "Logged!")
        public static let create = NSLocalizedString("ui.create", tableName: table, comment: "Create")
        public static let add = NSLocalizedString("ui.add", tableName: table, comment: "Add")
        public static let notNow = NSLocalizedString("ui.not_now", tableName: table, comment: "Not Now")
        public static let learnMore = NSLocalizedString("ui.learn_more", tableName: table, comment: "Learn More")
        public static let getMore = NSLocalizedString("ui.get_more", tableName: table, comment: "Get More")
        public static let change = NSLocalizedString("ui.change", tableName: table, comment: "Change")
        public static let more = NSLocalizedString("ui.more", tableName: table, comment: "More")
        public static let less = NSLocalizedString("ui.less", tableName: table, comment: "Less")
        public static let today = NSLocalizedString("ui.today", tableName: table, comment: "Today")
        public static let version = NSLocalizedString("ui.version", tableName: table, comment: "Version")
        public static let about = NSLocalizedString("ui.about", tableName: table, comment: "About")
        public static let premium = NSLocalizedString("ui.premium", tableName: table, comment: "Premium")
        public static let custom = NSLocalizedString("ui.custom", tableName: table, comment: "Custom")
        public static let selected = NSLocalizedString("ui.selected", tableName: table, comment: "Selected:")
        public static let done = NSLocalizedString("ui.done", tableName: table, comment: "Done")
    }
}
