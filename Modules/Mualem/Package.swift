// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mualem",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Mualem",
            targets: ["Mualem"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Swinject/Swinject.git",
            exact: "2.9.1"
        ),
        .package(path: "../Common"),
        .package(path: "../Mushaf")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Mualem",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "Common", package: "Common"),
                .product(name: "Mushaf", package: "Mushaf")
            ],
            
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MualemTests",
            dependencies: ["Mualem"]),
    ]
)
