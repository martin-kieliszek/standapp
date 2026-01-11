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
        public static let mascotName = NSLocalizedString("mascot.name", tableName: table, comment: "Mascot name")
        public static let mascotGreeting = NSLocalizedString("mascot.greeting", tableName: table, comment: "Mascot greeting")
        public static let mascotEncouragement = NSLocalizedString("mascot.encouragement", tableName: table, comment: "Mascot encouragement")
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

        // Mascot messages (shown on the main screen)
        public static let mascotPositive01 = NSLocalizedString("main.mascot_positive_01", tableName: table, comment: "Mascot positive reinforcement 1")
        public static let mascotPositive02 = NSLocalizedString("main.mascot_positive_02", tableName: table, comment: "Mascot positive reinforcement 2")
        public static let mascotPositive03 = NSLocalizedString("main.mascot_positive_03", tableName: table, comment: "Mascot positive reinforcement 3")
        public static let mascotPositive04 = NSLocalizedString("main.mascot_positive_04", tableName: table, comment: "Mascot positive reinforcement 4")
        public static let mascotPositive05 = NSLocalizedString("main.mascot_positive_05", tableName: table, comment: "Mascot positive reinforcement 5")
        public static let mascotPositive06 = NSLocalizedString("main.mascot_positive_06", tableName: table, comment: "Mascot positive reinforcement 6")
        public static let mascotPositive07 = NSLocalizedString("main.mascot_positive_07", tableName: table, comment: "Mascot positive reinforcement 7")
        public static let mascotPositive08 = NSLocalizedString("main.mascot_positive_08", tableName: table, comment: "Mascot positive reinforcement 8")
        public static let mascotPositive09 = NSLocalizedString("main.mascot_positive_09", tableName: table, comment: "Mascot positive reinforcement 9")
        public static let mascotPositive10 = NSLocalizedString("main.mascot_positive_10", tableName: table, comment: "Mascot positive reinforcement 10")

        public static let mascotMotivation01 = NSLocalizedString("main.mascot_motivation_01", tableName: table, comment: "Mascot motivational suggestion 1")
        public static let mascotMotivation02 = NSLocalizedString("main.mascot_motivation_02", tableName: table, comment: "Mascot motivational suggestion 2")
        public static let mascotMotivation03 = NSLocalizedString("main.mascot_motivation_03", tableName: table, comment: "Mascot motivational suggestion 3")
        public static let mascotMotivation04 = NSLocalizedString("main.mascot_motivation_04", tableName: table, comment: "Mascot motivational suggestion 4")
        public static let mascotMotivation05 = NSLocalizedString("main.mascot_motivation_05", tableName: table, comment: "Mascot motivational suggestion 5")
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
        public static let custom = NSLocalizedString("settings.custom", tableName: table, comment: "Custom (lowercase label)")

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
        
        // Focus Mode warnings
        public static let focusModes = NSLocalizedString("settings.focus_modes", tableName: table, comment: "Focus Modes label")
        public static let focusMaySilence = NSLocalizedString("settings.focus_may_silence", tableName: table, comment: "Reminders may be silenced when a Focus is active")
        public static let focusCheckSettings = NSLocalizedString("settings.focus_check_settings", tableName: table, comment: "Check Settings > Focus to allow StandFit notifications")
        public static let focusActiveBanner = NSLocalizedString("settings.focus_active_banner", tableName: table, comment: "Focus Mode active - reminders may be silenced")
        
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

        // Notification titles
        public static let exerciseReminder = NSLocalizedString("notification.exercise_reminder", tableName: table, comment: "Exercise reminder title")
        public static let timeToMoveTitle = NSLocalizedString("notification.time_to_move_title", tableName: table, comment: "Time to Move! title")
        public static let stillThereTitle = NSLocalizedString("notification.still_there_title", tableName: table, comment: "Still there? title")
        public static let progressReport = NSLocalizedString("notification.progress_report", tableName: table, comment: "Progress report title")
        public static let achievementUnlocked = NSLocalizedString("notification.achievement_unlocked", tableName: table, comment: "Achievement unlocked title")
        public static let achievementUnlockedWithTrophy = NSLocalizedString("notification.achievement_unlocked_with_trophy", tableName: table, comment: "Achievement unlocked with trophy emoji")

        // Notification bodies
        public static let timeToExercise = NSLocalizedString("notification.time_to_exercise", tableName: table, comment: "Time to exercise message")
        public static let standUpExerciseBody = NSLocalizedString("notification.stand_up_exercise_body", tableName: table, comment: "Stand up and do some quick exercises")
        public static let stillThere = NSLocalizedString("notification.still_there", tableName: table, comment: "Dead response follow-up")
        public static let missedReminderBody = NSLocalizedString("notification.missed_reminder_body", tableName: table, comment: "Missed reminder body message")

        // Action buttons
        public static let actionLog = NSLocalizedString("notification.action_log", tableName: table, comment: "Log exercise action")
        public static let actionLogExercise = NSLocalizedString("notification.action_log_exercise", tableName: table, comment: "Log Exercise action button")
        public static let actionSnooze = NSLocalizedString("notification.action_snooze", tableName: table, comment: "Snooze action")
        public static let actionSnooze5Min = NSLocalizedString("notification.action_snooze_5min", tableName: table, comment: "Snooze 5 min action button")
        public static let actionDismiss = NSLocalizedString("notification.action_dismiss", tableName: table, comment: "Dismiss action")
        public static let actionView = NSLocalizedString("notification.action_view", tableName: table, comment: "View action")
        public static let actionViewDetails = NSLocalizedString("notification.action_view_details", tableName: table, comment: "View Details action button")
        public static let actionViewAll = NSLocalizedString("notification.action_view_all", tableName: table, comment: "View All action button")
        public static let resetTimer = NSLocalizedString("notification.reset_timer", tableName: table, comment: "Reset Timer button")
        public static let snooze1Min = NSLocalizedString("notification.snooze_1min", tableName: table, comment: "Snooze for 1 minute")
        public static let snooze5Min = NSLocalizedString("notification.snooze_5min", tableName: table, comment: "Snooze for 5 minutes")

        // Format strings
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
        public static let selectColor = NSLocalizedString("create_exercise.select_color", tableName: table, comment: "Select Color")
        public static let colorPreview = NSLocalizedString("create_exercise.color_preview", tableName: table, comment: "Color preview")
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

        // Basic strings
        public static let title = NSLocalizedString("premium.title", tableName: table, comment: "StandFit Premium")
        public static let unlockAll = NSLocalizedString("premium.unlock_all", tableName: table, comment: "Unlock all premium features")
        public static let allFeaturesUnlocked = unlockAll  // Alias for consistency
        public static let unlockAllFeatures = unlockAll  // Another alias
        public static let unlockPremium = unlockAll  // Another alias
        public static let limitedFeatures = NSLocalizedString("premium.limited_features", tableName: table, comment: "Free tier label")
        public static let premiumActive = NSLocalizedString("premium.premium_active", tableName: table, comment: "Premium active status")
        public static let maximizeJourney = unlockAll  // Placeholder - use unlockAll text
        public static let startFreeTrial = NSLocalizedString("premium.start_free_trial", tableName: table, comment: "Start Free Trial")
        public static let restorePurchases = NSLocalizedString("premium.restore_purchases", tableName: table, comment: "Restore Purchases")
        public static let restore = restorePurchases  // Alias
        public static let subscribe = NSLocalizedString("premium.subscribe", tableName: table, comment: "Subscribe")
        public static let cancelAnytime = NSLocalizedString("premium.cancel_anytime", tableName: table, comment: "Cancel anytime")
        public static let privacyPolicy = NSLocalizedString("premium.privacy_policy", tableName: table, comment: "Privacy Policy")
        public static let termsOfUse = NSLocalizedString("premium.terms_of_use", tableName: table, comment: "Terms of Use")
        public static let trialDuration = freeTrial(14)  // Default 14-day trial
        public static let trialNoPayment = cancelAnytime  // Alias
        public static let subscriptionRenewNote = NSLocalizedString("premium.subscription_renew_note", tableName: table, comment: "Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
        public static let upgradeKeepAchievements = NSLocalizedString("premium.upgrade_keep_achievements", tableName: table, comment: "Upgrade now to keep your achievements & stats")

        // Features
        public static let customExercises = NSLocalizedString("premium.custom_exercises", tableName: table, comment: "Create custom exercises")
        public static let featureAchievements = NSLocalizedString("premium.feature_achievements", tableName: table, comment: "Track achievements")
        public static let featureAchievementSystem = featureAchievements  // Alias
        public static let featureAdvancedStats = NSLocalizedString("premium.feature_advanced_stats", tableName: table, comment: "Advanced statistics")
        public static let featureAdvancedAnalytics = featureAdvancedStats  // Alias
        public static let featureCustomTemplates = NSLocalizedString("premium.feature_custom_templates", tableName: table, comment: "Custom achievement templates")
        public static let featureProgressReports = NSLocalizedString("premium.feature_progress_reports", tableName: table, comment: "Progress reports")
        public static let featureUnlimitedExercises = NSLocalizedString("premium.feature_unlimited_exercises", tableName: table, comment: "Unlimited custom exercises")
        public static let featureUnlimitedCustom = featureUnlimitedExercises  // Alias
        public static let featureUnlimitedProfiles = NSLocalizedString("premium.feature_unlimited_profiles", tableName: table, comment: "Unlimited schedule profiles")
        public static let featureTimelineViz = NSLocalizedString("premium.feature_timeline_viz", tableName: table, comment: "Timeline Visualization")
        public static let featureWeeklyInsights = NSLocalizedString("premium.feature_weekly_insights", tableName: table, comment: "Weekly Insights")
        public static let featureCustomGoals = NSLocalizedString("premium.feature_custom_goals", tableName: table, comment: "Custom Goals & Achievements")
        public static let featureExportData = NSLocalizedString("premium.feature_export_data", tableName: table, comment: "Export Your Data")
        public static let featureiCloudSync = NSLocalizedString("premium.feature_icloud_sync", tableName: table, comment: "iCloud Sync")

        // Feature Descriptions
        public static let featureAchievementSystemDesc = NSLocalizedString("premium.feature_achievement_system_desc", tableName: table, comment: "Unlock all badges, streaks, and challenges")
        public static let featureAdvancedAnalyticsDesc = NSLocalizedString("premium.feature_advanced_analytics_desc", tableName: table, comment: "30/60/90-day trends and insights")
        public static let featureWeeklyInsightsDesc = NSLocalizedString("premium.feature_weekly_insights_desc", tableName: table, comment: "Get personalized weekly progress reports")
        public static let featureCustomGoalsDesc = NSLocalizedString("premium.feature_custom_goals_desc", tableName: table, comment: "Create your own goals and achievement milestones")
        public static let featureTimelineVizDesc = NSLocalizedString("premium.feature_timeline_viz_desc", tableName: table, comment: "See your response patterns over time")
        public static let featureUnlimitedCustomDesc = NSLocalizedString("premium.feature_unlimited_custom_desc", tableName: table, comment: "Create as many exercises as you need")
        public static let featureExportDataDesc = NSLocalizedString("premium.feature_export_data_desc", tableName: table, comment: "Download activity reports anytime")
        public static let featureiCloudSyncDesc = NSLocalizedString("premium.feature_icloud_sync_desc", tableName: table, comment: "Backup and sync across devices")

        // Pricing & Format strings
        public static let perMonth = NSLocalizedString("premium.per_month", tableName: table, comment: "/ month")
        public static let perYear = NSLocalizedString("premium.per_year", tableName: table, comment: "/ year")
        public static let savePercentage = NSLocalizedString("premium.save_percentage", tableName: table, comment: "Save 37%")
        public static let bestValueBadge = NSLocalizedString("premium.best_value_badge", tableName: table, comment: "BEST VALUE")

        public static func freeTrial(_ days: Int) -> String {
            String(format: NSLocalizedString("premium.free_trial", tableName: table, comment: "X-day free trial"), days)
        }

        public static func monthlyPrice(_ price: String) -> String {
            String(format: NSLocalizedString("premium.monthly_price", tableName: table, comment: "X / month"), price)
        }

        public static func yearlyPrice(_ price: String) -> String {
            String(format: NSLocalizedString("premium.yearly_price", tableName: table, comment: "X / year"), price)
        }

        // PaywallView
        public static let navigationTitle = NSLocalizedString("premium.navigation_title", tableName: table, comment: "Premium")
        public static let closeButton = NSLocalizedString("premium.close_button", tableName: table, comment: "Close")
        public static let premiumFeature = NSLocalizedString("premium.premium_feature", tableName: table, comment: "Premium Feature")
        public static let purchaseFailed = NSLocalizedString("premium.purchase_failed", tableName: table, comment: "Purchase failed. Please try again.")

        // SubscriptionSettingsView
        public static let subscriptionStatus = NSLocalizedString("premium.subscription_status", tableName: table, comment: "Subscription Status")
        public static let getMore = NSLocalizedString("premium.get_more", tableName: table, comment: "Get More")
        public static let upgradeToPremium = NSLocalizedString("premium.upgrade_to_premium", tableName: table, comment: "Upgrade to Premium")
        public static let subscriptionNavigation = NSLocalizedString("premium.subscription_navigation", tableName: table, comment: "Subscription")

        // Developer Mode
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

        // Helper functions for trial days remaining
        public static func daysRemainingInTrial(_ days: Int) -> String {
            return trialDaysFormat(days)
        }

        public static func daysRemaining(_ days: Int) -> String {
            return trialDaysFormat(days)
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
        public static let scheduling = NSLocalizedString("schedule.scheduling", tableName: table, comment: "Prompt to set a reminder schedule")
        public static let activeProfile = NSLocalizedString("schedule.active_profile", tableName: table, comment: "Active Schedule Profile")
        public static let currentSchedule = NSLocalizedString("schedule.current_schedule", tableName: table, comment: "Current Schedule")
        public static let defaultProfile = NSLocalizedString("schedule.default_profile", tableName: table, comment: "Default profile name")
        
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

        // Schedule Profile Summary
        public static let noActiveDays = NSLocalizedString("schedule.no_active_days", tableName: table, comment: "No active days")

        public static func everyDayRemindersPerDay(_ reminders: Int) -> String {
            String(format: NSLocalizedString("schedule.every_day_reminders_per_day", tableName: table, comment: "Every day, X reminders/day"), reminders)
        }

        public static func daysRemindersPerDay(_ days: String, _ reminders: Int) -> String {
            String(format: NSLocalizedString("schedule.days_reminders_per_day", tableName: table, comment: "X, Y reminders/day"), days, reminders)
        }

        // DayScheduleEditorView strings
        public static let minutePicker = NSLocalizedString("schedule.minute_picker", tableName: table, comment: "Minute picker label")
        public static let addTimeBlockButton = NSLocalizedString("schedule.add_time_block_button", tableName: table, comment: "Add Time Block button")
        public static let timeBlocksHeader = NSLocalizedString("schedule.time_blocks_header", tableName: table, comment: "Time Blocks section header")
        public static let remindersOnlyDuringBlocksFooter = NSLocalizedString("schedule.reminders_only_during_blocks_footer", tableName: table, comment: "Reminders only fire during these time blocks")
        public static let noFixedTimesTitle = NSLocalizedString("schedule.no_fixed_times_title", tableName: table, comment: "No Fixed Times title")
        public static let addSpecificTimesDescription = NSLocalizedString("schedule.add_specific_times_description", tableName: table, comment: "Add specific times for reminders")
        public static let minSuffix = NSLocalizedString("schedule.min_suffix", tableName: table, comment: " min suffix")

        public static func everyMinutesShort(_ minutes: Int) -> String {
            String(format: NSLocalizedString("schedule.every_minutes_short", tableName: table, comment: "Every Xm"), minutes)
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
        
        // XP earned popup
        public static func xpEarned(_ amount: Int) -> String {
            String(format: NSLocalizedString("stats.xp_earned", tableName: table, comment: "+X XP earned"), amount)
        }
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
        public static let weeklyScheduleDay = NSLocalizedString("progress_report_settings.weekly_schedule_day", tableName: table, comment: "Day for weekly progress reports")
        public static let weeklyScheduleFooter = NSLocalizedString("progress_report_settings.weekly_schedule_footer", tableName: table, comment: "Footer explaining weekly insights schedule")
        
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
    
    // MARK: - Reporting
    
    public enum Reporting {
        private static let table = "Reporting"
        
        public static let today = NSLocalizedString("reporting.today", tableName: table, comment: "Today")
        public static let yesterday = NSLocalizedString("reporting.yesterday", tableName: table, comment: "Yesterday")
        public static let daily = NSLocalizedString("reporting.daily", tableName: table, comment: "Daily")
        public static let weekly = NSLocalizedString("reporting.weekly", tableName: table, comment: "Weekly")
        public static let progressReportTitle = NSLocalizedString("reporting.progress_report_title", tableName: table, comment: "Progress Report")
        public static let timeframeToday = NSLocalizedString("reporting.timeframe_today", tableName: table, comment: "today")
        public static let timeframeThisWeek = NSLocalizedString("reporting.timeframe_this_week", tableName: table, comment: "this week")
        
        public static func weekOf(_ date: String) -> String {
            String(format: NSLocalizedString("reporting.week_of", tableName: table, comment: "Week of %@"), date)
        }
        
        public static func exercisesLogged(count: Int, plural: String, timeframe: String) -> String {
            String(format: NSLocalizedString("reporting.exercises_logged", tableName: table, comment: "You logged %d exercise(s) %@"), count, plural, timeframe)
        }
        
        public static func comparisonVsLast(arrow: String, percent: Int, timeframe: String) -> String {
            String(format: NSLocalizedString("reporting.comparison_vs_last", tableName: table, comment: "%@%d%% vs last %@"), arrow, percent, timeframe)
        }
        
        public static func streakDays(_ days: Int) -> String {
            String(format: NSLocalizedString("reporting.streak_days", tableName: table, comment: "🔥 %d-day streak!"), days)
        }
        
        public static let pluralS = NSLocalizedString("reporting.plural_s", tableName: table, comment: "s")
    }
    
    // MARK: - Schedule Templates
    
    public enum ScheduleTemplate {
        private static let table = "ScheduleTemplate"
        
        // Template names
        public static let officeWorkerName = NSLocalizedString("schedule_template.office_worker_name", tableName: table, comment: "Office Worker")
        public static let officeWorkerDescription = NSLocalizedString("schedule_template.office_worker_description", tableName: table, comment: "Mon-Fri work hours with lunch break")
        public static let remoteWorkerName = NSLocalizedString("schedule_template.remote_worker_name", tableName: table, comment: "Remote Worker")
        public static let remoteWorkerDescription = NSLocalizedString("schedule_template.remote_worker_description", tableName: table, comment: "Flexible schedule for remote work")
        public static let trainingModeName = NSLocalizedString("schedule_template.training_mode_name", tableName: table, comment: "Training Mode")
        public static let trainingModeDescription = NSLocalizedString("schedule_template.training_mode_description", tableName: table, comment: "Intensive training schedule")
        public static let recoveryModeName = NSLocalizedString("schedule_template.recovery_mode_name", tableName: table, comment: "Recovery Mode")
        public static let recoveryModeDescription = NSLocalizedString("schedule_template.recovery_mode_description", tableName: table, comment: "Gentle reminders for rest days")
        public static let weekendWarriorName = NSLocalizedString("schedule_template.weekend_warrior_name", tableName: table, comment: "Weekend Warrior")
        public static let weekendWarriorDescription = NSLocalizedString("schedule_template.weekend_warrior_description", tableName: table, comment: "Active weekends only")
        public static let minimalistName = NSLocalizedString("schedule_template.minimalist_name", tableName: table, comment: "Minimalist")
        public static let minimalistDescription = NSLocalizedString("schedule_template.minimalist_description", tableName: table, comment: "3 reminders per day")
        public static let everyDayName = NSLocalizedString("schedule_template.every_day_name", tableName: table, comment: "Every Day")
        public static let everyDayDescription = NSLocalizedString("schedule_template.every_day_description", tableName: table, comment: "Consistent daily routine")
        
        // Time block names
        public static let morning = NSLocalizedString("schedule_template.morning", tableName: table, comment: "Morning")
        public static let afternoon = NSLocalizedString("schedule_template.afternoon", tableName: table, comment: "Afternoon")
        public static let evening = NSLocalizedString("schedule_template.evening", tableName: table, comment: "Evening")
        public static let workHours = NSLocalizedString("schedule_template.work_hours", tableName: table, comment: "Work Hours")
        public static let weekend = NSLocalizedString("schedule_template.weekend", tableName: table, comment: "Weekend")
        public static let training = NSLocalizedString("schedule_template.training", tableName: table, comment: "Training")
        public static let gentleMovement = NSLocalizedString("schedule_template.gentle_movement", tableName: table, comment: "Gentle Movement")
        public static let weekendActivity = NSLocalizedString("schedule_template.weekend_activity", tableName: table, comment: "Weekend Activity")
        public static let activeHours = NSLocalizedString("schedule_template.active_hours", tableName: table, comment: "Active Hours")
    }

    // MARK: - Achievement Definitions

    public enum AchievementDefinition {
        private static let table = "AchievementDefinitions"

        // Milestone achievements
        public static let firstExerciseName = NSLocalizedString("achievement.first_exercise.name", tableName: table, comment: "First Steps achievement name")
        public static let firstExerciseDescription = NSLocalizedString("achievement.first_exercise.description", tableName: table, comment: "Log your first exercise")
        public static let tenExercisesName = NSLocalizedString("achievement.ten_exercises.name", tableName: table, comment: "Getting Started achievement name")
        public static let tenExercisesDescription = NSLocalizedString("achievement.ten_exercises.description", tableName: table, comment: "Log 10 exercise sessions")
        public static let centuryName = NSLocalizedString("achievement.century.name", tableName: table, comment: "Century Club achievement name")
        public static let centuryDescription = NSLocalizedString("achievement.century.description", tableName: table, comment: "Log 100 exercise sessions")
        public static let fiveHundredName = NSLocalizedString("achievement.five_hundred.name", tableName: table, comment: "Dedicated achievement name")
        public static let fiveHundredDescription = NSLocalizedString("achievement.five_hundred.description", tableName: table, comment: "Log 500 exercise sessions")
        public static let thousandName = NSLocalizedString("achievement.thousand.name", tableName: table, comment: "The Grind achievement name")
        public static let thousandDescription = NSLocalizedString("achievement.thousand.description", tableName: table, comment: "Log 1,000 exercise sessions")

        // Consistency achievements
        public static let weekStreakName = NSLocalizedString("achievement.week_streak.name", tableName: table, comment: "Week Warrior achievement name")
        public static let weekStreakDescription = NSLocalizedString("achievement.week_streak.description", tableName: table, comment: "Maintain a 7-day streak")
        public static let twoWeekStreakName = NSLocalizedString("achievement.two_week_streak.name", tableName: table, comment: "Building Habits achievement name")
        public static let twoWeekStreakDescription = NSLocalizedString("achievement.two_week_streak.description", tableName: table, comment: "Maintain a 14-day streak")
        public static let monthStreakName = NSLocalizedString("achievement.month_streak.name", tableName: table, comment: "Monthly Master achievement name")
        public static let monthStreakDescription = NSLocalizedString("achievement.month_streak.description", tableName: table, comment: "Maintain a 30-day streak")
        public static let yearStreakName = NSLocalizedString("achievement.year_streak.name", tableName: table, comment: "Unstoppable achievement name")
        public static let yearStreakDescription = NSLocalizedString("achievement.year_streak.description", tableName: table, comment: "Maintain a 365-day streak")

        // Variety achievements
        public static let wellRoundedName = NSLocalizedString("achievement.well_rounded.name", tableName: table, comment: "Well Rounded achievement name")
        public static let wellRoundedDescription = NSLocalizedString("achievement.well_rounded.description", tableName: table, comment: "Do 5 different exercise types in one day")
        public static let varietyExpertName = NSLocalizedString("achievement.variety_expert.name", tableName: table, comment: "Variety Expert achievement name")
        public static let varietyExpertDescription = NSLocalizedString("achievement.variety_expert.description", tableName: table, comment: "Do all 10 exercise types in one day")

        // Challenge achievements
        public static let earlyBirdName = NSLocalizedString("achievement.early_bird.name", tableName: table, comment: "Early Bird achievement name")
        public static let earlyBirdDescription = NSLocalizedString("achievement.early_bird.description", tableName: table, comment: "Log an exercise before 7 AM")
        public static let nightOwlName = NSLocalizedString("achievement.night_owl.name", tableName: table, comment: "Night Owl achievement name")
        public static let nightOwlDescription = NSLocalizedString("achievement.night_owl.description", tableName: table, comment: "Log an exercise after 10 PM")
        public static let powerDayName = NSLocalizedString("achievement.power_day.name", tableName: table, comment: "Power Day achievement name")
        public static let powerDayDescription = NSLocalizedString("achievement.power_day.description", tableName: table, comment: "Complete 10 exercises in one day")
        public static let marathonName = NSLocalizedString("achievement.marathon.name", tableName: table, comment: "Marathon achievement name")
        public static let marathonDescription = NSLocalizedString("achievement.marathon.description", tableName: table, comment: "Complete 20 exercises in one day")

        // Volume achievements - Pushups
        public static let pushup100Name = NSLocalizedString("achievement.pushup_100.name", tableName: table, comment: "Pushup Pro achievement name")
        public static let pushup100Description = NSLocalizedString("achievement.pushup_100.description", tableName: table, comment: "Complete 100 total pushup reps")
        public static let pushup500Name = NSLocalizedString("achievement.pushup_500.name", tableName: table, comment: "Pushup Expert achievement name")
        public static let pushup500Description = NSLocalizedString("achievement.pushup_500.description", tableName: table, comment: "Complete 500 total pushup reps")
        public static let pushup1000Name = NSLocalizedString("achievement.pushup_1000.name", tableName: table, comment: "Pushup Master achievement name")
        public static let pushup1000Description = NSLocalizedString("achievement.pushup_1000.description", tableName: table, comment: "Complete 1,000 total pushup reps")

        // Volume achievements - Squats
        public static let squat100Name = NSLocalizedString("achievement.squat_100.name", tableName: table, comment: "Squat Pro achievement name")
        public static let squat100Description = NSLocalizedString("achievement.squat_100.description", tableName: table, comment: "Complete 100 total squat reps")
        public static let squat500Name = NSLocalizedString("achievement.squat_500.name", tableName: table, comment: "Squat Expert achievement name")
        public static let squat500Description = NSLocalizedString("achievement.squat_500.description", tableName: table, comment: "Complete 500 total squat reps")
        public static let squat1000Name = NSLocalizedString("achievement.squat_1000.name", tableName: table, comment: "Squat Master achievement name")
        public static let squat1000Description = NSLocalizedString("achievement.squat_1000.description", tableName: table, comment: "Complete 1,000 total squat reps")

        // Volume achievements - Lunges
        public static let lunge100Name = NSLocalizedString("achievement.lunge_100.name", tableName: table, comment: "Lunge Pro achievement name")
        public static let lunge100Description = NSLocalizedString("achievement.lunge_100.description", tableName: table, comment: "Complete 100 total lunge reps")
        public static let lunge500Name = NSLocalizedString("achievement.lunge_500.name", tableName: table, comment: "Lunge Expert achievement name")
        public static let lunge500Description = NSLocalizedString("achievement.lunge_500.description", tableName: table, comment: "Complete 500 total lunge reps")
        public static let lunge1000Name = NSLocalizedString("achievement.lunge_1000.name", tableName: table, comment: "Lunge Master achievement name")
        public static let lunge1000Description = NSLocalizedString("achievement.lunge_1000.description", tableName: table, comment: "Complete 1,000 total lunge reps")

        // Volume achievements - Plank
        public static let plank300Name = NSLocalizedString("achievement.plank_300.name", tableName: table, comment: "Plank Beginner achievement name")
        public static let plank300Description = NSLocalizedString("achievement.plank_300.description", tableName: table, comment: "Hold plank for 300 total seconds")
        public static let plank1800Name = NSLocalizedString("achievement.plank_1800.name", tableName: table, comment: "Plank Warrior achievement name")
        public static let plank1800Description = NSLocalizedString("achievement.plank_1800.description", tableName: table, comment: "Hold plank for 1,800 total seconds")
        public static let plank3600Name = NSLocalizedString("achievement.plank_3600.name", tableName: table, comment: "Plank Champion achievement name")
        public static let plank3600Description = NSLocalizedString("achievement.plank_3600.description", tableName: table, comment: "Hold plank for 3,600 total seconds (1 hour)")

        // Volume achievements - Stretch
        public static let stretch600Name = NSLocalizedString("achievement.stretch_600.name", tableName: table, comment: "Flexibility Friend achievement name")
        public static let stretch600Description = NSLocalizedString("achievement.stretch_600.description", tableName: table, comment: "Stretch for 600 total seconds")
        public static let stretch3000Name = NSLocalizedString("achievement.stretch_3000.name", tableName: table, comment: "Stretch Master achievement name")
        public static let stretch3000Description = NSLocalizedString("achievement.stretch_3000.description", tableName: table, comment: "Stretch for 3,000 total seconds")
        public static let stretch6000Name = NSLocalizedString("achievement.stretch_6000.name", tableName: table, comment: "Zen Master achievement name")
        public static let stretch6000Description = NSLocalizedString("achievement.stretch_6000.description", tableName: table, comment: "Stretch for 6,000 total seconds")

        // Volume achievements - Calf Raises
        public static let calfRaise200Name = NSLocalizedString("achievement.calf_raise_200.name", tableName: table, comment: "Calf Crusher achievement name")
        public static let calfRaise200Description = NSLocalizedString("achievement.calf_raise_200.description", tableName: table, comment: "Complete 200 total calf raises")
        public static let calfRaise1000Name = NSLocalizedString("achievement.calf_raise_1000.name", tableName: table, comment: "Calf Expert achievement name")
        public static let calfRaise1000Description = NSLocalizedString("achievement.calf_raise_1000.description", tableName: table, comment: "Complete 1,000 total calf raises")
        public static let calfRaise2000Name = NSLocalizedString("achievement.calf_raise_2000.name", tableName: table, comment: "Steel Calves achievement name")
        public static let calfRaise2000Description = NSLocalizedString("achievement.calf_raise_2000.description", tableName: table, comment: "Complete 2,000 total calf raises")

        // Volume achievements - Walk In Place
        public static let walk1000Name = NSLocalizedString("achievement.walk_1000.name", tableName: table, comment: "Stepping Up achievement name")
        public static let walk1000Description = NSLocalizedString("achievement.walk_1000.description", tableName: table, comment: "Walk in place 1,000 total steps")
        public static let walk5000Name = NSLocalizedString("achievement.walk_5000.name", tableName: table, comment: "Step Counter achievement name")
        public static let walk5000Description = NSLocalizedString("achievement.walk_5000.description", tableName: table, comment: "Walk in place 5,000 total steps")
        public static let walk10000Name = NSLocalizedString("achievement.walk_10000.name", tableName: table, comment: "Daily Walker achievement name")
        public static let walk10000Description = NSLocalizedString("achievement.walk_10000.description", tableName: table, comment: "Walk in place 10,000 total steps")

        // Volume achievements - Neck Rolls
        public static let neckRoll100Name = NSLocalizedString("achievement.neck_roll_100.name", tableName: table, comment: "Neck Relief achievement name")
        public static let neckRoll100Description = NSLocalizedString("achievement.neck_roll_100.description", tableName: table, comment: "Complete 100 total neck rolls")
        public static let neckRoll500Name = NSLocalizedString("achievement.neck_roll_500.name", tableName: table, comment: "Tension Tamer achievement name")
        public static let neckRoll500Description = NSLocalizedString("achievement.neck_roll_500.description", tableName: table, comment: "Complete 500 total neck rolls")

        // Volume achievements - Shoulder Shrugs
        public static let shoulderShrug200Name = NSLocalizedString("achievement.shoulder_shrug_200.name", tableName: table, comment: "Shoulder Soother achievement name")
        public static let shoulderShrug200Description = NSLocalizedString("achievement.shoulder_shrug_200.description", tableName: table, comment: "Complete 200 total shoulder shrugs")
        public static let shoulderShrug1000Name = NSLocalizedString("achievement.shoulder_shrug_1000.name", tableName: table, comment: "Desk Warrior achievement name")
        public static let shoulderShrug1000Description = NSLocalizedString("achievement.shoulder_shrug_1000.description", tableName: table, comment: "Complete 1,000 total shoulder shrugs")

        // Volume achievements - Arm Circles
        public static let armCircle150Name = NSLocalizedString("achievement.arm_circle_150.name", tableName: table, comment: "Circle Starter achievement name")
        public static let armCircle150Description = NSLocalizedString("achievement.arm_circle_150.description", tableName: table, comment: "Complete 150 total arm circles")
        public static let armCircle750Name = NSLocalizedString("achievement.arm_circle_750.name", tableName: table, comment: "Rotation Master achievement name")
        public static let armCircle750Description = NSLocalizedString("achievement.arm_circle_750.description", tableName: table, comment: "Complete 750 total arm circles")
    }

    // MARK: - Achievement Categories

    public enum AchievementCategoryName {
        private static let table = "AchievementCategory"

        public static let milestone = NSLocalizedString("achievement_category.milestone", tableName: table, comment: "Milestone achievement category")
        public static let consistency = NSLocalizedString("achievement_category.consistency", tableName: table, comment: "Consistency achievement category")
        public static let volume = NSLocalizedString("achievement_category.volume", tableName: table, comment: "Volume achievement category")
        public static let variety = NSLocalizedString("achievement_category.variety", tableName: table, comment: "Variety achievement category")
        public static let challenge = NSLocalizedString("achievement_category.challenge", tableName: table, comment: "Challenge achievement category")
        public static let social = NSLocalizedString("achievement_category.social", tableName: table, comment: "Social achievement category")
        public static let template = NSLocalizedString("achievement_category.template", tableName: table, comment: "Custom Templates achievement category")
    }

    // MARK: - Achievement Tiers

    public enum AchievementTierName {
        private static let table = "AchievementTier"

        public static let bronze = NSLocalizedString("achievement_tier.bronze", tableName: table, comment: "Bronze achievement tier")
        public static let silver = NSLocalizedString("achievement_tier.silver", tableName: table, comment: "Silver achievement tier")
        public static let gold = NSLocalizedString("achievement_tier.gold", tableName: table, comment: "Gold achievement tier")
        public static let platinum = NSLocalizedString("achievement_tier.platinum", tableName: table, comment: "Platinum achievement tier")
    }

    // MARK: - Streak Types

    public enum StreakTypeName {
        private static let table = "StreakType"

        public static let dailyActive = NSLocalizedString("streak_type.daily_active", tableName: table, comment: "Daily Active streak type")
        public static let reminderResponse = NSLocalizedString("streak_type.reminder_response", tableName: table, comment: "Reminder Response streak type")
        public static let weeklyGoal = NSLocalizedString("streak_type.weekly_goal", tableName: table, comment: "Weekly Goal streak type")
    }

    // MARK: - Challenge Types

    public enum ChallengeTypeName {
        private static let table = "ChallengeType"

        // Challenge type names
        public static let dailyExercises = NSLocalizedString("challenge_type.daily_exercises.name", tableName: table, comment: "Daily Exercises challenge type name")
        public static let specificExercise = NSLocalizedString("challenge_type.specific_exercise.name", tableName: table, comment: "Specific Exercise challenge type name")
        public static let varietyChallenge = NSLocalizedString("challenge_type.variety_challenge.name", tableName: table, comment: "Variety Challenge type name")
        public static let streakProtect = NSLocalizedString("challenge_type.streak_protect.name", tableName: table, comment: "Streak Protect challenge type name")
        public static let earlyBird = NSLocalizedString("challenge_type.early_bird.name", tableName: table, comment: "Early Bird challenge type name")

        // Challenge type descriptions
        public static let dailyExercisesDescription = NSLocalizedString("challenge_type.daily_exercises.description", tableName: table, comment: "Complete exercises today challenge description")
        public static let specificExerciseDescription = NSLocalizedString("challenge_type.specific_exercise.description", tableName: table, comment: "Complete specific exercise challenge description")
        public static let varietyChallengeDescription = NSLocalizedString("challenge_type.variety_challenge.description", tableName: table, comment: "Try different exercises challenge description")
        public static let streakProtectDescription = NSLocalizedString("challenge_type.streak_protect.description", tableName: table, comment: "Maintain your streak challenge description")
        public static let earlyBirdDescription = NSLocalizedString("challenge_type.early_bird.description", tableName: table, comment: "Exercise before 8 AM challenge description")
    }

    // MARK: - Achievement Template Types

    public enum AchievementTemplateTypeName {
        private static let table = "AchievementTemplateType"

        // Template type names
        public static let volume = NSLocalizedString("achievement_template_type.volume.name", tableName: table, comment: "Lifetime Volume template type name")
        public static let dailyGoal = NSLocalizedString("achievement_template_type.daily_goal.name", tableName: table, comment: "Daily Goal template type name")
        public static let weeklyGoal = NSLocalizedString("achievement_template_type.weekly_goal.name", tableName: table, comment: "Weekly Goal template type name")
        public static let streak = NSLocalizedString("achievement_template_type.streak.name", tableName: table, comment: "Consecutive Days template type name")
        public static let speed = NSLocalizedString("achievement_template_type.speed.name", tableName: table, comment: "Speed Challenge template type name")

        // Template type descriptions
        public static let volumeDescription = NSLocalizedString("achievement_template_type.volume.description", tableName: table, comment: "Track total lifetime count for this exercise")
        public static let dailyGoalDescription = NSLocalizedString("achievement_template_type.daily_goal.description", tableName: table, comment: "Achieve a target count in a single day")
        public static let weeklyGoalDescription = NSLocalizedString("achievement_template_type.weekly_goal.description", tableName: table, comment: "Reach a weekly target across 7 days")
        public static let streakDescription = NSLocalizedString("achievement_template_type.streak.description", tableName: table, comment: "Log this exercise on consecutive days")
        public static let speedDescription = NSLocalizedString("achievement_template_type.speed.description", tableName: table, comment: "Complete reps within a time window")
    }

    // MARK: - Achievement Template Tier Labels

    public enum AchievementTemplateTierLabel {
        private static let table = "AchievementTemplateTier"

        // Volume tier labels
        public static let novice = NSLocalizedString("achievement_template_tier.novice", tableName: table, comment: "Novice tier label")
        public static let intermediate = NSLocalizedString("achievement_template_tier.intermediate", tableName: table, comment: "Intermediate tier label")
        public static let advanced = NSLocalizedString("achievement_template_tier.advanced", tableName: table, comment: "Advanced tier label")
        public static let master = NSLocalizedString("achievement_template_tier.master", tableName: table, comment: "Master tier label")

        // Daily goal tier labels
        public static let dailyAchiever = NSLocalizedString("achievement_template_tier.daily_achiever", tableName: table, comment: "Daily Achiever tier label")
        public static let dailyChampion = NSLocalizedString("achievement_template_tier.daily_champion", tableName: table, comment: "Daily Champion tier label")
        public static let dailyLegend = NSLocalizedString("achievement_template_tier.daily_legend", tableName: table, comment: "Daily Legend tier label")

        // Weekly goal tier labels
        public static let weekWarrior = NSLocalizedString("achievement_template_tier.week_warrior", tableName: table, comment: "Week Warrior tier label")
        public static let weekChampion = NSLocalizedString("achievement_template_tier.week_champion", tableName: table, comment: "Week Champion tier label")
        public static let weekLegend = NSLocalizedString("achievement_template_tier.week_legend", tableName: table, comment: "Week Legend tier label")

        // Streak tier labels
        public static let consistent = NSLocalizedString("achievement_template_tier.consistent", tableName: table, comment: "Consistent tier label")
        public static let dedicated = NSLocalizedString("achievement_template_tier.dedicated", tableName: table, comment: "Dedicated tier label")
        public static let committed = NSLocalizedString("achievement_template_tier.committed", tableName: table, comment: "Committed tier label")

        // Speed tier labels
        public static let speedy = NSLocalizedString("achievement_template_tier.speedy", tableName: table, comment: "Speedy tier label")
        public static let lightning = NSLocalizedString("achievement_template_tier.lightning", tableName: table, comment: "Lightning tier label")
    }

    // MARK: - Weekly Insights
    
    public enum WeeklyInsights {
        private static let table = "WeeklyInsights"
        
        public static let navigationTitle = NSLocalizedString("weekly_insights.navigation_title", tableName: table, comment: "Navigation title for weekly insights view")
        public static let doneButton = NSLocalizedString("weekly_insights.done_button", tableName: table, comment: "Done button")
        
        public static func pageIndicator(current: Int, total: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.page_indicator", tableName: table, comment: "Page indicator"), current, total)
        }
        
        // Total Activity Card
        public static let totalActivitySubtitle = NSLocalizedString("weekly_insights.total_activity_subtitle", tableName: table, comment: "Subtitle for total activity card")
        
        public static func vsLastWeek(_ percentage: String) -> String {
            String(format: NSLocalizedString("weekly_insights.vs_last_week", tableName: table, comment: "Comparison label"), percentage)
        }
        
        // Top Exercise Card
        public static let topExerciseSubtitle = NSLocalizedString("weekly_insights.top_exercise_subtitle", tableName: table, comment: "Subtitle for top exercise card")
        
        public static func timesCount(_ count: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.times_count", tableName: table, comment: "Number of times performed"), count)
        }
        
        public static func percentageActivity(_ percentage: String) -> String {
            String(format: NSLocalizedString("weekly_insights.percentage_activity", tableName: table, comment: "Percentage of all activity"), percentage)
        }
        
        // Consistency Card
        public static func consistencyDays(_ days: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.consistency_days", tableName: table, comment: "Active days count"), days)
        }
        
        public static let consistencySubtitle = NSLocalizedString("weekly_insights.consistency_subtitle", tableName: table, comment: "Subtitle for consistency card")
        
        public static func tryForMoreDays(_ days: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.try_for_more_days", tableName: table, comment: "Encouragement to be active more days"), days)
        }
        
        // Day abbreviations
        public static let dayMon = NSLocalizedString("weekly_insights.day_mon", tableName: table, comment: "Monday abbreviation")
        public static let dayTue = NSLocalizedString("weekly_insights.day_tue", tableName: table, comment: "Tuesday abbreviation")
        public static let dayWed = NSLocalizedString("weekly_insights.day_wed", tableName: table, comment: "Wednesday abbreviation")
        public static let dayThu = NSLocalizedString("weekly_insights.day_thu", tableName: table, comment: "Thursday abbreviation")
        public static let dayFri = NSLocalizedString("weekly_insights.day_fri", tableName: table, comment: "Friday abbreviation")
        public static let daySat = NSLocalizedString("weekly_insights.day_sat", tableName: table, comment: "Saturday abbreviation")
        public static let daySun = NSLocalizedString("weekly_insights.day_sun", tableName: table, comment: "Sunday abbreviation")
        
        // Streak Card
        public static let streakDaySingular = NSLocalizedString("weekly_insights.streak_day_singular", tableName: table, comment: "Singular day for streak")
        public static let streakTitle = NSLocalizedString("weekly_insights.streak_title", tableName: table, comment: "Title for streak card")
        public static let streakMessageShort = NSLocalizedString("weekly_insights.streak_message_short", tableName: table, comment: "Message for streak under 3 days")
        public static let streakMessageMedium = NSLocalizedString("weekly_insights.streak_message_medium", tableName: table, comment: "Message for streak 3-6 days")
        public static let streakMessageLong = NSLocalizedString("weekly_insights.streak_message_long", tableName: table, comment: "Message for streak 7+ days")
        
        // Achievement Card
        public static let newBadge = NSLocalizedString("weekly_insights.new_badge", tableName: table, comment: "NEW badge for new achievements")
        public static let unlockedToday = NSLocalizedString("weekly_insights.unlocked_today", tableName: table, comment: "Achievement unlocked today")
        
        public static func unlockedDaysAgo(_ days: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.unlocked_days_ago", tableName: table, comment: "Achievement unlocked days ago"), days)
        }
        
        // Milestone Card
        public static let almostThere = NSLocalizedString("weekly_insights.almost_there", tableName: table, comment: "Almost there title for milestone card")
        
        public static func progressRatio(current: Int, target: Int) -> String {
            String(format: NSLocalizedString("weekly_insights.progress_ratio", tableName: table, comment: "Progress ratio format"), current, target)
        }
    }

    // MARK: - Exercise Reference

    public enum ExerciseReferenceName {
        private static let table = "ExerciseReference"

        public static let customExercise = NSLocalizedString("exercise_reference.custom_exercise", tableName: table, comment: "Custom Exercise label")
    }

    // MARK: - Exercise Type

    public enum ExerciseTypeName {
        private static let table = "ExerciseType"

        public static let squats = NSLocalizedString("exercise_type.squats", tableName: table, comment: "Squats exercise name")
        public static let pushups = NSLocalizedString("exercise_type.pushups", tableName: table, comment: "Push-ups exercise name")
        public static let lunges = NSLocalizedString("exercise_type.lunges", tableName: table, comment: "Lunges exercise name")
        public static let plank = NSLocalizedString("exercise_type.plank", tableName: table, comment: "Plank exercise name")
        public static let standingStretch = NSLocalizedString("exercise_type.standing_stretch", tableName: table, comment: "Standing Stretch exercise name")
        public static let neckRolls = NSLocalizedString("exercise_type.neck_rolls", tableName: table, comment: "Neck Rolls exercise name")
        public static let shoulderShrugs = NSLocalizedString("exercise_type.shoulder_shrugs", tableName: table, comment: "Shoulder Shrugs exercise name")
        public static let calfRaises = NSLocalizedString("exercise_type.calf_raises", tableName: table, comment: "Calf Raises exercise name")
        public static let armCircles = NSLocalizedString("exercise_type.arm_circles", tableName: table, comment: "Arm Circles exercise name")
        public static let walkInPlace = NSLocalizedString("exercise_type.walk_in_place", tableName: table, comment: "Walk in Place exercise name")
    }

    // MARK: - Exercise Unit Type

    public enum ExerciseUnitTypeName {
        private static let table = "ExerciseUnitType"

        public static let reps = NSLocalizedString("exercise_unit_type.reps", tableName: table, comment: "Reps unit type name")
        public static let seconds = NSLocalizedString("exercise_unit_type.seconds", tableName: table, comment: "Seconds unit type name")
        public static let minutes = NSLocalizedString("exercise_unit_type.minutes", tableName: table, comment: "Minutes unit type name")

        public static let repsLabel = NSLocalizedString("exercise_unit_type.reps.label", tableName: table, comment: "Reps unit label (lowercase)")
        public static let secondsLabel = NSLocalizedString("exercise_unit_type.seconds.label", tableName: table, comment: "Seconds unit label (lowercase)")
        public static let minutesLabel = NSLocalizedString("exercise_unit_type.minutes.label", tableName: table, comment: "Minutes unit label (lowercase)")
    }

    // MARK: - Onboarding

    public enum Onboarding {
        private static let table = "Onboarding"

        // Welcome screen
        public static let welcomeTitle = NSLocalizedString("onboarding.welcome_title", tableName: table, comment: "Welcome screen title")
        public static let welcomeSubtitle = NSLocalizedString("onboarding.welcome_subtitle", tableName: table, comment: "Welcome screen subtitle")
        public static let benefitScheduling = NSLocalizedString("onboarding.benefit_scheduling", tableName: table, comment: "Scheduling benefit")
        public static let benefitTimeBlocks = NSLocalizedString("onboarding.benefit_time_blocks", tableName: table, comment: "Time blocks benefit")
        public static let benefitReschedule = NSLocalizedString("onboarding.benefit_reschedule", tableName: table, comment: "Reschedule benefit")

        // Schedule power screen
        public static let schedulePowerTitle = NSLocalizedString("onboarding.schedule_power_title", tableName: table, comment: "Schedule power page title")
        public static let schedulePowerDescription = NSLocalizedString("onboarding.schedule_power_description", tableName: table, comment: "Schedule power page description")
        public static let exampleSchedule = NSLocalizedString("onboarding.example_schedule", tableName: table, comment: "Example schedule label")
        public static let exampleMorningRoutine = NSLocalizedString("onboarding.example_morning_routine", tableName: table, comment: "Morning routine example")
        public static let exampleWorkTime = NSLocalizedString("onboarding.example_work_time", tableName: table, comment: "Work time example")
        public static let exampleEvening = NSLocalizedString("onboarding.example_evening", tableName: table, comment: "Evening example")
        public static let exampleEvery30Min = NSLocalizedString("onboarding.example_every_30min", tableName: table, comment: "Every 30 min interval example")
        public static let exampleEvery60Min = NSLocalizedString("onboarding.example_every_60min", tableName: table, comment: "Every 60 min interval example")
        public static let exampleEvery45Min = NSLocalizedString("onboarding.example_every_45min", tableName: table, comment: "Every 45 min interval example")
        public static let createYourSchedule = NSLocalizedString("onboarding.create_your_schedule", tableName: table, comment: "Create your schedule button")
        public static let viewYourSchedule = NSLocalizedString("onboarding.view_your_schedule", tableName: table, comment: "View your schedule button")
        public static let noProfileYet = NSLocalizedString("onboarding.no_profile_yet", tableName: table, comment: "No profile yet message")

        // Reschedule screen
        public static let rescheduleTitle = NSLocalizedString("onboarding.reschedule_title", tableName: table, comment: "Reschedule page title")
        public static let rescheduleDescription = NSLocalizedString("onboarding.reschedule_description", tableName: table, comment: "Reschedule page description")
        public static let rescheduleButtonLocation = NSLocalizedString("onboarding.reschedule_button_location", tableName: table, comment: "Reschedule button location label")
        public static let nextReminder = NSLocalizedString("onboarding.next_reminder", tableName: table, comment: "Next reminder label")
        public static let whenToReschedule = NSLocalizedString("onboarding.when_to_reschedule", tableName: table, comment: "When to reschedule header")
        public static let useCaseSleep = NSLocalizedString("onboarding.use_case_sleep", tableName: table, comment: "Sleep use case")
        public static let useCaseMeeting = NSLocalizedString("onboarding.use_case_meeting", tableName: table, comment: "Meeting use case")
        public static let useCaseErrand = NSLocalizedString("onboarding.use_case_errand", tableName: table, comment: "Errand use case")

        // Navigation
        public static let next = NSLocalizedString("onboarding.next", tableName: table, comment: "Next button")
        public static let back = NSLocalizedString("onboarding.back", tableName: table, comment: "Back button")
        public static let getStarted = NSLocalizedString("onboarding.get_started", tableName: table, comment: "Get started button")
        public static let gotIt = NSLocalizedString("onboarding.got_it", tableName: table, comment: "Got it button")
        public static let skip = NSLocalizedString("onboarding.skip", tableName: table, comment: "Skip button")
    }

    // MARK: - Share

    public enum Share {
        private static let table = "Share"

        // Share buttons
        public static let buttonShare = NSLocalizedString("share.button_share", tableName: table, comment: "Share button label")
        public static let shareAchievement = NSLocalizedString("share.share_achievement", tableName: table, comment: "Share achievement button label")
        public static let shareWeek = NSLocalizedString("share.share_week", tableName: table, comment: "Share weekly summary button label")

        // Share card
        public static let shareYourProgress = NSLocalizedString("share.share_your_progress", tableName: table, comment: "Share your progress card title")
        public static let shareYourProgressSubtitle = NSLocalizedString("share.share_your_progress_subtitle", tableName: table, comment: "Share your progress card subtitle")

        // Share image text
        public static let achievementUnlocked = NSLocalizedString("share.achievement_unlocked", tableName: table, comment: "Achievement unlocked headline on share image")
        public static let weeklySummary = NSLocalizedString("share.weekly_summary", tableName: table, comment: "Weekly summary headline on share image")
        public static let appTagline = NSLocalizedString("share.app_tagline", tableName: table, comment: "App tagline on share images")

        // Share text templates
        public static func achievementText(_ achievementName: String) -> String {
            String(format: NSLocalizedString("share.achievement_text", tableName: table, comment: "Share text for achievement unlock"), achievementName)
        }

        public static let weeklySummaryText = NSLocalizedString("share.weekly_summary_text", tableName: table, comment: "Share text for weekly summary")
    }
}
