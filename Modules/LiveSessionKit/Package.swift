// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiveSessionKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "LiveSessionKit",
            targets: ["LiveSessionKit"]
        )
    ],
    dependencies: [
        .package(path: "../AgoraKit"),
        .package(path: "../RealtimeKit"),
        .package(path: "../NetworkKit"),
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "LiveSessionKit",
            dependencies: [
                .product(name: "AgoraKit", package: "AgoraKit"),
                .product(name: "RealtimeKit", package: "RealtimeKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Common", package: "Common"),
            ]
        ),
        .testTarget(
            name: "LiveSessionKitTests",
            dependencies: ["LiveSessionKit"]
        ),
    ]
)
