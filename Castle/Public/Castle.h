//
//  Castle.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Project version number for Castle. */
FOUNDATION_EXPORT double CastleVersionNumber;

/**
 Project version string for Castle. */
FOUNDATION_EXPORT const unsigned char CastleVersionString[];

NS_ASSUME_NONNULL_BEGIN

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
 Get base url
 */
@property (nonatomic, copy, readonly, getter=baseURL, nonnull) NSURL *baseURL;

/**
 Sets a block to be called when IDFA / AdSupport identifier is created.
 */
@property (nonatomic, strong, nullable) NSString * _Nonnull (^adSupportBlock)(void);

/**
 Whether the analytics client should track advertisting info. `YES` by default.
 */
@property (nonatomic, assign, getter=isAdvertisingTrackingEnabled) BOOL enableAdvertisingTracking;

/**
  Wether the analytics client should track application lifecycle events. `YES` by default.
 */
@property (nonatomic, assign, getter=isApplicationLifecycleTrackingEnabled) BOOL enableApplicationLifecycleTracking;

/**
 Default configuration with provided publishable key

 @param publishableKey Castle publishable key
 @return CastleConfiguration instance with default settings
 @code // Create configuration object
 CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_373428597387773"];
 @endcode
 */
+ (instancetype _Nonnull)configurationWithPublishableKey:(NSString * _Nonnull)publishableKey;

@end

/**
 Castle request token header name
 */
extern NSString * const CastleRequestTokenHeaderName;

/**
 This class is the main entry point for using the Castle SDK and provides methods
 for tracking events, screen views, manual flushing of the event queue, allowlisting behaviour and resetting. */
@interface Castle : NSObject

/**
 Get SDK version as a string

 @return Version string
 */
+ (NSString *)versionString;

#pragma mark - Configuration

/**
 Configure Castle using the provided configuration

 @param configuration CastleConfiguration instance
 @code CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_373428597387773"];
 [Castle configure:configuration];
 @endcode
 */
+ (void)configure:(CastleConfiguration *)configuration;

/**
 Configure Castle with default configuration using publishable key

 @param publishableKey Castle publishable key
 @code [Castle configureWithPublishableKey:@"pk_373428597387773"];
 */
+ (void)configureWithPublishableKey:(NSString *)publishableKey;

/**
 Session configuration used to enable the Castle request interceptor.
 All requests created with the NSURLSession using the configuration will be intercepted if the URL is
 allowlisted and the client identifier will be added as a header 'X-Castle-Client-Id'.

 This can be used to enable the request interceptor on a specific NSURLSession for more
 control instead of setting deviceIDAutoForwardingEnabled on your CastleConfiguration instance to YES.

 @return NSURLSessionConfiguration with the Castle interceptor enabled
 @code // Initialize an NSURLSession instance with the request interceptor enabled
 NSURLSessionConfiguration *configuration = [Castle urlSessionInterceptConfiguration];
 NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
 @endcode
 */
+ (NSURLSessionConfiguration *)urlSessionInterceptConfiguration;

/**
 Reset current configuration. Will disable logging, request interception (if enabled).
 Once reset the shared Castle instance can be re-configured.

 @code // Reset configuration
 [Castle resetConfiguration];
 @endcode
 */
+ (void)resetConfiguration;

#pragma mark - Tracking

/**
 Track identify event with specified user id. User jwt will be persisted. A call to identify or reset will clear the stored user identity.

 @param userJwt User Jwt
 @code // Set user jwt
 [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];
 @endcode
 */
+ (void)setUserJwt:(nullable NSString *)userJwt NS_SWIFT_NAME(userJwt(_:));

/**
 Track screen event with a specified name

 @param name Screen name
 @code // Track a screen view
 [Castle screenWithName:@"Menu"];
 @endcode
 */
+ (void)screenWithName:(NSString *)name NS_SWIFT_NAME(screen(name:));

/**
 Track custom event with a specified name

 @param name Event name
 @code // Track custom event
 [Castle customWithName:@"Custom"];
 @endcode
 */
+ (void)customWithName:(NSString *)name NS_SWIFT_NAME(custom(name:));

/**
 Track custom event with a specified name and properties

 @param name Event name
 @param properties Properties
 @code // Track custom event with properties
 [Castle customWithName:@"Custom" properties:@{ @"customKey": @"value" }];
 @endcode
 */
+ (void)customWithName:(NSString *)name properties:(NSDictionary *)properties NS_SWIFT_NAME(custom(name:properties:));

/**
 Force a flush of the event queue, even if the flush limit hasn't been reached
 */
+ (void)flush;

/**
 Force a flush if needed for a specific url, flushes if url is allowlisted

 @param url Allowlist url
 @code // Flush if the provided url matches an allowlisted base url
 [Castle flushIfNeeded:[NSURL urlWithString:@"https://google.com/foobar"];
 @endcode
 */
+ (BOOL)flushIfNeeded:(nonnull NSURL *)url;

/**
 Reset any stored user information and flush the event queue
 */
+ (void)reset;

/**
 Determine if a given url is allowlisted

 @param url url
 @return return url allowlist status
 */
+ (BOOL)isAllowlistURL:(nullable NSURL *)url;

/**
 Get base url

 @return return Base URL
 */
+ (NSURL *)baseURL;

#pragma mark - Metadata

/**
 Get request token

 @return request token
 */
+ (NSString *)createRequestToken;

/**
 Get the User Agent for used in all requests to the Castle API.
 User agent will have the following format: App Name/x.x (xxxx) (iPhone XR; iOS xx.x; Castle x.x.x)

 @return User Agent
 */
+ (NSString *)userAgent;

/**
 Get the current size of the event queue

 @return return The current size of the event queue
 */
+ (NSUInteger)queueSize;

@end

NS_ASSUME_NONNULL_END
