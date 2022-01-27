//
//  CASBatch.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASMonitor.h"

#import "CASUtils.h"
#import "Castle+Util.h"
#import "Castle.h"

@interface CASMonitor ()
@property (nonatomic, strong, readwrite) NSArray *events;
@property (nonatomic, strong) CASUser *user;
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
    
    CASUser *user = [Castle user];
    if(user == nil) {
        CASLog(@"[%@] No user id set, won't flush events.", NSStringFromClass(self.class));
        return nil;
    }
    
    CASMonitor *batch = [[CASMonitor alloc] init];
    batch.events = events;
    batch.user = user;
    return batch;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    id userPayload = [self.user JSONPayload];
    return @{
        @"user": userPayload,
        @"events": [self.events valueForKey:@"JSONPayload"]
    };
}

@end
