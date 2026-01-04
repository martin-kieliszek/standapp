//
//  ShareService.swift
//  StandFit iOS
//
//  Lightweight service for sharing achievements and progress via iOS ShareSheet
//

import SwiftUI
import UIKit

/// Service for presenting iOS native ShareSheet with content
@MainActor
class ShareService {
    static let shared = ShareService()

    private init() {}

    /// Present ShareSheet with an image and optional text
    /// - Parameters:
    ///   - image: The image to share
    ///   - text: Optional text to accompany the image
    func presentShareSheet(image: UIImage, text: String? = nil) {
        var items: [Any] = [image]
        if let text = text {
            items.append(text)
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Exclude activities that don't make sense for our content
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .print
        ]

        // Present from the top-most view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            print("⚠️ Could not find root view controller for ShareSheet")
            return
        }

        // Find the presented view controller if there is one
        var presentingVC = rootVC
        while let presented = presentingVC.presentedViewController {
            presentingVC = presented
        }

        // On iPad, configure popover presentation
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presentingVC.view
            popover.sourceRect = CGRect(
                x: presentingVC.view.bounds.midX,
                y: presentingVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presentingVC.present(activityVC, animated: true)
    }
}

/// Utility for rendering SwiftUI views to UIImage
@MainActor
struct ShareImageRenderer {
    /// Render a SwiftUI view to a high-resolution UIImage
    /// - Parameters:
    ///   - size: The size of the output image
    ///   - content: The SwiftUI view to render
    /// - Returns: UIImage or nil if rendering fails
    static func render<Content: View>(size: CGSize, @ViewBuilder content: () -> Content) -> UIImage? {
        let view = content()
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // High resolution for social media

        return renderer.uiImage
    }
}
