//
//  TimelineGraphView.swift
//  StandFit iOS
//
//  Timeline visualization showing notifications vs exercises
//

import SwiftUI
import StandFitCore

// MARK: - Main Timeline Graph View

struct TimelineGraphView: View {
    let notifications: [TimelineEvent]
    let exercises: [TimelineEvent]

    @State private var selectedEvent: TimelineEvent?

    private let hourRange: ClosedRange<Int>
    private let calendar = Calendar.current

    init(notifications: [TimelineEvent], exercises: [TimelineEvent]) {
        self.notifications = notifications
        self.exercises = exercises

        // Calculate dynamic hour range based on data
        let allEvents = notifications + exercises
        if !allEvents.isEmpty {
            let hours = allEvents.map { $0.hourOfDay }
            let minHour = hours.min() ?? 9
            let maxHour = hours.max() ?? 17
            // Add padding
            hourRange = max(0, minHour - 1)...min(23, maxHour + 1)
        } else {
            // Default range: 9 AM to 9 PM
            hourRange = 9...21
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with analytics
            headerView

            if notifications.isEmpty && exercises.isEmpty {
                emptyStateView
            } else {
                // Timeline visualization
                VStack(alignment: .leading, spacing: 16) {
                    timelineView
                    
                    // Legend
                    legendView
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Timeline")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            if let analysis = timelineAnalysis {
                if let avgResponse = analysis.averageResponseTimeMinutes {
                    Text("\(Int(avgResponse))min avg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Timeline Visualization

    private var timelineView: some View {
        VStack(spacing: 16) {
            // Time axis labels
            timeAxisLabels

            // Notification track
            EventTrackView(
                events: notifications,
                hourRange: hourRange,
                trackType: .notification,
                selectedEvent: $selectedEvent
            )

            // Exercise track
            EventTrackView(
                events: exercises,
                hourRange: hourRange,
                trackType: .exercise,
                selectedEvent: $selectedEvent
            )
        }
    }

    private var timeAxisLabels: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(Array(hourRange), id: \.self) { hour in
                    Text(formatHour(hour))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .frame(width: geometry.size.width / CGFloat(hourRange.count))
                }
            }
        }
        .frame(height: 16)
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 16) {
            Label {
                Text("Notifications")
            } icon: {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            }
            .font(.caption)

            Label {
                Text("Exercises")
            } icon: {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.green)
            }
            .font(.caption)

            Spacer()

            if let analysis = timelineAnalysis {
                let responsePercent = Int(analysis.responseRate * 100)
                Text("\(responsePercent)% response rate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No activity today")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var timelineAnalysis: TimelineAnalysis? {
        guard !notifications.isEmpty || !exercises.isEmpty else { return nil }
        return TimelineAnalysis(notifications: notifications, exercises: exercises)
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 { return "12a" }
        if hour < 12 { return "\(hour)a" }
        if hour == 12 { return "12p" }
        return "\(hour - 12)p"
    }
}

// MARK: - Event Track View

enum TrackType {
    case notification
    case exercise

    var color: Color {
        switch self {
        case .notification: return .orange
        case .exercise: return .green
        }
    }

    var markerIcon: String {
        switch self {
        case .notification: return "circle.fill"
        case .exercise: return "checkmark"
        }
    }
}

struct EventTrackView: View {
    let events: [TimelineEvent]
    let hourRange: ClosedRange<Int>
    let trackType: TrackType
    @Binding var selectedEvent: TimelineEvent?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background line
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 2)

                // Event markers
                ForEach(events) { event in
                    eventMarker(for: event, in: geometry)
                }
            }
        }
        .frame(height: 32)
    }

    @ViewBuilder
    private func eventMarker(for event: TimelineEvent, in geometry: GeometryProxy) -> some View {
        let xPosition = calculateXPosition(for: event, in: geometry)

        Button {
            selectedEvent = event
        } label: {
            ZStack {
                // Background for tap area
                Circle()
                    .fill(.clear)
                    .frame(width: 24, height: 24)

                // Marker icon
                Image(systemName: trackType.markerIcon)
                    .font(.system(size: trackType == .notification ? 10 : 8, weight: .semibold))
                    .foregroundStyle(trackType.color)
            }
        }
        .buttonStyle(.plain)
        .position(x: xPosition, y: 16)
    }

    private func calculateXPosition(for event: TimelineEvent, in geometry: GeometryProxy) -> CGFloat {
        let totalMinutesInRange = (hourRange.upperBound - hourRange.lowerBound) * 60
        let eventMinutesSinceRangeStart = event.minuteOfDay - (hourRange.lowerBound * 60)

        let relativePosition = CGFloat(eventMinutesSinceRangeStart) / CGFloat(totalMinutesInRange)
        return relativePosition * geometry.size.width
    }
}

// MARK: - Preview

#Preview {
    let now = Date()
    let calendar = Calendar.current

    // Create sample notification events
    let notifications: [TimelineEvent] = [
        TimelineEvent(
            timestamp: calendar.date(byAdding: .hour, value: -6, to: now)!,
            type: .notificationFired
        ),
        TimelineEvent(
            timestamp: calendar.date(byAdding: .hour, value: -4, to: now)!,
            type: .notificationFired
        ),
        TimelineEvent(
            timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
            type: .notificationFired
        ),
    ]

    // Create sample exercise events
    let exercises: [TimelineEvent] = [
        TimelineEvent(
            timestamp: calendar.date(byAdding: .hour, value: -5, to: now)!,
            type: .exerciseLogged(item: ExerciseItem(builtIn: .squats), count: 15)
        ),
        TimelineEvent(
            timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
            type: .exerciseLogged(item: ExerciseItem(builtIn: .pushups), count: 10)
        ),
    ]

    return ScrollView {
        VStack(spacing: 20) {
            TimelineGraphView(notifications: notifications, exercises: exercises)
            TimelineGraphView(notifications: [], exercises: [])
        }
        .padding()
    }
}
