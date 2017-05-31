//
//  CASBatch.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASBatch.h"

#import "CASUtils.h"

@interface CASBatch ()
@property (nonatomic, strong, readwrite) NSArray *events;
@end

@implementation CASBatch

#pragma mark - Factory

+ (instancetype)batchWithEvents:(NSArray *)events
{
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

- (id)JSONPayload
{
    NSString *timestamp = [[CASModel timestampDateFormatter] stringFromDate:[NSDate date]];
    return @{ @"batch": [self.events valueForKey:@"JSONPayload"],
              @"sent_at": timestamp };
}

@end
