//
//  CastleTests.m
//  CastleTests
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

@import XCTest;
@import Castle;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfiguration
{
    // Create configuration object
    CastleConfiguration *configuration = [CastleConfiguration configurationWithPublishableKey:@"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ"];
    configuration.screenTrackingEnabled = YES;
    configuration.debugLoggingEnabled = YES;
    configuration.deviceIDAutoForwardingEnabled = YES;
    configuration.flushLimit = 10;
    configuration.baseURLWhiteList = @[ [NSURL URLWithString:@"https://google.com/"] ];
    
    // Setup Castle SDK with provided configuration
    [Castle setupWithConfiguration:configuration];
    
    // Check that all the configuration parameters where set correctly
    XCTAssertEqual(configuration.publishableKey, @"pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ");
    XCTAssertEqual(configuration.screenTrackingEnabled, YES);
    XCTAssertEqual(configuration.debugLoggingEnabled, YES);
    XCTAssertEqual(configuration.deviceIDAutoForwardingEnabled, YES);
    XCTAssertEqual(configuration.flushLimit, 10);
    XCTAssertEqual(configuration.baseURLWhiteList.count, 1);
    XCTAssertEqual(configuration.baseURLWhiteList[0].absoluteString, [NSURL URLWithString:@"https://google.com/"].absoluteString);
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

@end

