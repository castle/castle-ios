//
//  UIViewController+CASScreen.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "UIViewController+CASScreen.h"

#import "Castle.h"
#import "CASUtils.h"

#import <objc/runtime.h>

@implementation UIViewController (CASScreen)

+ (void)ca_swizzleViewDidAppear
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(ca_viewDidAppear:);

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

        CASLog(@"Did swizzle viewDidAppear:");
    });
}

- (void)ca_viewDidAppear:(BOOL)animated
{
    [self ca_viewDidAppear:animated];

    NSString *normalizedClassName = [self normalizedClassName];
    if([normalizedClassName hasPrefix:@"UI"]) {
        return;
    }

    NSString *identifier = [self viewIdentifier];
    CASLog(@"Will send automatic screen event for screen: %@", identifier);
    [Castle screen:identifier];
}

- (NSString *)viewIdentifier
{
    // Use the title string of the view controller if available
    if(self.title != nil && ![self.title isEqualToString:@""]) {
        return self.title;
    }

    // Fallback to using the class name
    NSString *identifier = [self normalizedClassName];

    // Empty identifier string: default to Unknown
    if(identifier.length == 0) {
        return @"Unknown";
    }

    return identifier;
}

- (NSString *)normalizedClassName
{
    // Remove potential namespace (when using Swift)
    NSString *name = [NSStringFromClass(self.class) componentsSeparatedByString:@"."].lastObject;

    // Remove any occurrence of "ViewController"
    name = [name stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];

    return name;
}

@end
