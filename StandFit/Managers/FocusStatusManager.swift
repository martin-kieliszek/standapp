//
//  FocusStatusManager.swift
//  StandFit iOS
//
//  Manages Focus Mode status detection and authorization
//

import Foundation
import Intents
import Combine

@available(iOS 15.0, *)
class FocusStatusManager: ObservableObject {
    static let shared = FocusStatusManager()
    
    @Published var isFocusActive: Bool = false
    @Published var authorizationStatus: INFocusStatusAuthorizationStatus = .notDetermined
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private init() {
        checkAuthorizationStatus()
        observeFocusStatus()
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = INFocusStatusCenter.default.authorizationStatus
    }
    
    /// Request authorization to access Focus Mode status
    func requestAuthorization() {
        INFocusStatusCenter.default.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized {
                    self?.startMonitoring()
                }
            }
        }
    }
    
    /// Observe Focus Mode status changes
    private func observeFocusStatus() {
        // Check authorization first
        checkAuthorizationStatus()
        
        if authorizationStatus == .authorized {
            startMonitoring()
        }
    }
    
    /// Start monitoring focus status
    private func startMonitoring() {
        updateFocusStatus()
        
        // Poll focus status every 30 seconds
        // (There's no reliable notification API for focus status changes)
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updateFocusStatus()
        }
    }
    
    /// Update the current focus status
    private func updateFocusStatus() {
        guard authorizationStatus == .authorized else {
            isFocusActive = false
            return
        }
        
        isFocusActive = INFocusStatusCenter.default.focusStatus.isFocused ?? false
        
        #if DEBUG
        print("Focus status updated: \(isFocusActive ? "Active" : "Inactive")")
        #endif
    }
    
    deinit {
        timer?.invalidate()
    }
}
