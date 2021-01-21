//
//  CASAPIClient.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CastleConfiguration;

@interface CASAPIClient : NSObject

+ (instancetype)clientWithConfiguration:(CastleConfiguration *)configuration;

- (NSURLSessionDataTask *)dataTaskWithPath:(NSString *)path
                                  postData:(NSData *)data
                                completion:(void (^)(id _Nullable responseObject, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
