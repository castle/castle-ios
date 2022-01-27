//
//  CASUser.m
//  Castle
//
//  Created by Alexander Simson on 2022-01-24.
//

#import "CASUser.h"
#import "CASUtils.h"

@interface CASUser ()
@property (nonatomic, copy, readwrite) NSString * _Nonnull userId;
@property (nonatomic, copy, readwrite) NSString * _Nullable name;
@property (nonatomic, copy, readwrite) NSString * _Nullable email;
@property (nonatomic, copy, readwrite) NSString * _Nullable phone;
@property (nonatomic, copy, readwrite) NSDate * _Nullable registeredAt;
@property (nonatomic, readwrite) NSDictionary * _Nullable traits;
@end

@implementation CASUser

#pragma mark - Factory

+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId
{
    return [self userWithId:userId
                       name:nil
                      email:nil
                      phone:nil
               registeredAt:nil
                     traits:@{}];
}

+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId properties:(NSDictionary * _Nullable)properties
{
    NSString *name = [properties objectForKey:@"name"];
    NSString *email = [properties objectForKey:@"email"];
    NSString *phone = [properties objectForKey:@"phone"];
    NSDictionary *traits = [properties objectForKey:@"traits"];

    id registeredAt = [properties objectForKey:@"registered_at"];
    if ([registeredAt isKindOfClass:NSString.class]) {
        registeredAt = [[CASModel timestampDateFormatter] dateFromString:registeredAt];
    } else if([registeredAt isKindOfClass:NSDate.class]) {
        // Do nothing, use the NSDate object directly
    } else {
        // If the registered_at param is not a NSString or NSDate set it to nil
        registeredAt = nil;
    }
    
    return [self userWithId:userId
                       name:name
                      email:email
                      phone:phone
               registeredAt:registeredAt
                     traits:traits];
}

+ (_Nullable instancetype)userWithId:(NSString * _Nonnull)userId
                                name:(NSString * _Nullable)name
                               email:(NSString * _Nullable)email
                               phone:(NSString * _Nullable)phone
                        registeredAt:(NSDate * _Nullable)registeredAt
                              traits:(NSDictionary * _Nullable)traits
{
    if(!userId) {
        CASLog(@"User id can't be nil.");
        return nil;
    }
    
    if(userId.length == 0) {
        CASLog(@"User id can't be empty.");
        return nil;
    }
    
    BOOL valid = [CASModel propertiesContainValidData:traits];
    if(traits != nil && !valid) {
        CASLog(@"Traits dictionary contains invalid data. Supported types are: NSString, NSNumber, NSDictionary & NSNull");
        return nil;
    }
    
    CASUser *user = [(CASUser *) [self alloc] init];
    user.userId = userId;
    user.name = name;
    user.email = email;
    user.phone = phone;
    user.registeredAt = registeredAt;
    user.traits = traits;
    return user;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        self.userId = [decoder decodeObjectOfClass:NSString.class forKey:@"userId"];
        self.name = [decoder decodeObjectOfClass:NSString.class forKey:@"name"];
        self.email = [decoder decodeObjectOfClass:NSString.class forKey:@"email"];
        self.phone = [decoder decodeObjectOfClass:NSString.class forKey:@"phone"];
        self.registeredAt = [decoder decodeObjectOfClass:NSString.class forKey:@"registered_at"];
        self.traits = [decoder decodeObjectOfClass:NSDictionary.class forKey:@"traits"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.registeredAt forKey:@"registered_at"];
    [encoder encodeObject:self.traits forKey:@"traits"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:CASUser.class]) {
        return [self.userId isEqual: ((CASUser *) object).userId];
    }
    return false;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    
    [payload setObject:self.userId forKey:@"id"];
    
    if(self.name != nil) {
        [payload setObject:self.name forKey:@"name"];
    }
    
    if(self.email != nil) {
        [payload setObject:self.email forKey:@"email"];
    }
    
    if(self.phone != nil) {
        [payload setObject:self.phone forKey:@"phone"];
    }
    
    if(self.registeredAt != nil) {
        NSString *date = [[CASModel timestampDateFormatter] stringFromDate:self.registeredAt];
        [payload setObject:date forKey:@"registered_at"];
    }
    
    if (self.traits && self.traits.count > 0) {
        [payload setObject:self.traits forKey:@"traits"];
    }
    
    return [payload copy];
}

@end
