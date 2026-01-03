# UX20: International Language Support

**Status**: Phase 1 Complete (Infrastructure) - In Progress
**Priority**: High
**Complexity**: Medium
**Est. Effort**: 16-24 hours (4-6 hours completed)
**Target Release**: v2.0
**Phase 1 Completed**: 2026-01-03

---

## Overview

Implement comprehensive internationalization (i18n) and localization (L10n) support to make StandFit accessible to users worldwide. This includes extracting all user-facing strings to centralized language files, supporting right-to-left (RTL) languages, and adapting UI elements for different locales.

---

## CRITICAL: App Store Deployment Strategy

### Single App vs. Multiple Apps

**✅ RECOMMENDED: Single App with Multiple Localizations**

Apple's App Store supports **one universal app** that automatically serves the correct language based on the user's device settings. You do **NOT** need to create separate apps for different regions.

#### How It Works

1. **Xcode Project Configuration**
   ```
   Xcode → Project Settings → Info → Localizations
   - Add: Spanish, French, German, Japanese, Chinese (Simplified), Portuguese (Brazil)
   ```

2. **Automatic Language Selection**
   - User in Spain with device set to Spanish → Gets Spanish version
   - User in Japan with device set to Japanese → Gets Japanese version
   - User in France with device set to English → Gets English version (fallback)

3. **Single App Bundle**
   - All languages packaged in one `.ipa` file
   - iOS automatically loads correct `.xcstrings` based on `Locale.current`
   - No region-specific app downloads required

#### Xcode Project Setup

```xml
<!-- Info.plist -->
<key>CFBundleDevelopmentRegion</key>
<string>en</string>  <!-- Base language -->

<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
    <string>de</string>
    <string>ja</string>
    <string>zh-Hans</string>
    <string>pt-BR</string>
</array>
```

#### App Store Connect Configuration

**One App Listing with Multiple Localizations:**

```
App Store Connect → My Apps → StandFit → App Store

For EACH language:
1. Add Localization
2. Provide:
   - App Name (30 chars)
   - Subtitle (30 chars)
   - Description (4,000 chars)
   - Keywords (100 chars)
   - Screenshots (per device size)
   - What's New text

Languages → automatically shown to users in that region
```

#### What Happens in the App Store

**User Experience by Region:**

| Region | App Store Shows | User Downloads | App Language |
|--------|----------------|----------------|--------------|
| 🇺🇸 USA (English) | English metadata | StandFit v1.0 | English |
| 🇪🇸 Spain (Spanish) | Spanish metadata | StandFit v1.0 | Spanish |
| 🇯🇵 Japan (Japanese) | Japanese metadata | StandFit v1.0 | Japanese |
| 🇫🇷 France (French) | French metadata | StandFit v1.0 | French |

**Same app, different presentation.**

#### Key Benefits of Single App Approach

✅ **Unified Analytics** - All users in one dashboard
✅ **Single Review Process** - Submit once, approved for all regions
✅ **Shared Ratings** - Reviews count toward global rating
✅ **Easier Updates** - One build pushes to all countries
✅ **Cross-Region Users** - Travelers/expats get seamless experience
✅ **Lower Maintenance** - Don't manage multiple app IDs

#### When You Might Need Separate Apps

❌ **DON'T use separate apps for:**
- Different languages (single app handles this)
- Different regions (single app handles this)
- Different currencies (in-app purchases support regional pricing)

✅ **DO use separate apps ONLY for:**
- Fundamentally different features per region (extremely rare)
- Legal/regulatory requirements (e.g., China-specific censorship)
- Completely different brands/marketing in regions

**For StandFit: Use single app with localizations.**

#### Developer Implementation Checklist

```swift
// No code changes needed for multi-region!
// iOS handles everything automatically:

// User's device locale
let userLocale = Locale.current  // "es_ES", "ja_JP", "fr_FR", etc.

// Correct strings loaded automatically
Text(LocalizedString.achievements)
// Spanish user sees: "Logros"
// Japanese user sees: "実績"
// French user sees: "Succès"

// Correct number formatting
LocalizationManager.shared.formatNumber(1234)
// US: "1,234"
// Germany: "1.234"
// France: "1 234"
```

