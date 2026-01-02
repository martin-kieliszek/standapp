//
//  ExerciseModels.swift
//  StandFitCore
//
//  Platform-agnostic exercise data models
//

import Foundation

// MARK: - Exercise Unit Type

/// Defines whether an exercise is measured in repetitions or time
public enum ExerciseUnitType: String, Codable, CaseIterable, Identifiable {
    case reps = "Reps"
    case seconds = "Seconds"
    case minutes = "Minutes"

    public var id: String { rawValue }

    public var unitLabel: String {
        switch self {
        case .reps: return "reps"
        case .seconds: return "seconds"
        case .minutes: return "minutes"
        }
    }

    public var unitLabelShort: String {
        switch self {
        case .reps: return "×"
        case .seconds: return "s"
        case .minutes: return "m"
        }
    }

    /// Returns true if this unit type represents time (stored as seconds internally)
    public var isTimeBased: Bool {
        switch self {
        case .reps: return false
        case .seconds, .minutes: return true
        }
    }

    /// Convert display value to storage value (minutes → seconds)
    public func toStorageValue(_ displayValue: Int) -> Int {
        switch self {
        case .reps, .seconds: return displayValue
        case .minutes: return displayValue * 60
        }
    }

    /// Convert storage value to display value (seconds → minutes)
    public func toDisplayValue(_ storageValue: Int) -> Int {
        switch self {
        case .reps, .seconds: return storageValue
        case .minutes: return storageValue / 60
        }
    }
}

// MARK: - Built-in Exercise Types

/// An enum for exercise types that can be saved to JSON (`Codable`) and displayed in lists (`CaseIterable`)
public enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case squats = "Squats"
    case pushups = "Pushups"
    case lunges = "Lunges"
    case plank = "Plank (seconds)"

    public var id: String {
        rawValue
    }

    public var icon: String {
        switch self {
        case .squats: return "figure.stand"
        case .pushups: return "figure.strengthtraining.traditional"
        case .lunges: return "figure.walk"
        case .plank: return "figure.core.training"
        }
    }

    public var defaultCount: Int {
        switch self {
        case .squats: return 10
        case .pushups: return 10
        case .lunges: return 10
        case .plank: return 30
        }
    }

    public var unitType: ExerciseUnitType {
        switch self {
        case .squats, .pushups, .lunges: return .reps
        case .plank: return .seconds
        }
    }
}

// MARK: - Custom Exercise

/// A user-defined custom exercise with configurable icon, unit type, and default count
/// Note: defaultCount is stored in the base unit (seconds for time-based, reps for count-based)
public struct CustomExercise: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var icon: String
    public var unitType: ExerciseUnitType
    public var defaultCount: Int  // Stored in base unit (seconds for time, reps for count)
    public var sortOrder: Int

    public init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        unitType: ExerciseUnitType = .reps,
        defaultCount: Int = 10,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.unitType = unitType
        self.defaultCount = defaultCount
        self.sortOrder = sortOrder
    }

    /// Get the display value for the default count (converts seconds to minutes if needed)
    public var defaultCountDisplay: Int {
        unitType.toDisplayValue(defaultCount)
    }
}

// MARK: - Exercise Item (Unified Protocol)

/// A unified representation of any exercise (built-in or custom) for display purposes
public struct ExerciseItem: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let icon: String
    public let unitType: ExerciseUnitType
    public let defaultCount: Int
    public let isBuiltIn: Bool
    public let builtInType: ExerciseType?
    public let customExercise: CustomExercise?

    public init(builtIn: ExerciseType) {
        self.id = "builtin_\(builtIn.id)"
        self.name = builtIn.rawValue
        self.icon = builtIn.icon
        self.unitType = builtIn.unitType
        self.defaultCount = builtIn.defaultCount
        self.isBuiltIn = true
        self.builtInType = builtIn
        self.customExercise = nil
    }

    public init(custom: CustomExercise) {
        self.id = "custom_\(custom.id.uuidString)"
        self.name = custom.name
        self.icon = custom.icon
        self.unitType = custom.unitType
        self.defaultCount = custom.defaultCount
        self.isBuiltIn = false
        self.builtInType = nil
        self.customExercise = custom
    }

    public static func == (lhs: ExerciseItem, rhs: ExerciseItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Exercise Logs

public struct ExerciseLog: Codable, Identifiable {
    public let id: UUID
    public let exerciseType: ExerciseType?
    public let customExerciseId: UUID?
    public let count: Int
    public let timestamp: Date

    /// Initialize with a built-in exercise type
    public init(exerciseType: ExerciseType, count: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.exerciseType = exerciseType
        self.customExerciseId = nil
        self.count = count
        self.timestamp = timestamp
    }

    /// Initialize with a custom exercise
    public init(customExerciseId: UUID, count: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.exerciseType = nil
        self.customExerciseId = customExerciseId
        self.count = count
        self.timestamp = timestamp
    }

    /// Initialize with an ExerciseItem (unified)
    public init(item: ExerciseItem, count: Int, timestamp: Date = Date()) {
        self.id = UUID()
        if item.isBuiltIn {
            self.exerciseType = item.builtInType
            self.customExerciseId = nil
        } else {
            self.exerciseType = nil
            self.customExerciseId = item.customExercise?.id
        }
        self.count = count
        self.timestamp = timestamp
    }

    public var isBuiltIn: Bool {
        exerciseType != nil
    }
}

public struct ExerciseSummary {
    public let type: ExerciseType
    public let totalCount: Int
    public let sessionCount: Int

    public init(type: ExerciseType, totalCount: Int, sessionCount: Int) {
        self.type = type
        self.totalCount = totalCount
        self.sessionCount = sessionCount
    }
}

public struct CustomExerciseSummary {
    public let customExercise: CustomExercise
    public let totalCount: Int
    public let sessionCount: Int

    public init(customExercise: CustomExercise, totalCount: Int, sessionCount: Int) {
        self.customExercise = customExercise
        self.totalCount = totalCount
        self.sessionCount = sessionCount
    }
}
