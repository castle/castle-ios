//
//  CastleConfiguration.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CastleConfiguration : NSObject

@property (nonatomic, copy, readonly) NSString * _Nonnull publishableKey;

@property (nonatomic, assign, getter=isLifecycleTrackingEnabled) BOOL lifecycleTrackingEnabled;
@property (nonatomic, assign, getter=isScreenTrackingEnabled) BOOL screenTrackingEnabled;
@property (nonatomic, assign, getter=isDebugLoggingEnabled) BOOL debugLoggingEnabled;
@property (nonatomic, assign, getter=isDeviceIDAutoForwardingEnabled) BOOL deviceIDAutoForwardingEnabled;

@property (nonatomic, assign) NSUInteger maxQueueLimit;
@property (nonatomic, assign) NSUInteger flushLimit;

@property (nonatomic, strong, readwrite) NSArray<NSURL *> * _Nonnull baseURLWhiteList;

+ (instancetype _Nonnull)configurationWithPublishableKey:(NSString * _Nonnull)publishableKey;
    
@end
