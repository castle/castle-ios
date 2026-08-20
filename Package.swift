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
          url: "https://github.com/castle/castle-ios/releases/download/4.3.0/Castle.xcframework.zip",
          checksum: "87edd30f38bed8f359c1d66a2a6ea0b72197505763df6b60a02968ed9f92c2a1"
      )
  ]
)
