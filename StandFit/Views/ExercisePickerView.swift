//
//  ExercisePickerView.swift
//  StandFit iOS
//
//  Enhanced exercise picker with modern card design
//

import SwiftUI
import StandFitCore

/// A reusable exercise picker grid optimized for iPhone (3 columns)
/// Supports both built-in and custom exercises via ExerciseItem.
struct ExercisePickerView: View {
    @ObservedObject var store: ExerciseStore = ExerciseStore.shared
    let onSelect: (ExerciseItem) -> Void
    
    @State private var searchText = ""

    private let notificationManager = NotificationManager.shared
    
    // Computed properties for filtering and sectioning
    private var builtInExercises: [ExerciseItem] {
        store.allExercises.filter { $0.isBuiltIn }
    }
    
    private var customExercises: [ExerciseItem] {
        store.allExercises.filter { !$0.isBuiltIn }
    }
    
    private var filteredBuiltIn: [ExerciseItem] {
        if searchText.isEmpty {
            return builtInExercises
        }
        return builtInExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredCustom: [ExerciseItem] {
        if searchText.isEmpty {
            return customExercises
        }
        return customExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var hasResults: Bool {
        !filteredBuiltIn.isEmpty || !filteredCustom.isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            // Search bar (always visible for quick filtering)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                
                TextField("Search exercises...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            
            // Recent exercises section (if any, hidden when searching)
            if !store.recentExercises.isEmpty && searchText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.orange)
                            .font(.subheadline)
                        Text("Recent")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(store.recentExercises) { item in
                            ExercisePickerButton(item: item) {
                                notificationManager.playClickHaptic()
                                onSelect(item)
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.orange.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.orange.opacity(0.2), lineWidth: 1)
                )
            }
            
            if hasResults {
                VStack(spacing: 20) {
                    // Built-in exercises section
                    if !filteredBuiltIn.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundStyle(.blue)
                                    .font(.subheadline)
                                Text("Built-in Exercises")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredBuiltIn) { item in
                                    ExercisePickerButton(item: item) {
                                        notificationManager.playClickHaptic()
                                        onSelect(item)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Custom exercises section
                    if !filteredCustom.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.purple)
                                    .font(.subheadline)
                                Text("Custom Exercises")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredCustom) { item in
                                    ExercisePickerButton(item: item) {
                                        notificationManager.playClickHaptic()
                                        onSelect(item)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // No results state
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No exercises found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Try adjusting your search")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }
}

/// Individual exercise button for the picker grid (iOS-sized with enhanced design)
struct ExercisePickerButton: View {
    let item: ExerciseItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ExerciseColorPalette.color(for: item),
                                    ExerciseColorPalette.color(for: item).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: ExerciseColorPalette.color(for: item).opacity(0.3), radius: 4, x: 0, y: 2)

                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                Text(item.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(ExerciseColorPalette.color(for: item).opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Full-screen exercise picker presented from main view
/// Shows a title and the exercise grid, then opens the logger.
struct ExercisePickerFullScreenView: View {
    @ObservedObject var store: ExerciseStore
    @Binding var selectedExerciseItem: ExerciseItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("What did you do?")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Select an exercise to log your activity")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)

                        // Exercise grid in card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Exercise")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            ExercisePickerView(store: store) { item in
                                selectedExerciseItem = item
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(item: $selectedExerciseItem) { item in
                ExerciseLoggerView(
                    store: store,
                    exerciseItem: item
                )
            }
        }
    }
}

#Preview("Picker Grid") {
    ExercisePickerView { item in
        print("Selected: \(item.name)")
    }
    .padding()
}

#Preview("Full Screen") {
    ExercisePickerFullScreenView(
        store: ExerciseStore.shared,
        selectedExerciseItem: .constant(nil)
    )
}