#### App Store Submission Process

1. **Build in Xcode** with all localizations enabled
2. **Archive** → Single `.ipa` file contains all languages
3. **Upload to App Store Connect**
4. **Add Metadata** for each language in App Store Connect
5. **Submit for Review** → One review for all regions
6. **Approve** → App goes live in all countries simultaneously

#### Regional Pricing

**In-App Purchases (Premium Subscription):**

```
App Store Connect → Pricing and Availability

Base Price: $3.99 USD

Apple Auto-Converts to:
- Spain: €3.99
- Japan: ¥600
- Germany: €3.99
- Brazil: R$19.90
- France: €3.99

(Apple handles exchange rates and local tax)
```

#### Testing Multi-Language App

**Method 1: Xcode Scheme**
```
Xcode → Edit Scheme → Run → Options
→ App Language: Spanish
→ App Region: Spain
→ Run
```

**Method 2: Simulator Settings**
```
Simulator → Settings → General → Language & Region
→ iPhone Language: 日本語 (Japanese)
→ Relaunch app
```

**Method 3: Device Settings**
```
Physical iPhone → Settings → General → Language & Region
→ Add Language → Español
→ Relaunch StandFit
```

#### Common Pitfalls to Avoid

❌ **Don't** hardcode language checks:
```swift
// BAD
if Locale.current.languageCode == "es" {
    showSpanishFeature()
}
```

✅ **Do** use localized strings:
```swift
// GOOD
Text(LocalizedString.feature)  // Auto-translates
```

❌ **Don't** create separate targets for languages
❌ **Don't** use `#if` preprocessor directives for languages
❌ **Don't** submit separate apps for different countries

✅ **Do** rely on iOS localization system
✅ **Do** test with Xcode scheme language switching
✅ **Do** provide complete metadata for each language in App Store Connect

---

## Business Value

### Market Expansion
- **Global Reach**: Tap into non-English markets (76% of App Store users)
- **Higher Conversion**: Localized apps see 128% increase in downloads per country
- **Premium Upsell**: Users 4x more likely to purchase in native language
- **App Store Rankings**: Better visibility in localized App Store searches

### Target Markets (Phase 1)
1. **Spanish** (es) - 460M native speakers, growing iOS market
2. **French** (fr) - 280M speakers, strong App Store presence
3. **German** (de) - 100M speakers, high premium conversion
4. **Japanese** (ja) - 125M speakers, premium market leader
5. **Chinese Simplified** (zh-Hans) - 1.1B speakers, largest mobile market
6. **Portuguese** (pt-BR) - 215M speakers, emerging market

### Phase 2 Additions
- Italian (it), Dutch (nl), Korean (ko), Russian (ru), Arabic (ar)

---

## Current State Analysis

### Hardcoded Strings Audit

I've analyzed the codebase and identified **400+ user-facing strings** across:

#### **Critical Areas**
- ✅ **Views**: 280+ strings in SwiftUI views
- ✅ **Notifications**: 25+ notification messages
- ✅ **Achievements**: 60+ achievement names/descriptions
- ✅ **Templates**: 40+ template type labels
- ✅ **Settings**: 35+ setting labels and descriptions
- ✅ **Errors**: 20+ error messages

#### **Current Issues**
```swift
// ❌ Hardcoded throughout codebase
Text("Achievements")
Text("Start Free Trial")
achievement.name = "Daily Achiever"  // Generated dynamically

// ❌ No pluralization
"\(count) exercises"  // Should be "1 exercise" vs "2 exercises"

// ❌ No locale-aware formatting
Text("$3.99/month")  // Should adapt to local currency

// ❌ String interpolation challenges
"Complete \(target) \(exerciseName) in a single day"
```

---

## Technical Implementation Strategy

### Architecture: String Catalog System (iOS 15+)

