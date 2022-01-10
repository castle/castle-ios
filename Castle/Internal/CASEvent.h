//
//  CASEvent.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CASModel.h"

@interface CASEvent : CASModel <NSSecureCoding>

@property (nonatomic, copy, readonly) NSString * _Nullable name;
@property (nonatomic, copy, readonly) NSDate * _Nonnull timestamp;
@property (nonatomic, copy, readonly) NSString * _Nonnull type;
@property (nonatomic, readonly) NSString * _Nonnull token;

+ (_Nullable instancetype)eventWithName:(NSString * _Nullable)name;

+ (BOOL)propertiesContainValidData:(NSDictionary * _Nullable)dictionary;

@end
