// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sheikh",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Sheikh", targets: ["Sheikh"]),
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(path: "../Common"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "Sheikh",
            dependencies: [
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Common",     package: "Common"),
                .product(name: "Alamofire",  package: "Alamofire"),
            ]
        ),
        .testTarget(
            name: "SheikhTests",
            dependencies: ["Sheikh"]
        ),
    ]
)