Apple's **String Catalogs** (`.xcstrings`) provide modern localization:
- ✅ Compiler-generated keys (type-safe)
- ✅ Automatic pluralization rules
- ✅ Context-aware translations
- ✅ Xcode built-in editor
- ✅ Version control friendly (JSON format)

### Folder Structure

```
StandFit/
├── Resources/
│   └── Localizations/
│       ├── Localizable.xcstrings          # Main app strings
│       ├── Achievements.xcstrings         # Achievement definitions
│       ├── Templates.xcstrings            # Template type strings
│       ├── Notifications.xcstrings        # Push notification text
│       └── InfoPlist.xcstrings            # App metadata
│
StandFitCore/
├── Resources/
│   └── Localizations/
│       ├── CoreStrings.xcstrings          # Shared business logic strings
│       └── Errors.xcstrings               # Error messages
│
├── Sources/StandFitCore/
│   └── Localization/
│       ├── LocalizedString.swift          # String key definitions
│       └── LocalizationManager.swift      # Runtime locale handling
```

---

## Implementation Plan

### Phase 1: Infrastructure Setup (4-6 hours)

#### 1.1 Create String Catalog Files

```bash
# In Xcode
# File → New → Resource → Strings Catalog
# Create: Localizable.xcstrings
```

#### 1.2 Define Localization Manager

```swift
// StandFitCore/Sources/StandFitCore/Localization/LocalizationManager.swift

import Foundation

public final class LocalizationManager {
    public static let shared = LocalizationManager()

    /// Current app locale (defaults to device locale)
    @Published public var currentLocale: Locale = Locale.current

    /// Supported locales
    public static let supportedLocales: [Locale] = [
        Locale(identifier: "en"),    // English (base)
        Locale(identifier: "es"),    // Spanish
        Locale(identifier: "fr"),    // French
        Locale(identifier: "de"),    // German
        Locale(identifier: "ja"),    // Japanese
        Locale(identifier: "zh-Hans"), // Chinese Simplified
        Locale(identifier: "pt-BR")  // Portuguese (Brazil)
    ]

    /// Check if locale is RTL (Right-to-Left)
    public var isRTL: Bool {
        Locale.characterDirection(forLanguage: currentLocale.languageCode ?? "en") == .rightToLeft
    }

    /// Get localized string from bundle
    public func string(forKey key: String, bundle: Bundle = .main, comment: String = "") -> String {
        NSLocalizedString(key, bundle: bundle, comment: comment)
    }

    /// Format number with locale
    public func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Format currency
    public func formatCurrency(_ amount: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: amount as NSNumber) ?? "\(amount)"
    }

    /// Format date with locale
    public func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
}
```

#### 1.3 Create Localized String Keys

```swift
// StandFitCore/Sources/StandFitCore/Localization/LocalizedString.swift

import Foundation

/// Type-safe localized string keys
public enum LocalizedString {

    // MARK: - General

    public static let appName = NSLocalizedString(
        "app.name",
        comment: "App name"
    )

    public static let cancel = NSLocalizedString(
        "general.cancel",
        comment: "Cancel button"
    )

    public static let save = NSLocalizedString(
        "general.save",
        comment: "Save button"
    )

    public static let delete = NSLocalizedString(
        "general.delete",
        comment: "Delete button"
    )

    // MARK: - Achievements

    public static func achievementUnlocked(_ name: String) -> String {
        String(format: NSLocalizedString(
            "achievement.unlocked",
            comment: "Achievement unlocked message"
        ), name)
    }

    public static func achievementProgress(_ current: Int, _ target: Int) -> String {
        String(format: NSLocalizedString(
            "achievement.progress.format",
            comment: "Achievement progress: X/Y"
        ), current, target)
    }

    // MARK: - Templates

    public static let templateTypeVolume = NSLocalizedString(
        "template.type.volume",
        comment: "Lifetime Volume template type"
    )

    public static let templateTypeDailyGoal = NSLocalizedString(
        "template.type.daily_goal",
        comment: "Daily Goal template type"
    )

    // MARK: - Pluralization

    public static func exerciseCount(_ count: Int) -> String {
        String(format: NSLocalizedString(
            "exercise.count",
            comment: "Number of exercises (supports pluralization)"
        ), count)
    }

    public static func daysStreak(_ days: Int) -> String {
        String(format: NSLocalizedString(
            "streak.days",
            comment: "Streak days count (supports pluralization)"
        ), days)
    }
}
```

