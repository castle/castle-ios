//
//  Castle+MockAPI.m
//  Castle_Tests
//
//  Created by Alexander Simson on 2024-07-26.
//  Copyright © 2024 Alexander Simson. All rights reserved.
//

#import "CASAPIClient+MockAPI.h"
#import "Castle_Tests-Swift.h"
#import <Castle/CASUtils.h>
#import <Castle/Castle+Util.h>

#import <objc/runtime.h>

@implementation CASAPIClient (MockAPI)

+ (void)swizzleSession;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(session);
        SEL swizzledSelector = @selector(ca_session);

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

- (NSURLSession *)ca_session
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = @[MockURLProtocol.self];
    return [NSURLSession sessionWithConfiguration:configuration];
}

@end
