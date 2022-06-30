# iOS SDK for Castle

**[Castle](https://castle.io) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Castle.svg)](https://img.shields.io/cocoapods/v/Castle.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Castle.svg?style=flat)](http://cocoapods.org/pods/Castle)
[![CircleCI](https://circleci.com/gh/castle/castle-ios.svg?style=shield)](https://circleci.com/gh/castle/castle-ios)
[![codecov](https://codecov.io/gh/castle/castle-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/castle/castle-ios)

## Requirements

- iOS 9.0+
- Xcode 9.0+

## Installation

Castle is available through [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and [Switft Package Manager](https://swift.org/package-manager/).

### CocoaPods
Add Castle as a dependency by including it in your `Podfile`.

```
pod "Castle", "3.0.6"
```

### Carthage
We have started to include internal dependencies (as xcframeworks) that Carthage currently doesn't support. Therefore we are (temporarily) not supporting Carthage until they add support for adding xcframework dependencies. For now we recommend that you use one of the other installation options.

### Swift Package Manager
Add Castle as a dependency by adding it to the `dependencies` value of your `Package.swift`.

```
dependencies: [
    .package(url: "https://github.com/castle/castle-ios.git", .upToNextMajor(from: "3.0.6"))
]
```

### Manually
Download the zip file from the github release, unzip and drag `GeoZip.xcframework`, `Highwind.xcframework` and `Castle.xcframework` to the **Frameworks, Libraries and Embedded Content** section of the target. They should all be set to **Embed & Sign**

## Usage

Please see the [Mobile Integration Guide](https://docs.castle.io/docs/sdk-mobile).

## Library size

Library size is approximately **74kb** and was calculated using the [cocoapods-size](https://github.com/google/cocoapods-size) tool from Google.
