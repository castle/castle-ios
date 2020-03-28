//
//  Castle.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "Castle.h"

#import <UIKit/UIKit.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "CASAPIClient.h"
#import "CASReachability.h"
#import "CASUtils.h"
#import "CASEvent.h"
#import "CASIdentity.h"
#import "CASScreen.h"
#import "CASBatch.h"
#import "CASEventStorage.h"
#import "CASRequestInterceptor.h"
#import "UIViewController+CASScreen.h"

NSString *const CastleUserIdentifierKey = @"CastleUserIdentifierKey";
NSString *const CastleSecureSignatureKey = @"CastleSecureSignatureKey";
NSString *const CastleAppVersionKey = @"CastleAppVersionKey";

NSString *const CastleClientIdHeaderName = @"X-Castle-Client-Id";

static CTTelephonyNetworkInfo *_telephonyNetworkInfo;

@interface Castle ()
@property (nonatomic, strong) CASAPIClient *client;
@property (nonatomic, strong) CastleConfiguration *configuration;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userSignature;
@property (nonatomic, assign, readonly) NSUInteger maxBatchSize;
@property (nonatomic, strong, readwrite) CASReachability *reachability;
@end

@implementation Castle

@synthesize userId = _userId;
@synthesize userSignature = _userSignature;

+ (instancetype)sharedInstance {
    static Castle *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Castle alloc] init];
    });
    return _sharedClient;
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark - Configuration

+ (void)configure:(CastleConfiguration *)configuration
{
    // Setup shared instance using provided configuration
    Castle *castle = [Castle sharedInstance];
    castle.client = [CASAPIClient clientWithConfiguration:configuration];
    castle.configuration = configuration;

    castle.reachability = [CASReachability reachabilityWithHostname:@"google.com"];
    [castle.reachability startNotifier];
    
    // Initialize interceptor
    if(configuration.isDeviceIDAutoForwardingEnabled) {
        [NSURLProtocol registerClass:[CASRequestInterceptor class]];
    }

    // Initialize automatic screen events
    if(configuration.isScreenTrackingEnabled) {
        [UIViewController ca_swizzleViewDidAppear];
    }

    // Update debug logging setting
    CASEnableDebugLogging([configuration isDebugLoggingEnabled]);

    // Track application update/install
    [castle trackApplicationUpdated];
}

+ (void)configureWithPublishableKey:(NSString *)publishableKey
{
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:publishableKey];
    [Castle configure:configuration];
}

+ (void)resetConfiguration
{
    Castle *castle = [Castle sharedInstance];
    CastleConfiguration *configuration = castle.configuration;
    
    // Reset Castle shared instance properties
    castle.client = nil;
    castle.configuration = nil;
    castle.reachability = nil;
    CASEnableDebugLogging(NO);
    
    // Unregister request interceptor
    if(configuration.isDeviceIDAutoForwardingEnabled) {
        [NSURLProtocol unregisterClass:[CASRequestInterceptor class]];
    }
}

+ (NSURLSessionConfiguration *)urlSessionInterceptConfiguration
{
    NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
    configuration.protocolClasses = @[[CASRequestInterceptor class]];
    return configuration;
}

#pragma mark - Getters

+ (NSString *)versionString
{
    return @"1.0.4";
}

- (NSString *)deviceIdentifier
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSMutableArray *)eventQueue
{
    if(!_eventQueue) {
        NSArray *persistedQueue = [CASEventStorage storedQueue];
        _eventQueue = [persistedQueue != nil && persistedQueue.count > 0 ? persistedQueue.copy : @[] mutableCopy];
    }
    return _eventQueue;
}

- (NSUInteger)maxBatchSize
{
    return 100;
}

- (NSString *)userId
{
    // If there's no user id: try fetching it from settings
    if(!_userId) {
        _userId = [[NSUserDefaults standardUserDefaults] objectForKey:CastleUserIdentifierKey];
    }
    return _userId;
}

- (NSString *)userSignature
{
    // If there's no user signature: try fetching it from settings
    if(!_userSignature) {
        _userSignature = [[NSUserDefaults standardUserDefaults] objectForKey:CastleSecureSignatureKey];
    }
    return _userSignature;
}

+ (NSString *)userAgent
{
    return CASUserAgent();
}

+ (BOOL)isWifiAvailable
{
    return [Castle sharedInstance].reachability.isReachableViaWiFi;
}

+ (BOOL)isCellularAvailable
{
    return [Castle sharedInstance].reachability.isReachableViaWWAN;
}

