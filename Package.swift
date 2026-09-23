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
          url: "https://github.com/castle/castle-ios/releases/download/4.3.2/Castle.xcframework.zip",
          checksum: "cde3ef5a4c8a05aec7e4ba0db46b8f0cf3015433f75e91367ad4dd49fde04fd9"
      )
  ]
)
