//
//  CASScreen.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASScreen.h"

#import "Castle.h"
#import "CASUtils.h"

@interface CASScreen ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSDate *timestamp;
@end

@implementation CASScreen

@synthesize name = _name;
@synthesize timestamp = _timestamp;

#pragma mark - Factory

+ (instancetype)eventWithName:(NSString *)name
{
    if(!name) {
        CASLog(@"Screen name can't be nil.");
        return nil;
    }
    
    if([name isEqualToString:@""]) {
        CASLog(@"Screen names must be at least one (1) character long.");
        return nil;
    }
    
    CASScreen *screen = (CASScreen *) [super eventWithName:name];
    return screen;
}

#pragma mark - CASModel

- (id)JSONPayload
{
    return @{ @"name": self.name };
}

#pragma mark - Getters

- (NSString *)type
{
    return @"$screen";
}

@end
