//
//  CASMonitor.m
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
#import "CASUserJwt.h"
#import "Castle.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASMonitor ()
@property (nonatomic, strong, readwrite) NSArray *events;
@property (nonatomic, strong) NSString *userJwt;
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
    
    NSString *userJwt = [Castle userJwt];
    if(userJwt == nil) {
        CASLog(@"[%@] No user jwt set, won't flush events.", NSStringFromClass(self.class));
        return nil;
    }
    
    CASMonitor *monitor = [[CASMonitor alloc] init];
    monitor.events = events;
    monitor.userJwt = userJwt;
    
    return monitor;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - CASModel

- (nullable id)JSONPayload
{
    if(![Castle isReady]) {
        CASLog(@"[WARNING] SDK not yet ready, CASMonitor JSONPayload will be nil.");
        return nil;
    }
    
    Highwind *highwind = [Castle highwind];
    NSString *userPayload = [[CASUserJwt userWithJwt:self.userJwt] JSONString];
    NSString *encodedUser = [highwind encodeUserJwtPayloadSetWithPayload:userPayload];
    
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
        return [highwind encodeScreenEventWithRequestToken:event.token payload:payload];
    } else if([event isKindOfClass:CASCustom.class]) {
        return [highwind encodeCustomEventWithRequestToken:event.token payload:payload];
    }
    
    NSAssert(false, @"Unhandled event class type (%@) in %s", NSStringFromClass(event.class), __PRETTY_FUNCTION__);
    return nil;
}

@end

NS_ASSUME_NONNULL_END
