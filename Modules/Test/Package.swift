// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Test",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Test",
            targets: ["Test"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Mushaf"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "Test",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Mushaf", package: "Mushaf"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        ),
        .testTarget(
            name: "TestTests",
            dependencies: ["Test"]
        ),
    ]
)
