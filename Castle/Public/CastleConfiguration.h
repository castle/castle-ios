//
//  CastleConfiguration.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This object provides configuration options used to initialize the Castle SDK.
 Changes to the configuration object won't have any affect on the SDK configuration once configured.
 */
@interface CastleConfiguration : NSObject

/**
 Castle publishable key
 */
@property (nonatomic, copy, readonly) NSString * _Nonnull publishableKey;

/**
 Automatic screen tracking enabled
 */
@property (nonatomic, assign, getter=isScreenTrackingEnabled) BOOL screenTrackingEnabled;

/**
 Debug logging enabled
 */
@property (nonatomic, assign, getter=isDebugLoggingEnabled) BOOL debugLoggingEnabled;

/**
 Device ID auto forwarding enabled
 */
@property (nonatomic, assign, getter=isDeviceIDAutoForwardingEnabled) BOOL deviceIDAutoForwardingEnabled;

/**
 The upper limit for stored events in the event queue
 */
@property (nonatomic, assign) NSUInteger maxQueueLimit;

/**
 The number of events stored before flushing the queue
 */
@property (nonatomic, assign) NSUInteger flushLimit;

/**
 Base url allowlist
 */
@property (nonatomic, strong, readwrite, nullable) NSArray<NSURL *> *baseURLAllowList;

/**
 Cloudflare proxying enabled
 */
@property (nonatomic, assign) BOOL useCloudflareApp;

/**
 Get base url
 */
@property (nonatomic, copy, readonly, getter=baseURL, nonnull) NSURL * baseURL;

/**
 Get API domain
 */
@property (nonatomic, copy) NSString * _Nonnull apiDomain;

/**
 Get API path
 */
@property (nonatomic, copy) NSString * _Nullable apiPath;

/**
 Default configuration with provided publishable key

 @param publishableKey Castle publishable key
 @return CastleConfiguration instance with default settings
 @code // Create configuration object
 CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_373428597387773"];
 @endcode
 */
+ (instancetype _Nonnull)configurationWithPublishableKey:(NSString * _Nonnull)publishableKey;

/**
 Default configuration without publishable key
 @return CastleConfiguration instance with default settings
 @code // Create configuration object
 CastleConfiguration *configuration = [CastleConfiguration defaultConfiguration];
 @endcode
 */
+ (instancetype _Nonnull)defaultConfiguration;

@end
