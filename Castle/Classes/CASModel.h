//
//  CASModel.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CASModel : NSObject

- (id)JSONPayload;
- (NSData *)JSONData;

+ (NSDateFormatter *)timestampDateFormatter;

@end

NS_ASSUME_NONNULL_END
