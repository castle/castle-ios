//
//  CASMonitor.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASMonitor : CASModel

@property (nonatomic, strong, readonly, nullable) NSArray *events;

+ (nullable instancetype)monitorWithEvents:(nullable NSArray *)events;

@end

NS_ASSUME_NONNULL_END
