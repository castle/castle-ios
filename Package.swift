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
            targets: ["Castle", "Highwind", "GeoZip"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Castle",
            dependencies: ["Highwind", "GeoZip"],
            path: "Castle/",
            exclude: ["Info.plist", "Highwind.xcframework", "GeoZip.xcframework"],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Public"),
                .headerSearchPath("Internal"),
                .define("NS_BLOCK_ASSERTIONS", to: "1", .when(configuration: .release))
            ]
        ),
        .binaryTarget(
            name: "Highwind",
            path: "Castle/Highwind.xcframework"
        ),
        .binaryTarget(
            name: "GeoZip",
            path: "Castle/GeoZip.xcframework"
        )
    ]
)
