//
//  CASIdentity.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

@interface CASIdentity : CASEvent

+ (instancetype _Nullable)identityWithUserId:(NSString * _Nonnull)userId traits:(NSDictionary * _Nonnull)traits;

@end
