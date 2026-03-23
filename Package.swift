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
          url: "https://github.com/castle/castle-ios/releases/download/4.0.0/Castle.xcframework.zip",
          checksum: "0b5e96bfa5c461d032bdb7f5509a8c9e41152cc0fb92d33ed624d783df2770a7"
      )
  ]
)
