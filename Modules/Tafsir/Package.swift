// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tafsir",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Tafsir",
            targets: ["Tafsir"]
        ),
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(path: "../Common")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Tafsir",
            dependencies: [
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Common", package: "Common"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TafsirTests",
            dependencies: ["Tafsir"]
        ),
    ]
)
