// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Listening",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Listening",
            targets: ["Listening"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../NetworkKit"),
        .package(
            url: "https://github.com/Swinject/Swinject.git",
            exact: "2.9.1"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Listening",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Swinject", package: "Swinject"),
            ]
        ),
        .testTarget(
            name: "ListeningTests",
            dependencies: ["Listening"]
        ),
    ]

)
