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
#import <Castle/CASBatch.h>
#import <Castle/CASIdentity.h>
#import <Castle/CASRequestInterceptor.h>
#import <Castle/CASAPIClient.h>
#import <Castle/UIViewController+CASScreen.h>

#import "MainViewController.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSArray *baseURLWhiteList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    configuration.baseURLWhiteList = baseURLWhiteList;
    
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
    NSString *pattern = @"[a-zA-Z0-9\\s._-]+/[0-9]+\\.[0-9]+\\.?[0-9]* \\([a-zA-Z0-9-_.]+\\) \\([a-zA-Z0-9\\s]+; iOS [0-9]+\\.?[0-9]+.?[0-9]*; Castle [0-9]+\\.[0-9]+\\.?[0-9]*\\)";
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:userAgent options:0 range:NSMakeRange(0, userAgent.length)];
    XCTAssertNil(error, @"Failed to create regular expression for User Agent format validation");
    XCTAssert(matches == 1);
}

- (void)testConfiguration
{
    NSArray *baseURLWhiteList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    
    // Check that all default values are set correctly
    XCTAssertEqual(configuration.screenTrackingEnabled, YES);
    XCTAssertEqual(configuration.debugLoggingEnabled, NO);
    XCTAssertEqual(configuration.flushLimit, 20);
    XCTAssertEqual(configuration.maxQueueLimit, 1000);
    XCTAssertNil(configuration.baseURLWhiteList);
    
    // Update configuration
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.maxQueueLimit = 20;
    configuration.baseURLWhiteList = baseURLWhiteList;

    // Check that all the configuration parameters where set correctly
    XCTAssertTrue([configuration.publishableKey isEqualToString:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"]);
    XCTAssertEqual(configuration.screenTrackingEnabled, YES);
    XCTAssertEqual(configuration.debugLoggingEnabled, YES);
    XCTAssertEqual(configuration.deviceIDAutoForwardingEnabled, YES);
    XCTAssertEqual(configuration.flushLimit, 10);
    XCTAssertEqual(configuration.maxQueueLimit, 20);
    XCTAssertEqual(configuration.baseURLWhiteList.count, 1);
    XCTAssertTrue([configuration.baseURLWhiteList[0].absoluteString isEqualToString:@"https://google.com/"]);

    [configuration setBaseURLWhiteList:@[ [NSURL URLWithString:@"https://google.com/somethingelse"]]];
    XCTAssertFalse([configuration.baseURLWhiteList[0].absoluteString isEqualToString:@"https://google.com/somethingelse"]);

    // Setup Castle SDK with publishable key
    [Castle configureWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    
    // Configuration reset
    [Castle resetConfiguration];
    XCTAssertFalse([Castle isWhitelistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    
    // Setup Castle SDK with provided configuration
    [Castle configure:configuration];
    
    // Check whitelisting on configured instance
    XCTAssertTrue([Castle isWhitelistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    XCTAssertFalse([Castle isWhitelistURL:nil]);
}

- (void)testDeviceIdentifier
{
    // Check device ID
    XCTAssertNotNil([Castle clientId]);
}

- (void)testUserIdPersistance
{
    // Make sure the user id is persisted correctly after identify
    [Castle identify:@"thisisatestuser"];

    // Check that the stored identity is the same as the identity we tracked
    XCTAssertEqual([Castle userId], @"thisisatestuser");
}

- (void)testSignaturePersistance
{
    // Call secure to save the signature
    [Castle secure:@"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"];
    
    // Check that the stored user signature is the same as the user signature we provided
    XCTAssertEqual([Castle userSignature], @"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52");
}

- (void)testReset
{
    [Castle reset];

    // Check to see if the user id and user signature was cleared on reset
    XCTAssertNil([Castle userId]);
    XCTAssertNil([Castle userSignature]);
}

- (void)testTracking
{
    [Castle reset];
    
    // This should lead to no event being tracked since empty string isn't a valid name
    NSUInteger count = [CASEventStorage storedQueue].count;
    [Castle track:@""];
    NSUInteger newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked since empty string isn't a valid name
    count = [CASEventStorage storedQueue].count;
    [Castle screen:@""];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked since identity can't be an empty string
    count = [CASEventStorage storedQueue].count;
    [Castle identify:@""];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount); // Count should be unchanced
    XCTAssertNil([Castle userId]); // User id should be nil

    // This should lead to no event being tracked properties can't be nil
    count = [CASEventStorage storedQueue].count;
    [Castle identify:@"testuser1" traits:nil];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount); // Count should be unchanced
    XCTAssertNil([Castle userId]); // User id should be nil

    CASScreen *screen = [CASScreen eventWithName:@"Main"];
    XCTAssertNotNil(screen);
    XCTAssertTrue([screen.type isEqualToString:@"screen"]);
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
    CASBatch *batch1 = [CASBatch batchWithEvents:nil];
    XCTAssertNil(batch1);

    CASBatch *batch2 = [CASBatch batchWithEvents:@[]];
    XCTAssertNil(batch2);

    CASEvent *event1 = [CASEvent eventWithName:nil];
    XCTAssertNil(event1);

    CASEvent *event2 = [CASEvent eventWithName:@""];
    XCTAssertNil(event2);

    CASScreen *screen1 = [CASScreen eventWithName:nil];
    XCTAssertNil(screen1);

    CASScreen *screen2 = [CASScreen eventWithName:@""];
    XCTAssertNil(screen2);

    CASIdentity *identity1 = [CASIdentity identityWithUserId:@"" traits:@{}];
    XCTAssertNil(identity1);

    CASIdentity *identity2 = [CASIdentity identityWithUserId:@"testuser" traits:@{}];

    NSData *identity2Data = [NSKeyedArchiver archivedDataWithRootObject:identity2];
    XCTAssertNotNil(identity2Data);

    CASIdentity *identity3 = [NSKeyedUnarchiver unarchiveObjectWithData:identity2Data];
    XCTAssertNotNil(identity3);

    XCTAssertTrue([CASEvent supportsSecureCoding]);
}

- (void)testSecureMode
{
    // Calling secure with a nil user signature should not store or replace any previous signature
    [Castle secure:nil];
    XCTAssertNil([Castle userSignature]);
    
    // User signature should be stored
    [Castle secure:@"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"];
    XCTAssertEqual([Castle userSignature], @"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52");
    
    // Calling secure again should override previously stored signature
    [Castle secure:@"844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"];
    XCTAssertEqual([Castle userSignature], @"844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52");
}

- (void)testObjectSerializationForScreen
{
    [Castle reset];
    [Castle identify:@"thisisatestuser1"];
    
    // Create screen view
    CASEvent *event = [CASScreen eventWithName:@"Main"];
    XCTAssertNotNil(event);
    XCTAssertTrue([event.name isEqualToString:@"Main"]);
    
    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"name"] isEqualToString:@"Main"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"screen"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);
    XCTAssertNil(payload[@"user_signature"]);
    
    // Device name should not be included
    XCTAssertNil(payload[@"device"][@"name"]);
    
    // Payload should not include these parameters
    XCTAssertNil(payload[@"event"]);
    
    // Enable secure mode
    NSString *signature = @"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature];
    
    // The user signature should be included in any new event objects
    CASEvent *event2 =  [CASScreen eventWithName:@"Second"];
    XCTAssertEqualObjects(event2.userId, @"thisisatestuser1");
    XCTAssertEqualObjects(event2.userSignature, signature);
    
    // Archive identity object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    CASEvent *event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event2.userId, event3.userId);
    XCTAssertEqualObjects(event2.userSignature, event3.userSignature);
    
    // Update user identity
    [Castle identify:@"thisisatestuser2"];
    
    // Update user signature
    NSString *signature2 = @"844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature2];
    
    // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
    data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event3.userId, @"thisisatestuser1");
    XCTAssertEqualObjects(event3.userSignature, signature);
    
    // Create a new event that should have the new updated user id and signature
    CASEvent *event4 = [CASScreen eventWithName:@"Third"];
    data = [NSKeyedArchiver archivedDataWithRootObject:event4];
    CASEvent *event5 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event5.userId, @"thisisatestuser2");
    XCTAssertEqualObjects(event5.userSignature, signature2);
}

- (void)testObjectSerializationForIdentify
{
    [Castle reset];
    [Castle identify:@"thisisatestuser1"];
    
    // Create user identity
    NSDictionary *traits = @{ @"trait": @"value" };
    CASIdentity *event = [CASIdentity identityWithUserId:@"123" traits:traits];

    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"user_id"] isEqualToString:@"123"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"identify"]);
    XCTAssertTrue([payload[@"traits"] isEqualToDictionary:traits]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);
    XCTAssertNil(payload[@"user_signature"]);
    
    // Payload should not include these parameters
    XCTAssertNil(payload[@"properties"]);
    XCTAssertNil(payload[@"event"]);
    
    // Enable secure mode
    NSString *signature = @"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature];
    
    // The user signature should be included in any new event objects
    CASEvent *event2 =  [CASIdentity identityWithUserId:@"456" traits:traits];
    XCTAssertEqualObjects(event2.userId, @"456");
    XCTAssertEqualObjects(event2.userSignature, signature);
    
    // Archive identity object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    CASEvent *event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event2.userId, event3.userId);
    XCTAssertEqualObjects(event2.userSignature, event3.userSignature);
    
    // Update user identity
    [Castle identify:@"thisisatestuser2"];
    
    // Update user signature
    NSString *signature2 = @"844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature2];
    
    // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
    data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event3.userId, event2.userId);
    XCTAssertEqualObjects(event3.userSignature, signature);
    
    // Create a new event that should have the new updated user id and signature
    CASEvent *event4 = [CASIdentity identityWithUserId:@"789" traits:traits];
    data = [NSKeyedArchiver archivedDataWithRootObject:event4];
    CASEvent *event5 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event5.userId, @"789");
    XCTAssertEqualObjects(event5.userSignature, signature2);
}

