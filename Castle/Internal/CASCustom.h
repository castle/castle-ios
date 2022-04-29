//
//  CASCustom.h
//  Castle
//
//  Created by Alexander Simson on 2022-01-07.
//

#import "CASEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASCustom : CASEvent

@property (nonatomic, readonly) NSDictionary * _Nullable properties;

+ (_Nullable instancetype)eventWithName:(NSString * _Nullable)name properties:(NSDictionary * _Nullable)properties;

@end

NS_ASSUME_NONNULL_END
