//
//  Castle+InvalidUUID.m
//  Castle_Example
//
//  Created by Alexander Simson on 2022-04-29.
//  Copyright © 2022 Alexander Simson. All rights reserved.
//

#import "Castle+InvalidUUID.h"
#import <Castle/CASUtils.h>
#import <Castle/Castle+Util.h>

#import <objc/runtime.h>

@implementation Castle (InvalidUUID)

NSString const *swizzleKey = @"castle.invalidUUID.swizzle.key";

- (void)setSwizzle:(BOOL)enable
{
    objc_setAssociatedObject(self, &swizzleKey, @(enable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)swizzle
{
    return [objc_getAssociatedObject(self, &swizzleKey) boolValue];
}

+ (void)ca_swizzleDeviceIdentifier
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(deviceIdentifier);
        SEL swizzledSelector = @selector(ca_deviceIdentifier);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

+ (void)enableSwizzle:(BOOL)enabled
{
    [self ca_swizzleDeviceIdentifier];
    [self sharedInstance].swizzle = enabled;
}

- (nullable NSString *)ca_deviceIdentifier
{
    if(self.swizzle) {
        return nil;
    }
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end
