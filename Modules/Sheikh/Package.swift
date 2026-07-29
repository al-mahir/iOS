// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sheikh",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Sheikh", targets: ["Sheikh"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", exact: "2.9.1"),
        .package(path: "../NetworkKit"),
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "Sheikh",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Common", package: "Common"),
            ]
        ),
        .testTarget(
            name: "SheikhTests",
            dependencies: ["Sheikh"]
        ),
    ]
)
