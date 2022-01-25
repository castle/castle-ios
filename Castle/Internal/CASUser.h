//
//  CASUser.h
//  Castle
//
//  Created by Alexander Simson on 2022-01-24.
//

#import <Foundation/Foundation.h>

#import "CASModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASUser : CASModel <NSSecureCoding>

@property (nonatomic, copy, readonly) NSString * _Nonnull userId;
@property (nonatomic, copy, readonly) NSString * _Nullable name;
@property (nonatomic, copy, readonly) NSString * _Nullable email;
@property (nonatomic, copy, readonly) NSString * _Nullable phone;
@property (nonatomic, copy, readonly) NSDate * _Nullable registeredAt;
@property (nonatomic, readonly) NSDictionary * _Nullable traits;

+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId;
+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId properties:(NSDictionary * _Nullable)properties;
+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId
                                name:(NSString * _Nullable)name
                               email:(NSString * _Nullable)email
                               phone:(NSString * _Nullable)phone
                        registeredAt:(NSDate * _Nullable)registeredAt
                              traits:(NSDictionary * _Nullable)traits;

@end

NS_ASSUME_NONNULL_END
