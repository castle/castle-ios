//
//  CASEvent.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

#import "CASUtils.h"
#import "CASContext.h"
#import "Castle.h"

@interface CASEvent ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSDictionary *properties;
@property (nonatomic, copy, readwrite) NSDate *timestamp;
@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userSignature;
@end

@implementation CASEvent

#pragma mark - Factory

+ (instancetype)eventWithName:(NSString *)name
{
    return [CASEvent eventWithName:name properties:@{}];
}

+ (instancetype)eventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    if(!name) {
        CASLog(@"Event name can't be nil.");
        return nil;
    }

    if([name isEqualToString:@""]) {
        CASLog(@"Event names must be at least one (1) character long.");
        return nil;
    }

    BOOL valid = [CASEvent propertiesContainValidData:properties];
    if(!valid) {
        CASLog(@"Traits dictionary contains invalid data. Supported types are: NSString, NSNumber, NSDictionary & NSNull");
        return nil;
    }

    CASEvent *event = [[self alloc] init];
    event.name = name;
    event.properties = properties;
    return event;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.timestamp = [NSDate date];
        self.userId = [Castle userId];
        self.userSignature = [Castle userSignature];
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectOfClass:NSString.class forKey:@"name"];
        self.properties = [decoder decodeObjectOfClass:NSDictionary.class forKey:@"properties"];
        self.timestamp = [decoder decodeObjectOfClass:NSDate.class forKey:@"timestamp"];
        self.userId = [decoder decodeObjectOfClass:NSString.class forKey:@"user_id"];
        self.userSignature = [decoder decodeObjectOfClass:NSString.class forKey:@"user_signature"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.properties forKey:@"properties"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeObject:self.userId forKey:@"user_id"];
    [encoder encodeObject:self.userSignature forKey:@"user_signature"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    NSString *timestamp = [[CASModel timestampDateFormatter] stringFromDate:self.timestamp];
    NSDictionary *context = [[CASContext sharedContext] JSONPayload];

    NSMutableDictionary *payload = @{ @"type": self.type,
                                      @"event": self.name,
                                      @"timestamp": timestamp,
                                      @"context": context }.mutableCopy;

    if(self.userId != nil) {
        payload[@"user_id"] = self.userId;
    }
    
    if(self.userSignature != nil) {
        payload[@"user_signature"] = self.userSignature;
    }
    
    return [payload copy];
}

#pragma mark - Getters

- (NSString *)type
{
    return @"track";
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
        // If the value is a NSDictionary call the method recursively
        if([value isKindOfClass:NSDictionary.class]) {
            // If the contents aren't valid we can return without continuing any futher
            BOOL valid = [CASEvent propertiesContainValidData:value];
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
            CASLog(@"Properties dictionary contains invalid data. Fount object with type: %@", NSStringFromClass(dictionary.class));
            return NO;
        }
    }

    // No data in the traits dictionary was caught by the validation i.e. it's valid
    return YES;
}

@end
