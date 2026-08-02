// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealtimeKit",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "RealtimeKit",
            targets: ["RealtimeKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Romixery/SwiftStomp.git", from: "1.0.4")
    ],
    targets: [
        .target(
            name: "RealtimeKit",
            dependencies: [
                .product(name: "SwiftStomp", package: "SwiftStomp")
            ]
        ),
        .testTarget(
            name: "RealtimeKitTests",
            dependencies: ["RealtimeKit"]
        ),
    ]
)
