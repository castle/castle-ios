//
//  CASEvent.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CASModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASEvent : CASModel

@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, copy, readonly, nonnull) NSDate *timestamp;
@property (nonatomic, copy, readonly, nonnull) NSString *type;
@property (nonatomic, readonly, nonnull) NSString *token;

+ (nullable instancetype)eventWithName:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
