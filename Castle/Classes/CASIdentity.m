//
//  CASIdentity.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <CASIdentity.h>

#import <CASContext.h>
#import <CASUtils.h>

@interface CASIdentity ()
@property (nonatomic, copy, readwrite) NSString *userId;
@end

@implementation CASIdentity

@synthesize userId = _userId;

+ (instancetype)identityWithUserId:(NSString *)userId traits:(NSDictionary *)traits
{
    if(userId.length == 0) {
        CASLog(@"User id needs to be at least one character long");
        return nil;
    }
    
    CASIdentity *identity = (CASIdentity *) [super eventWithName:@"identify" properties:traits];
    identity.userId = userId;
    return identity;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    NSMutableDictionary *payload = ((NSDictionary *) [super JSONPayload]).mutableCopy;

    // Remove unneccessary data from payload
    [payload removeObjectForKey:@"event"];
    [payload removeObjectForKey:@"properties"];
    
    // Override user_id property with the new userId and set properties for key traits
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
