//
//  StandFitCore.swift
//  StandFitCore
//
//  Shared business logic for StandFit (iOS & WatchOS)
//
//  This module contains all platform-agnostic code:
//  - Data models (Exercise, Gamification, Reporting, Timeline)
//  - Business logic services (Exercise, Gamification, Reporting, Timeline)
//  - Localization (LocalizationManager, LocalizedString enums)
//  - Persistence layer (protocol-based, supports JSON files, Core Data, CloudKit)
//  - Utility functions (notification scheduling calculations)
//
//  Platform-specific code (UI, notification managers, haptics) remains in app targets.
//

import Foundation

// MARK: - Module Version

public struct StandFitCore {
    public static let version = "1.1.0"
    public static let buildDate = "2026-01-03"
}

// MARK: - Public API

// Models are exported automatically from their respective files
// Services are exported automatically from their respective files
// Persistence protocols are exported automatically

// This file serves as documentation for the module structure
