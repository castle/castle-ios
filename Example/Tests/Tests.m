//
//  Tests.m
//  Castle_Tests
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

@import XCTest;

#import <Castle/Castle.h>
#import <Castle/CASEventStorage.h>
#import <Castle/CASScreen.h>
#import <Castle/CASMonitor.h>
#import <Castle/CASCustom.h>
#import <Castle/CASRequestInterceptor.h>
#import <Castle/CASAPIClient.h>
#import <Castle/UIViewController+CASScreen.h>
#import <Castle/CASReachability.h>
#import <Castle/Castle+Util.h>
#import <Castle/CASUserJwt.h>

#import "MainViewController.h"

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
    
    // Update configuration
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.maxQueueLimit = 20;
    configuration.baseURLAllowList = baseURLAllowList;

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

    // Setup Castle SDK with publishable key
    [Castle configureWithPublishableKey:publishableKey];
    
    // Configuration reset
    [Castle resetConfiguration];
    XCTAssertFalse([Castle isAllowlistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    // Check allowlisting on configured instance
    XCTAssertTrue([Castle isAllowlistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    XCTAssertFalse([Castle isAllowlistURL:nil]);
    
    [Castle resetConfiguration];
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

    // This should lead to no event being tracked since empty string isn't a valid name
    NSUInteger count = [CASEventStorage storedQueue].count;
    [Castle screenWithName:@""];
    NSUInteger newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked since identity can't be an empty string
    count = [CASEventStorage storedQueue].count;
    [Castle setUserJwt:@""];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount); // Count should be unchanced
    XCTAssertNil([Castle userJwt]); // User jwt should be nil

    // This should lead to no event being tracked properties can't be nil
    count = [CASEventStorage storedQueue].count;
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount); // Count should be unchanced
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
    CASMonitor *batch1 = [CASMonitor monitorWithEvents:nil];
    XCTAssertNil(batch1);

    CASMonitor *batch2 = [CASMonitor monitorWithEvents:@[]];
    XCTAssertNil(batch2);

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

    CASCustom *invalidEvent2 = [CASCustom eventWithName:@"testevent2" properties:@{ @"invalidParamContainer": @{ @"invalidParam": [[NSObject alloc] init] } }];
    XCTAssertNil(invalidEvent2);
    
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/castle/events"];

    // Track a single event to trigger the persistance
    [Castle screenWithName:@"example screen"];
    XCTAssertTrue([fileManager fileExistsAtPath:path]);

    // Remove event queue data file and verify
    NSError *error = nil;
    [fileManager removeItemAtPath:path error:&error];
    XCTAssertNil(error);
    XCTAssertFalse([fileManager fileExistsAtPath:path]);

    // Track a single event to trigger the persistance
    [Castle screenWithName:@"example screen"];
    XCTAssertTrue([fileManager fileExistsAtPath:path]);
    
    NSUInteger currentQueueSize = [Castle queueSize];
    
    // Unarchive stored event queue and check that the queue count is the same as the current size of the in memory queue
    NSArray *queue = [CASEventStorage storedQueue];
    XCTAssertEqual(currentQueueSize, queue.count);
    
    // Tracking a new event should increase queue size by one
    [Castle screenWithName:@"example screen"];
    queue = [CASEventStorage storedQueue];
    XCTAssertTrue(queue.count == currentQueueSize+1);
    
    // Tracking a new event should increase queue size by one
    [Castle customWithName:@"custom event"];
    queue = [CASEventStorage storedQueue];
    XCTAssertTrue(queue.count == currentQueueSize+2);
    
    // Tracking a new event should increase queue size by one
    [Castle customWithName:@"custom event" properties:@{ @"key": @"value" }];
    queue = [CASEventStorage storedQueue];
    XCTAssertTrue(queue.count == currentQueueSize+3);
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
    __block CASMonitor *batchModel = [CASMonitor monitorWithEvents:@[event]];
    XCTAssertNotNil(batchModel);

    XCTestExpectation *expectation = [self expectationWithDescription:@"POST /monitor"];

    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    CASAPIClient *client = [CASAPIClient clientWithConfiguration:configuration];

    // Perform batch network request
    NSURLSessionTask *task = [client dataTaskWithPath:@"monitor" postData:[batchModel JSONData] completion:^(id responseObject, NSURLResponse *response, NSError *error) {
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
    // Set current app version to semething old
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0.1.1" forKey:@"CastleAppVersionKey"];
    [defaults synchronize];
    
    [Castle resetConfiguration];
    [Castle configureWithPublishableKey:@"pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"];
    
    // Check to see if the installed version was updated correctly i.e. the SDK detected an app update.
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *installedVersion = [defaults objectForKey:@"CastleAppVersionKey"];
    XCTAssertEqual(currentVersion, installedVersion);
}

- (void)testReachabilityValidHost
{
    NSString *validHostName = @"google.com";
    
    CASReachability *reachability = [CASReachability reachabilityWithHostname:validHostName];
    
    if (reachability == nil) {
        XCTFail(@"Unable to create reachability");
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check valid host"];
    [reachability setReachableBlock:^(CASReachability *reachability) {
        NSLog(@"Pass: %@ is reachable - %@", validHostName, reachability);
        [expectation fulfill];
    }];
    
    [reachability setUnreachableBlock:^(CASReachability *reachability) {
        NSLog(@"%@ is initially unreachable - %@", validHostName, reachability);
    }];
    
    @try {
        [reachability startNotifier];
    } @catch (NSException *exception) {
        return XCTFail(@"Unable to start notifier");
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    [reachability stopNotifier];
}

- (void)testReachabilityInvalidHost
{
    NSString *validHostName = @"invalidhost";
    
    CASReachability *reachability = [CASReachability reachabilityWithHostname:validHostName];
    
    if (reachability == nil) {
        XCTFail(@"Unable to create reachability");
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check invalid host"];
    [reachability setReachableBlock:^(CASReachability *reachability) {
        NSLog(@"Pass: %@ is reachable - %@", validHostName, reachability);
    }];
    
    [reachability setUnreachableBlock:^(CASReachability *reachability) {
        NSLog(@"%@ is initially unreachable - %@", validHostName, reachability);
        [expectation fulfill];
    }];
    
    @try {
        [reachability startNotifier];
    } @catch (NSException *exception) {
        return XCTFail(@"Unable to start notifier");
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    [reachability stopNotifier];
}

@end

