//
//  TimeBlockEditorSheet.swift
//  StandFit
//

import SwiftUI
import StandFitCore

/// Standalone navigation view for editing time blocks (non-sheet)
struct TimeBlockEditorView: View {
    let block: TimeBlock
    let onSave: (TimeBlock) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var intervalMinutes: Int
    @State private var enableRandomization: Bool
    @State private var randomizationRange: Int
    @State private var selectedIcon: String?
    @State private var notificationStyle: TimeBlock.NotificationStyle
    
    let intervalOptions = [1, 15, 20, 30, 45, 60, 90, 120]
    let icons = ["sun.max.fill", "sunrise.fill", "moon.fill", "briefcase.fill", 
                 "laptopcomputer", "figure.run", "leaf.fill", "clock.fill",
                 "bell.fill", "star.fill", "heart.fill", "bolt.fill"]
    
    init(block: TimeBlock, onSave: @escaping (TimeBlock) -> Void) {
        self.block = block
        self.onSave = onSave
        
        _name = State(initialValue: block.name ?? "")
        _startHour = State(initialValue: block.startHour)
        _startMinute = State(initialValue: block.startMinute)
        _endHour = State(initialValue: block.endHour)
        _endMinute = State(initialValue: block.endMinute)
        _intervalMinutes = State(initialValue: block.intervalMinutes)
        _enableRandomization = State(initialValue: block.randomizationRange != nil)
        _randomizationRange = State(initialValue: block.randomizationRange ?? 5)
        _selectedIcon = State(initialValue: block.icon)
        _notificationStyle = State(initialValue: block.notificationStyle)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Block Name (optional)", text: $name)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Name")
            } footer: {
                Text("e.g., 'Morning Focus', 'Work Hours', 'Evening Wind-Down'")
            }
            
            Section {
                HStack {
                    Text("Start Time")
                    Spacer()
                    Picker("Hour", selection: $startHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 60)
                    
                    Text(":")
                    
                    Picker("Minute", selection: $startMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 60)
                }
                
                HStack {
                    Text("End Time")
                    Spacer()
                    Picker("Hour", selection: $endHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 60)
                    
                    Text(":")
                    
                    Picker("Minute", selection: $endMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 60)
                }
            } header: {
                Text("Time Range")
            } footer: {
                if isValidTimeRange {
                    Text("Duration: \(durationDescription)")
                } else {
                    Text("End time must be after start time")
                        .foregroundStyle(.red)
                }
            }
            
            Section {
                Picker("Interval", selection: $intervalMinutes) {
                    ForEach(intervalOptions, id: \.self) { interval in
                        Text("\(interval) min").tag(interval)
                    }
                }
                .pickerStyle(.menu)
                
                if isValidTimeRange {
                    HStack {
                        Text("Estimated Reminders")
                        Spacer()
                        Text("\(estimatedReminderCount)")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Reminder Interval")
            }
            
            // Visual preview of notification times
            if isValidTimeRange {
                Section {
                    TimelineVisualizationView(
                        dayLabel: "Preview",
                        schedule: DailySchedule(
                            enabled: true,
                            scheduleType: .timeBlocks([currentTimeBlock])
                        ),
                        fallbackInterval: 30,
                        config: TimelineVisualizationConfig(
                            showHourLabels: true,
                            showLegend: false,
                            blockHeight: 24
                        )
                    )
                    .padding(.vertical, 4)
                } header: {
                    Text("Notification Periods (Preview)")
                } footer: {
                    Text("Visual representation of when reminders will fire during this time block. Darker blue = more frequent.")
                }
            }
            
            Section {
                Toggle("Add Randomness", isOn: $enableRandomization)
                
                if enableRandomization {
                    Stepper("± \(randomizationRange) minutes", value: $randomizationRange, in: 1...30)
                    
                    Text("Prevents habituation by varying reminder times slightly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Advanced")
            } footer: {
                if enableRandomization {
                    Text("Reminders will vary by ±\(randomizationRange) minutes from the base interval")
                }
            }
            
            Section {
                Picker("Style", selection: $notificationStyle) {
                    Text("Standard").tag(TimeBlock.NotificationStyle.standard)
                    Text("Gentle (Silent)").tag(TimeBlock.NotificationStyle.gentle)
                    Text("Urgent").tag(TimeBlock.NotificationStyle.urgent)
                }
            } header: {
                Text("Notification Style")
            }
            
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Button {
                            selectedIcon = nil
                        } label: {
                            VStack {
                                Image(systemName: "xmark.circle")
                                    .font(.title)
                                    .foregroundStyle(selectedIcon == nil ? .blue : .gray)
                                Text("None")
                                    .font(.caption2)
                            }
                        }
                        
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundStyle(selectedIcon == icon ? .blue : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("Icon (Optional)")
            }
        }
        .navigationTitle("Time Block")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let updatedBlock = TimeBlock(
                        id: block.id,
                        name: name.isEmpty ? nil : name,
                        startHour: startHour,
                        startMinute: startMinute,
                        endHour: endHour,
                        endMinute: endMinute,
                        intervalMinutes: intervalMinutes,
                        randomizationRange: enableRandomization ? randomizationRange : nil,
                        icon: selectedIcon,
                        notificationStyle: notificationStyle
                    )
                    onSave(updatedBlock)
                    dismiss()
                }
                .disabled(!isValidTimeRange)
            }
        }
    }
    
    private var isValidTimeRange: Bool {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        return endMinutes > startMinutes
    }
    
    private var durationDescription: String {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let duration = endMinutes - startMinutes
        
        let hours = duration / 60
        let mins = duration % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
    
    private var estimatedReminderCount: Int {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let duration = endMinutes - startMinutes
        return max(0, duration / intervalMinutes)
    }
    
    private var currentTimeBlock: TimeBlock {
        TimeBlock(
            id: block.id,
            name: name.isEmpty ? nil : name,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            intervalMinutes: intervalMinutes,
            randomizationRange: enableRandomization ? randomizationRange : nil,
            icon: selectedIcon,
            notificationStyle: notificationStyle
        )
    }
}