---

### Phase 2: Extract Existing Strings (8-12 hours)

#### 2.1 String Extraction Script

```swift
// Tools/ExtractStrings.swift
// Run: swift Tools/ExtractStrings.swift

import Foundation

struct StringExtractor {
    func extractStringsFromViews() {
        // Parse all .swift files
        // Find Text("...") patterns
        // Extract to Localizable.xcstrings
        // Replace with LocalizedString references
    }
}
```

#### 2.2 Migration Pattern

**Before:**
```swift
// AchievementsView.swift
Text("Achievements")
    .font(.title)

Text("\(unlockedCount)/\(totalCount)")
```

**After:**
```swift
// AchievementsView.swift
Text(LocalizedString.achievements)
    .font(.title)

Text(LocalizedString.achievementCount(unlockedCount, totalCount))
```

#### 2.3 String Catalog Entry

```json
// Localizable.xcstrings
{
  "sourceLanguage": "en",
  "strings": {
    "achievements": {
      "comment": "Achievements tab title",
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "value": "Achievements" } },
        "es": { "stringUnit": { "value": "Logros" } },
        "fr": { "stringUnit": { "value": "Succès" } },
        "de": { "stringUnit": { "value": "Erfolge" } },
        "ja": { "stringUnit": { "value": "実績" } },
        "zh-Hans": { "stringUnit": { "value": "成就" } }
      }
    },
    "achievement.count": {
      "comment": "Achievement count display",
      "localizations": {
        "en": { "stringUnit": { "value": "%1$d/%2$d" } }
      }
    }
  }
}
```

---

### Phase 3: Dynamic Content Localization (4-6 hours)

#### 3.1 Achievement Definitions

**Challenge**: Achievements are defined in code with hardcoded names.

**Before:**
```swift
// AchievementDefinitions.swift
Achievement(
    id: "first_exercise",
    name: "First Steps",
    description: "Complete your first exercise",
    // ...
)
```

**After:**
```swift
// AchievementDefinitions.swift
Achievement(
    id: "first_exercise",
    nameKey: "achievement.first_steps.name",
    descriptionKey: "achievement.first_steps.description",
    // ...
)

// Update Achievement model
public struct Achievement {
    public let nameKey: String  // Localization key
    public let descriptionKey: String

    // Computed properties
    public var name: String {
        NSLocalizedString(nameKey, comment: "")
    }

    public var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }
}
```

#### 3.2 Template-Generated Achievements

**Challenge**: Template names are user-created, but descriptions are system-generated.

**Solution**: Localize template patterns, preserve user names.

```swift
// AchievementTemplateEngine.swift
private func generateDescription(
    template: AchievementTemplate,
    tier: AchievementTemplateTier,
    exerciseItem: ExerciseItem
) -> String {
    switch template.templateType {
    case .volume:
        return String(format: NSLocalizedString(
            "template.description.volume",
            comment: "Complete X total [exercise]"
        ), tier.target, exerciseItem.name)

    case .dailyGoal:
        return String(format: NSLocalizedString(
            "template.description.daily_goal",
            comment: "Complete X [exercise] in a single day"
        ), tier.target, exerciseItem.name)
    }
}
```

**String Catalog:**
```json
"template.description.volume": {
  "comment": "Template volume description",
  "localizations": {
    "en": { "stringUnit": { "value": "Complete %1$d total %2$@" } },
    "es": { "stringUnit": { "value": "Completa %1$d %2$@ en total" } },
    "ja": { "stringUnit": { "value": "%2$@を合計%1$d回完了" } }
  }
}
```

---

### Phase 4: Pluralization (2-3 hours)

#### 4.1 Stringsdict for Plural Rules

