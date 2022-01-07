//
//  CASEvent.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CASModel.h"

@interface CASEvent : CASModel <NSSecureCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDate *timestamp;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, readonly) NSString *token;

+ (instancetype)eventWithName:(NSString *)name;

+ (BOOL)propertiesContainValidData:(NSDictionary *)dictionary;

@end
