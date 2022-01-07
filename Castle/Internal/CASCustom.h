//
//  CASCustom.h
//  Pods
//
//  Created by Alexander Simson on 2022-01-07.
//

#import "CASEvent.h"

@interface CASCustom : CASEvent

@property (nonatomic, readonly) NSDictionary *properties;

+ (instancetype)eventWithName:(NSString *)name properties:(NSDictionary *)properties;

@end
