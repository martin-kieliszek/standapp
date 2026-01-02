//
//  IconPickerView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/01/2026.
//

import SwiftUI
import StandFitCore

/// A swipeable icon picker using TabView with page style for WatchOS
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

    /// Group icons into pages for easier swiping (6 icons per page for watch)
    private var iconPages: [[String]] {
        stride(from: 0, to: Self.exerciseIcons.count, by: 6).map {
            Array(Self.exerciseIcons[$0..<min($0 + 6, Self.exerciseIcons.count)])
        }
    }

    /// Find which page contains the selected icon
    private var initialPage: Int {
        for (pageIndex, page) in iconPages.enumerated() {
            if page.contains(selectedIcon) {
                return pageIndex
            }
        }
        return 0
    }

    @State private var currentPage: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Select Icon")
                    .font(.headline)
                    .padding(.top, 4)

                TabView(selection: $currentPage) {
                    ForEach(0..<iconPages.count, id: \.self) { pageIndex in
                        IconGridPage(
                            icons: iconPages[pageIndex],
                            selectedIcon: $selectedIcon
                        )
                        .tag(pageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 110)

                // Current selection preview
                HStack(spacing: 8) {
                    Image(systemName: selectedIcon)
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text("Selected")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            currentPage = initialPage
        }
    }
}

/// A single page of icons in a 3x2 grid
struct IconGridPage: View {
    let icons: [String]
    @Binding var selectedIcon: String

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(icons, id: \.self) { icon in
                IconButton(
                    icon: icon,
                    isSelected: selectedIcon == icon
                ) {
                    selectedIcon = icon
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

/// Individual icon button in the picker
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(
                    isSelected
                        ? Color.blue.opacity(0.3)
                        : Color.clear
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
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
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(6)

                Text("Change Icon")
                    .font(.caption)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
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
