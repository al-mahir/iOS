// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Notification",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Notification",
            targets: ["Notification"]
        ),
    ],
    dependencies: [
            .package(path: "../Authentication"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Notification",
            dependencies: [
                .product(name: "Authentication", package: "Authentication"),
            ],
        ),
        .testTarget(
            name: "NotificationTests",
            dependencies: ["Notification"]
        ),
    ]
)
