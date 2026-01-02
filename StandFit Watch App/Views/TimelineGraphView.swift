//
//  TimelineGraphView.swift
//  StandFit Watch App
//
//  Created by Claude on 01/02/2026.
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
        VStack(alignment: .leading, spacing: 8) {
            // Header with analytics
            headerView

            if notifications.isEmpty && exercises.isEmpty {
                emptyStateView
            } else {
                // Timeline visualization
                timelineView
                    .frame(height: 100)

                // Legend
                legendView
            }
        }
        .padding()
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Timeline")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Spacer()

            if let analysis = timelineAnalysis {
                if let avgResponse = analysis.averageResponseTimeMinutes {
                    Text("\(Int(avgResponse))min avg")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Timeline Visualization

    private var timelineView: some View {
        VStack(spacing: 12) {
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
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: geometry.size.width / CGFloat(hourRange.count))
                }
            }
        }
        .frame(height: 12)
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 12) {
            Label {
                Text("Notif")
            } icon: {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
            }
            .font(.system(size: 9))

            Label {
                Text("Exercise")
            } icon: {
                Image(systemName: "checkmark")
                    .font(.system(size: 6))
                    .foregroundStyle(.green)
            }
            .font(.system(size: 9))

            Spacer()

            if let analysis = timelineAnalysis {
                let responsePercent = Int(analysis.responseRate * 100)
                Text("\(responsePercent)% response")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 4) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("No activity today")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
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
                    .fill(.gray.opacity(0.2))
                    .frame(height: 1)

                // Event markers
                ForEach(events) { event in
                    eventMarker(for: event, in: geometry)
                }
            }
        }
        .frame(height: 20)
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
                    .frame(width: 16, height: 16)

                // Marker icon
                Image(systemName: trackType.markerIcon)
                    .font(.system(size: trackType == .notification ? 8 : 6))
                    .foregroundStyle(trackType.color)
            }
        }
        .buttonStyle(.plain)
        .position(x: xPosition, y: 10)
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
        VStack(spacing: 16) {
            TimelineGraphView(notifications: notifications, exercises: exercises)
            TimelineGraphView(notifications: [], exercises: [])
        }
        .padding()
    }
}
