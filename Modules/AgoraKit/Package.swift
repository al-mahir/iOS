// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AgoraKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AgoraKit", targets: ["AgoraKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/AgoraIO/AgoraRtcEngine_iOS",
            from: "4.6.0"
        )
    ],
    targets: [
        .target(
            name: "AgoraKit",
            dependencies: [
                .product(name: "RtcBasic", package: "AgoraRtcEngine_iOS")
            ]
        )
    ]
)
