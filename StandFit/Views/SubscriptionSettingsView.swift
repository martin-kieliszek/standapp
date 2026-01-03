//
//  SubscriptionSettingsView.swift
//  StandFit
//
//  Subscription management and dev mode testing UI
//

import SwiftUI

struct SubscriptionSettingsView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @State private var showingPaywall = false
    
    var body: some View {
        List {
            // Current status
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscriptionManager.currentTier.displayName)
                            .font(.headline)
                        
                        if let trial = subscriptionManager.trialState, trial.isActive {
                            Text("\(trial.daysRemaining) days remaining in trial")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        } else if subscriptionManager.isPremium {
                            Text("All features unlocked")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Text("Limited features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if subscriptionManager.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                    }
                }
            } header: {
                Text("Subscription Status")
            }
            
            // Premium features
            if !subscriptionManager.isPremium {
                Section {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upgrade to Premium")
                                    .font(.headline)
                                Text("Unlock all features")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Get More")
                }
            }
            
            // Dev Mode (only show in debug builds)
            #if DEBUG
            Section {
                Toggle("Enable Dev Mode", isOn: $subscriptionManager.devModeEnabled)
                
                if subscriptionManager.devModeEnabled {
                    Picker("Simulate Tier", selection: $subscriptionManager.devModeTier) {
                        Text("Free").tag(SubscriptionTier.free)
                        Text("Premium").tag(SubscriptionTier.premium)
                    }
                    
                    Toggle("Active Trial", isOn: $subscriptionManager.devModeHasActiveTrial)
                    
                    if subscriptionManager.devModeHasActiveTrial {
                        Stepper("Trial: \(subscriptionManager.devModeTrialDuration) days",
                               value: $subscriptionManager.devModeTrialDuration,
                               in: 1...30)
                    }
                    
                    if let trial = subscriptionManager.trialState {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Trial ends: \(trial.endDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                            Text("\(trial.daysRemaining) days remaining")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("🧪 Developer Testing")
            } footer: {
                Text("Dev mode simulates subscription states without real purchases. Perfect for testing paywalls and premium features during development.")
            }
            #endif
        }
        .navigationTitle("Subscription")
        .sheet(isPresented: $showingPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionSettingsView(subscriptionManager: SubscriptionManager.shared)
    }
}
