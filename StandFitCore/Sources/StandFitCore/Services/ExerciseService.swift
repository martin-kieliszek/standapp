//
//  ExerciseService.swift
//  StandFitCore
//
//  Platform-agnostic exercise management service
//

import Foundation

/// Service for managing exercises and exercise logs
/// Platform-agnostic - no SwiftUI or platform-specific dependencies
public class ExerciseService {
    private let persistence: PersistenceProvider

    private static let logsKey = "exercise_logs"
    private static let customExercisesKey = "custom_exercises"

    public init(persistence: PersistenceProvider) {
        self.persistence = persistence
    }

    // MARK: - Exercise Logs

    public func loadLogs() throws -> [ExerciseLog] {
        guard let logs: [ExerciseLog] = try persistence.load(forKey: Self.logsKey, as: [ExerciseLog].self) else {
            return []
        }
        return logs
    }

    public func saveLogs(_ logs: [ExerciseLog]) throws {
        try persistence.save(logs, forKey: Self.logsKey)
    }

    public func addLog(_ log: ExerciseLog, to logs: inout [ExerciseLog]) throws {
        logs.insert(log, at: 0)
        try saveLogs(logs)
    }

    public func deleteLog(_ log: ExerciseLog, from logs: inout [ExerciseLog]) throws {
        logs.removeAll { $0.id == log.id }
        try saveLogs(logs)
    }

    public func clearAllLogs() throws {
        try saveLogs([])
    }

    // MARK: - Custom Exercises

    public func loadCustomExercises() throws -> [CustomExercise] {
        guard let exercises: [CustomExercise] = try persistence.load(forKey: Self.customExercisesKey, as: [CustomExercise].self) else {
            return []
        }
        return exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    public func saveCustomExercises(_ exercises: [CustomExercise]) throws {
        try persistence.save(exercises, forKey: Self.customExercisesKey)
    }

    public func addCustomExercise(_ exercise: CustomExercise, to exercises: inout [CustomExercise]) throws {
        var newExercise = exercise
        newExercise.sortOrder = exercises.count
        exercises.append(newExercise)
        try saveCustomExercises(exercises)
    }

    public func updateCustomExercise(_ exercise: CustomExercise, in exercises: inout [CustomExercise]) throws {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
            try saveCustomExercises(exercises)
        }
    }

    public func deleteCustomExercise(_ exercise: CustomExercise, from exercises: inout [CustomExercise]) throws {
        exercises.removeAll { $0.id == exercise.id }
        // Re-order remaining exercises
        for i in 0..<exercises.count {
            exercises[i].sortOrder = i
        }
        try saveCustomExercises(exercises)
    }

    public func moveCustomExercise(from source: IndexSet, to destination: Int, in exercises: inout [CustomExercise]) throws {
        // Manually implement move functionality since Array doesn't have move(fromOffsets:toOffset:)
        var movedElements: [CustomExercise] = []
        var remainingElements: [CustomExercise] = []

        for (index, exercise) in exercises.enumerated() {
            if source.contains(index) {
                movedElements.append(exercise)
            } else {
                remainingElements.append(exercise)
            }
        }

        // Insert moved elements at destination
        remainingElements.insert(contentsOf: movedElements, at: min(destination, remainingElements.count))
        exercises = remainingElements

        // Update sort orders
        for i in 0..<exercises.count {
            exercises[i].sortOrder = i
        }
        try saveCustomExercises(exercises)
    }

    // MARK: - Utility Methods

    public func getAllExercises(customExercises: [CustomExercise]) -> [ExerciseItem] {
        let builtIn = ExerciseType.allCases.map { ExerciseItem(builtIn: $0) }
        let custom = customExercises.sorted { $0.sortOrder < $1.sortOrder }
            .map { ExerciseItem(custom: $0) }
        return builtIn + custom
    }

    public func customExercise(byId id: UUID, in exercises: [CustomExercise]) -> CustomExercise? {
        exercises.first { $0.id == id }
    }

    // MARK: - Statistics

    public func todaysLogs(from logs: [ExerciseLog]) -> [ExerciseLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return logs.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }
    }

    public func todaysSummaries(from logs: [ExerciseLog]) -> [ExerciseSummary] {
        let todaysLogs = self.todaysLogs(from: logs)
        let builtInLogs = todaysLogs.filter { $0.exerciseType != nil }
        let grouped = Dictionary(grouping: builtInLogs) { $0.exerciseType! }
        return grouped.map { type, logs in
            ExerciseSummary(
                type: type,
                totalCount: logs.reduce(0) { $0 + $1.count },
                sessionCount: logs.count
            )
        }
        .sorted { $0.totalCount > $1.totalCount }
    }

    public func todaysCustomSummaries(from logs: [ExerciseLog], customExercises: [CustomExercise]) -> [CustomExerciseSummary] {
        let todaysLogs = self.todaysLogs(from: logs)
        let customLogs = todaysLogs.filter { $0.customExerciseId != nil }
        let grouped = Dictionary(grouping: customLogs) { $0.customExerciseId! }
        return grouped.compactMap { id, logs in
            guard let exercise = customExercise(byId: id, in: customExercises) else { return nil }
            return CustomExerciseSummary(
                customExercise: exercise,
                totalCount: logs.reduce(0) { $0 + $1.count },
                sessionCount: logs.count
            )
        }
        .sorted { $0.totalCount > $1.totalCount }
    }

    public func logsForLastDays(_ days: Int, from logs: [ExerciseLog]) -> [ExerciseLog] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }
        return logs.filter { $0.timestamp >= startDate }
    }
}
