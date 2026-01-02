//
//  ProfileBadgeView.swift
//  StandFit
//
//  A small badge view showing the active schedule profile
//

import SwiftUI
import StandFitCore

struct ProfileBadgeView: View {
    let profile: ScheduleProfile?
    let compact: Bool
    
    init(profile: ScheduleProfile?, compact: Bool = false) {
        self.profile = profile
        self.compact = compact
    }
    
    var body: some View {
        if let profile = profile {
            if compact {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption2)
                    Text(profile.name)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile.name)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(profile.summaryDescription)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileBadgeView(
            profile: ScheduleProfile(
                name: "Office Worker",
                fallbackInterval: 30
            )
        )
        
        ProfileBadgeView(
            profile: ScheduleProfile(
                name: "Office Worker",
                fallbackInterval: 30
            ),
            compact: true
        )
    }
    .padding()
}
