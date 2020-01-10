//
//  UIViewController+CASScreen.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "UIViewController+CASScreen.h"

#import "Castle.h"
#import "Castle+Util.h"
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
    
    UIViewController *top = [[self class] ca_visibleViewController];
    if (!top) {
        CASLog(@"Couldn't determine the visible view controller.");
        return;
    }
    
    // Only generate a screen event if the current controller is currently on screen
    if (self == top) {
        NSString *identifier = [top ca_viewIdentifier];
        CASLog(@"Will send automatic screen event for screen: %@", identifier);
        [Castle screen:identifier];
    }
}

+ (UIViewController *)ca_visibleViewController
{
    // Get application instance
    UIApplication *application = [Castle sharedUIApplication];
    
    // Determine the visible view controller starting with the applications root view controller and work our way towards the top.
    if (application != nil) {
        UIViewController *root = application.keyWindow.rootViewController;
        return [self ca_visibleViewController:root];
    }
    
    return nil;
}

+ (UIViewController *)ca_visibleViewController:(UIViewController *)rootViewController
{
    // Deterrmine the currently visible controller using rootViewController as a starting point
    if (rootViewController.presentedViewController != nil) {
        // Get presented view controller (if there is one)
        return [self ca_visibleViewController:rootViewController.presentedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        // Get visible view controller for UINavigationController
        UIViewController *visibleViewController = ((UINavigationController *)rootViewController).visibleViewController;
        return [self ca_visibleViewController:visibleViewController];
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        // Get selected view controller for UITabBarController
        UIViewController *selectedViewController = ((UITabBarController *)rootViewController).selectedViewController;
        return [self ca_visibleViewController:selectedViewController];
    }

    // If the rootViewController doesn't match any of the above cases it should be the visible controller.
    // However this won't account for embedded view controller, but we don't care about that now.
    return rootViewController;
}

- (NSString *)ca_viewIdentifier
{
    // Use the title string of the view controller if available
    if(self.title != nil && ![self.title isEqualToString:@""]) {
        return self.title;
    }

    // Fallback to using the class name
    NSString *identifier = [self ca_normalizedClassName];

    // Empty identifier string: default to Unknown
    if(identifier.length == 0 || [identifier isEqualToString:@"UI"]) {
        return @"Unknown";
    }

    return identifier;
}

- (NSString *)ca_normalizedClassName
{
    // Remove potential namespace (when using Swift)
    NSString *name = [NSStringFromClass(self.class) componentsSeparatedByString:@"."].lastObject;

    // Remove any occurrence of "ViewController"
    name = [name stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];

    return name;
}

@end
