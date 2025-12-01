//
//  Castle.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "Castle.h"

#import <UIKit/UIKit.h>

#import "CASAPIClient.h"
#import "CASUtils.h"
#import "CASEvent.h"
#import "CASScreen.h"
#import "CASCustom.h"
#import "CASMonitor.h"
#import "CASEventQueue.h"
#import "CASRequestInterceptor.h"
#import "UIViewController+CASScreen.h"

@import Highwind;

NS_ASSUME_NONNULL_BEGIN

static NSString *CastleConfigurationDefaultAPIDomain = @"m.castle.io";
static NSString *CastleConfigurationCastleAPIPath = @"v1/";

@interface CastleConfiguration ()
@property (nonatomic, copy, readwrite) NSString *publishableKey;
@end

@implementation CastleConfiguration

+ (instancetype _Nonnull)configurationWithPublishableKey:(NSString * _Nonnull)publishableKey
{
    NSAssert([publishableKey hasPrefix:@"pk_"], @"You must provide a valid Castle publishable key when initializing the SDK.");

    CastleConfiguration *configuration = [[CastleConfiguration alloc] init];
    configuration.publishableKey = publishableKey;
    configuration.screenTrackingEnabled = NO;
    configuration.debugLoggingEnabled = NO;
    configuration.flushLimit = 20;
    configuration.maxQueueLimit = 1000;
    configuration.enableAdvertisingTracking = YES;
    configuration.enableApplicationLifecycleTracking = YES;
    return configuration;
}

#pragma mark - Setters

- (void)setBaseURLAllowList:(nullable NSArray *)baseURLAllowList
{
    NSMutableArray *allowlist = @[].mutableCopy;
    for (NSURL *url in baseURLAllowList) {
        if([url isKindOfClass:NSURL.class]) {
            // Only add the base URL discarding any other components of the provided URL
            [allowlist addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/", url.scheme, url.host]]];
        }
    }
    _baseURLAllowList = allowlist.copy;
}

#pragma mark - Getters

- (NSURL *)baseURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@", CastleConfigurationDefaultAPIDomain, CastleConfigurationCastleAPIPath]];
}

@end


static Castle *_sharedClient = nil;

NSString *const CastleUserJwtKey = @"CastleUserJwtKey";
NSString *const CastleAppVersionKey = @"CastleAppVersionKey";

NSString *const CastleRequestTokenHeaderName = @"X-Castle-Request-Token";

@interface Castle ()
@property (nonatomic, strong, nullable) CastleConfiguration *configuration;
@property (nonatomic, strong, nullable) CASEventQueue *eventQueue;
@property (nonatomic, copy, readwrite, nullable) NSString *userJwt;
@property (nonatomic, strong, readwrite, nullable) Highwind *highwind;
@end

@implementation Castle

@synthesize userJwt = _userJwt;

+ (instancetype)sharedInstance {
    NSAssert([Castle isConfigured], @"Castle SDK must be configured before calling this method");
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Castle alloc] init];
    });
    
    // Check if the SDK has already been configured.
    // If that is the case reset the instance and start over.
    if ([Castle isConfigured]) {
        [Castle resetConfiguration];
    }
    
    // Setup shared instance using provided configuration
    Castle *castle = _sharedClient;
    castle.configuration = configuration;
    
    // Initialize event queue, must be done after setting configuration
    castle.eventQueue = [[CASEventQueue alloc] init];
    
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
    // If the SDK hasn't been configured, no reset is necessary
    if (![Castle isConfigured]) {
        return;
    }
    
    Castle *castle = [Castle sharedInstance];
    CastleConfiguration *configuration = castle.configuration;
    
    // Reset Castle shared instance properties
    castle.eventQueue = nil;
    castle.configuration = nil;
    castle.highwind = nil;
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