- (void)testObjectSerializationForEvent
{
    [Castle reset];
    [Castle identify:@"thisisatestuser1"];
    
    CASModel *model = [[CASModel alloc] init];
    XCTAssertNil(model.JSONPayload);
    XCTAssertNil(model.JSONData);

    // Create basic event with valid data
    CASEvent *event = [CASEvent eventWithName:@"testevent1" properties:@{ @"param1": @"value1", @"param2": @{ @"param3": @(2) } }];
    XCTAssertNotNil(event);
    XCTAssertTrue([event.name isEqualToString:@"testevent1"]);
    XCTAssertNotNil(event.properties);

    // Validate simple factory method
    CASEvent *event1 = [CASEvent eventWithName:@"testevent2"];
    XCTAssertTrue([event1.name isEqualToString:@"testevent2"]);
    XCTAssertNotNil(event1.properties);

    // Validate payload
    NSDictionary *payload = [event JSONPayload];
    XCTAssertTrue([payload[@"event"] isEqualToString:@"testevent1"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"track"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);
    XCTAssertNil(payload[@"user_signature"]);

    // Validate JSON Serialization success
    XCTAssertNotNil(event.JSONData);

    CASEvent *invalidEvent1 = [CASEvent eventWithName:@"testevent2" properties:@{ @"invalidparam": [[NSObject alloc] init] }];
    XCTAssertNil(invalidEvent1);

    CASEvent *invalidEvent2 = [CASEvent eventWithName:@"testevent2" properties:@{ @"invalidParamContainer": @{ @"invalidParam": [[NSObject alloc] init] } }];
    XCTAssertNil(invalidEvent2);
    
    // Enable secure mode
    NSString *signature = @"944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature];
    
    // The user signature should be included in any new event objects
    CASEvent *event2 =  [CASEvent eventWithName:@"event2"];
    XCTAssertEqualObjects(event2.userId, @"thisisatestuser1");
    XCTAssertEqualObjects(event2.userSignature, signature);
    
    // Archive identity object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    CASEvent *event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event2.userId, event3.userId);
    XCTAssertEqualObjects(event2.userSignature, event3.userSignature);
    
    // Update user identity
    [Castle identify:@"thisisatestuser2"];
    
    // Update user signature
    NSString *signature2 = @"844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52";
    [Castle secure:signature2];
    
    // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
    data = [NSKeyedArchiver archivedDataWithRootObject:event2];
    event3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event3.userId, @"thisisatestuser1");
    XCTAssertEqualObjects(event3.userSignature, signature);
    
    // Create a new event that should have the new updated user id and signature
    CASEvent *event4 = [CASEvent eventWithName:@"event4"];
    data = [NSKeyedArchiver archivedDataWithRootObject:event4];
    CASEvent *event5 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(event5.userId, @"thisisatestuser2");
    XCTAssertEqualObjects(event5.userSignature, signature2);
}

