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

#import "CastleConfiguration.h"

/**
 Castle client id header name */
extern NSString *const CastleClientIdHeaderName;

/**
 This class is the main entry point for using the Castle SDK and provides methods
 for tracking events, screen views, manual flushing of the event queue, whitelisting behaviour and resetting. */
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
 whitelisted and the client identifier will be added as a header 'X-Castle-Client-Id'.
 
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
 Track identify event with specified user identity. User identity will be persisted. A call to identify or reset will clear the stored user identity.

 @param identifier user id
 @code // Identify user with unique identifier
 [Castle identify:@"1245-3055"];
 @endcode
 */
+ (void)identify:(NSString *)identifier;

/**
 Track identify event with specified user identity. User identity will be persisted. A call to identify or reset will clear the stored user identity.
 Provided user traits will be included in the identify event sent to the Castle API.

 @param identifier user id
 @param traits user traits
 @code // Identify user with unique identifier including user traits
 [Castle identify:@"1245-3055" traits:@{ @"email": @"laura@example.com" }];
 @endcode
 */
+ (void)identify:(NSString *)identifier traits:(NSDictionary *)traits;

/**
 Track event with a specified name

 @param eventName event name
 @code // Track an event
 [Castle track:@"loginFormSubmitted"];
 @endcode
 */
+ (void)track:(NSString *)eventName;

/**
 Track event with a specified name and provided properties
 
 @param eventName event name
 @param properties event properties
 @code // Track an event and include some properties
 [Castle track:@"loginFormSubmitted" properties:@{ @"username": @"laura" }];
 @endcode
 */
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties;

/**
 Track screen event with a specified name

 @param screenName Screen name
 @code // Track a screen view
 [Castle screen:@"Menu"];
 @endcode
 */
+ (void)screen:(NSString *)screenName;

/**
 Track screen event with a specified name

 @param screenName Screen name
 @param properties Screen properties
 @code // Track a screen view and include some properties
 [Castle screen:@"Menu" properties:@{ @"locale": @"en_US" }];
 @endcode
 */
+ (void)screen:(NSString *)screenName properties:(NSDictionary *)properties;

/**
 Force a flush of the batch event queue, even if the flush limit hasn't been reached
 */
+ (void)flush;

/**
 Force a flush if needed for a specific url, flushes if url is whitelisted

 @param url Whitelist url
 @code // Flush if the provided url matches a whitelisted base url
 [Castle flushIfNeeded:[NSURL urlWithString:@"https://google.com/foobar"];
 @endcode
 */
+ (void)flushIfNeeded:(NSURL *)url;

/**
 Reset any stored user information and flush the event queue
 */
+ (void)reset;

/**
 Determine if a given url is whitelisted

 @param url url
 @return return url whitelist status
 */
+ (BOOL)isWhitelistURL:(NSURL *)url;

#pragma mark - Metadata

/**
 Get client identifier if set, otherwise returns nil

 @return client identifier
 */
+ (NSString *)clientId;

/**
 Get stored user identity from last identify call, returns nil if not set

 @return User identity
 */
+ (NSString *)userIdentity;


/**
 Get the current size of the event queue

 @return return The current size of the event queue
 */
+ (NSUInteger)queueSize;
    
@end
