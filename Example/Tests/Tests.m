//
//  Tests.m
//  Castle_Tests
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

@import XCTest;

#import <Castle/Castle.h>
#import <Castle/CASEventQueue.h>
#import <Castle/CASScreen.h>
#import <Castle/CASMonitor.h>
#import <Castle/CASCustom.h>
#import <Castle/CASRequestInterceptor.h>
#import <Castle/CASAPIClient.h>
#import <Castle/UIViewController+CASScreen.h>
#import <Castle/Castle+Util.h>
#import <Castle/CASUserJwt.h>

#import "MainViewController.h"
#import "Castle+InvalidUUID.h"
#import "Castle+Test.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSArray *baseURLAllowList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    configuration.baseURLAllowList = baseURLAllowList;
    
    [Castle configure:configuration];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/castle/events"];
    
    // Remove event queue data file
    NSError *error = nil;
    if([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:&error];
        XCTAssertNil(error);
    }
}

- (void)testDateFormatter
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    NSString *formattedDateString = [[CASModel timestampDateFormatter] stringFromDate:date];
    XCTAssertEqualObjects(formattedDateString, @"1970-01-01T00:00:00.000Z");
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 1984;
    components.month = 5;
    components.day = 27;
    components.hour = 12;
    components.minute = 45;
    components.second = 45;
    components.nanosecond = 455000000;
    calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:1*60*60];
    date = [calendar dateFromComponents:components];
    
    formattedDateString = [[CASModel timestampDateFormatter] stringFromDate:date];
    XCTAssertEqualObjects(formattedDateString, @"1984-05-27T11:45:45.455Z");
}

- (void)testUserAgent
{
    NSString *userAgent = [Castle userAgent];
    NSString *pattern = @"[a-zA-Z0-9\\s._-]+/[0-9]+\\.[0-9]+\\.?[0-9]* \\([a-zA-Z0-9-_.]+\\) \\([a-zA-Z0-9\\s,]+; iOS [0-9]+\\.?[0-9]+.?[0-9]*; Castle [0-9]+\\.[0-9]+\\.?[0-9]*\\)";
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:userAgent options:0 range:NSMakeRange(0, userAgent.length)];
    XCTAssertNil(error, @"Failed to create regular expression for User Agent format validation");
    XCTAssert(matches == 1);
}

