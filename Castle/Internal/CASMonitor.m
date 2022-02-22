//
//  CASBatch.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASMonitor.h"

#import "CASUtils.h"
#import "Castle+Util.h"
#import "CASEvent.h"
#import "CASScreen.h"
#import "CASCustom.h"
#import "Castle.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASMonitor ()
@property (nonatomic, strong, readwrite) NSArray *events;
@property (nonatomic, strong) CASUser *user;
@end

@implementation CASMonitor

#pragma mark - Factory

+ (nullable instancetype)monitorWithEvents:(nullable NSArray *)events
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

- (nullable id)JSONPayload
{
    Highwind *highwind = [Castle highwind];
    NSString *userPayload = [self.user JSONString];
    NSString *encodedUser = [highwind encodeUserPayloadSetWithPayload:userPayload userFlexibleEncoding:false];
    
    NSMutableArray *encodedEvents = @[].mutableCopy;
    for (CASEvent *event in self.events) {
        NSString *encodedEvent = [self encodeEvent:event];
        [encodedEvents addObject:encodedEvent];
    }
    
    NSString *publishableKey = [Castle publishableKey];
    NSString *encodedData = [highwind encodePayloadWithPublishableKey:publishableKey encodedUserPayload:encodedUser encodedEventPayloads:encodedEvents];
    
    return @{ @"data": encodedData };
}

- (NSString *)encodeEvent:(CASEvent *)event
{
    Highwind *highwind = [Castle highwind];
    NSString *payload = [event JSONString];
    
    if([event isKindOfClass:CASScreen.class]) {
        return [highwind encodeScreenEventWithRequestToken:event.token payload:payload userFlexibleEncoding:false];
    } else if([event isKindOfClass:CASCustom.class]) {
        return [highwind encodeCustomEventWithRequestToken:event.token payload:payload userFlexibleEncoding:false];
    }
    
    NSAssert(false, @"Unhandled event class type (%@) in %s", NSStringFromClass(event.class), __PRETTY_FUNCTION__);
    return nil;
}

@end

NS_ASSUME_NONNULL_END
