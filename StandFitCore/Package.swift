// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StandFitCore",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "StandFitCore",
            targets: ["StandFitCore"]),
    ],
    targets: [
        .target(
            name: "StandFitCore",
            dependencies: []),
        .testTarget(
            name: "StandFitCoreTests",
            dependencies: ["StandFitCore"]),
    ]
)
