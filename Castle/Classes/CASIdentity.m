//
//  CASIdentity.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASIdentity.h"

#import "CASIdentity.h"
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
    NSString *timestamp = [[CASModel timestampDateFormatter] stringFromDate:self.timestamp];
    
    return @{ @"type": @"identify",
              @"user_id": self.userId,
              @"traits": self.properties,
              @"timestamp": timestamp };
}

@end
