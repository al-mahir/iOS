// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgoraKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AgoraKit",
            targets: ["AgoraKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/AgoraIO/AgoraRtcEngine_iOS.git",
            from: "4.6.0"
        )
    ],
    targets: [
        .target(
            name: "AgoraKit",
            dependencies: [
                .product(name: "RtcBasic", package: "AgoraRtcEngine_iOS")
            ]
        ),
        .testTarget(
            name: "AgoraKitTests",
            dependencies: ["AgoraKit"]
        )
    ]
)
