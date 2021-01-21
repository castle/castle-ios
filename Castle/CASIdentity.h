//
//  CASIdentity.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASIdentity : CASEvent

+ (instancetype _Nullable)identityWithUserId:(NSString *)userId traits:(NSDictionary *)traits;

@end

NS_ASSUME_NONNULL_END
