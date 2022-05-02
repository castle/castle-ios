//
//  Castle+Util.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import "Castle.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Castle (Util)

+ (nullable Castle *)sharedInstance;

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
  Get the UIApplication instance if available
 
 @return UIApplication instance
 */
+ (nullable UIApplication *)sharedUIApplication;

/**
 Determine if the Castle SDK instance is ready to be used
 */
+ (BOOL)isReady;

/**
 Returns a uniue UUID using [[UIDevice currentDevice] identifierForVendor]
 */
- (nullable NSString *)deviceIdentifier;

@end

NS_ASSUME_NONNULL_END
