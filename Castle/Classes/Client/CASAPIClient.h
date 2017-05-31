//
//  CASAPIClient.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CastleConfiguration;

@interface CASAPIClient : NSObject

+ (instancetype)clientWithConfiguration:(CastleConfiguration *)configuration;

- (NSURLSessionDataTask *)dataTaskWithPath:(NSString *)path
                                  postData:(NSData *)data
                                completion:(void (^)(id responseObject, NSURLResponse *response, NSError *error))completion;

@end
