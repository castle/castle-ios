//
//  CASEventStorage.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CASEventStorage : NSObject

+ (NSArray *)storedQueue;
+ (void)persistQueue:(NSArray *)queue;

@end

NS_ASSUME_NONNULL_END
