//
//  CASUserJwt.h
//  Castle
//
//  Created by Alexander Simson on 2022-03-08.
//

#import <Foundation/Foundation.h>

#import "CASModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASUserJwt : CASModel

@property (nonatomic, copy, readonly) NSString * _Nonnull jwt;

+ (_Nullable instancetype)userWithJwt:(NSString * _Nullable)jwt;

@end

NS_ASSUME_NONNULL_END