- (void)testConfiguration
{
    NSString *publishableKey = @"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA";
    NSArray *baseURLAllowList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:publishableKey];
    
    // Check that all default values are set correctly
    XCTAssertEqual(configuration.screenTrackingEnabled, NO);
    XCTAssertEqual(configuration.debugLoggingEnabled, NO);
    XCTAssertEqual(configuration.flushLimit, 20);
    XCTAssertEqual(configuration.maxQueueLimit, 1000);
    XCTAssertNil(configuration.baseURLAllowList);
    XCTAssertEqual(configuration.enableAdvertisingTracking, YES);
    XCTAssertEqual(configuration.enableApplicationLifecycleTracking, YES);
    
    // Check ad tracking state, set ad support block with mock IDFA
    XCTAssertEqual([Castle isAdTrackingEnabled], NO);
    [configuration setAdSupportBlock:^NSString* {
        return @"00000000-0000-0000-0000-000000000000";
    }];
    
    // Update configuration and check ad tracking enabled
    [Castle configure:configuration];
    XCTAssertEqual([Castle isAdTrackingEnabled], YES);
    
    // Update configuration
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.maxQueueLimit = 20;
    configuration.baseURLAllowList = baseURLAllowList;
    configuration.enableAdvertisingTracking = NO;
    configuration.enableApplicationLifecycleTracking = NO;
    
    // Check that all the configuration parameters where set correctly
    XCTAssertTrue([configuration.publishableKey isEqualToString:publishableKey]);
    XCTAssertEqual(configuration.screenTrackingEnabled, YES);
    XCTAssertEqual(configuration.debugLoggingEnabled, YES);
    XCTAssertEqual(configuration.deviceIDAutoForwardingEnabled, YES);
    XCTAssertEqual(configuration.flushLimit, 10);
    XCTAssertEqual(configuration.maxQueueLimit, 20);
    XCTAssertEqual(configuration.baseURLAllowList.count, 1);
    XCTAssertTrue([configuration.baseURLAllowList[0].absoluteString isEqualToString:@"https://google.com/"]);
    XCTAssertTrue([configuration.baseURL.absoluteString isEqualToString:@"https://m.castle.io/v1/"]);

    [configuration setBaseURLAllowList:@[ [NSURL URLWithString:@"https://google.com/somethingelse"]]];
    XCTAssertFalse([configuration.baseURLAllowList[0].absoluteString isEqualToString:@"https://google.com/somethingelse"]);

    XCTAssertEqual(configuration.enableAdvertisingTracking, NO);
    XCTAssertEqual(configuration.enableApplicationLifecycleTracking, NO);
    
    // Setup Castle SDK with publishable key
    [Castle configureWithPublishableKey:publishableKey];
    
    // Ad tracking enabled should now be false, since we reconfigured with the default configuration
    XCTAssertEqual([Castle isAdTrackingEnabled], NO);
    
    XCTAssertFalse([Castle isAllowlistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    // Check allowlisting on configured instance
    XCTAssertTrue([Castle isAllowlistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    XCTAssertFalse([Castle isAllowlistURL:nil]);
    
    [Castle resetConfiguration];
    
    // Test invalid publishable key validation error
    XCTAssertThrows([Castle configureWithPublishableKey:@""]);
    XCTAssertThrows([Castle configureWithPublishableKey:@"ab_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"]);
}

- (void)testHighwindInvalidUUID
{
    [Castle reset];
    
    // Swizzle device identifier to return an invalid UUID string
    [Castle enableSwizzle:true];
    
    NSString *publishableKey = @"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA";
    NSString *jwt = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0";
    [Castle configureWithPublishableKey:publishableKey];
    [Castle setUserJwt:jwt];
    
    // Clear cached deviceUUID to force re-fetching via swizzled method
    [Castle clearDeviceUUID];
    
    // createRequestToken should return empty string when deviceIdentifier returns an invalid UUID
    NSString *token = [Castle createRequestToken];
    XCTAssertEqualObjects(token, @"");
    
    // Disable swizzle, deviceIdentifier should now return a valid UUID
    [Castle enableSwizzle:false];
    
    // Clear cached deviceUUID again to get valid UUID
    [Castle clearDeviceUUID];
    
    // Token should now be valid (non-empty)
    NSString *validToken = [Castle createRequestToken];
    XCTAssertGreaterThan(validToken.length, 0);
}

- (void)testDeviceIdentifier
{
    // Check device ID
    XCTAssertNotNil([Castle createRequestToken]);
}

- (void)testUserIdPersistance
{
    // Make sure the user id is persisted correctly after identify
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];

    // Check that the stored identity is the same as the identity we tracked
    NSString *userJwt = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0";
    XCTAssertEqual([Castle userJwt], userJwt);
}

- (void)testReset
{
    [Castle reset];

    // Check to see if the user id and user signature was cleared on reset
    XCTAssertNil([Castle userJwt]);
}

- (void)testTracking
{
    [Castle reset];
    
    CASEventQueue *eventQueue = [[CASEventQueue alloc] init];

    // This should lead to no event being tracked since empty string isn't a valid name
    NSUInteger count = [eventQueue storedQueueSync].count;
    [Castle screenWithName:@""];
    NSUInteger newCount = [eventQueue storedQueueSync].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked since identity can't be an empty string
    count = [eventQueue storedQueueSync].count;
    [Castle setUserJwt:@""];
    newCount = [eventQueue storedQueueSync].count;
    XCTAssertTrue(count == newCount); // Count should be unchanged
    XCTAssertNil([Castle userJwt]); // User jwt should be nil

    // This should lead to no event being tracked properties can't be nil
    count = [eventQueue storedQueueSync].count;
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];
    newCount = [eventQueue storedQueueSync].count;
    XCTAssertTrue(count == newCount); // Count should be unchanged
    XCTAssertNotNil([Castle userJwt]); // User jwt should not be nil

    CASScreen *screen = [CASScreen eventWithName:@"Main"];
    XCTAssertNotNil(screen);
    XCTAssertTrue([screen.type isEqualToString:@"$screen"]);
    
    NSDictionary *properties = @{ @"key": @"value" };
    CASCustom *custom = [CASCustom eventWithName: @"Custom" properties: properties];
    XCTAssertNotNil(custom);
    XCTAssertTrue([custom.type isEqualToString:@"$custom"]);
    XCTAssertEqual(custom.properties, properties);
}

- (void)testViewControllerSwizzle
{
    // Check to see if UIViewController responds to ca_viewDidAppear
    UIViewController *viewController = [[UIViewController alloc] init];
    XCTAssertTrue([viewController respondsToSelector:NSSelectorFromString(@"ca_viewDidAppear:")]);

    // Check if view identifier is working correctly
    XCTAssertTrue([[viewController ca_viewIdentifier] isEqualToString:@"Unknown"]);

    viewController.title = @"Test View Controller";
    XCTAssertTrue([viewController.title isEqualToString:[viewController ca_viewIdentifier]]);

    viewController = [[MainViewController alloc] init];
    XCTAssertTrue([[viewController ca_viewIdentifier] isEqualToString:@"Main"]);
}

- (void)testModels
{
    CASMonitor *monitor1 = [CASMonitor monitorWithEvents:nil];
    XCTAssertNil(monitor1);

    CASMonitor *monitor2 = [CASMonitor monitorWithEvents:@[]];
    XCTAssertNil(monitor2);

    CASCustom *event1 = [CASCustom eventWithName:nil];
    XCTAssertNil(event1);

    CASCustom *event2 = [CASCustom eventWithName:@""];
    XCTAssertNil(event2);

    CASScreen *screen1 = [CASScreen eventWithName:nil];
    XCTAssertNil(screen1);

    CASScreen *screen2 = [CASScreen eventWithName:@""];
    XCTAssertNil(screen2);

    CASUserJwt *user1 = [CASUserJwt userWithJwt:@""];
    XCTAssertNil(user1);
    
    XCTAssertTrue([CASEvent supportsSecureCoding]);
    XCTAssertTrue([CASMonitor supportsSecureCoding]);
    XCTAssertTrue([CASModel supportsSecureCoding]);
}

- (void)testModelInvalidData
{
    NSData *data = [[NSData alloc] init];
    NSDictionary *properties = @{ @"key": data };
    CASEvent *event = [CASCustom eventWithName:@"event" properties: properties];
    XCTAssertNil(event);
    
    event = [CASScreen eventWithName:@""];
    XCTAssertNil(event);
    
    CASUserJwt *user = [CASUserJwt userWithJwt:@""];
    XCTAssertNil(user);
    
    user = [CASUserJwt userWithJwt:nil];
    XCTAssertNil(user);
}

- (void)testObjectSerializationForScreen
{
    [Castle reset];
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];
    
    // Create screen view
    CASEvent *event = [CASScreen eventWithName:@"Main"];
    XCTAssertNotNil(event);
    XCTAssertTrue([event.name isEqualToString:@"Main"]);
    
    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"name"] isEqualToString:@"Main"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"$screen"]);
    XCTAssertNil(payload[@"properties"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    
    // Request token should be set
    XCTAssertNotNil(payload[@"request_token"]);
    
    // Payload should not include these parameters
    XCTAssertNil(payload[@"event"]);
    
    // The user signature should be included in any new event objects
    CASEvent *event2 =  [CASScreen eventWithName:@"Second"];
    XCTAssertEqualObjects(event2.name, @"Second");
    XCTAssertEqualObjects(event2.type, @"$screen");
    
    // Archive screen object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event2 requiringSecureCoding:true error:nil];
    
    // Unarchived data should match model before archive
    CASEvent *event3 = [NSKeyedUnarchiver unarchivedObjectOfClass:CASScreen.class fromData:data error:nil];
    XCTAssertEqualObjects(event3.name, event2.name);
    XCTAssertEqualObjects(event3.type, event2.type);
}

- (void)testObjectSerializationForIdentify
{
    NSString *userJwt = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0";
    [Castle reset];
    [Castle setUserJwt:userJwt];

    // Create user identity
    CASUserJwt *event = [CASUserJwt userWithJwt:userJwt];

    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"jwt"] isEqualToString:userJwt]);

    // Validate jwt payload
    CASUserJwt *event2 = [CASUserJwt userWithJwt:userJwt];
    XCTAssertEqualObjects(event2.jwt, userJwt);
}

