# StandFit UX Issues Index

This directory contains detailed documentation for all UX issues identified in the StandFit project. The original 4321-line UX_ISSUES.md file has been split into manageable, focused documents for easier navigation and maintenance.

## Priority Tasks Queue

| ID | Issue | Status | Completion Date | Document |
|----|-------|--------|-----------------|----------|
| UX1 | Silent interval/settings changes - no user feedback when notifications reschedule | ✅ Complete | 2026-01-01 | [ux01-silent-settings-changes.md](./ux01-silent-settings-changes.md) |
| UX2 | Missed notifications lost forever - need "dead response reset" with configurable timeout | ✅ Complete | 2026-01-01 | [ux02-dead-response-reset.md](./ux02-dead-response-reset.md) |
| UX3 | Hardcoded exercises - users cannot add custom exercises or choose icons | ✅ Complete | 2026-01-01 | [ux03-custom-exercises.md](./ux03-custom-exercises.md) |
| UX4 | Additional UX polish items (see below) | ⏳ Pending | — | [ux04-additional-polish-items.md](./ux04-additional-polish-items.md) |
| UX5 | "Log Exercise" notification lands on main view instead of exercise picker | ✅ Complete | 2026-01-01 | [ux05-notification-log-exercise-deep-link.md](./ux05-notification-log-exercise-deep-link.md) |
| UX6 | "Reset Timer" button doesn't indicate what interval it will reset to | ✅ Complete | 2026-01-02 | [ux06-reset-timer-button-lacks-context.md](./ux06-reset-timer-button-lacks-context.md) |
| UX7 | No warning when Focus Mode may block notifications | ⏳ Pending | — | [ux07-focus-mode-notification-warning.md](./ux07-focus-mode-notification-warning.md) |
| UX8 | No progress comparison view (day/week/month/year reporting) | ✅ Complete | 2026-01-01 | [ux08-progress-reporting-view.md](./ux08-progress-reporting-view.md) |
| UX9 | No automatic progress report notifications | ✅ Complete | 2026-01-01 | [ux09-automatic-progress-report-notifications.md](./ux09-automatic-progress-report-notifications.md) |
| UX10 | No gamification (streaks, achievements, milestones) | ✅ Complete | 2026-01-02 | [ux10-gamification-system.md](./ux10-gamification-system.md) |
| UX11 | No social features (friends, sharing, leaderboards) | ⏳ Pending | — | [ux11-social-features.md](./ux11-social-features.md) |
| UX12 | Snooze +5min button resets schedule instead of legitimate snooze | ⏳ Pending | — | [ux12-snooze-button-notification-behavior.md](./ux12-snooze-button-notification-behavior.md) |
| UX13 | Progress Report crashes when selecting Week or Month period | ✅ Complete | 2026-01-02 | [ux13-progress-report-crash.md](./ux13-progress-report-crash.md) |
| UX14 | Notification vs. Exercise Timeline visualization | ✅ Complete | 2026-01-02 | [ux14-notification-vs-exercise-timeline.md](./ux14-notification-vs-exercise-timeline.md) |
| UX15 | Monetization Strategy (analysis) | 📋 Strategy Phase | — | [ux15-monetization-strategy.md](./ux15-monetization-strategy.md) |
| UX16 | User-created achievement templates for custom exercises | ⏳ Pending | — | [ux16-user-created-achievement-templates.md](./ux16-user-created-achievement-templates.md) |
| UX17 | Multi-platform deployment strategy (iOS/WatchOS) | 📋 Strategy Phase | — | [ux17-multi-platform-deployment-strategy.md](./ux17-multi-platform-deployment-strategy.md) |
| UX18 | iOS Widgets - Home Screen & Lock Screen engagement | ⏳ Pending | — | [ux18-ios-widgets.md](./ux18-ios-widgets.md) |
| UX19 | Advanced Reminder Scheduling - Per-day, time blocks, profiles | ⏳ Pending | — | [ux19-advanced-reminder-scheduling.md](./ux19-advanced-reminder-scheduling.md) |
| UX20 | International Language Support - Localization & i18n | 🚧 In Progress | — | [UX20_INTERNATIONAL_LANGUAGES.md](./UX20_INTERNATIONAL_LANGUAGES.md), [Progress](./UX20_IMPLEMENTATION_PROGRESS.md) |

## Status Legend

- ✅ **Complete**: Issue has been fully implemented and resolved
- ⏳ **Pending**: Issue identified but not yet implemented
- 📋 **Strategy Phase**: Analysis and planning document, not a bug or feature request

## Quick Links by Category

### Completed Issues
- [UX1: Silent Settings Changes](./ux01-silent-settings-changes.md)
- [UX2: Dead Response Reset](./ux02-dead-response-reset.md)
- [UX3: Custom Exercises](./ux03-custom-exercises.md)
- [UX5: Notification Deep Link](./ux05-notification-log-exercise-deep-link.md)
- [UX6: Reset Timer Button Context](./ux06-reset-timer-button-lacks-context.md)
- [UX8: Progress Reporting View](./ux08-progress-reporting-view.md)
- [UX9: Automatic Progress Report Notifications](./ux09-automatic-progress-report-notifications.md)
- [UX10: Gamification System](./ux10-gamification-system.md)
- [UX13: Progress Report Crash Fix](./ux13-progress-report-crash.md)
- [UX14: Notification vs. Exercise Timeline](./ux14-notification-vs-exercise-timeline.md)

### Pending Issues
- [UX4: Additional Polish Items](./ux04-additional-polish-items.md)
- [UX7: Focus Mode Warning](./ux07-focus-mode-notification-warning.md)
- [UX11: Social Features](./ux11-social-features.md)
- [UX12: Snooze Button Behavior](./ux12-snooze-button-notification-behavior.md)
- [UX16: User-Created Achievement Templates](./ux16-user-created-achievement-templates.md)
- [UX18: iOS Widgets](./ux18-ios-widgets.md)
- [UX19: Advanced Reminder Scheduling](./ux19-advanced-reminder-scheduling.md)
- [UX20: International Language Support](./UX20_INTERNATIONAL_LANGUAGES.md) - [Implementation Progress](./UX20_IMPLEMENTATION_PROGRESS.md)

### Strategy & Analysis Documents
- [UX15: Monetization Strategy](./ux15-monetization-strategy.md)
- [UX17: Multi-Platform Deployment Strategy](./ux17-multi-platform-deployment-strategy.md)

## Document Organization

Each UX issue document contains:
- **Status**: Current state (Complete, Pending, Strategy Phase)
- **Problem**: Description of the issue
- **Solution**: Implemented solution or proposed approach
- **Implementation Details**: Code snippets, data models, and technical specifications
- **Files Changed**: List of affected files
- **Dependencies**: Required frameworks or external dependencies

## Contributing

When updating UX issue documents:
1. Update the status and completion date in both the individual file and this INDEX.md
2. Keep the priority table in sync with individual documents
3. Add any new files created to the "Files Changed" section
4. Document any new dependencies or breaking changes

## Related Documentation

- [Main UX_ISSUES.md](../../UX_ISSUES.md) - Original consolidated document (4321 lines)
- [IOS_PORT.md](../../IOS_PORT.md) - iOS porting notes
- [NOTIFICATION_ISSUE.md](../../NOTIFICATION_ISSUE.md) - Notification-specific issues
