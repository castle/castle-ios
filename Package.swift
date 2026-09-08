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
          url: "https://github.com/castle/castle-ios/releases/download/4.3.1/Castle.xcframework.zip",
          checksum: "79441bbbb3f56b6171138de9f6a7c5e9cdfcfee4d3c862aac4869cedc8df6081"
      )
  ]
)