- (void)testObjectSerializationForEvent
{
    NSString *userJwt = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0";
    [Castle reset];
    [Castle setUserJwt:userJwt];
    
    CASModel *model = [[CASModel alloc] init];
    XCTAssertNil(model.JSONPayload);
    XCTAssertNil(model.JSONData);

    // Create basic event with valid data
    CASCustom *event = [CASCustom eventWithName:@"testevent1"];
    XCTAssertNotNil(event);
    XCTAssertTrue([event.name isEqualToString:@"testevent1"]);

    // Validate simple factory method
    CASCustom *event1 = [CASCustom eventWithName:@"testevent2"];
    XCTAssertTrue([event1.name isEqualToString:@"testevent2"]);

    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"name"] isEqualToString:@"testevent1"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"$custom"]);
    XCTAssertNil(payload[@"properties"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"request_token"]);
    
    // Validate JSON Serialization success
    XCTAssertNotNil(event.JSONData);

    CASCustom *invalidEvent1 = [CASCustom eventWithName:@"testevent2" properties:@{ @"invalidparam": [[NSObject alloc] init] }];
    XCTAssertNil(invalidEvent1);

    // Event will skip any nested dictionaries
    CASCustom *validEventSkipNested = [CASCustom eventWithName:@"testevent2" properties:@{ @"invalidParamContainer": @{ @"invalidParam": [[NSObject alloc] init] } }];
    XCTAssertNotNil(validEventSkipNested);
    
    // Check parameters of custom model
    CASCustom *event2 =  [CASCustom eventWithName:@"event2"];
    XCTAssertEqualObjects(event2.name, @"event2");
    XCTAssertEqualObjects(event2.type, @"$custom");
    
    // Archive custom object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event2 requiringSecureCoding:true error:nil];
    
    // Unarchived data should match model before archive
    CASEvent *event3 = [NSKeyedUnarchiver unarchivedObjectOfClass:CASEvent.class fromData:data error:nil];
    XCTAssertEqualObjects(event2.name, event3.name);
    XCTAssertEqualObjects(event2.type, event3.type);
}

