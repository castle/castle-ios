//
//  CASIdentity.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASIdentity.h"

#import "CASContext.h"
#import "CASUtils.h"

@interface CASIdentity ()
@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSDictionary *traits;
@end

@implementation CASIdentity

@synthesize userId = _userId;

+ (instancetype)identityWithUserId:(NSString *)userId traits:(NSDictionary *)traits
{
    if(userId.length == 0) {
        CASLog(@"User id needs to be at least one character long");
        return nil;
    }
    
    
    BOOL valid = [CASIdentity traitsContainValidData:traits];
    if(!valid) {
        CASLog(@"Traits dictionary contains invalid data. Supported types are: NSString, NSNumber, NSDictionary & NSNull");
        return nil;
    }
    
    CASIdentity *identity = (CASIdentity *) [super eventWithName:@"identify"];
    identity.userId = userId;
    identity.traits = traits;
    return identity;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self) {
        self.traits = [decoder decodeObjectOfClass:NSDictionary.class forKey:@"traits"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.traits forKey:@"traits"];
}

#pragma mark - CASModel

- (id)JSONPayload
{
    NSMutableDictionary *payload = ((NSDictionary *) [super JSONPayload]).mutableCopy;

    // Remove unneccessary data from payload
    [payload removeObjectForKey:@"event"];
    
    // Override user_id property with the new userId and set properties for key traits
    [payload setObject:self.userId forKey:@"user_id"];
    [payload setObject:self.traits forKey:@"traits"];
    
    return [payload copy];
}

#pragma mark - Getters

- (NSString *)type
{
    return @"identify";
}

#pragma mark - Util

+ (BOOL)traitsContainValidData:(NSDictionary *)dictionary
{
    // Check if dictionary is nil
    if(!dictionary) {
        return NO;
    }

    // Iterate through the contents and make sure there's no unsupported data types
    for(id value in dictionary.allValues) {
        // If the value is a NSDictionary call the method recursively
        if([value isKindOfClass:NSDictionary.class]) {
            // If the contents aren't valid we can return without continuing any futher
            BOOL valid = [CASIdentity traitsContainValidData:value];
            if(!valid) {
                return NO;
            }
        }

        // If the value if of any other type than NSNumber, NSString or NSNull: validation failed
        if(!([value isKindOfClass:NSNumber.class] ||
             [value isKindOfClass:NSString.class] ||
             [value isKindOfClass:NSNull.class] ||
             [value isKindOfClass:NSDictionary.class] ||
             [value isKindOfClass:NSArray.class]))
        {
            CASLog(@"Traits dictionary contains invalid data. Fount object with type: %@", NSStringFromClass(dictionary.class));
            return NO;
        }
    }

    // No data in the traits dictionary was caught by the validation i.e. it's valid
    return YES;
}

@end
