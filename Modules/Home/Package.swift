// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Home",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Home",
            targets: ["Home"]
        ),
    ],
    dependencies: [
      
        .package(path: "../Common"),
        .package(path: "../Authentication"),
        .package(path: "../NetworkKit"),
        .package(path: "../Mushaf"),
        .package(path: "../Sheikh"),
        .package(path: "../Search"),
        .package(path: "../Circles"),
        .package(path: "../Notification"),
        .package(path: "../Test")
        
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
                "Common",
                "Authentication",
                "NetworkKit",
                "Mushaf",
                "Sheikh",
                "Search",
                "Circles",
                "Notification",
                "Test"
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: ["Home"]
        ),
    ]
)