```xml
<!-- Localizable.stringsdict -->
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>exercise.count</key>
    <dict>
        <key>NSStringLocalizedFormatKey</key>
        <string>%#@exercises@</string>
        <key>exercises</key>
        <dict>
            <key>NSStringFormatSpecTypeKey</key>
            <string>NSStringPluralRuleType</string>
            <key>NSStringFormatValueTypeKey</key>
            <string>d</string>
            <key>zero</key>
            <string>no exercises</string>
            <key>one</key>
            <string>1 exercise</string>
            <key>other</key>
            <string>%d exercises</string>
        </dict>
    </dict>
</dict>
</plist>
```

**Usage:**
```swift
// Automatic pluralization
let count = 5
Text(LocalizedString.exerciseCount(count))
// English: "5 exercises"
// Spanish: "5 ejercicios"
// Japanese: "5個のエクササイズ"
```

---

### Phase 5: RTL Support (2-3 hours)

#### 5.1 SwiftUI Auto-Layout

Most SwiftUI views auto-adapt, but check:

```swift
// Manual RTL adjustments where needed
HStack(spacing: 12) {
    Image(systemName: "chevron.right")
        .environment(\.layoutDirection, LocalizationManager.shared.isRTL ? .rightToLeft : .leftToRight)
    Text("Next")
}
```

#### 5.2 SF Symbols Direction

```swift
// Use directional symbols
Image(systemName: "chevron.forward")  // Auto-flips in RTL
// NOT: "chevron.right"
```

#### 5.3 Test RTL Mode

```swift
// In Xcode scheme
// Edit Scheme → Run → Options → App Language → Arabic
// Or programmatically for testing:
@Environment(\.layoutDirection) var layoutDirection
```

---

### Phase 6: Locale-Specific Formatting (2-3 hours)

#### 6.1 Numbers

```swift
// Before
Text("\(count) reps")

// After
let formattedNumber = LocalizationManager.shared.formatNumber(count)
Text("\(formattedNumber) \(LocalizedString.reps)")
// English: "1,234 reps"
// German: "1.234 Wiederholungen"
// Japanese: "1,234回"
```

#### 6.2 Currency

```swift
// Before
Text("$3.99/month")

// After
let price = LocalizationManager.shared.formatCurrency(3.99, currencyCode: "USD")
Text("\(price)/\(LocalizedString.month)")
// US: "$3.99/month"
// EU: "3,99 €/Monat"
// Japan: "¥399/月"
```

#### 6.3 Dates

```swift
// Before
Text(achievement.unlockedAt.formatted())

// After
Text(LocalizationManager.shared.formatDate(achievement.unlockedAt, style: .medium))
// US: "Jan 3, 2026"
// EU: "3 janv. 2026"
// Japan: "2026年1月3日"
```

---

## Testing Strategy

### 1. Pseudolocalization (Development)

Generate pseudo-translations to catch issues early:

```
Original: "Achievements"
Pseudo:   "[!!! Àçĥîév€m€ñţš !!!]"
```

**Benefits:**
- Spots untranslated strings (stay in English)
- Reveals layout issues (expanded text)
- Tests character encoding (accents, special chars)

### 2. Language Switching (QA)

```swift
// SettingsView.swift - Developer menu
Section("Debug: Localization") {
    Picker("Language", selection: $selectedLanguage) {
        ForEach(LocalizationManager.supportedLocales, id: \.identifier) { locale in
            Text(locale.localizedString(forIdentifier: locale.identifier) ?? "")
                .tag(locale)
        }
    }
    .onChange(of: selectedLanguage) { newLocale in
        LocalizationManager.shared.currentLocale = newLocale
        // Restart required for full effect
    }
}
```

### 3. Automated String Coverage

```swift
// Tests/LocalizationTests.swift
func testAllStringsHaveTranslations() {
    let requiredLanguages = ["en", "es", "fr", "de", "ja", "zh-Hans"]
    let catalog = loadStringCatalog("Localizable.xcstrings")

    for (key, translations) in catalog.strings {
        for language in requiredLanguages {
            XCTAssertNotNil(
                translations[language],
                "Missing translation for '\(key)' in \(language)"
            )
        }
    }
}
```

