//
//  DayScheduleEditorView.swift
//  StandFit
//

import SwiftUI
import StandFitCore

struct DayScheduleEditorView: View {
    @ObservedObject var store: ExerciseStore
    @Binding var profile: ScheduleProfile
    @Environment(\.dismiss) private var dismiss
    
    let weekdays = [
        (1, "Sunday"),
        (2, "Monday"),
        (3, "Tuesday"),
        (4, "Wednesday"),
        (5, "Thursday"),
        (6, "Friday"),
        (7, "Saturday")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(weekdays, id: \.0) { weekday, name in
                        NavigationLink {
                            SingleDayEditorView(
                                store: store,
                                profile: $profile,
                                weekday: weekday,
                                dayName: name
                            )
                        } label: {
                            DayScheduleRow(
                                profile: profile,
                                weekday: weekday,
                                dayName: name
                            )
                        }
                    }
                }
                
                Section {
                    Button {
                        copyWeekdaysToWeekends()
                    } label: {
                        Label("Copy Weekdays to Weekends", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        setAllDaysToSame()
                    } label: {
                        Label("Set All Days to Monday", systemImage: "square.on.square")
                    }
                    
                    Button(role: .destructive) {
                        clearAllSchedules()
                    } label: {
                        Label("Clear All Schedules", systemImage: "trash")
                    }
                } header: {
                    Text("Quick Actions")
                }
                
                Section {
                    TimelineVisualizationView(
                        profile: profile,
                        config: TimelineVisualizationConfig(
                            showHourLabels: true,
                            showLegend: true,
                            blockHeight: 20,
                            blockSpacing: 2
                        )
                    )
                    .padding(.vertical, 4)
                } header: {
                    Text("Week Overview")
                } footer: {
                    Text("Darker blue indicates more frequent reminders. Tap a day above to customize.")
                }
            }
            .navigationTitle(profile.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateProfile(profile)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func copyWeekdaysToWeekends() {
        // Use Monday's schedule for Saturday and Sunday
        if let mondaySchedule = profile.dailySchedules[2] {
            var updatedProfile = profile
            updatedProfile.dailySchedules[1] = mondaySchedule // Sunday
            updatedProfile.dailySchedules[7] = mondaySchedule // Saturday
            profile = updatedProfile
        }
    }
    
    private func setAllDaysToSame() {
        if let mondaySchedule = profile.dailySchedules[2] {
            var updatedProfile = profile
            for weekday in 1...7 {
                updatedProfile.dailySchedules[weekday] = mondaySchedule
            }
            profile = updatedProfile
        }
    }
    
    private func clearAllSchedules() {
        profile.dailySchedules.removeAll()
    }
}

struct DayScheduleRow: View {
    let profile: ScheduleProfile
    let weekday: Int
    let dayName: String
    
    private var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        return today == weekday
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dayName)
                        .font(.headline)
                    
                    if isToday {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                    
                    if let schedule = profile.dailySchedules[weekday], schedule.enabled {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                
                if let schedule = profile.dailySchedules[weekday], schedule.enabled {
                    Text(scheduleDescription(schedule))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No reminders")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
        }
    }
    
    private func scheduleDescription(_ schedule: DailySchedule) -> String {
        switch schedule.scheduleType {
        case .timeBlocks(let blocks):
            if blocks.isEmpty {
                return "No time blocks"
            } else if blocks.count == 1 {
                let block = blocks[0]
                return "\(block.startHour):\(String(format: "%02d", block.startMinute)) - \(block.endHour):\(String(format: "%02d", block.endMinute)), every \(block.intervalMinutes)m"
            } else {
                return "\(blocks.count) time blocks"
            }
        case .fixedTimes(let reminders):
            return "\(reminders.count) fixed reminders"
        case .useFallback:
            return "Using default interval (\(profile.fallbackInterval)m)"
        }
    }
}

struct SingleDayEditorView: View {
    @ObservedObject var store: ExerciseStore
    @Binding var profile: ScheduleProfile
    let weekday: Int
    let dayName: String
    
