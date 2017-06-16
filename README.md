# iOS SDK for Castle

**[Castle](https://castle.io) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Castle.svg)](https://img.shields.io/cocoapods/v/Castle.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/castle/castle-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/aalekz/castle-ios)
[![Build Status](https://travis-ci.org/castle/castle-ios.svg?branch=master)](https://travis-ci.org/aalekz/castle-ios)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
	- [Configuration](#configuration)
	- [Identify](#identify)
	- [Track Events](#track-events)
	- [Track Screen Views](#track-screen-views)

## Requirements

- iOS 9.0+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.2+

## Installation

Castle is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

```
pod "Castle", "0.9"
```

### Carthage

```
github "castle/castle-ios"
```

### Usage

#### Configuration

Configurating Castle is easy. Add the following snippet to your app delegate's ```application:didFinishLaunchingWithOptions:``` method.

##### Swift

```swift
import Castle

// Create configuration
let configuration = CastleConfiguration(publishableKey: "pk_373428597387773")
configuration.isScreenTrackingEnabled = true
configuration.isDebugLoggingEnabled = true

// Setup Castle SDK with provided configuration
Castle.setup(with: configuration)
```
##### Objective-C
```objective-c
#import <Castle/Castle.h>

// Create configuration object
CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_373428597387773"];
configuration.screenTrackingEnabled = YES;
configuration.debugLoggingEnabled = YES;
configuration.baseURLWhiteList = @[ [NSURL URLWithString:@"https://api.castle.io/"] ];
    
// Setup Castle SDK with provided configuration
[Castle setupWithConfiguration:configuration];
```
#### Identify

The identify call lets you tie a user to their action and record traits about them. We recommend calling it once after the user successfully logged in. The user_id will be persisted locally so subsequent calls to track and screen will automatically be tied to that user.

##### Swift

```swift
// Identify user with a unique identifier
Castle.identify("1245-3055")

// OR

// Identify user with a unique identifier including user traits
Castle.identify("1245-3055", traits: [ "email": "laura@example.com" ] )
```
##### Objective-C
```objective-c
// Track an event
[Castle identify:@"1245-3055"];

// OR

// Identify user with unique identifier including user traits
[Castle identify:@"1245-3055" traits:@{ @"email": @"laura@example.com" }];
```

#### Track Events

Track lets you record any actions your users perform, along with properties that describe the action. It could look something like this:

##### Swift

```swift
// Track an event
Castle.track("loginFormSubmitted")

// OR

// Track an event and include some properties
Castle.track("loginFormSubmitted", properties: ["username": "laura"])
```
##### Objective-C
```objective-c
// Track an event
[Castle track:@"loginFormSubmitted"];

// OR

// Track an event and include some properties
[Castle track:@"loginFormSubmitted" properties:@{ @"username": @"laura" }];
```

#### Track Screen Views

The screen call lets you record whenever a user sees a screen. It could look something like this:

##### Swift

```swift
// Track a screen view
Castle.screen("Menu")

// OR

// Track screen view and include some properties
Castle.screen("Menu", properties: ["locale": "en_US"])
```
##### Objective-C
```objective-c
// Track a screen view
[Castle screen:@"Menu"];

// OR

// Track a screen view and include some properties
[Castle screen:@"Menu" properties:@{ @"locale": @"en_US" }];
```
