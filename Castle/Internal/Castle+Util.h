//
//  Castle+Util.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import "Castle.h"
#import "CASUser.h"

@import Highwind;

@interface Castle (Util)

/**
 Get Highwind instance used for token generation and payload encoding
 
 @return Highwind instance
 */
+ (nonnull Highwind *)highwind;

/**
 Get publishable key
 
 @return Publishable key
 */
+ (nullable NSString *)publishableKey;

/**
 Get stored user information from last identify call, returns nil if not set

 @return User object
 */
+ (nullable CASUser *)user;

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

@end
