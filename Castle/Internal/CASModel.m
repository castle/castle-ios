//
//  CASModel.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASModel.h"

#import "CASUtils.h"

@implementation CASModel

- (NSDictionary *)JSONPayload
{
    CASLog(@"JSONPayload method should be overridden in subclass: %@", NSStringFromClass(self.class));
    return nil;
}

- (NSData *)JSONData
{
    id payload = [self JSONPayload];
    if(payload != nil) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
        if(error != nil) {
            CASLog(@"Seralization of object (%@) failed with error: %@", NSStringFromClass(self.class), error);
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        return data;
    }
    return nil;
}

+ (NSDateFormatter *)timestampDateFormatter
{
    static NSDateFormatter *_timestampDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timestampDateFormatter = [[NSDateFormatter alloc] init];
        [_timestampDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_timestampDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [_timestampDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    });
    return _timestampDateFormatter;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass(self.class), [self JSONPayload]];
}

@end
