//
//  Castle+InvalidUUID.h
//  Castle_Example
//
//  Created by Alexander Simson on 2022-04-29.
//  Copyright © 2022 Alexander Simson. All rights reserved.
//

#import <Castle/Castle.h>

NS_ASSUME_NONNULL_BEGIN

@interface Castle (InvalidUUID)

@property (nonatomic, assign) BOOL swizzle;

+ (void)enableSwizzle:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
