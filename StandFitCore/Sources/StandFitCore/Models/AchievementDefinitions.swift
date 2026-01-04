
// MARK: - Achievement Definitions

/// Predefined achievements available in the app

public struct AchievementDefinitions {
    public static let all: [Achievement] = [
        // MARK: Milestones (Session-based)
        Achievement(
            id: "first_exercise",
            name: LocalizedString.AchievementDefinition.firstExerciseName,
            description: LocalizedString.AchievementDefinition.firstExerciseDescription,
            icon: "figure.walk",
            category: .milestone,
            tier: .bronze,
            requirement: .totalSessions(1),
            progress: 0
        ),
        Achievement(
            id: "ten_exercises",
            name: LocalizedString.AchievementDefinition.tenExercisesName,
            description: LocalizedString.AchievementDefinition.tenExercisesDescription,
            icon: "10.circle.fill",
            category: .milestone,
            tier: .bronze,
            requirement: .totalSessions(10),
            progress: 0
        ),
        Achievement(
            id: "century",
            name: LocalizedString.AchievementDefinition.centuryName,
            description: LocalizedString.AchievementDefinition.centuryDescription,
            icon: "100.circle.fill",
            category: .milestone,
            tier: .silver,
            requirement: .totalSessions(100),
            progress: 0
        ),
        Achievement(
            id: "five_hundred",
            name: LocalizedString.AchievementDefinition.fiveHundredName,
            description: LocalizedString.AchievementDefinition.fiveHundredDescription,
            icon: "star.fill",
            category: .milestone,
            tier: .gold,
            requirement: .totalSessions(500),
            progress: 0
        ),
        Achievement(
            id: "thousand",
            name: LocalizedString.AchievementDefinition.thousandName,
            description: LocalizedString.AchievementDefinition.thousandDescription,
            icon: "star.circle.fill",
            category: .milestone,
            tier: .platinum,
            requirement: .totalSessions(1000),
            progress: 0
        ),

        // MARK: Consistency
        Achievement(
            id: "week_streak",
            name: LocalizedString.AchievementDefinition.weekStreakName,
            description: LocalizedString.AchievementDefinition.weekStreakDescription,
            icon: "flame.fill",
            category: .consistency,
            tier: .bronze,
            requirement: .streak(7),
            progress: 0
        ),
        Achievement(
            id: "two_week_streak",
            name: LocalizedString.AchievementDefinition.twoWeekStreakName,
            description: LocalizedString.AchievementDefinition.twoWeekStreakDescription,
            icon: "flame.fill",
            category: .consistency,
            tier: .silver,
            requirement: .streak(14),
            progress: 0
        ),
        Achievement(
            id: "month_streak",
            name: LocalizedString.AchievementDefinition.monthStreakName,
            description: LocalizedString.AchievementDefinition.monthStreakDescription,
            icon: "flame.circle.fill",
            category: .consistency,
            tier: .gold,
            requirement: .streak(30),
            progress: 0
        ),
        Achievement(
            id: "year_streak",
            name: LocalizedString.AchievementDefinition.yearStreakName,
            description: LocalizedString.AchievementDefinition.yearStreakDescription,
            icon: "crown.fill",
            category: .consistency,
            tier: .platinum,
            requirement: .streak(365),
            progress: 0
        ),

        // MARK: Variety
        Achievement(
            id: "well_rounded",
            name: LocalizedString.AchievementDefinition.wellRoundedName,
            description: LocalizedString.AchievementDefinition.wellRoundedDescription,
            icon: "circle.hexagongrid.fill",
            category: .variety,
            tier: .bronze,
            requirement: .unique(5),
            progress: 0
        ),
        Achievement(
            id: "variety_expert",
            name: LocalizedString.AchievementDefinition.varietyExpertName,
            description: LocalizedString.AchievementDefinition.varietyExpertDescription,
            icon: "star.circle.fill",
            category: .variety,
            tier: .silver,
            requirement: .unique(10),
            progress: 0
        ),

        // MARK: Challenges
        Achievement(
            id: "early_bird",
            name: LocalizedString.AchievementDefinition.earlyBirdName,
            description: LocalizedString.AchievementDefinition.earlyBirdDescription,
            icon: "sunrise.fill",
            category: .challenge,
            tier: .bronze,
            requirement: .timeWindow(hour: 7, comparison: .before, count: 1),
            progress: 0
        ),
        Achievement(
            id: "night_owl",
            name: LocalizedString.AchievementDefinition.nightOwlName,
            description: LocalizedString.AchievementDefinition.nightOwlDescription,
            icon: "moon.stars.fill",
            category: .challenge,
            tier: .bronze,
            requirement: .timeWindow(hour: 22, comparison: .after, count: 1),
            progress: 0
        ),
        Achievement(
            id: "power_day",
            name: LocalizedString.AchievementDefinition.powerDayName,
            description: LocalizedString.AchievementDefinition.powerDayDescription,
            icon: "bolt.fill",
            category: .challenge,
            tier: .silver,
            requirement: .dailyGoal(10),
            progress: 0
        ),
        Achievement(
            id: "marathon",
            name: LocalizedString.AchievementDefinition.marathonName,
            description: LocalizedString.AchievementDefinition.marathonDescription,
            icon: "figure.run",
            category: .challenge,
            tier: .gold,
            requirement: .dailyGoal(20),
            progress: 0
        ),

        // MARK: Volume (Built-in exercises - Rep/Duration based)
        Achievement(
            id: "pushup_100",
            name: LocalizedString.AchievementDefinition.pushup100Name,
            description: LocalizedString.AchievementDefinition.pushup100Description,
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Pushups", 100),
            progress: 0
        ),
        Achievement(
            id: "pushup_500",
            name: LocalizedString.AchievementDefinition.pushup500Name,
            description: LocalizedString.AchievementDefinition.pushup500Description,
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Pushups", 500),
            progress: 0
        ),
        Achievement(
            id: "pushup_1000",
            name: LocalizedString.AchievementDefinition.pushup1000Name,
            description: LocalizedString.AchievementDefinition.pushup1000Description,
            icon: "figure.strengthtraining.traditional",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Pushups", 1000),
            progress: 0
        ),
        Achievement(
            id: "squat_100",
            name: LocalizedString.AchievementDefinition.squat100Name,
            description: LocalizedString.AchievementDefinition.squat100Description,
            icon: "figure.stand",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Squats", 100),
            progress: 0
        ),
        Achievement(
            id: "squat_500",
            name: LocalizedString.AchievementDefinition.squat500Name,
            description: LocalizedString.AchievementDefinition.squat500Description,
            icon: "figure.stand",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Squats", 500),
            progress: 0
        ),
        Achievement(
            id: "squat_1000",
            name: LocalizedString.AchievementDefinition.squat1000Name,
            description: LocalizedString.AchievementDefinition.squat1000Description,
            icon: "figure.stand",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Squats", 1000),
            progress: 0
        ),
        Achievement(
            id: "lunge_100",
            name: LocalizedString.AchievementDefinition.lunge100Name,
            description: LocalizedString.AchievementDefinition.lunge100Description,
            icon: "figure.walk",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Lunges", 100),
            progress: 0
        ),
        Achievement(
            id: "lunge_500",
            name: LocalizedString.AchievementDefinition.lunge500Name,
            description: LocalizedString.AchievementDefinition.lunge500Description,
            icon: "figure.walk",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Lunges", 500),
            progress: 0
        ),
        Achievement(
            id: "lunge_1000",
            name: LocalizedString.AchievementDefinition.lunge1000Name,
            description: LocalizedString.AchievementDefinition.lunge1000Description,
            icon: "figure.walk",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Lunges", 1000),
            progress: 0
        ),
        Achievement(
            id: "plank_300",
            name: LocalizedString.AchievementDefinition.plank300Name,
            description: LocalizedString.AchievementDefinition.plank300Description,
            icon: "figure.core.training",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Plank", 300),
            progress: 0
        ),
        Achievement(
            id: "plank_1800",
            name: LocalizedString.AchievementDefinition.plank1800Name,
            description: LocalizedString.AchievementDefinition.plank1800Description,
            icon: "figure.core.training",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Plank", 1800),
            progress: 0
        ),
        Achievement(
            id: "plank_3600",
            name: LocalizedString.AchievementDefinition.plank3600Name,
            description: LocalizedString.AchievementDefinition.plank3600Description,
            icon: "figure.core.training",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Plank", 3600),
            progress: 0
        ),
        Achievement(
            id: "stretch_600",
            name: LocalizedString.AchievementDefinition.stretch600Name,
            description: LocalizedString.AchievementDefinition.stretch600Description,
            icon: "figure.flexibility",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Standing Stretch", 600),
            progress: 0
        ),
        Achievement(
            id: "stretch_3000",
            name: LocalizedString.AchievementDefinition.stretch3000Name,
            description: LocalizedString.AchievementDefinition.stretch3000Description,
            icon: "figure.flexibility",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Standing Stretch", 3000),
            progress: 0
        ),
        Achievement(
            id: "stretch_6000",
            name: LocalizedString.AchievementDefinition.stretch6000Name,
            description: LocalizedString.AchievementDefinition.stretch6000Description,
            icon: "figure.flexibility",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Standing Stretch", 6000),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_200",
            name: LocalizedString.AchievementDefinition.calfRaise200Name,
            description: LocalizedString.AchievementDefinition.calfRaise200Description,
            icon: "figure.stand",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Calf Raises", 200),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_1000",
            name: LocalizedString.AchievementDefinition.calfRaise1000Name,
            description: LocalizedString.AchievementDefinition.calfRaise1000Description,
            icon: "figure.stand",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Calf Raises", 1000),
            progress: 0
        ),
        Achievement(
            id: "calf_raise_2000",
            name: LocalizedString.AchievementDefinition.calfRaise2000Name,
            description: LocalizedString.AchievementDefinition.calfRaise2000Description,
            icon: "figure.stand",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Calf Raises", 2000),
            progress: 0
        ),
        Achievement(
            id: "walk_1000",
            name: LocalizedString.AchievementDefinition.walk1000Name,
            description: LocalizedString.AchievementDefinition.walk1000Description,
            icon: "figure.walk.motion",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Walk In Place", 1000),
            progress: 0
        ),
        Achievement(
            id: "walk_5000",
            name: LocalizedString.AchievementDefinition.walk5000Name,
            description: LocalizedString.AchievementDefinition.walk5000Description,
            icon: "figure.walk.motion",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Walk In Place", 5000),
            progress: 0
        ),
        Achievement(
            id: "walk_10000",
            name: LocalizedString.AchievementDefinition.walk10000Name,
            description: LocalizedString.AchievementDefinition.walk10000Description,
            icon: "figure.walk.motion",
            category: .volume,
            tier: .gold,
            requirement: .exerciseVolume("Walk In Place", 10000),
            progress: 0
        ),
        Achievement(
            id: "neck_roll_100",
            name: LocalizedString.AchievementDefinition.neckRoll100Name,
            description: LocalizedString.AchievementDefinition.neckRoll100Description,
            icon: "figure.mind.and.body",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Neck Rolls", 100),
            progress: 0
        ),
        Achievement(
            id: "neck_roll_500",
            name: LocalizedString.AchievementDefinition.neckRoll500Name,
            description: LocalizedString.AchievementDefinition.neckRoll500Description,
            icon: "figure.mind.and.body",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Neck Rolls", 500),
            progress: 0
        ),
        Achievement(
            id: "shoulder_shrug_200",
            name: LocalizedString.AchievementDefinition.shoulderShrug200Name,
            description: LocalizedString.AchievementDefinition.shoulderShrug200Description,
            icon: "figure.cooldown",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Shoulder Shrugs", 200),
            progress: 0
        ),
        Achievement(
            id: "shoulder_shrug_1000",
            name: LocalizedString.AchievementDefinition.shoulderShrug1000Name,
            description: LocalizedString.AchievementDefinition.shoulderShrug1000Description,
            icon: "figure.cooldown",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Shoulder Shrugs", 1000),
            progress: 0
        ),
        Achievement(
            id: "arm_circle_150",
            name: LocalizedString.AchievementDefinition.armCircle150Name,
            description: LocalizedString.AchievementDefinition.armCircle150Description,
            icon: "figure.arms.open",
            category: .volume,
            tier: .bronze,
            requirement: .exerciseVolume("Arm Circles", 150),
            progress: 0
        ),
        Achievement(
            id: "arm_circle_750",
            name: LocalizedString.AchievementDefinition.armCircle750Name,
            description: LocalizedString.AchievementDefinition.armCircle750Description,
            icon: "figure.arms.open",
            category: .volume,
            tier: .silver,
            requirement: .exerciseVolume("Arm Circles", 750),
            progress: 0
        ),
    ]
}