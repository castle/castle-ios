//
//  CASModel.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CASModel : NSObject <NSSecureCoding>

- (nullable id)JSONPayload;
- (nullable NSData *)JSONData;
- (nullable NSString *)JSONString;

+ (NSDateFormatter *)timestampDateFormatter;
+ (BOOL)propertiesContainValidData:(NSDictionary * _Nullable)dictionary;

@end

NS_ASSUME_NONNULL_END
