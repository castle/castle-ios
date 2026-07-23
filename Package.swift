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
          url: "https://github.com/castle/castle-ios/releases/download/4.1.2/Castle.xcframework.zip",
          checksum: "19ee9aa967eddc3cc05eade3325c447c521b1d68f1a9f63b533aa1af0d185652"
      )
  ]
)
