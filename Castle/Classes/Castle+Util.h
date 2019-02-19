//
//  Castle+Util.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import <Castle/Castle.h>

@interface Castle (Util)

+ (BOOL)isWifiAvailable;
+ (BOOL)isCellularAvailable;
+ (NSString *)carrierName;
+ (NSString *)userAgent;

@end
