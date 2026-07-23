# iOS SDK for Castle

**[Castle](https://castle.io) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

[![License](https://img.shields.io/cocoapods/l/Castle.svg?style=flat)](http://cocoapods.org/pods/Castle)
[![CircleCI](https://circleci.com/gh/castle/castle-ios.svg?style=shield)](https://circleci.com/gh/castle/castle-ios)
[![codecov](https://codecov.io/gh/castle/castle-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/castle/castle-ios)

**NOTE:** Version `4.0.0` has small breaking changes compared to previous `3.x.x.` Versions. The import statement changed to `CastleSDK`. `configure` is now a throwable, and `createRequestToken` returns nil before the sdk is initialized.


## Requirements
- iOS 13.0+

## Compiled with
- Xcode 26.2 (swiftlang-6.2.3.3.20 clang-1700.6.3.2)

## Installation

Castle is available through [Switft Package Manager](https://swift.org/package-manager/).
Version < 4.0.0 are also avilable through [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### Swift Package Manager
Add Castle as a dependency by adding it to the `dependencies` value of your `Package.swift`.

```
dependencies: [
    .package(url: "https://github.com/castle/castle-ios.git", .upToNextMajor(from: "4.1.2"))
]
```

### Manually
Download the zip file from the github release, unzip and drag `Castle.xcframework` to the **Frameworks, Libraries and Embedded Content** section of the target. They should all be set to **Embed & Sign**

## Usage

Please see the [Mobile Integration Guide](https://docs.castle.io/docs/sdk-mobile).

## Library size

Library size is approximately **1.3mb**.


