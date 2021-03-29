//
//  UIViewController+CASScreen.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CASScreen)

+ (void)ca_swizzleViewDidAppear;

- (void)ca_viewDidAppear:(BOOL)animated;
- (NSString *)ca_viewIdentifier;
- (NSString *)ca_normalizedClassName;

@end