- (void)testPersistance
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/castle/events"];

    CASEventQueue *eventQueue = [[CASEventQueue alloc] init];
    
    // Track a single event to trigger the persistance
    [Castle screenWithName:@"example screen"];
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue([fileManager fileExistsAtPath:path]);
    });

    // Remove event queue data file and verify
    NSError *error = nil;
    [fileManager removeItemAtPath:path error:&error];
    XCTAssertNil(error);
    XCTAssertFalse([fileManager fileExistsAtPath:path]);

    // Track a single event to trigger the persistance
    [Castle screenWithName:@"example screen"];
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue([fileManager fileExistsAtPath:path]);
    });
    
    NSUInteger currentQueueSize = [Castle queueSize];
    
    // Unarchive stored event queue and check that the queue count is the same as the current size of the in memory queue
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertEqual(currentQueueSize, queue.count);
    });
    
    // Tracking a new event should increase queue size by one
    [Castle screenWithName:@"example screen"];
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue(queue.count == currentQueueSize + 1);
    });
    
    // Tracking a new event should increase queue size by one
    [Castle customWithName:@"custom event"];
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue(queue.count == currentQueueSize + 2);
    });
    
    // Tracking a new event should increase queue size by one
    [Castle customWithName:@"custom event" properties:@{ @"key": @"value" }];
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue(queue.count == currentQueueSize + 3);
    });
}

- (void)verifyStorageWithOldStorageDir:(NSString *)oldStorageDir
                         oldStoragePath:(NSString *)oldStoragePath
                         newStorageDir:(NSString *)newStorageDir
                         newStoragePath:(NSString *)newStoragePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CASEventQueue *eventQueue = [[CASEventQueue alloc] init];
    
    // Check that old storage directory doesn't exist
    BOOL isOldStorageDir = NO;
    XCTAssertTrue(![fileManager fileExistsAtPath:oldStorageDir isDirectory:&isOldStorageDir] && !isOldStorageDir);
    
    // Check that old storage file doesn't exist
    XCTAssertTrue(![fileManager fileExistsAtPath:oldStoragePath]);
    
    // Check that new storage directory exists
    BOOL isNewStorageDir = NO;
    XCTAssertTrue([fileManager fileExistsAtPath:newStorageDir isDirectory:&isNewStorageDir] && isNewStorageDir);
    
    // Check that new storage file exists
    waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self, ^(NSArray<CASEvent *> * _Nonnull queue) {
        XCTAssertTrue([fileManager fileExistsAtPath:newStoragePath]);
    });
}

