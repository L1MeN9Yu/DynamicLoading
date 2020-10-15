// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DynamicLoading",
    products: [
        .library(name: "DynamicLoading", targets: ["DynamicLoading"]),
    ],
    targets: [
        .target(name: "DynamicLoading", path: "Sources"),
        .testTarget(name: "DynamicLoadingTests", dependencies: ["DynamicLoading"]),
    ]
)