+ (NSString *)carrierName
{
    static dispatch_once_t networkInfoOnceToken;
    dispatch_once(&networkInfoOnceToken, ^{
        _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    
    CTCarrier *carrier = [_telephonyNetworkInfo subscriberCellularProvider];
    return carrier.carrierName.length > 0 ? carrier.carrierName : @"unknown";
}

+ (UIApplication *)sharedUIApplication
{
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

#pragma mark - Setters

- (void)setUserId:(NSString *)userId
{
    _userId = userId;

    // Store user identity in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:CastleUserIdentifierKey];
    [defaults synchronize];
}
    
- (void)setUserSignature:(NSString *)userSignature
{
    _userSignature = userSignature;
    
    // Store user signature in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userSignature forKey:CastleSecureSignatureKey];
    [defaults synchronize];
}

#pragma mark - Tracking

+ (void)track:(NSString *)eventName
{
    [Castle track:eventName properties:@{}];
}

+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties
{
    if(!eventName || [eventName isEqualToString:@""]) {
        CASLog(@"No event name provided. Will cancel track event operation.");
        return;
    }

    Castle *castle = [Castle sharedInstance];
    CASEvent *event = [CASEvent eventWithName:eventName properties:properties];
    [castle queueEvent:event];
}

+ (void)screen:(NSString *)screenName
{
    [Castle screen:screenName properties:@{}];
}

+ (void)screen:(NSString *)screenName properties:(NSDictionary *)properties
{
    if(!screenName || [screenName isEqualToString:@""]) {
        CASLog(@"No screen name provided. Will cancel track event operation.");
        return;
    }

    Castle *castle = [Castle sharedInstance];
    CASScreen *screen = [CASScreen eventWithName:screenName properties:properties];
    [castle queueEvent:screen];
}

+ (void)identify:(NSString *)userId
{
    [Castle identify:userId traits:@{}];
}

+ (void)identify:(NSString *)userId traits:(NSDictionary *)traits
{
    if(!userId || [userId isEqualToString:@""]) {
        CASLog(@"No user id provided. Will cancel identify operation.");
        return;
    }

    Castle *castle = [Castle sharedInstance];
    if(![castle secureModeEnabled]) {
        CASLog(@"Identify called without secure mode user signature set. If secure mode is enabled in Castle and identify is called before secure, the identify event will be discarded.");
    }
    
    CASIdentity *identity = [CASIdentity identityWithUserId:userId traits:traits];
    if(identity != nil) {
        [castle setUserId:userId];
        [castle queueEvent:identity];
        
        // Identify call will always flush
        [Castle flush];
    }
}

+ (void)secure:(NSString *)userSignature
{
    if(!userSignature || [userSignature isEqualToString:@""]) {
        CASLog(@"No user signature provided. Will cancel secure operation.");
        return;
    }
    
    Castle *castle = [Castle sharedInstance];
    [castle setUserSignature:userSignature];
}

+ (void)flush
{
    __block Castle *castle = [Castle sharedInstance];

    if(castle.task != nil) {
        CASLog(@"Queue is already being flushed. Won't flush again.");
        return;
    }

    NSArray *batch = @[];
    if ([castle.eventQueue count] >= castle.maxBatchSize) {
        batch = [castle.eventQueue subarrayWithRange:NSMakeRange(0, castle.maxBatchSize)];
    } else {
        batch = [NSArray arrayWithArray:castle.eventQueue];
    }

    CASLog(@"Flushing %ld of %ld queued events", batch.count, castle.eventQueue.count);

    __block CASBatch *batchModel = [CASBatch batchWithEvents:batch];

    // Nil batch model object means there's no events to flush
    if(!batchModel) {
        return;
    }

    castle.task = [castle.client dataTaskWithPath:@"batch" postData:[batchModel JSONData] completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if(error != nil) {
            CASLog(@"Flush failed with error: %@", error);
            castle.task = nil;
            return;
        }

        // Remove successfully flushed events from queue and persist
        [castle.eventQueue removeObjectsInArray:batchModel.events];
        [castle persistQueue];

        castle.task = nil;

        CASLog(@"Successfully flushed (%ld) events: %@", batchModel.events.count, [batchModel JSONPayload]);
        
        if ([castle eventQueueExceedsFlushLimit] && castle.eventQueue.count > 0) {
            CASLog(@"Current event queue still exceeds flush limit. Flush again");
            [Castle flush];
        }
    }];

    [castle.task resume];
}

+ (void)flushIfNeeded:(NSURL *)url
{
    if([self isWhitelistURL:url]) {
        [self flush];
    }
}

+ (void)reset
{
    Castle *castle = [Castle sharedInstance];
    CASLog(@"(%ld) event in queue. Resetting event queue.", castle.eventQueue.count);

    // Cancel any running flush task
    [castle.task cancel];
    castle.task = nil;

    // Flush queue
    [Castle flush];

    // Reset cached user id
    castle.userId = nil;
    
    // Reset cached signature
    castle.userSignature = nil;
}

+ (BOOL)isWhitelistURL:(NSURL *)url
{
    if(url == nil) {
        CASLog(@"Provided whitelist URL was nil");
        return NO;
    }

    Castle *castle = [Castle sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.host = %@ AND self.scheme = %@", url.host, url.scheme];
    return [castle.configuration.baseURLWhiteList filteredArrayUsingPredicate:predicate].count > 0;
}

#pragma mark - Private

- (BOOL)eventQueueExceedsFlushLimit
{
    return [self.eventQueue count] >= self.configuration.flushLimit;
}

- (void)queueEvent:(CASEvent *)event
{
    if(!event) {
        CASLog(@"Can't enqueue nil event");
        return;
    }

    // Trim queue before adding element to make sure it never exceeds maxQueueLimit
    [self trimQueue];
    
    // Add event to the queue
    CASLog(@"Queing event: %@", event);
    [self.eventQueue addObject:event];

    // Persist queue to disk
    [self persistQueue];

    // Flush queue if the number of events exceeds the flush limit
    if(self.eventQueue.count >= self.configuration.flushLimit) {
        // very first event should be fired immediately
        CASLog(@"Event queue exceeded flush limit (%ld). Flushing events.", [Castle sharedInstance].configuration.flushLimit);
        [self.class flush];
    }
}

- (void)trimQueue
{
    // Trim queue to maxQueueLimit - 1. This method is only called when queuing an event
    NSUInteger maxQueueLimit = self.configuration.maxQueueLimit - 1;
    
    // If the queue doesn't exceed maxQueueLimit just return
    if(self.eventQueue.count < maxQueueLimit) {
        return;
    }
    
    // Remove the oldest excess events from the queue
    NSRange trimRange = NSMakeRange(0, self.eventQueue.count - maxQueueLimit);
    CASLog(@"Queue (size %ld) will exceed maxQueueLimit (%ld). Will trim %ld events from queue.", self.eventQueue.count, self.configuration.maxQueueLimit, trimRange.length);
    [self.eventQueue removeObjectsInRange:trimRange];
}

- (void)persistQueue
{
    CASLog(@"Will persist queue with %ld events.", self.eventQueue.count);
    [CASEventStorage persistQueue:self.eventQueue.copy];
}

- (void)trackApplicationUpdated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *installedVersion = [defaults objectForKey:CastleAppVersionKey];

    if (installedVersion == nil) {
        // This means that the application was just installed.
        CASLog(@"No app version was stored in settings: the application was just installed.");
        CASLog(@"Application life cycle event detected: Will track install event");
        [Castle track:@"Application installed"];

        // Flush the event queue when a application installed event is triggered
        [Castle flush];
    } else if (![installedVersion isEqualToString:currentVersion]) {
        // App version changed since the application was last run: application was updated
        CASLog(@"App version stored in settings is different from current version string: the application was just updated.");
        CASLog(@"Application life cycle event detected: Will track update event");
        [Castle track:@"Application updated"];

        // Flush the event queue when a application updated event is triggered
        [Castle flush];
    }

    [defaults setObject:currentVersion forKey:CastleAppVersionKey];
    [defaults synchronize];
}

- (BOOL)secureModeEnabled
{
    return self.userSignature != nil;
}

#pragma mark - Application Lifecycle

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    CASLog(@"Application life cycle event detected: Will track application did become active event");
    [Castle track:@"Application Did Become Active"];

    // Flush the event queue when a application did become active event is triggered
    [Castle flush];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    CASLog(@"Application life cycle event detected: Will track application did enter background event");
    [Castle track:@"Application Did Enter Background"];

    // Flush the event queue when a application did enter background event is triggered
    [Castle flush];
}

- (void)applicationWillTerminate:(NSNotificationCenter *)notification
{
    CASLog(@"Application life cycle event detected: Will track application will terminate event");
    [Castle track:@"Application Will Terminate"];

    // Flush the event queue when a application will terminate event is triggered
    [Castle flush];
}

#pragma mark - Metadata

+ (NSString *)clientId
{
    return [Castle sharedInstance].deviceIdentifier;
}

+ (NSString *)userId
{
    return [Castle sharedInstance].userId;
}
    
+ (NSString *)userSignature
{
    return [Castle sharedInstance].userSignature;
}

+ (NSUInteger)queueSize
{
    return [Castle sharedInstance].eventQueue.count;
}

@end