- (nullable Highwind *)highwind
{
    // Create a new Highwind instance if there is none and the SDK has been configured
    if (_highwind == nil && [[self class] isConfigured]) {
        Castle *castle = [Castle sharedInstance];
        CastleConfiguration *configuration = castle.configuration;
        
        NSString *uuid = [castle deviceIdentifier];
        NSError *error = nil;
        _highwind = [[Highwind alloc] initWithVersion:Castle.versionString
                                                 uuid:uuid
                                       publishableKey:configuration.publishableKey
                                            userAgent:CASUserAgent()
                                                error:&error
                                       adSupportBlock:configuration.adSupportBlock];
        
        if(error) {
            if (error.domain == HighwindErrorDomain && error.code == HighwindErrorInvalidPublishableKey) {
                NSAssert(true, @"You must provide a valid Castle publishable key when initializing the SDK.");
            } else if (error.domain == HighwindErrorDomain && error.code == HighwindErrorInvalidUUID) {
                CASLog(@"[WARNING] Invalid uuid detected (%@). Will try to recover.", uuid);
            }
            NSAssert(true, @"Unknown unrecoverable error occurred: %@", error);
        }
    }
    return _highwind;
}

+ (NSString *)versionString
{
    return @"3.1.6";
}

- (nullable NSString *)deviceIdentifier
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (nullable NSString *)userJwt
{
    // If there's no user jwt: try fetching it from settings
    if(!_userJwt) {
        _userJwt = [[NSUserDefaults standardUserDefaults] objectForKey:CastleUserJwtKey];
    }
    return _userJwt;
}

