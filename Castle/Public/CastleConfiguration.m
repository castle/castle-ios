//
//  CastleConfiguration.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CastleConfiguration.h"

static NSString *CastleConfigurationDefaultAPIDomain = @"m.castle.io";
static NSString *CastleConfigurationCastleAPIPath = @"v1/";

@interface CastleConfiguration ()
@property (nonatomic, copy, readwrite) NSString *publishableKey;
@end

@implementation CastleConfiguration

+ (instancetype _Nonnull)configurationWithPublishableKey:(NSString * _Nonnull)publishableKey
{
    NSAssert([publishableKey hasPrefix:@"pk_"], @"You must provide a valid Castle publishable key when initializing the SDK.");

    CastleConfiguration *configuration = [[CastleConfiguration alloc] init];
    configuration.publishableKey = publishableKey;
    configuration.screenTrackingEnabled = NO;
    configuration.debugLoggingEnabled = NO;
    configuration.flushLimit = 20;
    configuration.maxQueueLimit = 1000;
    configuration.enableAdvertisingTracking = YES;
    return configuration;
}

#pragma mark - Setters

- (void)setBaseURLAllowList:(NSArray *)baseURLAllowList
{
    NSMutableArray *allowlist = @[].mutableCopy;
    for (NSURL *url in baseURLAllowList) {
        if([url isKindOfClass:NSURL.class]) {
            // Only add the base URL discarding any other components of the provided URL
            [allowlist addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/", url.scheme, url.host]]];
        }
    }
    _baseURLAllowList = allowlist.copy;
}

#pragma mark - Getters

- (NSURL *)baseURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@", CastleConfigurationDefaultAPIDomain, CastleConfigurationCastleAPIPath]];
}

@end