    @State private var isEnabled: Bool = false
    @State private var scheduleType: ScheduleTypeOption = .timeBlocks
    @State private var timeBlocks: [TimeBlock] = []
    @State private var fixedReminders: [FixedReminder] = []
    @State private var showingAddBlock = false
    @State private var showingAddReminder = false
    @State private var newReminderHour = 9
    @State private var newReminderMinute = 0
    
    enum ScheduleTypeOption: String, CaseIterable {
        case timeBlocks = "Time Blocks"
        case fixedTimes = "Fixed Times"
        case useFallback = "Use Default"
    }
    
    var body: some View {
        List {
            Section {
                Toggle("Enable \(dayName)", isOn: $isEnabled)
            }
            
            if isEnabled {
                Section {
                    Picker("Schedule Type", selection: $scheduleType) {
                        ForEach(ScheduleTypeOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Schedule Type")
                }
                
                // Day visualization
                if scheduleType == .timeBlocks && !timeBlocks.isEmpty {
                    Section {
                        TimelineVisualizationView(
                            dayLabel: String(dayName.prefix(3)),
                            schedule: DailySchedule(enabled: true, scheduleType: .timeBlocks(timeBlocks)),
                            fallbackInterval: profile.fallbackInterval,
                            config: TimelineVisualizationConfig(
                                showHourLabels: true,
                                showLegend: false,
                                blockHeight: 24
                            )
                        )
                        .padding(.vertical, 4)
                    } header: {
                        Text("Day Overview")
                    } footer: {
                        Text("Visual representation of your time blocks. Darker blue = more frequent reminders.")
                    }
                }
                
                switch scheduleType {
                case .timeBlocks:
                    timeBlocksSection
                case .fixedTimes:
                    fixedTimesSection
                case .useFallback:
                    fallbackSection
                }
            }
        }
        .navigationTitle(dayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSchedule)
        .onChange(of: isEnabled) { _, _ in saveSchedule() }
        .onChange(of: scheduleType) { _, _ in saveSchedule() }
        .onChange(of: timeBlocks) { _, _ in saveSchedule() }
        .onChange(of: fixedReminders) { _, _ in saveSchedule() }
        .sheet(isPresented: $showingAddBlock) {
            TimeBlockEditorSheet(
                block: TimeBlock(
                    startHour: 9,
                    startMinute: 0,
                    endHour: 17,
                    endMinute: 0,
                    intervalMinutes: 30
                ),
                onSave: { newBlock in
                    timeBlocks.append(newBlock)
                    showingAddBlock = false
                },
                onCancel: {
                    showingAddBlock = false
                }
            )
        }
    }
    
    @ViewBuilder
    private var timeBlocksSection: some View {
        Section {
            if timeBlocks.isEmpty {
                ContentUnavailableView(
                    "No Time Blocks",
                    systemImage: "clock",
                    description: Text("Add time blocks to define when reminders should occur")
                )
            } else {
                ForEach(timeBlocks) { block in
                    let blockId = block.id
                    NavigationLink {
                        TimeBlockEditorView(block: block) { updatedBlock in
                            if let index = timeBlocks.firstIndex(where: { $0.id == blockId }) {
                                var updatedBlocks = timeBlocks
                                updatedBlocks[index] = updatedBlock
                                timeBlocks = updatedBlocks
                            }
                        }
                    } label: {
                        TimeBlockRowView(block: block)
                    }
                }
                .onDelete { offsets in
                    timeBlocks.remove(atOffsets: offsets)
                }
                .onMove { source, destination in
                    timeBlocks.move(fromOffsets: source, toOffset: destination)
                }
            }
            
            Button {
                showingAddBlock = true
            } label: {
                Label("Add Time Block", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Time Blocks")
        } footer: {
            Text("Reminders will only fire during these time blocks")
        }
    }
    
    @ViewBuilder
    private var fixedTimesSection: some View {
        Section {
            if fixedReminders.isEmpty {
                ContentUnavailableView(
                    "No Fixed Times",
                    systemImage: "clock.badge.checkmark",
                    description: Text("Add specific times for reminders")
                )
            } else {
                ForEach(fixedReminders) { reminder in
                    HStack {
                        Text(reminder.formattedTime)
                            .font(.headline)
                        if let label = reminder.label {
                            Text(label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    fixedReminders.remove(atOffsets: offsets)
                }
            }
            
            Button {
                newReminderHour = 9
                newReminderMinute = 0
                showingAddReminder = true
            } label: {
                Label("Add Fixed Time", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Fixed Reminder Times")
        }
        .sheet(isPresented: $showingAddReminder) {
            NavigationStack {
                Form {
                    Section {
                        HStack {
                            Text("Time")
                            Spacer()
                            Picker("Hour", selection: $newReminderHour) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 60)
                            
                            Text(":")
                            
                            Picker("Minute", selection: $newReminderMinute) {
                                ForEach([0, 15, 30, 45], id: \.self) { minute in
                                    Text(String(format: "%02d", minute)).tag(minute)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 60)
                        }
                    } header: {
                        Text("Reminder Time")
                    } footer: {
                        Text("Set the exact time for this reminder")
                    }
                }
                .navigationTitle("Add Fixed Time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddReminder = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let newReminder = FixedReminder(hour: newReminderHour, minute: newReminderMinute)
                            fixedReminders.append(newReminder)
                            showingAddReminder = false
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var fallbackSection: some View {
        Section {
            HStack {
                Text("Default Interval")
                Spacer()
                Text("\(profile.fallbackInterval) min")
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Reminders will use the profile's default interval throughout the day")
        }
    }
    
    private func loadSchedule() {
        if let schedule = profile.dailySchedules[weekday] {
            isEnabled = schedule.enabled
            
            switch schedule.scheduleType {
            case .timeBlocks(let blocks):
                scheduleType = .timeBlocks
                timeBlocks = blocks
            case .fixedTimes(let reminders):
                scheduleType = .fixedTimes
                fixedReminders = reminders
            case .useFallback:
                scheduleType = .useFallback
            }
        } else {
            isEnabled = false
            scheduleType = .timeBlocks
            timeBlocks = []
            fixedReminders = []
        }
    }
    
    private func saveSchedule() {
        if !isEnabled {
            profile.dailySchedules[weekday] = DailySchedule(enabled: false, scheduleType: .useFallback)
            store.updateProfile(profile)
            return
        }
        
        let scheduleTypeValue: DailySchedule.ScheduleType
        switch scheduleType {
        case .timeBlocks:
            scheduleTypeValue = .timeBlocks(timeBlocks)
        case .fixedTimes:
            scheduleTypeValue = .fixedTimes(fixedReminders)
        case .useFallback:
            scheduleTypeValue = .useFallback
        }
        
        profile.dailySchedules[weekday] = DailySchedule(
            enabled: true,
            scheduleType: scheduleTypeValue
        )
        store.updateProfile(profile)
    }
}

struct TimeBlockRowView: View {
    let block: TimeBlock
    
    var body: some View {
        HStack {
            if let icon = block.icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let name = block.name {
                    Text(name)
                        .font(.headline)
                }
                
                HStack {
                    Text("\(block.startHour):\(String(format: "%02d", block.startMinute)) - \(block.endHour):\(String(format: "%02d", block.endMinute))")
                        .font(.subheadline)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("Every \(block.intervalMinutes)m")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    NavigationStack {
        DayScheduleEditorView(
            store: ExerciseStore.shared,
            profile: .constant(ScheduleProfile(name: "Test Profile"))
        )
    }
}
