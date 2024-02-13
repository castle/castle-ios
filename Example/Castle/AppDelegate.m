//
//  AppDelegate.m
//  Castle
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

#import "AppDelegate.h"

@import AdSupport;
@import AppTrackingTransparency;

#import <Castle/Castle.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 20;
    configuration.baseURLAllowList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    [configuration setAdSupportBlock:^NSString* {
#if TARGET_IPHONE_SIMULATOR
        return @"00000000-0000-0000-0000-000000000001";
#else
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#endif
    }];
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    return YES;
}

@end
