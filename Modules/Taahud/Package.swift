// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Taahud",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Taahud",
            targets: ["Taahud"]
        ),
    ],
    targets: [
        .target(
            name: "Taahud"
        ),
        .testTarget(
            name: "TaahudTests",
            dependencies: ["Taahud"]
        ),
    ]
)
