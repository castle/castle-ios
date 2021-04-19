//
//  CASContext.h
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import "CASModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASContext : CASModel

+ (instancetype)snapshotContext;

@end

NS_ASSUME_NONNULL_END
