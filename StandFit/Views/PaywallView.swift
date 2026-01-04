//
//  PaywallView.swift
//  StandFit
//
//  Premium subscription paywall
//

import SwiftUI
import StoreKit
import StandFitCore

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(LocalizedString.Premium.startFreeTrial)
                            .font(.title.bold())
                        
                        Text(LocalizedString.Premium.maximizeJourney)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "trophy.fill", color: .purple, title: LocalizedString.Premium.featureAchievementSystem, description: LocalizedString.Premium.featureAchievementSystemDesc)
                        
                        FeatureRow(icon: "chart.bar.doc.horizontal.fill", color: .blue, title: LocalizedString.Premium.featureWeeklyInsights, description: LocalizedString.Premium.featureWeeklyInsightsDesc)
                        
                        FeatureRow(icon: "clock.fill", color: .green, title: LocalizedString.Premium.featureTimelineViz, description: LocalizedString.Premium.featureTimelineVizDesc)
                        
                        FeatureRow(icon: "plus.circle.fill", color: .pink, title: LocalizedString.Premium.featureUnlimitedCustom, description: LocalizedString.Premium.featureUnlimitedCustomDesc)
                        
                        FeatureRow(icon: "target", color: .orange, title: LocalizedString.Premium.featureCustomGoals, description: LocalizedString.Premium.featureCustomGoalsDesc)
                        
                        // MARK: - Future Features (Commented Out)
                        // FeatureRow(icon: "square.and.arrow.up.fill", color: .cyan, title: LocalizedString.Premium.featureExportData, description: LocalizedString.Premium.featureExportDataDesc)
                        // FeatureRow(icon: "icloud.fill", color: .indigo, title: LocalizedString.Premium.featureiCloudSync, description: LocalizedString.Premium.featureiCloudSyncDesc)
                    }
                    .padding(.horizontal)
                    
                    // Pricing cards
                    if let monthly = subscriptionManager.monthlyProduct,
                       let annual = subscriptionManager.annualProduct {
                        VStack(spacing: 12) {
                            PricingCard(
                                product: annual,
                                badge: LocalizedString.Premium.bestValueBadge,
                                savings: LocalizedString.Premium.savePercentage,
                                isSelected: selectedProduct?.id == annual.id
                            ) {
                                selectedProduct = annual
                            }
                            
                            PricingCard(
                                product: monthly,
                                badge: nil,
                                savings: nil,
                                isSelected: selectedProduct?.id == monthly.id
                            ) {
                                selectedProduct = monthly
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ProgressView()
                            .padding()
                    }
                    
                    // Trial info
                    VStack(spacing: 8) {
                        Text(LocalizedString.Premium.trialDuration)
                            .font(.headline)
                        
                        Text(LocalizedString.Premium.trialNoPayment)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    // CTA Button
                    Button {
                        Task {
                            await handlePurchase()
                        }
                    } label: {
                        Group {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(LocalizedString.Premium.startFreeTrial)
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedProduct == nil || isPurchasing)
                    .padding(.horizontal)
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    // Restore button
                    Button(LocalizedString.Premium.restore) {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    // Legal text
                    Text(LocalizedString.Premium.subscriptionRenewNote)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle(LocalizedString.Premium.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.Premium.closeButton) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Pre-select annual by default
            selectedProduct = subscriptionManager.annualProduct
        }
    }
    
    private func handlePurchase() async {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        errorMessage = nil
        
        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                dismiss()
            }
        } catch {
            errorMessage = LocalizedString.Premium.purchaseFailed
        }
        
        isPurchasing = false
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PricingCard: View {
    let product: Product
    let badge: String?
    let savings: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.headline)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Spacer()
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Text(product.displayPrice)
                        .font(.title2.bold())
                    
                    Text(product.subscription?.subscriptionPeriod.unit == .month ? LocalizedString.Premium.perMonth : LocalizedString.Premium.perYear)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.blue : Color(.separator),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Prompt Component

struct PremiumPrompt: View {
    let feature: String
    let icon: String
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text(LocalizedString.Premium.premiumFeature)
                .font(.title3.bold())
            
            Text(feature)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                onUpgrade()
            } label: {
                Text(LocalizedString.Premium.startFreeTrial)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager.shared)
}
