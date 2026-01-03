//
//  IconPickerView.swift
//  StandFit iOS
//
//  iOS-optimized icon picker using LazyVGrid instead of TabView
//

import SwiftUI
import StandFitCore

/// A grid-based icon picker optimized for iPhone screens
struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    /// Curated list of exercise-appropriate SF Symbols
    static let exerciseIcons: [String] = [
        // Fitness & Body
        "figure.stand",
        "figure.walk",
        "figure.run",
        "figure.cooldown",
        "figure.core.training",
        "figure.cross.training",
        "figure.flexibility",
        "figure.highintensity.intervaltraining",
        "figure.jumprope",
        "figure.mixed.cardio",
        "figure.pilates",
        "figure.rower",
        "figure.stairs",
        "figure.step.training",
        "figure.strengthtraining.traditional",
        "figure.strengthtraining.functional",
        "figure.yoga",
        "figure.dance",
        "figure.martial.arts",
        "figure.boxing",
        "figure.kickboxing",
        "figure.taichi",
        "figure.hiking",
        "figure.climbing",
        "figure.elliptical",
        "figure.indoor.cycle",
        "figure.outdoor.cycle",
        "figure.rolling",
        "figure.skiing.downhill",
        "figure.skiing.crosscountry",
        "figure.snowboarding",
        "figure.pool.swim",
        "figure.open.water.swim",
        "figure.surfing",
        "figure.water.fitness",
        // Sports
        "sportscourt",
        "basketball",
        "football",
        "tennis.racket",
        "volleyball",
        "baseball",
        "dumbbell",
        "dumbbell.fill",
        // Health & Timer
        "heart",
        "heart.fill",
        "bolt.heart",
        "waveform.path.ecg",
        "lungs",
        "brain.head.profile",
        "timer",
        "stopwatch",
        "clock",
        // Other activities
        "bed.double",
        "zzz",
        "drop",
        "cup.and.saucer",
        "fork.knife",
        "leaf",
        "wind",
        "flame",
        "flame.fill",
        "sparkles",
        "star",
        "star.fill",
        "bolt",
        "bolt.fill",
        "hand.raised",
        "hands.clap",
        "hand.thumbsup",
        "checkmark.circle",
        "checkmark.seal"
    ]

    // Use 4 icons per row for iPhone screens
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(LocalizedString.UI.selectIcon)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Self.exerciseIcons, id: \.self) { icon in
                            IconButton(
                                icon: icon,
                                isSelected: selectedIcon == icon
                            ) {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Current selection preview
                HStack(spacing: 12) {
                    Image(systemName: selectedIcon)
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("\(LocalizedString.UI.selected) \(selectedIcon)")
                        .font(.headline)
                    Spacer()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)

                Button(LocalizedString.UI.done) {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.bottom, 16)
            }
        }
    }
}

/// Individual icon button in the picker (iOS-sized)
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected
                        ? Color.blue.opacity(0.2)
                        : Color(.systemGray6)
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Inline icon picker for embedding in forms (shows current icon + opens full picker)
struct IconPickerButton: View {
    @Binding var selectedIcon: String
    @State private var showingPicker = false

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack {
                Image(systemName: selectedIcon)
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 32, height: 32)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)

                Text(LocalizedString.UI.changeIcon)
                    .font(.body)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
    }
}

#Preview("Icon Picker") {
    IconPickerView(selectedIcon: .constant("figure.stand"))
}

#Preview("Icon Picker Button") {
    IconPickerButton(selectedIcon: .constant("figure.run"))
        .padding()
}
