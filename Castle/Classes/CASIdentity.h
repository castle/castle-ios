//
//  CASIdentity.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

@interface CASIdentity : CASEvent

@property (nonatomic, copy, readonly) NSString * _Nonnull userId;

+ (instancetype _Nullable)identityWithUserId:(NSString * _Nonnull)userId traits:(NSDictionary * _Nonnull)traits;

@end