- (void)testStorageMigration {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    CASEventQueue *eventQueue = [[CASEventQueue alloc] init];
    NSArray *queue = eventQueue.storedQueueSync;
    
    // Fetch and persist the queue to make sure that the storage structure is correct according to new storage structure
    [eventQueue persistQueue:[eventQueue storedQueueSync]];
    
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *oldStorageDir = [documentsPaths[0] stringByAppendingPathComponent:@"castle"];
    NSString *oldStoragePath = [oldStorageDir stringByAppendingPathComponent:@"events"];
    
    NSArray *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *newStorageDir = [applicationSupportPaths[0] stringByAppendingPathComponent:@"castle"];
    NSString *newStoragePath = [newStorageDir stringByAppendingPathComponent:@"events"];
    
    // Verify storage structure, migration should already have happened in earlier tests
    [self verifyStorageWithOldStorageDir:oldStorageDir
                           oldStoragePath:oldStoragePath
                           newStorageDir:newStorageDir
                           newStoragePath:newStoragePath];
    
    // Remove new event storage file and verify deletion
    NSError *error;
    [fileManager removeItemAtPath:newStoragePath error:&error];
    XCTAssertTrue(![fileManager fileExistsAtPath:newStoragePath]);
    
    // Copy migration file from bundle to old storage path
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"events_migration_file" ofType:nil];
    [fileManager createDirectoryAtPath:oldStorageDir withIntermediateDirectories:NO attributes:nil error:nil];
    [fileManager copyItemAtPath:bundlePath toPath:oldStoragePath error:nil];
    
    // Calling storedQueue will trigger the migration, check event count to see that the migration was successful
    queue = [eventQueue storedQueueSync];
    XCTAssertTrue([[eventQueue storedQueueSync] count] == 1);
    
    // Persist queue
    [eventQueue persistQueue:queue];
    
    // Verify storage structure again to determine that the migration was successful
    [self verifyStorageWithOldStorageDir:oldStorageDir
                           oldStoragePath:oldStoragePath
                           newStorageDir:newStorageDir
                           newStoragePath:newStoragePath];
    
    // Check event count, should be the same after persisting the queue
    XCTAssertTrue([eventQueue storedQueueSync].count == 1);
}

- (void)testRequestTokenUninitialized
{
    XCTAssertNotNil([Castle createRequestToken]);
    [Castle resetConfiguration];
    XCTAssertThrows([Castle createRequestToken]);
}

- (void)testNonConfiguredInstance
{
    [Castle resetConfiguration];
    
    XCTAssertThrows([Castle screenWithName: @"Screen name"]);
    XCTAssertThrows([Castle customWithName: @"Custom event"]);
    XCTAssertThrows([Castle userJwt]);
    XCTAssertThrows([Castle setUserJwt: @"invalid_jwt_token_string"]);
    //XCTAssertThrows([Castle queueSize]);
    //XCTAssertThrows([Castle flush]);
    XCTAssertThrows([Castle flushIfNeeded:[NSURL URLWithString: @"https://google.com/"]]);
    XCTAssertThrows([Castle isAllowlistURL:[NSURL URLWithString: @"https://google.com/"]]);
    XCTAssertThrows([Castle baseURL]);
    XCTAssertThrows([Castle createRequestToken]);
}

- (void)testDefaultHeaders
{
    XCTAssertNotNil([Castle createRequestToken]);
    XCTAssertTrue([CastleRequestTokenHeaderName isEqualToString:@"X-Castle-Request-Token"]);
}

- (void)testRequestInterceptor
{
    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    
    NSArray *baseURLAllowList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    
    // Update configuration
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.baseURLAllowList = baseURLAllowList;
    
    [Castle configure:configuration];
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com/"]];
    XCTAssertTrue([CASRequestInterceptor canInitWithRequest:request1]);
    XCTAssertEqual([CASRequestInterceptor canonicalRequestForRequest:request1], request1);

    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com/"]];
    XCTAssertFalse([CASRequestInterceptor canInitWithRequest:request2]);
    XCTAssertEqual([CASRequestInterceptor canonicalRequestForRequest:request2], request2);

    XCTAssertTrue([CASRequestInterceptor requestIsCacheEquivalent:request2 toRequest:request2]);
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[Castle urlSessionInterceptConfiguration]];
    XCTAssertNotNil(urlSession);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test interceptor: google.com"];
    
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // Get required header from the Castle SDK if you don't want to use the request interceptor
    [request setValue:[Castle createRequestToken] forHTTPHeaderField:CastleRequestTokenHeaderName];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error, "error should be nil");
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            XCTAssertEqual(httpResponse.statusCode, 200, @"HTTP response status code should be 200");
        } else {
            XCTFail(@"Response was not NSHTTPURLResponse");
        }

        [expectation fulfill];
    }];
    [task resume];
    
    [Castle flushIfNeeded:url];
    
    [self waitForExpectationsWithTimeout:task.originalRequest.timeoutInterval handler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        [task cancel];
    }];
}

