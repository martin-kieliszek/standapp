//
//  TimelineVisualizationView.swift
//  StandFit
//
//  GitHub activity-style visualization for time blocks
//

import SwiftUI
import StandFitCore

/// Configuration for timeline visualization appearance
struct TimelineVisualizationConfig {
    var showHourLabels: Bool = true
    var showLegend: Bool = false
    var blockHeight: CGFloat = 24
    var blockSpacing: CGFloat = 2
    var cornerRadius: CGFloat = 4
    var hourLabelFont: Font = .caption2
    
    static let compact = TimelineVisualizationConfig(
        showHourLabels: false,
        showLegend: false,
        blockHeight: 16,
        blockSpacing: 1,
        cornerRadius: 2
    )
    
    static let detailed = TimelineVisualizationConfig(
        showHourLabels: true,
        showLegend: true,
        blockHeight: 32,
        blockSpacing: 3,
        cornerRadius: 6
    )
}

/// Represents a single day's timeline data
struct DayTimelineData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let timeBlocks: [TimeBlock]
    let fallbackInterval: Int
}

/// GitHub activity-style visualization showing time blocks across hours
struct TimelineVisualizationView: View {
    let data: [DayTimelineData]
    let config: TimelineVisualizationConfig
    
    private let hours = Array(0..<24)
    private let intensityLevels = 5 // Number of color intensity levels
    
    init(data: [DayTimelineData], config: TimelineVisualizationConfig = TimelineVisualizationConfig()) {
        self.data = data
        self.config = config
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: config.blockSpacing) {
            if config.showHourLabels {
                hourLabelsRow
            }
            
            ForEach(data) { dayData in
                HStack(spacing: config.blockSpacing) {
                    // Day label
                    Text(dayData.dayLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .leading)
                    
                    // Hour blocks
                    HStack(spacing: 1) {
                        ForEach(hours, id: \.self) { hour in
                            hourBlock(for: hour, in: dayData)
                        }
                    }
                }
            }
            
            if config.showLegend {
                legendView
            }
        }
    }
    
    @ViewBuilder
    private var hourLabelsRow: some View {
        HStack(spacing: config.blockSpacing) {
            // Spacer for day label
            Text("")
                .frame(width: 40)
            
            HStack(spacing: 1) {
                ForEach([0, 6, 12, 18], id: \.self) { hour in
                    Text("\(hour)")
                        .font(config.hourLabelFont)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    private func hourBlock(for hour: Int, in dayData: DayTimelineData) -> some View {
        let intensity = calculateIntensity(for: hour, in: dayData)
        
        Rectangle()
            .fill(colorForIntensity(intensity))
            .frame(height: config.blockHeight)
            .frame(maxWidth: .infinity)
            .cornerRadius(config.cornerRadius)
    }
    
    @ViewBuilder
    private var legendView: some View {
        HStack(spacing: 8) {
            Text("Less")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0...intensityLevels, id: \.self) { level in
                    Rectangle()
                        .fill(colorForIntensity(Double(level) / Double(intensityLevels)))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                }
            }
            
            Text("More")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Helper Methods
    
    /// Calculate activity intensity (0.0 to 1.0) for a given hour
    private func calculateIntensity(for hour: Int, in dayData: DayTimelineData) -> Double {
        let hourStart = hour * 60
        let hourEnd = (hour + 1) * 60
        
        // Check if this hour overlaps with any time blocks
        var totalCoverage = 0.0
        var maxFrequency = 0.0
        
        for block in dayData.timeBlocks {
            let blockStart = block.startMinutes
            let blockEnd = block.endMinutes
            
            // Calculate overlap
            let overlapStart = max(hourStart, blockStart)
            let overlapEnd = min(hourEnd, blockEnd)
            
            if overlapEnd > overlapStart {
                let overlapMinutes = overlapEnd - overlapStart
                let coverage = Double(overlapMinutes) / 60.0
                totalCoverage += coverage
                
                // Calculate frequency (inversely related to interval)
                // Shorter interval = higher frequency = higher intensity
                let frequency = 60.0 / Double(block.intervalMinutes)
                maxFrequency = max(maxFrequency, frequency)
            }
        }
        
        if totalCoverage == 0 {
            return 0.0
        }
        
        // Combine coverage and frequency
        // Coverage: how much of the hour is covered
        // Frequency: how often reminders fire
        let normalizedFrequency = min(maxFrequency / 4.0, 1.0) // 4 reminders/hour = max
        
        return min(totalCoverage * normalizedFrequency, 1.0)
    }
    
    /// Get color for intensity level
    private func colorForIntensity(_ intensity: Double) -> Color {
        if intensity == 0 {
            return Color(.systemGray6)
        }
        
        // Blue color with varying opacity based on intensity
        return Color.blue.opacity(0.2 + (intensity * 0.8))
    }
}

// MARK: - Convenience Initializers

extension TimelineVisualizationView {
    /// Create visualization for a single day
    init(dayLabel: String, schedule: DailySchedule?, fallbackInterval: Int, config: TimelineVisualizationConfig = TimelineVisualizationConfig()) {
        let blocks = schedule?.timeBlocks ?? []
        let data = [DayTimelineData(dayLabel: dayLabel, timeBlocks: blocks, fallbackInterval: fallbackInterval)]
        self.init(data: data, config: config)
    }
    
    /// Create visualization for a full week from profile
    init(profile: ScheduleProfile, config: TimelineVisualizationConfig = TimelineVisualizationConfig()) {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let weekdays = [1, 2, 3, 4, 5, 6, 7]
        
        let data = weekdays.map { weekday in
            let schedule = profile.dailySchedules[weekday]
            let blocks = schedule?.enabled == true ? (schedule?.timeBlocks ?? []) : []
            return DayTimelineData(
                dayLabel: dayNames[weekday - 1],
                timeBlocks: blocks,
                fallbackInterval: profile.fallbackInterval
            )
        }
        
        self.init(data: data, config: config)
    }
}

#Preview("Single Day") {
    VStack(spacing: 20) {
        TimelineVisualizationView(
            dayLabel: "Mon",
            schedule: DailySchedule(
                enabled: true,
                scheduleType: .timeBlocks([
                    TimeBlock(startHour: 9, startMinute: 0, endHour: 12, endMinute: 0, intervalMinutes: 20),
                    TimeBlock(startHour: 13, startMinute: 0, endHour: 17, endMinute: 0, intervalMinutes: 30),
                    TimeBlock(startHour: 18, startMinute: 0, endHour: 21, endMinute: 0, intervalMinutes: 60)
                ])
            ),
            fallbackInterval: 30,
            config: .detailed
        )
    }
    .padding()
}

#Preview("Full Week") {
    VStack(spacing: 20) {
        TimelineVisualizationView(
            profile: ScheduleTemplates.officeWorker.profile,
            config: TimelineVisualizationConfig(showHourLabels: true, showLegend: true)
        )
    }
    .padding()
}
