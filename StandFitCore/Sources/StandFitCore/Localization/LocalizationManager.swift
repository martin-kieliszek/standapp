//
//  LocalizationManager.swift
//  StandFitCore
//
//  Centralized localization and locale-aware formatting service
//  Supports 7 languages: en, es, fr, de, ja, zh-Hans, pt-BR
//

import Foundation
import Combine

/// Manages app localization, locale settings, and locale-aware formatting
public final class LocalizationManager: ObservableObject {

    public static let shared = LocalizationManager()

    /// Current locale (can be overridden for testing or user preference)
    @Published public var currentLocale: Locale

    /// All supported locales in the app
    public static let supportedLocales: [Locale] = [
        Locale(identifier: "en"),       // English (base)
        Locale(identifier: "es"),       // Spanish
        Locale(identifier: "fr"),       // French
        Locale(identifier: "de"),       // German
        Locale(identifier: "ja"),       // Japanese
        Locale(identifier: "zh-Hans"),  // Chinese Simplified
        Locale(identifier: "pt-BR")     // Portuguese (Brazil)
    ]

    /// Supported language codes for quick lookup
    public static let supportedLanguageCodes: Set<String> = [
        "en", "es", "fr", "de", "ja", "zh", "pt"
    ]

    private init() {
        // Initialize with device locale, fallback to English
        self.currentLocale = Self.deviceLocale()
    }

    /// Get the device's current locale, ensuring it's supported
    public static func deviceLocale() -> Locale {
        let deviceLocale = Locale.current

        // Check if device language is supported
        if let languageCode = deviceLocale.language.languageCode?.identifier,
           supportedLanguageCodes.contains(languageCode) {
            return deviceLocale
        }

        // Fallback to English
        return Locale(identifier: "en")
    }

    /// Check if a locale is supported
    public static func isSupported(locale: Locale) -> Bool {
        guard let languageCode = locale.language.languageCode?.identifier else {
            return false
        }
        return supportedLanguageCodes.contains(languageCode)
    }

    /// Override locale for testing or user preference
    public func setLocale(_ locale: Locale) {
        guard Self.isSupported(locale: locale) else {
            print("⚠️ LocalizationManager: Unsupported locale \(locale.identifier), ignoring")
            return
        }
        currentLocale = locale
    }

    /// Reset to device locale
    public func resetToDeviceLocale() {
        currentLocale = Self.deviceLocale()
    }

    // MARK: - Number Formatting

    /// Format an integer with locale-aware thousands separators
    public func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Format a double with locale-aware decimal separators
    public func formatDecimal(_ number: Double, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: number)) ?? String(format: "%.\(fractionDigits)f", number)
    }

    /// Format a percentage with locale-aware formatting
    public func formatPercent(_ value: Double, fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value * 100))%"
    }

    // MARK: - Currency Formatting

    /// Format currency based on locale and currency code
    public func formatCurrency(_ amount: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode

        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    /// Get currency symbol for current locale
    public func currencySymbol(for currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.currencySymbol ?? "$"
    }

    // MARK: - Date & Time Formatting

    /// Format date with locale-aware formatting
    public func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Format time with locale-aware formatting
    public func formatTime(_ date: Date, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = .none
        formatter.timeStyle = style
        return formatter.string(from: date)
    }

    /// Format date and time with locale-aware formatting
    public func formatDateTime(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }

    /// Format relative date (e.g., "2 days ago")
    public func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = currentLocale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Duration Formatting

    /// Format seconds as duration (e.g., "5:30" for 330 seconds)
    public func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        // Use locale-aware number formatting for components
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "0:%02d", remainingSeconds)
        }
    }

    /// Format seconds as long-form duration (e.g., "5 minutes, 30 seconds")
    public func formatDurationLong(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        var components: [String] = []

        if minutes > 0 {
            components.append(LocalizedString.Minutes.duration(minutes))
        }

        if remainingSeconds > 0 || minutes == 0 {
            components.append(LocalizedString.Seconds.duration(remainingSeconds))
        }

        // Join with locale-aware list separator
        let formatter = ListFormatter()
        formatter.locale = currentLocale
        return formatter.string(from: components) ?? components.joined(separator: ", ")
    }

    // MARK: - RTL Support

    /// Check if current locale uses right-to-left layout
    public var isRTL: Bool {
        return Locale.characterDirection(forLanguage: currentLocale.language.languageCode?.identifier ?? "en") == .rightToLeft
    }

    /// Get layout direction for current locale
    public var layoutDirection: LayoutDirection {
        return isRTL ? .rightToLeft : .leftToRight
    }

    public enum LayoutDirection {
        case leftToRight
        case rightToLeft
    }
}
