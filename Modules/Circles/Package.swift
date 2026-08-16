// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Circles",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Circles",
            targets: ["Circles"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../NetworkKit"),
        .package(path: "../RealtimeKit"),
        .package(path: "../LiveSessionKit"),
    ],
    targets: [
        .target(
            name: "Circles",
            dependencies: [
                "Common",
                "NetworkKit",
                "RealtimeKit",
                "LiveSessionKit",
            ]
        ),
        .testTarget(
            name: "CirclesTests",
            dependencies: ["Circles"]
        ),
    ]
)
