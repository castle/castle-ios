//
//  CASCustom.m
//  Castle
//
//  Created by Alexander Simson on 2022-01-07.
//

#import "CASCustom.h"

#import "Castle.h"
#import "CASUtils.h"

NS_ASSUME_NONNULL_BEGIN

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

+ (nullable instancetype)eventWithName:(nullable NSString *)name
{
    return [self eventWithName:name properties:@{}];
}

+ (nullable instancetype)eventWithName:(nullable NSString *)name properties:(nullable NSDictionary *)properties
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
    
    CASCustom *custom = (CASCustom *) [super eventWithName:name];
    custom.properties = properties;
    return custom;
}

#pragma mark - CASModel

- (nullable id)JSONPayload
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

NS_ASSUME_NONNULL_END