- (void)testNetworking
{
    CASCustom *event = [CASCustom eventWithName:@"Example event"];
    __block CASMonitor *monitorModel = [CASMonitor monitorWithEvents:@[event]];
    XCTAssertNotNil(monitorModel);

    XCTestExpectation *expectation = [self expectationWithDescription:@"POST /monitor"];

    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    CASAPIClient *client = [CASAPIClient clientWithConfiguration:configuration];

    // Perform monitor network request
    NSURLSessionTask *task = [client dataTaskWithPath:@"monitor" postData:[monitorModel JSONData] completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error, "error should be nil");

        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            XCTAssertEqual(httpResponse.statusCode, 204, @"HTTP response status code should be 204 (no response body)");
        } else {
            XCTFail(@"Response was not NSHTTPURLResponse");
        }

        [expectation fulfill];
    }];
    [task resume];

    [self waitForExpectationsWithTimeout:task.originalRequest.timeoutInterval handler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        [task cancel];
    }];
}

- (void)testMaxQueueLength
{
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    
    // Update configuration and set max queue limit to less than the flush limit.
    configuration.debugLoggingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.maxQueueLimit = 8;
    
    [Castle configure:configuration];
    
    // Fill the queue
    for (int i = 0; i < configuration.maxQueueLimit; i++) {
        [Castle screenWithName:[NSString stringWithFormat:@"Screen %d", i]];
    }
    
    // The queue size should be equal to maxQueueLimit
    XCTAssertTrue(configuration.maxQueueLimit == [Castle queueSize]);
    
    // Track a new event so the maxQueueLimit is reached
    [Castle screenWithName:@"Screen"];
    
    // Add one more event so the oldest event in the queue is evicted
    // The queue size should still be equal to maxQueueLimit
    XCTAssertTrue(configuration.maxQueueLimit == [Castle queueSize]);
}

- (void)testAppUpdateDetection
{
    // Set current app version to something old
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0.1.1" forKey:@"CastleAppVersionKey"];
    
    [Castle resetConfiguration];
    [Castle configureWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    
    // Check to see if the installed version was updated correctly i.e. the SDK detected an app update.
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for app version update"];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        for (int i = 0; i < 20; i++) { // Wait up to 2 seconds
            NSString *installedVersion = [defaults objectForKey:@"CastleAppVersionKey"];
            if ([installedVersion isEqualToString:currentVersion]) {
                [expectation fulfill];
                break;
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    });
    
    [self waitForExpectationsWithTimeout:2.5 handler:nil];
    
    NSString *installedVersion = [defaults objectForKey:@"CastleAppVersionKey"];
    XCTAssertEqualObjects(currentVersion, installedVersion);
}

- (void)testMainThreadBlockingOnApplicationDidBecomeActive
{
    [Castle resetConfiguration];

    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    configuration.flushLimit = 1000;
    configuration.maxQueueLimit = 1000;
    configuration.debugLoggingEnabled = YES;
    [Castle configure:configuration];
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];

    for (NSUInteger i = 0; i < 900; i++) {
        [Castle customWithName:@"test event" properties:@{@"data": [@"" stringByPaddingToLength:200 withString:@"x" startingAtIndex:0]}];
    }

    NSUInteger queueSizeBeforeFlush = Castle.queueSize;

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    NSTimeInterval blockingTimeMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000;

    CFAbsoluteTime flushStartTime = CFAbsoluteTimeGetCurrent();
    XCTAssertLessThan(blockingTimeMs, 100.0, @"applicationDidBecomeActive blocked for %.2f ms", blockingTimeMs);
    NSLog(@"applicationDidBecomeActive blocked for %.2f ms", blockingTimeMs);

    XCTestExpectation *flushExpectation = [self expectationWithDescription:@"Flush complete"];
    dispatch_queue_t storageQueue = dispatch_queue_create("com.castle.test.flush.monitor", DISPATCH_QUEUE_SERIAL);
    dispatch_async(storageQueue, ^{
        while (Castle.queueSize > 890) {
            [NSThread sleepForTimeInterval:0.01];
        }
        [flushExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30.0 handler:nil];

    NSTimeInterval flushTimeMs = (CFAbsoluteTimeGetCurrent() - flushStartTime) * 1000;
    NSLog(@"Flush completed: %.2f ms for %lu events", flushTimeMs, (unsigned long)queueSizeBeforeFlush);
    NSLog(@"Remaining Queue Size: %lu", Castle.queueSize);
}

@end
