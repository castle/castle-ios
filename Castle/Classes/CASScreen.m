//
//  CASScreen.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASScreen.h"

#import "Castle.h"
#import "CASDevice.h"
#import "CASUtils.h"

@interface CASScreen ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSDictionary *properties;
@property (nonatomic, copy, readwrite) NSDate *timestamp;
@end

@implementation CASScreen

@synthesize name = _name;
@synthesize properties = _properties;
@synthesize timestamp = _timestamp;

#pragma mark - Factory

+ (instancetype)eventWithName:(NSString *)name
{
    return [CASScreen eventWithName:name properties:@{}];
}

+ (instancetype)eventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    if(!name) {
        CASLog(@"Screen name can't be nil.");
        return nil;
    }
    
    if([name isEqualToString:@""]) {
        CASLog(@"Screen names must be at least one (1) character long.");
        return nil;
    }
    
    BOOL valid = [CASEvent propertiesContainValidData:properties];
    if(!valid) {
        CASLog(@"Traits dictionary contains invalid data. Supported types are: NSString, NSNumber, NSDictionary & NSNull");
        return nil;
    }
    
    CASScreen *screen = [[self alloc] init];
    screen.name = name;
    screen.properties = properties;
    screen.timestamp = [NSDate date];
    return screen;
}

#pragma mark - CASModel

- (id)JSONPayload
{
    NSString *timestamp = [[CASModel timestampDateFormatter] stringFromDate:self.timestamp];
    NSDictionary *context = @{ @"device": [[CASDevice sharedDevice] JSONPayload] };
    
    NSMutableDictionary *payload = @{ @"type": self.type,
                                      @"name": self.name,
                                      @"properties": self.properties,
                                      @"timestamp": timestamp,
                                      @"context": context }.mutableCopy;
    
    NSString *identity = [Castle userIdentity];
    if(identity) {
        payload[@"user_id"] = identity;
    }
    return payload.copy;
}

#pragma mark - Getters

- (NSString *)type
{
    return @"screen";
}

@end
