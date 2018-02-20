# iOS SDK for Castle

**[Castle](https://castle.io) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Castle.svg)](https://img.shields.io/cocoapods/v/Castle.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/castle/castle-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/castle/castle-ios)
[![Build Status](https://travis-ci.org/castle/castle-ios.svg?branch=master)](https://travis-ci.org/castle/castle-ios)

## Requirements

- iOS 9.0+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.2+

## Installation

Castle is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

```
pod "Castle", "0.9.8"
```

### Carthage

```
github "castle/castle-ios"
```

### Configuration

Add the following snippet to your app delegate's `application:didFinishLaunchingWithOptions:` method.

##### Swift

```swift
import Castle

let configuration = CastleConfiguration(publishableKey: "pk_373428597387773")

// The URL of your API
configuration.baseURLWhiteList = [URL(string: "https://api.example.com/")!] // Default: []
configuration.isDeviceIDAutoForwardingEnabled = true                        // Default: false

// Optional configuration
configuration.isScreenTrackingEnabled = true                                // Default: true
configuration.isDebugLoggingEnabled = true                                  // Default: false
        
// Setup Castle SDK with provided configuration
Castle.setup(with: configuration)
```

##### Objective-C
```objective-c
#import <Castle/Castle.h>

// Create configuration object
CastleConfiguration *configuration =
  [CastleConfiguration configurationWithPublishableKey:@"pk_373428597387773"];

// The URL of your API
configuration.baseURLWhiteList =
  @[[NSURL URLWithString:@"https://api.example.com/"]];  // Default: []
configuration.isDeviceIDAutoForwardingEnabled = YES      // Default: NO

// Optional configuration
configuration.screenTrackingEnabled = YES;               // Default: YES
configuration.debugLoggingEnabled = YES;                 // Default: NO
    
// Setup Castle SDK with provided configuration
[Castle setupWithConfiguration:configuration];
```

#### Client ID auto-forwarding

The Client ID can be automatically forwarded by including your backend endpoint to the `baseURLWhitelist` array property and setting `isDeviceIDAutoForwardingEnabled` of your `CastleConfiguration` instance when configuring the SDK. All requests made using the shared NSURLSession (`URLSession.shared / [NSURLSession sharedSession]`) matching any of the base URLs provided in the `baseURLWhitelist` array will be intercepted and the `X-Castle-Client-Id` will automatically be added and then picked up by the server-side SDK.

If you're setting up your own `NSURLSession` you can use get a configuration object with the auto-forwarding enabled like this.

##### Swift

```swift
let configuration = Castle.urlSessionInterceptConfiguration()
```

##### Objective-C

```objective-c
NSURLSessionConfiguration *configuration = [Castle urlSessionInterceptConfiguration]
```

The configuration can then be modified or left as is and provided when initializing the `NSURLSession` instance.

#### Manual Client ID forwarding

If you don't want to use the auto forwarding functionality you can easily add the required header when creating your requests. When using NSURLRequest it can easily be added according to the following examples.

##### Swift

```swift
request.setValue(Castle.deviceIdentifier, forHTTPHeaderField: CASCastleDeviceIdHeaderKey)
```

##### Objective-C

```objective-c
[request setValue:[Castle deviceIdentifier] forHTTPHeaderField:CASCastleDeviceIdHeaderKey];
```

##### Flushing

Remember to flush the queue after starting a request. This can be done by calling the ```flushIfNeeded``` method. It takes the url as an argument and will automatically flush the queue if the url matches a base url in the whitelist.

#### Identify

The `identify` call lets you tie a user to their action and should be called right after the user logged in successfully. The `user_id` will be persisted locally so subsequent calls `screen` will automatically be tied to that user.

##### Swift

```swift
Castle.identify("1245-3055")
```

##### Objective-C

```objective-c
[Castle identify:@"1245-3055"];
```

#### Manually tracking screen views

The default behavior is to let the SDK automatically track screen views, but you can always disable `isScreenTrackingEnabled` and instead call `screen` for each screen view.

Track screen view and include some properties (optional):

##### Swift

```swift
Castle.screen("Menu", properties: ["role": "Admin"])
```

##### Objective-C

```objective-c
[Castle screen:@"Menu" properties:@{ @"role": @"Admin" }];
```
