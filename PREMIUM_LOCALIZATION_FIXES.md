# Premium Localization Key Mapping Issues

## Summary
LocalizedString.Premium enum references string keys that don't exist in Premium.xcstrings.
Need to update LocalizedString.swift to use the actual keys from Premium.xcstrings.

## Mismatched Keys

### Keys in Premium.xcstrings (ACTUAL)
- `premium.title`
- `premium.start_free_trial`
- `premium.restore_purchases`
- `premium.subscribe`
- `premium.cancel_anytime`
- `premium.free_trial` (format: "%lld-day free trial")
- `premium.monthly_price` (format: "%@ / month")
- `premium.yearly_price` (format: "%@ / year")
- `premium.custom_exercises`
- `premium.feature_achievements`
- `premium.feature_advanced_stats`
- `premium.feature_custom_templates`
- `premium.feature_progress_reports`
- `premium.feature_unlimited_exercises`
- `premium.feature_unlimited_profiles`
- `premium.unlock_all`
- `premium.privacy_policy`
- `premium.terms_of_use`
- `premium.best_value_badge`
- `premium.close_button`
- `premium.navigation_title`
- `premium.per_month`
- `premium.per_year`
- `premium.premium_feature`
- `premium.purchase_failed`
- `premium.save_percentage`
- `premium.subscription_status`
- `premium.get_more`
- `premium.upgrade_to_premium`
- `premium.subscription_navigation`
- `premium.dev_mode_testing`
- `premium.dev_mode_footer`
- `premium.enable_dev_mode`
- `premium.simulate_tier`
- `premium.free_tier`
- `premium.premium_tier`
- `premium.active_trial`
- `premium.trial_days_format`
- `premium.trial_ends`

### Keys in LocalizedString.Premium (EXPECTED - WRONG)
- `premium.title` ✅ MATCHES
- `premium.unlock` ❌ NOT IN XCSTRINGS
- `premium.start_free_trial` ✅ MATCHES
- `premium.restore` ❌ should be `premium.restore_purchases`
- `premium.upgrade_now` ❌ NOT IN XCSTRINGS
- `premium.active` ❌ NOT IN XCSTRINGS
- `premium.trial_active` ❌ should be `premium.active_trial`
- `premium.limited_features` ❌ NOT IN XCSTRINGS
- `premium.all_features_unlocked` ❌ should be `premium.unlock_all`
- `premium.feature.custom_exercises` ❌ should be `premium.custom_exercises`
- `premium.feature.templates` ❌ should be `premium.feature_custom_templates`
- `premium.feature.advanced_stats` ❌ should be `premium.feature_advanced_stats` ✅
- `premium.feature.achievement_system` ❌ should be `premium.feature_achievements`
- `premium.feature.advanced_analytics` ❌ NOT IN XCSTRINGS
- `premium.feature.timeline` ❌ NOT IN XCSTRINGS
- `premium.feature.unlimited_custom` ❌ should be `premium.feature_unlimited_exercises`
- `premium.feature.export` ❌ NOT IN XCSTRINGS
- `premium.feature.icloud` ❌ NOT IN XCSTRINGS
- (many description keys that don't exist in xcstrings)
- `premium.trial_duration` ❌ should be `premium.free_trial`
- `premium.trial_no_payment` ❌ should be `premium.cancel_anytime`
- `premium.trial_free_desc` ❌ NOT IN XCSTRINGS
- `premium.subscription_renew_note` ❌ NOT IN XCSTRINGS
- `premium.days_remaining` ❌ NOT IN XCSTRINGS
- `premium.days_remaining_in_trial` ❌ NOT IN XCSTRINGS
- `premium.best_value` ❌ should be `premium.best_value_badge`
- `premium.per_month` ✅ MATCHES
- `premium.per_year` ✅ MATCHES
- `premium.save_amount` ❌ should be `premium.save_percentage`
- And many more...

## Action Required
Update LocalizedString.Premium to match Premium.xcstrings exactly.

## Notes
- Premium.xcstrings is the source of truth (already has all 7 language translations)
- LocalizedString.swift must be updated to use these exact keys
- PaywallView.swift and SubscriptionSettingsView.swift may need updates to use correct keys
