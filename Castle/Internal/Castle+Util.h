//
//  Castle+Util.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import "Castle.h"

@import Highwind;

@interface Castle (Util)

+ (nullable Castle *)sharedInstance;

/**
 Get Highwind instance used for token generation and payload encoding
 
 @return Highwind instance
 */
+ (nullable Highwind *)highwind;

/**
  Get configuration object
 
  @return Configuration object
 */
+ (nullable CastleConfiguration *)configuration;

/**
 Get publishable key
 
 @return Publishable key
 */
+ (nullable NSString *)publishableKey;

/**
 Get stored user jwt from last identify call, returns nil if not set

 @return User JWT
 */
+ (nullable NSString *)userJwt;

/**
 Get current connection state for Wifi

 @return Wifi is available
 */
+ (BOOL)isWifiAvailable;

/**
 Get current connection state for Cellular

 @return Cellular is available
 */
+ (BOOL)isCellularAvailable;

/**
 Get the name of the current carrier, only applicable when a cellular connection is available

 @return Carrier name
 */
+ (nullable NSString *)carrierName;

/**
  Get the UIApplication instance if available
 
 @return UIApplication instance
 */
+ (nullable UIApplication *)sharedUIApplication;

/**
 Determine if the Castle SDK instance is configured
 */
+ (BOOL)isConfigured;

/**
 Determine if the Castle SDK instance is ready to be used
 */
+ (BOOL)isReady;

/**
 Determine if ad tracking is enabled
 */
+ (BOOL)isAdTrackingEnabled;

/**
  Determine if application life cycle tracking is enabled
 */
+ (BOOL)isApplicationLifecycleTrackingEnabled;

/**
 Returns a uniue UUID using [[UIDevice currentDevice] identifierForVendor]
 */
- (nullable NSString *)deviceIdentifier;

@end
