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
@end

@implementation CASIdentity

+ (instancetype)identityWithUserId:(NSString *)userId traits:(NSDictionary *)traits
{
    if(userId.length == 0) {
        CASLog(@"User id needs to be at least on character long");
        return nil;
    }
    
    CASIdentity *identity = (CASIdentity *) [super eventWithName:@"identify" properties:traits];
    identity.userId = userId;
    return identity;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self) {
        self.userId = [decoder decodeObjectOfClass:NSString.class forKey:@"userId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.userId forKey:@"userId"];
}

#pragma mark - CASModel

- (id)JSONPayload
{
    NSMutableDictionary *payload = ((NSDictionary *) [super JSONPayload]).mutableCopy;

    // Remove unneccessary data from payload
    [payload removeObjectForKey:@"event"];
    [payload removeObjectForKey:@"properties"];
    
    // Add user_id to payload and remove event property
    [payload setObject:self.userId forKey:@"user_id"];
    [payload setObject:self.properties forKey:@"traits"];
    
    return [payload copy];
}

#pragma mark - Getters

- (NSString *)type
{
    return @"identify";
}

@end
