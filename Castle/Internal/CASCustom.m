//
//  CASCustom.m
//  Castle
//
//  Created by Alexander Simson on 2022-01-07.
//

#import "CASCustom.h"

#import "Castle.h"
#import "CASUtils.h"

@interface CASCustom ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSDictionary *properties;
@property (nonatomic, copy, readwrite) NSDate *timestamp;
@end

@implementation CASCustom

@synthesize name = _name;
@synthesize properties = _properties;
@synthesize timestamp = _timestamp;

#pragma mark - Factory

+ (instancetype)eventWithName:(NSString *)name
{
    return [self eventWithName:name properties:@{}];
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
    
    CASCustom *custom = (CASCustom *) [super eventWithName:name];
    custom.properties = properties;
    return custom;
}

#pragma mark - CASModel

- (id)JSONPayload
{
    NSMutableDictionary *payload = ((NSDictionary *) [super JSONPayload]).mutableCopy;
    
    // Add name to payload and remove event property
    [payload setObject:self.name forKey:@"name"];
    
    if (self.properties && self.properties.count > 0) {
        [payload setObject:self.properties forKey:@"properties"];
    }
    
    return [payload copy];
}

#pragma mark - Getters

- (NSString *)type
{
    return @"$custom";
}

@end
