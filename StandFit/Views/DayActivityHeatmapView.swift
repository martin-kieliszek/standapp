//
//  DayActivityHeatmapView.swift
//  StandFit
//
//  GitHub-style activity heatmap for a single day
//

import SwiftUI
import StandFitCore

struct DayActivityHeatmapView: View {
    let notifications: [TimelineEvent]
    let exercises: [TimelineEvent]
    
    private let calendar = Calendar.current
    private let hours = Array(0...23)
    
    private var uniqueExerciseItems: [ExerciseItem] {
        var items: [ExerciseItem] = []
        var seenIds = Set<String>()
        
        for event in exercises {
            if case .exerciseLogged(let item, _) = event.type {
                if !seenIds.contains(item.id) {
                    seenIds.insert(item.id)
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    private func exercisesForItem(_ item: ExerciseItem) -> [TimelineEvent] {
        exercises.filter { event in
            if case .exerciseLogged(let eventItem, _) = event.type {
                return eventItem.id == item.id
            }
            return false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Hour labels
                HStack(spacing: 0) {
                    Text("") // Spacer for row labels
                        .frame(width: 80, alignment: .leading)
                    
                    ForEach([0, 6, 12, 18], id: \.self) { hour in
                        Text("\(hour)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Notification row
                activityRow(
                    label: "Notifications",
                    events: notifications,
                    color: .blue
                )
                
                // Exercise row
                activityRow(
                    label: "Exercises",
                    events: exercises,
                    color: .green
                )
                
                // Individual exercise type rows
                ForEach(uniqueExerciseItems, id: \.id) { item in
                    activityRow(
                        label: "  \(item.name)",
                        events: exercisesForItem(item),
                        color: ExerciseColorPalette.color(for: item)
                    )
                }
                
                // Legend
                HStack(spacing: 16) {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(width: 12, height: 12)
                        Text("None")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Text("Low")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 12, height: 12)
                        Text("Medium")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                        Text("High")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func activityRow(label: String, events: [TimelineEvent], color: Color) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            HStack(spacing: 2) {
                ForEach(hours, id: \.self) { hour in
                    let count = eventCount(for: hour, in: events)
                    let intensity = calculateIntensity(count: count, maxCount: maxCountInHour(events))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForIntensity(intensity, baseColor: color))
                        .frame(height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(Color(.systemGray4).opacity(0.3), lineWidth: 0.5)
                        )
                        .help(tooltipText(hour: hour, count: count, label: label))
                }
            }
        }
    }
    
    private func eventCount(for hour: Int, in events: [TimelineEvent]) -> Int {
        events.filter { $0.hourOfDay == hour }.count
    }
    
    private func maxCountInHour(_ events: [TimelineEvent]) -> Int {
        let counts = hours.map { hour in
            eventCount(for: hour, in: events)
        }
        return counts.max() ?? 1
    }
    
    private func calculateIntensity(count: Int, maxCount: Int) -> Double {
        guard count > 0, maxCount > 0 else { return 0.0 }
        return Double(count) / Double(maxCount)
    }
    
    private func colorForIntensity(_ intensity: Double, baseColor: Color) -> Color {
        if intensity == 0.0 {
            return Color(.systemGray5)
        } else if intensity < 0.33 {
            return baseColor.opacity(0.3)
        } else if intensity < 0.67 {
            return baseColor.opacity(0.7)
        } else {
            return baseColor
        }
    }
    
    private func tooltipText(hour: Int, count: Int, label: String) -> String {
        let timeString = hour == 0 ? "12 AM" : hour < 12 ? "\(hour) AM" : hour == 12 ? "12 PM" : "\(hour - 12) PM"
        return "\(timeString): \(count) \(label.lowercased())"
    }
}

#Preview {
    DayActivityHeatmapView(
        notifications: [
            TimelineEvent(timestamp: Date(), type: .notificationFired),
            TimelineEvent(timestamp: Date().addingTimeInterval(-3600), type: .notificationFired)
        ],
        exercises: [
            TimelineEvent(timestamp: Date(), type: .exerciseLogged(item: ExerciseItem(builtIn: .squats), count: 1))
        ]
    )
    .padding()
}
