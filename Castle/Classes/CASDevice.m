//
//  CASDevice.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASDevice.h"

#import <UIKit/UIKit.h>
#include <sys/sysctl.h>

#import "Castle.h"

@implementation CASDevice

+ (instancetype)sharedDevice
{
    static CASDevice *_sharedDevice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDevice = [[CASDevice alloc] init];
    });
    return _sharedDevice;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    return @{ @"model": [CASDevice deviceModel],
              @"manufacturer": @"Apple",
              @"id": [Castle clientId],
              @"type": UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"tablet" : @"phone" };
}

#pragma mark - Private

+ (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char result[size];
    sysctlbyname("hw.machine", result, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
    return results;
}

@end
