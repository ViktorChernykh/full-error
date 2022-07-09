// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FullError",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "FullError", targets: ["FullError"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "FullError", dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ]),
        .testTarget(name: "FullErrorTests", dependencies: [
            .product(name: "XCTVapor", package: "vapor"),
            .target(name: "FullError"),
        ])
    ]
)
