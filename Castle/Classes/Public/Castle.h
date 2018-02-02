//
//  Castle.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Castle.
FOUNDATION_EXPORT double CastleVersionNumber;

//! Project version string for Castle.
FOUNDATION_EXPORT const unsigned char CastleVersionString[];

#import "CastleConfiguration.h"

@interface Castle : NSObject

#pragma mark - Configuration
    
+ (void)setupWithConfiguration:(CastleConfiguration *)configuration;
+ (NSURLSessionConfiguration *)urlSessionInterceptConfiguration;

#pragma mark - Tracking

+ (void)identify:(NSString *)identifier;
+ (void)identify:(NSString *)identifier traits:(NSDictionary *)traits;

+ (void)track:(NSString *)eventName;
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties;
    
+ (void)screen:(NSString *)screenName;
+ (void)screen:(NSString *)eventName properties:(NSDictionary *)properties;

+ (void)flush;
+ (void)reset;

+ (BOOL)isWhitelistURL:(NSURL *)url;

#pragma mark - Metadata
    
+ (NSString *)deviceIdentifier;
+ (NSString *)userIdentity;
+ (NSDictionary <NSString *, NSString *> *)headers;
    
@end