- (void)testPersistance
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/castle/events"];

    // Track a single event to trigger the persistance
    [Castle track:@"example event"];

    XCTAssertTrue([fileManager fileExistsAtPath:path]);

    // Remove event queue data file and verify
    NSError *error = nil;
    [fileManager removeItemAtPath:path error:&error];
    XCTAssertNil(error);
    XCTAssertFalse([fileManager fileExistsAtPath:path]);

    // Track a single event to trigger the persistance
    [Castle track:@"example event"];
    XCTAssertTrue([fileManager fileExistsAtPath:path]);
    
    NSUInteger currentQueueSize = [Castle queueSize];
    
    // Unarchive stored event queue and check that the queue count is the same as the current size of the in memory queue
    NSArray *queue = [CASEventStorage storedQueue];
    XCTAssertEqual(currentQueueSize, queue.count);
    
    // Tracking a new event should increase queue size by one
    [Castle track:@"example event"];
    queue = [CASEventStorage storedQueue];
    XCTAssertTrue(queue.count == currentQueueSize+1);
}

- (void)testDefaultHeaders
{
    XCTAssertNotNil([Castle clientId]);
    XCTAssertTrue([CastleClientIdHeaderName isEqualToString:@"X-Castle-Client-Id"]);
}

- (void)testRequestInterceptor
{
    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    
    NSArray *baseURLWhiteList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    
    // Update configuration
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.baseURLWhiteList = baseURLWhiteList;
    
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
    [request setValue:[Castle clientId] forHTTPHeaderField:CastleClientIdHeaderName];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error, "error should be nil");
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            XCTAssertEqual(httpResponse.statusCode, 200, @"HTTP response status code should be 202");
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
    CASEvent *event = [CASEvent eventWithName:@"Example event"];
    __block CASBatch *batchModel = [CASBatch batchWithEvents:@[event]];
    XCTAssertNotNil(batchModel);

    XCTestExpectation *expectation = [self expectationWithDescription:@"GET /batch"];

    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    CASAPIClient *client = [CASAPIClient clientWithConfiguration:configuration];

    // Perform batch network request
    NSURLSessionTask *task = [client dataTaskWithPath:@"batch" postData:[batchModel JSONData] completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error, "error should be nil");

        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            XCTAssertEqual(httpResponse.statusCode, 202, @"HTTP response status code should be 202");
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
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    
    // Update configuration and set max queue limit to less than the flush limit.
    configuration.debugLoggingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.maxQueueLimit = 8;
    
    [Castle configure:configuration];
    
    // Fill the queue
    for (int i = 0; i < configuration.maxQueueLimit; i++) {
        [Castle track:[NSString stringWithFormat:@"Event %d", i]];
    }
    
    // The queue size should be equal to maxQueueLimit
    XCTAssertTrue(configuration.maxQueueLimit == [Castle queueSize]);
    
    // Track a new event so the maxQueueLimit is reached
    [Castle track:@"New event"];
    
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
    [Castle configureWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    
    // Check to see if the installed version was updated correctly i.e. the SDK detected an app update.
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *installedVersion = [defaults objectForKey:@"CastleAppVersionKey"];
    XCTAssertEqual(currentVersion, installedVersion);
}

@end

