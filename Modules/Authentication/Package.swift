// swift-tools-version: 5.9
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
        .package(url: "https://github.com/google/GoogleSignIn-iOS", "8.0.0"..<"9.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", "11.0.0"..<"11.12.0")
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication"]
        ),
    ]
)

