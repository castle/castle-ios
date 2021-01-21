// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Castle",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Castle",
            targets: ["Castle"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Castle",
            path: "Castle",
            publicHeadersPath: "")
    ]
)
