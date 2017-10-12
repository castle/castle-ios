//
//  CastleTests.m
//  CastleTests
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

    // Clear current app version
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"CastleAppVersionKey"];
    [defaults synchronize];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfiguration
{
    NSArray *baseURLWhiteList = @[ [NSURL URLWithString:@"https://google.com/"] ];

    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.baseURLWhiteList = baseURLWhiteList;

    // Check that all the configuration parameters where set correctly
    XCTAssertTrue([configuration.publishableKey isEqualToString:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"]);
    XCTAssertEqual(configuration.screenTrackingEnabled, YES);
    XCTAssertEqual(configuration.debugLoggingEnabled, YES);
    XCTAssertEqual(configuration.deviceIDAutoForwardingEnabled, YES);
    XCTAssertEqual(configuration.flushLimit, 10);
    XCTAssertEqual(configuration.baseURLWhiteList.count, 1);
    XCTAssertTrue([configuration.baseURLWhiteList[0].absoluteString isEqualToString:@"https://google.com/"]);

    [configuration setBaseURLWhiteList:@[ [NSURL URLWithString:@"https://google.com/somethingelse"]]];
    XCTAssertFalse([configuration.baseURLWhiteList[0].absoluteString isEqualToString:@"https://google.com/somethingelse"]);

    XCTAssertTrue([Castle isWhitelistURL:[NSURL URLWithString:@"https://google.com/somethingelse"]]);
    XCTAssertFalse([Castle isWhitelistURL:nil]);

    // Setup Castle SDK with provided configuration
    [Castle setupWithConfiguration:configuration];

    // Set current app version to semething old
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0.1.1" forKey:@"CastleAppVersionKey"];
    [defaults synchronize];

    // Setup Castle SDK with provided configuration
    [Castle setupWithConfiguration:configuration];
}

- (void)testDeviceIdentifier
{
    // Check device ID
    XCTAssertNotNil([Castle deviceIdentifier]);
}

- (void)testUserIdPersistance
{
    // Make sure the user id is persisted correctly after identify
    [Castle identify:@"thisisatestuser"];

    // Check that the stored identity is the same as the identity we tracked
    XCTAssertEqual([Castle userIdentity], @"thisisatestuser");
}

- (void)testReset
{
    [Castle reset];

    // Check to see if the user identity was cleared on reset
    XCTAssertNil([Castle userIdentity]);
}

- (void)testTracking
{
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

    // This should lead to no event being tracked properties can't be nil
    count = [CASEventStorage storedQueue].count;
    [Castle screen:@"Screen" properties:nil];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked since identity can't be an empty string
    count = [CASEventStorage storedQueue].count;
    [Castle identify:@""];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

    // This should lead to no event being tracked properties can't be nil
    count = [CASEventStorage storedQueue].count;
    [Castle identify:@"testuser1" traits:nil];
    newCount = [CASEventStorage storedQueue].count;
    XCTAssertTrue(count == newCount);

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

- (void)testObjectSerializationForScreen
{
    // create screen view
    CASScreen *screen = [CASScreen eventWithName:@"Main"];
    XCTAssertNotNil(screen);
    XCTAssertTrue([screen.name isEqualToString:@"Main"]);
    
    // Validate payload
    NSDictionary *payload = [screen JSONPayload];
    XCTAssertTrue([payload[@"name"] isEqualToString:@"Main"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"screen"]);
    XCTAssertNotNil(payload[@"properties"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);
}

- (void)testObjectSerializationForIdentify
{
    // create user identity
    NSDictionary *traits = @{ @"trait": @"value" };
    CASIdentity *identity = [CASIdentity identityWithUserId:@"123" traits:traits];

    // Validate payload
    NSDictionary *payload = [identity JSONPayload];
    XCTAssertTrue([payload[@"user_id"] isEqualToString:@"123"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"identify"]);
    XCTAssertTrue([payload[@"traits"] isEqualToDictionary:traits]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);
}

- (void)testObjectSerializationForEvent
{
    CASModel *model = [[CASModel alloc] init];
    XCTAssertNil(model.JSONPayload);
    XCTAssertNil(model.JSONData);

    // Create basic event with valid data
    CASEvent *event1 = [CASEvent eventWithName:@"testevent1" properties:@{ @"param1": @"value1", @"param2": @{ @"param3": @(2) } }];
    XCTAssertNotNil(event1);
    XCTAssertTrue([event1.name isEqualToString:@"testevent1"]);
    XCTAssertNotNil(event1.properties);

    // Validate simple factory method
    CASEvent *event2 = [CASEvent eventWithName:@"testevent2"];
    XCTAssertTrue([event2.name isEqualToString:@"testevent2"]);
    XCTAssertNotNil(event2.properties);

    // Validate payload
    NSDictionary *payload = [event1 JSONPayload];
    XCTAssertTrue([payload[@"event"] isEqualToString:@"testevent1"]);
    XCTAssertTrue([payload[@"type"] isEqualToString:@"track"]);
    XCTAssertNotNil(payload[@"properties"]);
    XCTAssertNotNil(payload[@"timestamp"]);
    XCTAssertNotNil(payload[@"context"]);

    // Validate JSON Serialization success
    XCTAssertNotNil(event1.JSONData);

    CASEvent *invalidEvent1 = [CASEvent eventWithName:@"testevent2" properties:@{ @"invalidparam": [[NSObject alloc] init] }];
    XCTAssertNil(invalidEvent1);

    CASEvent *invalidEvent2 = [CASEvent eventWithName:@"testevent2" properties:@{ @"invalidParamContainer": @{ @"invalidParam": [[NSObject alloc] init] } }];
    XCTAssertNil(invalidEvent2);
}

- (void)testPersistance
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/castle/events.data"];

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
}

- (void)testDefaultHeaders
{
    NSDictionary *headers = [Castle headers];
    XCTAssertNotNil(headers);
    XCTAssertNotNil(headers[@"X-Castle-Client-Id"]);
    XCTAssertTrue([headers[@"X-Castle-Client-Id"] isEqualToString:[Castle deviceIdentifier]]);
}

- (void)testRequestInterceptor
{
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com/"]];
    XCTAssertTrue([CASRequestInterceptor canInitWithRequest:request1]);
    XCTAssertEqual([CASRequestInterceptor canonicalRequestForRequest:request1], request1);

    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com/"]];
    XCTAssertFalse([CASRequestInterceptor canInitWithRequest:request2]);
    XCTAssertEqual([CASRequestInterceptor canonicalRequestForRequest:request2], request2);

    XCTAssertTrue([CASRequestInterceptor requestIsCacheEquivalent:request2 toRequest:request2]);
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

@end

