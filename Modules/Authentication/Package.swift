// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Authentication", targets: ["Authentication"]),
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ]
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication"]
        ),
    ]
)

