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
          url: "https://github.com/castle/castle-ios/releases/download/4.3.3/Castle.xcframework.zip",
          checksum: "ba384125519e771af8b190b6e85909e3ada048d3c6e80bc332a07f61a439aedc"
      )
  ]
)
