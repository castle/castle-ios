//
//  AutmaticScreenViewEvents.m
//  Castle_UITests
//
//  Copyright (c) 2020 Castle. All rights reserved.
//

@import XCTest;

#import <Castle/Castle.h>

@interface Castle_UITests : XCTestCase

@end

@implementation Castle_UITests

- (void)setUp {
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAutomaticScreenTracking {
    XCUIApplication *app = [[XCUIApplication alloc] init];

    [app.buttons[@"reset"] tap];
    sleep(1);

    // Tap screen track button
    [app.buttons[@"trackScreen"] tap];
    BOOL exists = [app.staticTexts[@"Queue size: 1"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.buttons[@"push"] tap];
    exists = [app.staticTexts[@"Queue size: 2"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.buttons[@"push"] tap];
    exists = [app.staticTexts[@"Queue size: 3"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.buttons[@"push"] tap];
    exists = [app.staticTexts[@"Queue size: 4"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.buttons[@"push"] tap];
    exists = [app.staticTexts[@"Queue size: 5"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.navigationBars[@"View Controller 4"].buttons[@"View Controller 3"] tap];
    exists = [app.staticTexts[@"Queue size: 6"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.navigationBars[@"View Controller 3"].buttons[@"View Controller 2"] tap];
    exists = [app.staticTexts[@"Queue size: 7"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.navigationBars[@"View Controller 2"].buttons[@"View Controller 1"] tap];
    exists = [app.staticTexts[@"Queue size: 8"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app.navigationBars[@"View Controller 1"].buttons[@"Example"] tap];
    exists = [app.staticTexts[@"Queue size: 9"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
    
    [app/*@START_MENU_TOKEN@*/.buttons[@"pushEmbedded"]/*[[".buttons[@\"Push Embedded View Controller\"]",".buttons[@\"pushEmbedded\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];

    [app.tabBars.buttons[@"Item 2"] tap];
    
    [app.navigationBars[@"UITabBar"].buttons[@"Example"] tap];
    exists = [app.staticTexts[@"Queue size: 12"] waitForExistenceWithTimeout:10];
    XCTAssertTrue(exists);
}

@end
