//
//  SubscriptionManager.swift
//  StandFit
//
//  StoreKit 2 subscription management with dev mode support
//

import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Published State
    
    @Published private(set) var currentTier: SubscriptionTier = .free
    private var previousPremiumStatus: Bool = false
    @Published private(set) var trialState: TrialState?
    @Published private(set) var isLoading = false
    
    // MARK: - Product IDs
    
    private let monthlyProductID = "com.mke.upio.premium.monthly"
    private let annualProductID = "com.mke.upio.premium.annual"
    
    private var availableProducts: [Product] = []
    private var purchasedProductIDs = Set<String>()
    private var transactionListener: Task<Void, Error>?
    
    // MARK: - Dev Mode (Testing)
    
    /// Enable this in dev builds to simulate premium/trial without actual purchases
    @Published var devModeEnabled: Bool = false {
        didSet {
            if devModeEnabled {
                print("🧪 Dev Mode: Subscription testing enabled")
            }
            updateEntitlements()
        }
    }
    
    @Published var devModeTier: SubscriptionTier = .premium {
        didSet {
            if devModeEnabled {
                updateEntitlements()
            }
        }
    }
    
    @Published var devModeTrialDuration: Int = 14 {
        didSet {
            if devModeEnabled && devModeHasActiveTrial {
                activateDevTrial()
            }
        }
    }
    
    @Published var devModeHasActiveTrial: Bool = false {
        didSet {
            if devModeEnabled {
                if devModeHasActiveTrial {
                    activateDevTrial()
                } else {
                    trialState = nil
                }
                updateEntitlements()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var isPremium: Bool {
        if devModeEnabled {
            return devModeTier == .premium || (devModeHasActiveTrial && trialState?.isActive == true)
        }
        
        // Check active trial first
        if let trial = trialState, trial.isActive && !trial.hasExpired {
            return true
        }
        
        // Check purchased subscription
        return currentTier == .premium
    }
    
    var entitlements: FeatureEntitlement {
        let tier = isPremium ? SubscriptionTier.premium : .free
        return TierEntitlements(tier: tier)
    }
    
    var monthlyProduct: Product? {
        availableProducts.first { $0.id == monthlyProductID }
    }
    
    var annualProduct: Product? {
        availableProducts.first { $0.id == annualProductID }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Start transaction listener
        transactionListener = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
            loadTrialState()
            updateEntitlements()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: [monthlyProductID, annualProductID])
            await MainActor.run {
                self.availableProducts = products
                print("📦 Loaded \(products.count) products")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Flow
    
    func purchase(_ product: Product) async throws -> Bool {
        guard !devModeEnabled else {
            print("🧪 Dev Mode: Simulating purchase")
            await MainActor.run {
                devModeTier = .premium
                devModeHasActiveTrial = false
                updateEntitlements()
            }
            return true
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async {
        guard !devModeEnabled else {
            print("🧪 Dev Mode: Simulating restore")
            return
        }
        
        await updatePurchasedProducts()
    }
    
    // MARK: - Trial Management
    
    func startTrial() {
        if devModeEnabled {
            activateDevTrial()
            return
        }
        
        // Only allow trial if never had one before
        guard trialState == nil else {
            print("⚠️ Trial already used")
            return
        }
        
        let trial = TrialState.create(duration: 14)
        trialState = trial
        saveTrialState()
        updateEntitlements()
        
        print("🎁 Trial started: \(trial.daysRemaining) days remaining")
    }
    
    private func activateDevTrial() {
        let trial = TrialState.create(duration: devModeTrialDuration)
        trialState = trial
        updateEntitlements()
        print("🧪 Dev Mode: Trial activated for \(devModeTrialDuration) days")
    }
    
    // MARK: - Transaction Handling
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchasedIDs
            updateEntitlements()
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Entitlement Updates
    
    private func updateEntitlements() {
        let wasPremium = previousPremiumStatus
        
        let hasPurchase = !purchasedProductIDs.isEmpty
        let hasActiveTrial = trialState?.isActive == true && !(trialState?.hasExpired ?? true)
        
        if devModeEnabled {
            currentTier = devModeTier
        } else if hasPurchase {
            currentTier = .premium
        } else if hasActiveTrial {
            currentTier = .premium
        } else {
            currentTier = .free
        }
        
        let isNowPremium = isPremium
        
        // Detect upgrade from free to premium
        if !wasPremium && isNowPremium {
            print("🎉 User upgraded to premium - recalculating achievements")
            Task { @MainActor in
                // Access ExerciseStore from its singleton
                let store = ExerciseStore.shared
                GamificationStore.shared.recalculateAchievementsFromHistory(exerciseStore: store)
            }
        }
        
        previousPremiumStatus = isNowPremium
        
        print("✅ Entitlements updated: \(currentTier.displayName) (Premium: \(isPremium))")
    }
    
    // MARK: - Persistence
    
    private func saveTrialState() {
        guard let trial = trialState else { return }
        if let data = try? JSONEncoder().encode(trial) {
            UserDefaults.standard.set(data, forKey: "trialState")
        }
    }
    
    private func loadTrialState() {
        guard let data = UserDefaults.standard.data(forKey: "trialState"),
              let trial = try? JSONDecoder().decode(TrialState.self, from: data) else {
            return
        }
        trialState = trial
    }
}

// MARK: - Errors

enum StoreError: Error {
    case failedVerification
}
