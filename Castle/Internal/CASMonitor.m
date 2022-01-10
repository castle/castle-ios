//
//  CASBatch.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASMonitor.h"

#import "CASUtils.h"
#import "Castle.h"

@interface CASMonitor ()
@property (nonatomic, strong, readwrite) NSArray *events;
@end

@implementation CASMonitor

#pragma mark - Factory

+ (instancetype)monitorWithEvents:(NSArray *)events
{
    if(!events) {
        CASLog(@"[%@] Nil event array parameter provided. Won't flush events.", NSStringFromClass(self.class));
        return nil;
    }
    
    if(events.count == 0) {
        CASLog(@"[%@] Empty event array parameter provided.", NSStringFromClass(self.class));
        return nil;
    }
    
    if([Castle userId] == nil) {
        CASLog(@"[%@] No user id set, won't flush events.", NSStringFromClass(self.class));
        return nil;
    }
    
    CASMonitor *batch = [[CASMonitor alloc] init];
    batch.events = events;
    return batch;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    return @{
        @"user": @{ @"id": [Castle userId] },
        @"events": [self.events valueForKey:@"JSONPayload"]
    };
}

@end
