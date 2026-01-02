//
//  ScheduleProfilePickerView.swift
//  StandFit
//

import SwiftUI
import StandFitCore

struct ScheduleProfilePickerView: View {
    @ObservedObject var store: ExerciseStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingTemplateSheet = false
    @State private var showingCreateSheet = false
    @State private var newProfileName = ""
    @State private var selectedTemplate: ScheduleTemplate?
    
    var body: some View {
        NavigationStack {
            List {
                if !store.scheduleProfiles.isEmpty {
                    Section {
                        ForEach(store.scheduleProfiles) { profile in
                            ProfileRow(
                                profile: profile,
                                isActive: store.activeProfile?.id == profile.id,
                                onSelect: {
                                    store.switchToProfile(profile)
                                    dismiss()
                                }
                            )
                        }
                        .onDelete(perform: deleteProfiles)
                    } header: {
                        Text("Your Profiles")
                    }
                } else {
                    ContentUnavailableView(
                        "No Profiles",
                        systemImage: "calendar.badge.clock",
                        description: Text("Create your first schedule profile to get started")
                    )
                }
                
                Section {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Label("Create Custom Profile", systemImage: "plus.circle.fill")
                    }
                    
                    Button {
                        showingTemplateSheet = true
                    } label: {
                        Label("Create from Template", systemImage: "doc.on.doc.fill")
                    }
                } header: {
                    Text("Add New Profile")
                }
            }
            .navigationTitle("Schedule Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTemplateSheet) {
                TemplatePickerSheet(store: store, isPresented: $showingTemplateSheet)
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateProfileSheet(
                    store: store,
                    isPresented: $showingCreateSheet,
                    profileName: $newProfileName
                )
            }
        }
    }
    
    private func deleteProfiles(at offsets: IndexSet) {
        for index in offsets {
            let profile = store.scheduleProfiles[index]
            store.deleteProfile(profile)
        }
    }
}

struct ProfileRow: View {
    let profile: ScheduleProfile
    let isActive: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.name)
                            .font(.headline)
                        
                        if isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(profile.summaryDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let lastUsed = profile.lastUsedDate {
                        Text("Last used: \(lastUsed, style: .relative) ago")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                if isActive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct TemplatePickerSheet: View {
    @ObservedObject var store: ExerciseStore
    @Binding var isPresented: Bool
    @State private var selectedTemplate: ScheduleTemplate?
    @State private var customName = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ScheduleTemplates.all, id: \.id) { template in
                    NavigationLink {
                        NameProfileView(
                            store: store,
                            template: template,
                            onComplete: {
                                isPresented = false
                            }
                        )
                    } label: {
                        HStack {
                            Image(systemName: template.icon)
                                .font(.title2)
                                .foregroundStyle(.blue)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.headline)
                                
                                Text(template.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(template.profile.summaryDescription)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct NameProfileView: View {
    @ObservedObject var store: ExerciseStore
    let template: ScheduleTemplate
    let onComplete: () -> Void
    @State private var customName: String
    @Environment(\.dismiss) private var dismiss
    
    init(store: ExerciseStore, template: ScheduleTemplate, onComplete: @escaping () -> Void) {
        self.store = store
        self.template = template
        self.onComplete = onComplete
        _customName = State(initialValue: template.name)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Profile Name", text: $customName)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Name Your Profile")
            } footer: {
                Text("Based on template: \(template.name)")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(template.description)
                        .font(.subheadline)
                    
                    Text(template.profile.summaryDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    let profile = store.createProfile(name: customName, basedOn: template)
                    store.switchToProfile(profile)
                    onComplete()
                }
                .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

struct CreateProfileSheet: View {
    @ObservedObject var store: ExerciseStore
    @Binding var isPresented: Bool
    @Binding var profileName: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Profile Name", text: $profileName)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Profile Details")
                } footer: {
                    Text("You can customize the schedule after creating the profile")
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let profile = store.createProfile(name: profileName)
                        store.switchToProfile(profile)
                        isPresented = false
                        profileName = ""
                    }
                    .disabled(profileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ScheduleProfilePickerView(store: ExerciseStore.shared)
}
