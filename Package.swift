// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "http",
    products: [
        .library(
            name: "http",
            targets: ["http"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "http",
            dependencies: []),
        .testTarget(
            name: "httpTests",
            dependencies: ["http"]),
    ]
)
