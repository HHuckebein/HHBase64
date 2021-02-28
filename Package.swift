// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HHBase64",
    products: [
        .library(
            name: "HHBase64",
            targets: ["HHBase64"]),
    ],
    targets: [
        .target(
            name: "HHBase64",
            dependencies: []),
        .testTarget(
            name: "HHBase64Tests",
            dependencies: ["HHBase64"]),
    ]
)
