//
//  CASEventStorage.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CASEventStorage : NSObject

+ (NSMutableArray *)storedQueue;
+ (void)persistQueue:(NSArray *)queue;

@end
