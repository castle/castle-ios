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
          url: "https://github.com/castle/castle-ios/releases/download/4.1.1/Castle.xcframework.zip",
          checksum: "dddd3ce536980cc2216bd28def22d9eb6bc57cab7a4608b8daa5946fcb1095c3"
      )
  ]
)
