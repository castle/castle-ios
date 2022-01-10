//
//  CASEvent.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEvent.h"

#import "CASUtils.h"
#import "Castle.h"

@interface CASEvent ()
@property (nonatomic, copy, readwrite, nullable) NSString *name;
@property (nonatomic, copy, readwrite) NSDate *timestamp;
@property (nonatomic, copy, readwrite) NSString *token;
@end

@implementation CASEvent

#pragma mark - Factory

+ (instancetype)eventWithName:(NSString *)name
{
    CASEvent *event = [[self alloc] init];
    event.name = [name truncate:255];
    return event;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.timestamp = [NSDate date];
        self.token = [Castle createRequestToken];
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectOfClass:NSString.class forKey:@"name"];
        self.timestamp = [decoder decodeObjectOfClass:NSDate.class forKey:@"timestamp"];
        self.token = [decoder decodeObjectOfClass:NSString.class forKey:@"token"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeObject:self.token forKey:@"token"];
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

    return @{ @"type": self.type,
              @"timestamp": timestamp,
              @"request_token": self.token };
}

#pragma mark - Getters

- (NSString *)type
{
    NSAssert(false, @"Subclass of CASEvent must override %s", __PRETTY_FUNCTION__);
    return nil;
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
