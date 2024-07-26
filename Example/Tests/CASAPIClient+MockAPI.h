//
//  Castle+MockAPI.h
//  Castle_Tests
//
//  Created by Alexander Simson on 2024-07-26.
//  Copyright © 2024 Alexander Simson. All rights reserved.
//

#import "CASAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASAPIClient (MockAPI)

+ (void)swizzleSession;

@end


NS_ASSUME_NONNULL_END
