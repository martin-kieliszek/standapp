//
//  StandFitCore+iOS.swift
//  StandFit iOS
//
//  iOS-specific extensions for StandFitCore types
//

import SwiftUI
import StandFitCore

// MARK: - AchievementTier Color Extension

extension AchievementTier {
    /// SwiftUI color for this achievement tier (platform-specific)
    var color: Color {
        switch self {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        }
    }

    /// SF Symbol icon for this achievement tier
    var icon: String {
        switch self {
        case .bronze: return "medal.fill"
        case .silver: return "star.fill"
        case .gold: return "crown.fill"
        case .platinum: return "sparkles"
        }
    }

    /// Display name for tier
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - ExerciseItem Color Palette

/// Color palette for exercise items (platform-specific)
struct ExerciseColorPalette {
    // Predefined colors for built-in exercises
    private static let builtInColors: [ExerciseType: Color] = [
        .squats: .blue,
        .pushups: .green,
        .lunges: .orange,
        .plank: .purple
    ]

    // Extended palette for custom exercises (carefully chosen for iOS visibility)
    private static let customColorPalette: [Color] = [
        .teal,
        .cyan,
        .mint,
        .indigo,
        .pink,
        .yellow,
        .red,
        Color(red: 0.0, green: 0.8, blue: 0.4),  // emerald
        Color(red: 1.0, green: 0.4, blue: 0.0),  // deep orange
        Color(red: 0.6, green: 0.2, blue: 0.8),  // violet
        Color(red: 0.0, green: 0.7, blue: 0.9),  // sky blue
        Color(red: 1.0, green: 0.7, blue: 0.0),  // amber
    ]

    // Cache for custom exercise colors
    private static var customExerciseColors: [String: Color] = [:]

    static func color(for item: ExerciseItem) -> Color {
        // Check if it's a built-in exercise
        if let type = item.builtInType {
            return builtInColors[type] ?? .gray
        }

        // For custom exercises, assign a consistent color based on ID
        if let cached = customExerciseColors[item.id] {
            return cached
        }

        // Assign new color from palette
        let index = customExerciseColors.count % customColorPalette.count
        let color = customColorPalette[index]
        customExerciseColors[item.id] = color
        return color
    }

    // Reset cache (useful if exercises are deleted)
    static func resetCache() {
        customExerciseColors.removeAll()
    }
}

// MARK: - TimelineEventType Color Extension

extension TimelineEventType {
    /// SwiftUI color for this event type (platform-specific)
    var color: Color {
        switch self {
        case .notificationFired:
            return .orange
        case .exerciseLogged(let item, _):
            return ExerciseColorPalette.color(for: item)
        }
    }
}