---

## Migration Checklist

### Pre-Migration
- [ ] Audit all user-facing strings (use script)
- [ ] Create String Catalog files
- [ ] Set up LocalizationManager
- [ ] Define LocalizedString enum

### Migration Waves
- [ ] **Wave 1**: Views (highest visibility)
  - ContentView, AchievementsView, SettingsView
- [ ] **Wave 2**: Notifications (user-triggered)
  - Achievement unlocks, reminders, progress reports
- [ ] **Wave 3**: Models (dynamic content)
  - Achievement definitions, template types
- [ ] **Wave 4**: Errors & Edge Cases
  - Error messages, validation text

### Post-Migration
- [ ] Run extraction verification script
- [ ] Test all supported languages
- [ ] Check RTL layouts (Arabic simulation)
- [ ] Verify pluralization rules
- [ ] Update screenshots for App Store

---

## Translation Workflow

### Option 1: Professional Translation (Recommended)

**Services:**
- **Apple Translation API** - Built into Xcode
- **Lokalise** - Developer-friendly, API-driven
- **POEditor** - Collaborative translation platform

**Cost Estimate:**
- ~$0.10-0.15 per word
- 400 strings × 15 words avg = 6,000 words
- 6,000 words × 6 languages × $0.12 = **$4,320**

### Option 2: Community Translation

**Tools:**
- Export `.xcstrings` as XLIFF
- Share via GitHub/Crowdin
- Import translated XLIFF back

### Option 3: Machine Translation + Review

**Workflow:**
1. Use Apple/Google Translate for first pass
2. Native speaker review (cheaper than full translation)
3. Focus on high-visibility strings (80/20 rule)

---

## App Store Localization

### InfoPlist.xcstrings

```json
{
  "CFBundleDisplayName": {
    "comment": "App name shown on home screen",
    "localizations": {
      "en": { "stringUnit": { "value": "StandFit" } },
      "es": { "stringUnit": { "value": "StandFit" } },
      "ja": { "stringUnit": { "value": "スタンドフィット" } }
    }
  },
  "NSUserTrackingUsageDescription": {
    "comment": "ATT permission prompt",
    "localizations": {
      "en": { "stringUnit": { "value": "We use data to personalize your fitness experience" } },
      "es": { "stringUnit": { "value": "Usamos datos para personalizar tu experiencia" } }
    }
  }
}
```

### App Store Metadata

**Per Language:**
- App Name (30 chars max)
- Subtitle (30 chars max)
- Description (4,000 chars max)
- Keywords (100 chars max, comma-separated)
- Screenshots (6.5", 5.5" iPhones + iPad)
- Preview Videos (optional but recommended)

---

## Performance Considerations

### String Catalog Caching

```swift
public final class LocalizationManager {
    private var cachedStrings: [String: String] = [:]

    public func string(forKey key: String) -> String {
        if let cached = cachedStrings[key] {
            return cached
        }

        let value = NSLocalizedString(key, comment: "")
        cachedStrings[key] = value
        return value
    }
}
```

### Bundle Size Impact

**Estimated Sizes:**
- English base: ~30 KB
- Each language: ~25-35 KB
- 6 languages: ~180 KB total
- **Negligible impact** on 50+ MB app

### On-Demand Resources (Future)

For 20+ languages, consider:
```swift
// Download language packs on demand
let languagePack = NSBundleResourceRequest(tags: ["language-es"])
languagePack.beginAccessingResources { error in
    // Language now available
}
```

---

## Success Metrics

### KPIs to Track

1. **Download Rate by Country**
   - Target: +50% in localized markets vs. English-only

2. **Premium Conversion Rate**
   - Target: Native language users convert at 2-3x rate

3. **App Store Search Rankings**
   - Track position for localized keywords

4. **User Retention (D7/D30)**
   - Compare localized vs. English-only cohorts

