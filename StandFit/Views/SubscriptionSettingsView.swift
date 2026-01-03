//
//  SubscriptionSettingsView.swift
//  StandFit
//
//  Subscription management and dev mode testing UI
//

import SwiftUI
import StandFitCore

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
                            Text(LocalizedString.Premium.daysRemainingInTrial(trial.daysRemaining))
                                .font(.caption)
                                .foregroundStyle(.orange)
                        } else if subscriptionManager.isPremium {
                            Text(LocalizedString.Premium.allFeaturesUnlocked)
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Text(LocalizedString.Premium.limitedFeatures)
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
                Text(LocalizedString.Premium.subscriptionStatus)
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
                                Text(LocalizedString.Premium.upgradeToPremium)
                                    .font(.headline)
                                Text(LocalizedString.Premium.unlockAllFeatures)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(LocalizedString.Premium.getMore)
                }
            }
            
            // Dev Mode (only show in debug builds)
            #if DEBUG
            Section {
                Toggle(LocalizedString.Premium.enableDevMode, isOn: $subscriptionManager.devModeEnabled)
                
                if subscriptionManager.devModeEnabled {
                    Picker(LocalizedString.Premium.simulateTier, selection: $subscriptionManager.devModeTier) {
                        Text(LocalizedString.Premium.freeTier).tag(SubscriptionTier.free)
                        Text(LocalizedString.Premium.premiumTier).tag(SubscriptionTier.premium)
                    }
                    
                    Toggle(LocalizedString.Premium.activeTrial, isOn: $subscriptionManager.devModeHasActiveTrial)
                    
                    if subscriptionManager.devModeHasActiveTrial {
                        Stepper(LocalizedString.Premium.trialDaysFormat(subscriptionManager.devModeTrialDuration),
                               value: $subscriptionManager.devModeTrialDuration,
                               in: 1...30)
                    }
                    
                    if let trial = subscriptionManager.trialState {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedString.Premium.trialEnds(trial.endDate.formatted(date: .abbreviated, time: .shortened)))
                                .font(.caption)
                            Text(LocalizedString.Premium.daysRemaining(trial.daysRemaining))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text(LocalizedString.Premium.devModeTesting)
            } footer: {
                Text(LocalizedString.Premium.devModeFooter)
            }
            #endif
        }
        .navigationTitle(LocalizedString.Premium.subscriptionNavigation)
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
