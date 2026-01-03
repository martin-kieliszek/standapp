//
//  SubscriptionTier.swift
//  StandFit
//
//  Subscription tier definitions and entitlements
//

import Foundation

/// Subscription tiers available in the app
enum SubscriptionTier: String, Codable {
    case free = "free"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .free: return "StandFit Free"
        case .premium: return "StandFit Premium"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .premium: return "$3.99/month"
        }
    }
}

/// Feature entitlements based on subscription tier
protocol FeatureEntitlement {
    var tier: SubscriptionTier { get }
    var customExerciseLimit: Int { get }
    var canAccessAchievements: Bool { get }
    var canAccessAdvancedAnalytics: Bool { get }
    var canAccessTimeline: Bool { get }
    var canAccessSocialFeatures: Bool { get }
    var canExportData: Bool { get }
    var historyDaysLimit: Int { get }
}

/// Concrete entitlement implementation
struct TierEntitlements: FeatureEntitlement {
    let tier: SubscriptionTier
    
    var customExerciseLimit: Int {
        switch tier {
        case .free: return 2
        case .premium: return Int.max
        }
    }
    
    var canAccessAchievements: Bool {
        tier == .premium
    }
    
    var canAccessAdvancedAnalytics: Bool {
        tier == .premium
    }
    
    var canAccessTimeline: Bool {
        tier == .premium
    }
    
    var canAccessSocialFeatures: Bool {
        tier == .premium
    }
    
    var canExportData: Bool {
        tier == .premium
    }
    
    var historyDaysLimit: Int {
        switch tier {
        case .free: return 7
        case .premium: return Int.max
        }
    }
}

/// Trial state tracking
struct TrialState: Codable {
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    
    var daysRemaining: Int {
        guard isActive else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
        return max(0, days)
    }
    
    var hasExpired: Bool {
        Date() >= endDate
    }
    
    static func create(duration: Int = 14) -> TrialState {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: duration, to: start) ?? start
        return TrialState(startDate: start, endDate: end, isActive: true)
    }
}
