//
//  CASBatch.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Castle/CASModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface CASBatch : CASModel

@property (nonatomic, strong, readonly, nullable) NSArray *events;

+ (nullable instancetype)batchWithEvents:(nullable NSArray *)events;

@end

NS_ASSUME_NONNULL_END
