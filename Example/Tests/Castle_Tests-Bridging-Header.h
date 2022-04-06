//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "MainViewController.h"

NS_INLINE NSException * _Nullable tryBlock(void(NS_NOESCAPE^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
