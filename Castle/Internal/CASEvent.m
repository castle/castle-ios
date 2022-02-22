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
        
        // Check to see that all required fields could be decoded
        if(self.name == nil || self.timestamp == nil || self.token == nil) {
            CASLog(@"Failed to decode all required params, (name: %@, timestamp: %@, token: %@", self.name, self.timestamp, self.token);
            return nil;
        }
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

@end
