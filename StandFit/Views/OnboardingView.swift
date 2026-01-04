//
//  OnboardingView.swift
//  StandFit
//
//  Simple, focused onboarding highlighting the core scheduling feature (UX24)
//

import SwiftUI
import StandFitCore

struct OnboardingView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    let isInitialOnboarding: Bool

    init(store: ExerciseStore, isInitialOnboarding: Bool = true) {
        self.store = store
        self.isInitialOnboarding = isInitialOnboarding
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                TabView(selection: $currentPage) {
                    // Page 1: Welcome & Core Value
                    WelcomePageView()
                        .tag(0)

                    // Page 2: Schedule Power (THE key feature)
                    SchedulePowerPageView(store: store)
                        .tag(1)

                    // Page 3: Reschedule Button Explanation
                    RescheduleExplainerPageView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .overlay(alignment: .bottom) {
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button {
                                withAnimation {
                                    currentPage -= 1
                                }
                            } label: {
                                Text(LocalizedString.Onboarding.back)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }

                        Spacer()

                        if currentPage < 2 {
                            Button {
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack {
                                    Text(LocalizedString.Onboarding.next)
                                    Image(systemName: "arrow.right")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                            }
                        } else {
                            Button {
                                completeOnboarding()
                            } label: {
                                HStack {
                                    Text(isInitialOnboarding ? LocalizedString.Onboarding.getStarted : LocalizedString.Onboarding.gotIt)
                                    Image(systemName: "checkmark")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 80)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if isInitialOnboarding {
                            completeOnboarding()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text(isInitialOnboarding ? LocalizedString.Onboarding.skip : LocalizedString.General.close)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func completeOnboarding() {
        if isInitialOnboarding {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(Date(), forKey: "onboardingCompletedDate")
        }
        dismiss()
    }
}

// MARK: - Page 1: Welcome

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: .blue.opacity(0.4), radius: 20)

                Image(systemName: "figure.stand")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }

            // Title and subtitle
            VStack(spacing: 12) {
                Text(LocalizedString.Onboarding.welcomeTitle)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(LocalizedString.Onboarding.welcomeSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            // Key benefit callout
            VStack(alignment: .leading, spacing: 16) {
                OnboardingBenefitRow(
                    icon: "calendar.badge.clock",
                    text: LocalizedString.Onboarding.benefitScheduling,
                    color: .blue
                )
                OnboardingBenefitRow(
                    icon: "slider.horizontal.3",
                    text: LocalizedString.Onboarding.benefitTimeBlocks,
                    color: .purple
                )
                OnboardingBenefitRow(
                    icon: "arrow.clockwise",
                    text: LocalizedString.Onboarding.benefitReschedule,
                    color: .green
                )
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

private struct OnboardingBenefitRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)

            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Page 2: Schedule Power

struct SchedulePowerPageView: View {
    @ObservedObject var store: ExerciseStore

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .purple.opacity(0.4), radius: 20)

                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }

                // Title and description
                VStack(spacing: 16) {
                    Text(LocalizedString.Onboarding.schedulePowerTitle)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(LocalizedString.Onboarding.schedulePowerDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Mini preview of time blocks
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedString.Onboarding.exampleSchedule)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Example time blocks
                    TimeBlockExampleRow(
                        icon: "sunrise.fill",
                        name: LocalizedString.Onboarding.exampleMorningRoutine,
                        time: "7:00 - 9:00",
                        interval: LocalizedString.Onboarding.exampleEvery30Min,
                        color: .orange
                    )

                    TimeBlockExampleRow(
                        icon: "laptopcomputer",
                        name: LocalizedString.Onboarding.exampleWorkTime,
                        time: "9:00 - 17:00",
                        interval: LocalizedString.Onboarding.exampleEvery60Min,
                        color: .blue
                    )

                    TimeBlockExampleRow(
                        icon: "moon.fill",
                        name: LocalizedString.Onboarding.exampleEvening,
                        time: "18:00 - 21:00",
                        interval: LocalizedString.Onboarding.exampleEvery45Min,
                        color: .purple
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 32)

                // Call to action
                NavigationLink {
                    if let profile = store.activeProfile {
                        DayScheduleEditorView(
                            store: store,
                            profile: .constant(profile)
                        )
                    } else {
                        Text(LocalizedString.Onboarding.noProfileYet)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text(store.activeProfile == nil ? LocalizedString.Onboarding.createYourSchedule : LocalizedString.Onboarding.viewYourSchedule)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                }

                Spacer()
                    .frame(height: 120)
            }
        }
    }
}

struct TimeBlockExampleRow: View {
    let icon: String
    let name: String
    let time: String
    let interval: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))

                HStack(spacing: 4) {
                    Text(time)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(interval)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Page 3: Reschedule Button Explainer

struct RescheduleExplainerPageView: View {
    @State private var animateReschedule = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .green.opacity(0.4), radius: 20)

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(animateReschedule ? 360 : 0))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                        animateReschedule = true
                    }
                }

                // Title and description
                VStack(spacing: 16) {
                    Text(LocalizedString.Onboarding.rescheduleTitle)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(LocalizedString.Onboarding.rescheduleDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Visual example of reschedule button
                VStack(spacing: 16) {
                    Text(LocalizedString.Onboarding.rescheduleButtonLocation)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Mock timer card with reschedule button
                    VStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text(LocalizedString.Onboarding.nextReminder)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            Text("15:42")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }

                        Divider()

                        // Reschedule button highlight
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(LocalizedString.Notifications.resetTimer)
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 3)
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 32)

                // When to use it
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedString.Onboarding.whenToReschedule)
                        .font(.headline)

                    UseCaseRow(
                        icon: "moon.zzz.fill",
                        text: LocalizedString.Onboarding.useCaseSleep,
                        color: .purple
                    )

                    UseCaseRow(
                        icon: "calendar.badge.exclamationmark",
                        text: LocalizedString.Onboarding.useCaseMeeting,
                        color: .orange
                    )

                    UseCaseRow(
                        icon: "figure.walk",
                        text: LocalizedString.Onboarding.useCaseErrand,
                        color: .green
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 120)
            }
        }
    }
}

struct UseCaseRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    OnboardingView(store: ExerciseStore.shared, isInitialOnboarding: true)
}
