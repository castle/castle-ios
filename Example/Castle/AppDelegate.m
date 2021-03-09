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
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 20;
    configuration.baseURLAllowList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    return YES;
}

@end
