//
//  CASModel.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CASModel : NSObject

- (id)JSONPayload;
- (NSData *)JSONData;

+ (NSDateFormatter *)timestampDateFormatter;

@end
