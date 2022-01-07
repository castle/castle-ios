//
//  CastleConfiguration.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CastleConfiguration.h"

static NSString *CastleConfigurationDefaultAPIDomain = @"t.castle.io";
static NSString *CastleConfigurationCastleAPIPath = @"v1/";
static NSString *CastleConfigurationCloudflareAPIPath = @"v1/c/mobile/";

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
    configuration.useCloudflareApp = NO;
    configuration.apiDomain = CastleConfigurationDefaultAPIDomain;
    configuration.apiPath = nil;
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

- (void)setUseCloudflareApp:(BOOL)useCloudflareApp
{
    if (useCloudflareApp && [self.apiDomain isEqualToString:CastleConfigurationDefaultAPIDomain]) {
        NSException *exception = [[NSException alloc] initWithName:@"No API domain set" reason:@"You must set a API domain if useCloudflare app is enabled." userInfo:nil];
        [exception raise];
    }
    _useCloudflareApp = useCloudflareApp;
}

#pragma mark - Getters

- (NSURL *)baseURL
{
    if (self.useCloudflareApp) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@", self.apiDomain, self.apiPath]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@", CastleConfigurationDefaultAPIDomain, self.apiPath]];
}

- (NSString *)apiPath
{
    if (self.useCloudflareApp) {
        if (_apiPath != nil) {
            return _apiPath;
        } else {
            return CastleConfigurationCloudflareAPIPath;
        }
    }
    return CastleConfigurationCastleAPIPath;
}

@end
