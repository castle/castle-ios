//
//  CASBatch.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASBatch.h"

#import "CASUtils.h"
#import "Castle+Util.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASBatch ()
@property (nonatomic, strong, readwrite) NSArray *events;
@end

@implementation CASBatch

#pragma mark - Factory

+ (nullable instancetype)batchWithEvents:(nullable NSArray *)events
{
    if(![Castle isReady]) {
        CASLog(@"[WARNING] SDK not yet ready, CASBatch JSONPayload will be nil.");
        return nil;
    }
    
    if(!events) {
        CASLog(@"[%@] Nil event array parameter provided. Won't flush events.", NSStringFromClass(self.class));
        return nil;
    }
    
    if(events.count == 0) {
        CASLog(@"[%@] Empty event array parameter provided.", NSStringFromClass(self.class));
        return nil;
    }
    
    CASBatch *batch = [[CASBatch alloc] init];
    batch.events = events;
    return batch;
}

#pragma mark - CASModel

- (nullable NSDictionary *)JSONPayload
{
    if(![Castle isReady]) {
        CASLog(@"[WARNING] SDK not yet ready, CASBatch JSONPayload will be nil.");
        return nil;
    }
    
    NSString *timestamp = [[CASModel timestampDateFormatter] stringFromDate:[NSDate date]];
    return @{ @"batch": [self.events valueForKey:@"JSONPayload"],
              @"sent_at": timestamp };
}

@end

NS_ASSUME_NONNULL_END