/// Sheet wrapper for legacy sheet-based presentation
struct TimeBlockEditorSheet: View {
    let block: TimeBlock
    let onSave: (TimeBlock) -> Void
    let onCancel: () -> Void
    
    @State private var name: String
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var intervalMinutes: Int
    @State private var enableRandomization: Bool
    @State private var randomizationRange: Int
    @State private var selectedIcon: String?
    @State private var notificationStyle: TimeBlock.NotificationStyle
    
    let intervalOptions = [1, 15, 20, 30, 45, 60, 90, 120]
    let icons = ["sun.max.fill", "sunrise.fill", "moon.fill", "briefcase.fill", 
                 "laptopcomputer", "figure.run", "leaf.fill", "clock.fill",
                 "bell.fill", "star.fill", "heart.fill", "bolt.fill"]
    
    init(block: TimeBlock, onSave: @escaping (TimeBlock) -> Void, onCancel: @escaping () -> Void) {
        self.block = block
        self.onSave = onSave
        self.onCancel = onCancel
        
        _name = State(initialValue: block.name ?? "")
        _startHour = State(initialValue: block.startHour)
        _startMinute = State(initialValue: block.startMinute)
        _endHour = State(initialValue: block.endHour)
        _endMinute = State(initialValue: block.endMinute)
        _intervalMinutes = State(initialValue: block.intervalMinutes)
        _enableRandomization = State(initialValue: block.randomizationRange != nil)
        _randomizationRange = State(initialValue: block.randomizationRange ?? 5)
        _selectedIcon = State(initialValue: block.icon)
        _notificationStyle = State(initialValue: block.notificationStyle)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Block Name (optional)", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Name")
                } footer: {
                    Text("e.g., 'Morning Focus', 'Work Hours', 'Evening Wind-Down'")
                }
                
                Section {
                    HStack {
                        Text("Start Time")
                        Spacer()
                        Picker("Hour", selection: $startHour) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 60)
                        
                        Text(":")
                        
                        Picker("Minute", selection: $startMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 60)
                    }
                    
                    HStack {
                        Text("End Time")
                        Spacer()
                        Picker("Hour", selection: $endHour) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 60)
                        
                        Text(":")
                        
                        Picker("Minute", selection: $endMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 60)
                    }
                } header: {
                    Text("Time Range")
                } footer: {
                    if isValidTimeRange {
                        Text("Duration: \(durationDescription)")
                    } else {
                        Text("End time must be after start time")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Picker("Interval", selection: $intervalMinutes) {
                        ForEach(intervalOptions, id: \.self) { interval in
                            Text("\(interval) min").tag(interval)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if isValidTimeRange {
                        HStack {
                            Text("Estimated Reminders")
                            Spacer()
                            Text("\(estimatedReminderCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Reminder Interval")
                }
                
                // Visual preview of notification times
                if isValidTimeRange {
                    Section {
                        TimelineVisualizationView(
                            dayLabel: "Preview",
                            schedule: DailySchedule(
                                enabled: true,
                                scheduleType: .timeBlocks([currentTimeBlockSheet])
                            ),
                            fallbackInterval: 30,
                            config: TimelineVisualizationConfig(
                                showHourLabels: true,
                                showLegend: false,
                                blockHeight: 24
                            )
                        )
                        .padding(.vertical, 4)
                    } header: {
                        Text("Notification Preview")
                    } footer: {
                        Text("Visual representation of when reminders will fire during this time block. Darker blue = more frequent.")
                    }
                }
                
                Section {
                    Toggle("Add Randomness", isOn: $enableRandomization)
                    
                    if enableRandomization {
                        Stepper("± \(randomizationRange) minutes", value: $randomizationRange, in: 1...30)
                        
                        Text("Prevents habituation by varying reminder times slightly")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Advanced")
                } footer: {
                    if enableRandomization {
                        Text("Reminders will vary by ±\(randomizationRange) minutes from the base interval")
                    }
                }
                
                Section {
                    Picker("Style", selection: $notificationStyle) {
                        Text("Standard").tag(TimeBlock.NotificationStyle.standard)
                        Text("Gentle (Silent)").tag(TimeBlock.NotificationStyle.gentle)
                        Text("Urgent").tag(TimeBlock.NotificationStyle.urgent)
                    }
                } header: {
                    Text("Notification Style")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            Button {
                                selectedIcon = nil
                            } label: {
                                VStack {
                                    Image(systemName: "xmark.circle")
                                        .font(.title)
                                        .foregroundStyle(selectedIcon == nil ? .blue : .gray)
                                    Text("None")
                                        .font(.caption2)
                                }
                            }
                            
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title)
                                        .foregroundStyle(selectedIcon == icon ? .blue : .gray)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Icon (Optional)")
                }
            }
            .navigationTitle("Time Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedBlock = TimeBlock(
                            id: block.id,
                            name: name.isEmpty ? nil : name,
                            startHour: startHour,
                            startMinute: startMinute,
                            endHour: endHour,
                            endMinute: endMinute,
                            intervalMinutes: intervalMinutes,
                            randomizationRange: enableRandomization ? randomizationRange : nil,
                            icon: selectedIcon,
                            notificationStyle: notificationStyle
                        )
                        onSave(updatedBlock)
                    }
                    .disabled(!isValidTimeRange)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private var isValidTimeRange: Bool {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        return endMinutes > startMinutes
    }
    
    private var durationDescription: String {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let duration = endMinutes - startMinutes
        
        let hours = duration / 60
        let mins = duration % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
    
    private var estimatedReminderCount: Int {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let duration = endMinutes - startMinutes
        return max(0, duration / intervalMinutes)
    }
    
    private var currentTimeBlockSheet: TimeBlock {
        TimeBlock(
            id: block.id,
            name: name.isEmpty ? nil : name,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            intervalMinutes: intervalMinutes,
            randomizationRange: enableRandomization ? randomizationRange : nil,
            icon: selectedIcon,
            notificationStyle: notificationStyle
        )
    }
}

#Preview {
    TimeBlockEditorSheet(
        block: TimeBlock(
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0,
            intervalMinutes: 30
        ),
        onSave: { _ in },
        onCancel: {}
    )
}
