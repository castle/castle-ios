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

@synthesize userId = _userId;

+ (instancetype)identityWithUserId:(NSString *)userId
{
    if(userId.length == 0) {
        CASLog(@"User id needs to be at least one character long");
        return nil;
    }
    
    CASIdentity *identity = (CASIdentity *) [super eventWithName:@"identify"];
    identity.userId = userId;
    return identity;
}

#pragma mark - CASModel

- (id)JSONPayload
{
    NSMutableDictionary *payload = ((NSDictionary *) [super JSONPayload]).mutableCopy;

    // Remove unneccessary data from payload
    [payload removeObjectForKey:@"event"];
    
    // Override user_id property with the new userId and set properties for key traits
    [payload setObject:self.userId forKey:@"user_id"];
    
    return [payload copy];
}

#pragma mark - Getters

- (NSString *)type
{
    return @"identify";
}

@end
