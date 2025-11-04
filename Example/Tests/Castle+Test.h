//
//  Castle+Test.h
//  Castle_Example
//
//  Created by Alexander Simson on 2025-11-03.
//  Copyright © 2025 Castle Intelligence. All rights reserved.
//

#import <Castle/Castle.h>

#import "CASEventQueue.h"
#import "CASEvent.h"

@import XCTest;

NS_ASSUME_NONNULL_BEGIN

@interface CASEventQueue (Test)

- (NSArray<CASEvent *> *)storedQueueSync;
- (void)persistQueue:(NSArray<CASEvent *> *)queue;

@end

NS_INLINE NSException * _Nullable tryBlock(void(NS_NOESCAPE^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

NS_INLINE void waitForEventPersistenceWithQueue(CASEventQueue *eventQueue,
                                                NSTimeInterval timeout,
                                                NSTimeInterval delay,
                                                XCTestCase *testCase,
                                                void (^assertion)(NSArray<CASEvent *> *)) {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for event persistence"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray<CASEvent *> *queue = [eventQueue storedQueueSync];
        if (assertion) {
            assertion(queue);
        }
        [expectation fulfill];
    });
    [testCase waitForExpectations:@[expectation] timeout:timeout];
}

NS_ASSUME_NONNULL_END
