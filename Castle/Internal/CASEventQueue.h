//
//  CASEventStorage.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CASEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASEventQueue : NSObject

@property (readonly, nonatomic) NSUInteger count;

- (void)queueEvent:(CASEvent *)event;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
