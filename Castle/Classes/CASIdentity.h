//
//  CASIdentity.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

@interface CASIdentity : CASEvent

@property (nonatomic, copy, readonly) NSString *userId;

+ (instancetype)identityWithUserId:(NSString *)userId traits:(NSDictionary *)traits;

@end
