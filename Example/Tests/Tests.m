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
#import <Castle/CASReachability.h>

#include <arpa/inet.h>

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

    // Make sure to reset configuration
    [Castle resetConfiguration];
    
    // Create configuration object
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

- (void)testReachabilityInit
{
    CASReachability *reachability = [CASReachability reachabilityForLocalWiFi];
    XCTAssertNotNil(reachability);
    
    reachability = [CASReachability reachabilityForInternetConnection];
    XCTAssertNotNil(reachability);
    
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(8080);
    address.sin_addr.s_addr = inet_addr("216.58.199.174"); // Google IP
    reachability = [CASReachability reachabilityWithAddress:&address];
    XCTAssertNotNil(reachability);
}

- (void)testReachabilityValidHostname
{
    // Test valid Host name
    CASReachability *reachability = [CASReachability reachabilityWithHostName:@"google.com"];
    XCTAssertNotNil(reachability);
    
    // Test reachable getters
    XCTAssertTrue([reachability reachableOnWWAN]);
    XCTAssertTrue([reachability isReachableViaWiFi]);
    XCTAssertTrue([reachability isReachable]);
    
    XCTAssertFalse([reachability isConnectionRequired]);
    XCTAssertFalse([reachability isConnectionOnDemand]);
    XCTAssertFalse([reachability isInterventionRequired]);
    
    XCTAssertNotNil([reachability currentReachabilityString]);
    XCTAssertNotNil([reachability currentReachabilityFlags]);
    XCTAssertNotNil([reachability description]);
    
    XCTAssertTrue([reachability currentReachabilityStatus] != NotReachable);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Reachable expectation"];
    [reachability setReachableBlock:^(CASReachability *reachability) {
        [expectation fulfill];
    }];
    
    [reachability startNotifier];
   
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    [reachability stopNotifier];
}

- (void)testReachabilityInvalidHostname
{
    // Test invalid Host name
    CASReachability *reachability = [CASReachability reachabilityWithHostName:@"invalidhost"];
    XCTAssertNotNil(reachability);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Unreachable expectation"];
    [reachability setUnreachableBlock:^(CASReachability *reachability) {
        [expectation fulfill];
    }];
    
    [reachability startNotifier];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    [reachability stopNotifier];
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
    XCTAssertNotNil([Castle clientId]);
    XCTAssertTrue([CastleClientIdHeaderName isEqualToString:@"X-Castle-Client-Id"]);
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

