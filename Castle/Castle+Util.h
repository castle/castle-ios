//
//  Castle+Util.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import <Castle/Castle.h>

@interface Castle (Util)

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
+ (NSString *)carrierName;

/**
  Get the UIApplication instance if available
 
 @return UIApplication instance
 */
+ (UIApplication *)sharedUIApplication;

@end
