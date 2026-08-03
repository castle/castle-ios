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
          url: "https://github.com/castle/castle-ios/releases/download/4.2.0/Castle.xcframework.zip",
          checksum: "2ef9186ec59be96922f35e974b731a9939f45f810e29b1092ccc3cecee05b46e"
      )
  ]
)