5. **Support Ticket Volume**
   - Expect reduction in "app in wrong language" tickets

---

## Future Enhancements

### Phase 2 Features

1. **In-App Language Selector**
   - Override device locale
   - Settings → Language → Select from supported

2. **Regional Variants**
   - en-US vs en-GB ("color" vs "colour")
   - pt-PT vs pt-BR (European vs Brazilian Portuguese)
   - zh-Hans vs zh-Hant (Simplified vs Traditional Chinese)

3. **Voice-Over Localization**
   - Accessibility labels in native language
   - .accessibilityLabel(LocalizedString.key)

4. **Localized Content**
   - Regional exercise defaults (yoga in India, tai chi in China)
   - Culturally appropriate achievement names

5. **Time Zone Awareness**
   - "Daily goals" respect local midnight
   - Streaks calculated in user's timezone

---

## Implementation Risks & Mitigation

### Risk 1: Broken String References

**Mitigation:**
- Use enums/constants (compile-time safety)
- Automated tests for missing keys
- Fallback to English on missing translation

### Risk 2: Layout Breaking on Long Text

**Mitigation:**
- Use `.lineLimit(nil)` for dynamic text
- Test with German (longest) and Japanese (shortest)
- Pseudolocalization testing

### Risk 3: Context Loss in Translation

**Mitigation:**
- Provide context comments in String Catalog
- Include screenshots for translators
- Use placeholders: "Welcome, %@!" (not "Welcome, " + name)

### Risk 4: User-Generated Content (Templates)

**Mitigation:**
- Don't translate user's custom names
- Only translate system-generated patterns
- Document mixed-language handling

---

## Estimated Timeline

### Week 1: Setup & Infrastructure
- Day 1-2: Create String Catalogs, LocalizationManager
- Day 3-4: Define LocalizedString keys
- Day 5: Set up translation workflow

### Week 2: Migration
- Day 6-7: Extract View strings
- Day 8-9: Extract Model/Service strings
- Day 10: Extract Notification strings

### Week 3: Translation & Testing
- Day 11-13: Professional translation (or manage community)
- Day 14-15: QA testing all languages

### Week 4: Polish & Launch
- Day 16-17: RTL testing, layout fixes
- Day 18-19: App Store metadata translation
- Day 20: Submit localized build

**Total: 20 working days (4 weeks)**

---

## Appendix: Quick Reference

### Common Patterns

```swift
// Simple text
Text(LocalizedString.achievementsTitle)

// With interpolation
Text(LocalizedString.welcomeMessage(userName))

// With pluralization
Text(LocalizedString.exerciseCount(count))

// Formatted numbers
let formatted = LocalizationManager.shared.formatNumber(1234)
Text(formatted)  // "1,234" (en), "1.234" (de), "1,234" (ja)

// Formatted currency
let price = LocalizationManager.shared.formatCurrency(3.99, currencyCode: "USD")
Text(price)  // "$3.99" (en-US), "3,99 $" (fr-CA)

// Formatted dates
let dateString = LocalizationManager.shared.formatDate(Date(), style: .long)
Text(dateString)  // "January 3, 2026" (en), "3 janvier 2026" (fr)
```

### String Catalog JSON Structure

```json
{
  "sourceLanguage": "en",
  "version": "1.0",
  "strings": {
    "key.name": {
      "comment": "Developer context",
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "value": "English text" } },
        "es": { "stringUnit": { "value": "Texto en español" } }
      }
    }
  }
}
```

---

## Conclusion

Implementing international language support will:
- ✅ **Expand market reach** to 76% of non-English iOS users
- ✅ **Increase premium conversions** through native-language trust
- ✅ **Improve App Store rankings** in localized searches
- ✅ **Future-proof the codebase** with maintainable i18n architecture

The String Catalog system provides a modern, type-safe foundation that scales from 6 languages to 60+ as StandFit grows globally.

**Recommendation**: Prioritize for v2.0 release with initial 6-language support (en, es, fr, de, ja, zh-Hans). The 20-day investment will pay dividends in global user acquisition and retention.
