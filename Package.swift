// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "CastleSDK",
  platforms: [.iOS(.v13)],
  products: [
      .library(name: "CastleSDK", targets: ["CastleSDK"]),
  ],
  targets: [
      .binaryTarget(
          name: "CastleSDK",
          url: "https://github.com/castle/castle-ios/releases/download/4.1.0/Castle.xcframework.zip",
          checksum: "960a67e438db6834f3de26996fc53fabda09a0a6c0d309a3f29251c43b82f098"
      )
  ]
)
