// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [
        .iOS(.v16)
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
        .package(path: "../NetworkKit")
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
                "Common",
                "Authentication",
                "NetworkKit"
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: ["Home"]
        ),
    ]
)

