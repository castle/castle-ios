//
//  CASModel.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASModel.h"

#import "CASUtils.h"

@implementation CASModel

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { }

- (id)JSONPayload
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
        return data;
    }
    return nil;
}

- (NSString *)JSONString
{
    NSData *data = [self JSONData];
    if(data != nil) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
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

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Util

+ (BOOL)propertiesContainValidData:(NSDictionary *)dictionary
{
    // Check if dictionary is nil
    if(!dictionary) {
        return NO;
    }

    // Iterate through the contents and make sure there's no unsupported data types
    for(id value in dictionary.allValues) {
        // If the value if of any other type than NSNumber, NSString or NSNull: validation failed
        if(!([value isKindOfClass:NSNumber.class] ||
             [value isKindOfClass:NSString.class] ||
             [value isKindOfClass:NSNull.class] ||
             [value isKindOfClass:NSDictionary.class] ||
             [value isKindOfClass:NSArray.class]))
        {
            CASLog(@"Properties dictionary contains invalid data. Fount object with type: %@", NSStringFromClass(dictionary.class));
            return NO;
        }
    }

    // No data in the traits dictionary was caught by the validation i.e. it's valid
    return YES;
}

@end