+ (BOOL)isConfigured
{
    if (_sharedClient == nil) {
        return NO;
    }
    
    Castle *castle = _sharedClient;
    if (castle.configuration == nil) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isReady
{
    // SDK isn't ready if it hasn't been configured
    if (![self isConfigured]) {
        return NO;
    }
    
    // Check for valid Highwind instance
    Castle *castle = _sharedClient;
    if (castle.highwind == nil) {
        return NO;
    }
    
    // Validation passed, SDK ready to be used
    return YES;
}

+ (NSString *)userAgent
{
    return CASUserAgent();
}

+ (nullable UIApplication *)sharedUIApplication
{
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

+ (BOOL)isAdTrackingEnabled
{
    // SDK isn't ready if it hasn't been configured
    if (![self isReady]) {
        return NO;
    }
    
    Castle *castle = _sharedClient;
    if ((castle.configuration.adSupportBlock != nil) && (castle.configuration.enableAdvertisingTracking)) {
        return YES;
    }
    return NO;
}

+ (BOOL)isApplicationLifecycleTrackingEnabled
{
    // SDK isn't ready if it hasn't been configured
    if (![self isReady]) {
        return NO;
    }
    
    return _sharedClient.configuration.enableApplicationLifecycleTracking;
}

#pragma mark - Setters

- (void)setUserJwt:(nullable NSString *)userJwt
{
    _userJwt = userJwt;
    
    // Store user jwt in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userJwt forKey:CastleUserJwtKey];
    [defaults synchronize];
}

#pragma mark - Tracking

+ (void)customWithName:(NSString *)name
{
    [Castle customWithName:name properties:@{}];
}

+ (void)customWithName:(NSString *)name properties:(NSDictionary *)properties
{
    if(!name || [name isEqualToString:@""]) {
        CASLog(@"No event name provided. Will cancel track event operation.");
        return;
    }
    
    Castle *castle = [Castle sharedInstance];
    CASCustom *event = [CASCustom eventWithName:name properties: properties];
    [castle.eventQueue queueEvent:event];
}

+ (void)screenWithName:(NSString *)name
{
    if(!name || [name isEqualToString:@""]) {
        CASLog(@"No screen name provided. Will cancel track event operation.");
        return;
    }
    
    Castle *castle = [Castle sharedInstance];
    CASScreen *screen = [CASScreen eventWithName:name];
    [castle.eventQueue queueEvent:screen];
}

+ (void)setUserJwt:(nullable NSString *)userJwt
{
    if(!userJwt || [userJwt isEqualToString:@""]) {
        CASLog(@"No user jwt provided.");
        return;
    }
    
    Castle *castle = [Castle sharedInstance];
    [castle setUserJwt:userJwt];
}

+ (void)flush
{
    [[Castle sharedInstance].eventQueue flush];
}

+ (void)flushIfNeeded:(NSURL *)url
{
    if([self isAllowlistURL:url]) {
        [self flush];
    }
}

+ (void)reset
{
    if (![Castle isConfigured]) { return; }

    [Castle flush];
    [Castle sharedInstance].userJwt = nil;
}

+ (BOOL)isAllowlistURL:(nullable NSURL *)url
{
    if(url == nil) {
        CASLog(@"Provided allowlist URL was nil");
        return NO;
    }
    
    Castle *castle = [Castle sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.host = %@ AND self.scheme = %@", url.host, url.scheme];
    return [castle.configuration.baseURLAllowList filteredArrayUsingPredicate:predicate].count > 0;
}

+ (NSURL *)baseURL
{
    Castle *castle = [Castle sharedInstance];
    return castle.configuration.baseURL;
}

#pragma mark - Private

- (void)trackApplicationUpdated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *installedVersion = [defaults objectForKey:CastleAppVersionKey];
    
    if (installedVersion == nil) {
        // This means that the application was just installed.
        CASLog(@"No app version was stored in settings: the application was just installed.");
        CASLog(@"Application life cycle event detected: Will track install event");
        [Castle customWithName:@"Application installed"];
        
        // Flush the event queue when a application installed event is triggered
        [Castle flush];
    } else if (![installedVersion isEqualToString:currentVersion]) {
        // App version changed since the application was last run: application was updated
        CASLog(@"App version stored in settings is different from current version string: the application was just updated.");
        CASLog(@"Application life cycle event detected: Will track update event");
        [Castle customWithName:@"Application updated"];
        
        // Flush the event queue when a application updated event is triggered
        [Castle flush];
    }
    
    [defaults setObject:currentVersion forKey:CastleAppVersionKey];
    [defaults synchronize];
}

#pragma mark - Application Lifecycle

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (![Castle isConfigured]) {
        return;
    }
    
    if ([Castle isApplicationLifecycleTrackingEnabled]) {
        CASLog(@"Application life cycle event detected: Will track application did become active event");
        [Castle customWithName:@"Application Did Become Active"];
    }
    
    // Flush the event queue when a application did become active event is triggered
    [Castle flush];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (![Castle isConfigured]) {
        return;
    }
    
    if ([Castle isApplicationLifecycleTrackingEnabled]) {
        CASLog(@"Application life cycle event detected: Will track application did enter background event");
        [Castle customWithName:@"Application Did Enter Background"];
    }
    
    // Flush the event queue when a application did enter background event is triggered
    [Castle flush];
}

- (void)applicationWillTerminate:(NSNotificationCenter *)notification
{
    if (![Castle isConfigured]) {
        return;
    }
    
    if ([Castle isApplicationLifecycleTrackingEnabled]) {
        CASLog(@"Application life cycle event detected: Will track application will terminate event");
        [Castle customWithName:@"Application Will Terminate"];
    }
    
    // Flush the event queue when a application will terminate event is triggered
    [Castle flush];
}

#pragma mark - Metadata

+ (NSString *)createRequestToken
{
    return [[Castle sharedInstance].highwind token];
}

+ (NSString *)userJwt
{
    return [Castle sharedInstance].userJwt;
}

+ (nullable Highwind *)highwind
{
    return [Castle sharedInstance].highwind;
}

+ (nullable CastleConfiguration *)configuration
{
    return [Castle sharedInstance].configuration;
}

+ (nullable NSString *)publishableKey
{
    return [Castle sharedInstance].configuration.publishableKey;
}

+ (NSUInteger)queueSize
{
    return [Castle sharedInstance].eventQueue.count;
}

@end

NS_ASSUME_NONNULL_END
