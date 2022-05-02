//
//  AppDelegate.m
//  Castle
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

#import "AppDelegate.h"

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
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    // Enable secure mode
    NSString *signature = @"d2a28f905835ddcdd783be84c727a3b039ccdd3eef481259b6f9ecfaeeef573e";
    [Castle secure:signature];
    
    return YES;
}

@end
