//
//  SwiftTests.swift
//  Castle_Tests
//
//  Created by Alexander Simson on 2021-01-13.
//  Copyright © 2021 Alexander Simson. All rights reserved.
//

import XCTest

@testable import Castle

class MainViewController: UIViewController { }

class SwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let baseURLAllowList = [URL(string: "https://google.com/")!]
        let configuration = CastleConfiguration(publishableKey: "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA")
        configuration.baseURLAllowList = baseURLAllowList
        
        Castle.configure(configuration)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let path = paths[0].appending("/castle/events")
        
        if fileManager.fileExists(atPath: path) {
            XCTAssertNoThrow(try fileManager.removeItem(atPath: path))
        }
    }

    func testDateFormatter() throws {
        var date = Date(timeIntervalSince1970: 0)
        var formattedDateString = CASModel.timestampDateFormatter().string(from: date)
        XCTAssertEqual(formattedDateString, "1970-01-01T00:00:00.000Z")

        var calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = 1984;
        components.month = 5;
        components.day = 27;
        components.hour = 12;
        components.minute = 45;
        components.second = 45;
        components.nanosecond = 455000000;
        calendar.timeZone = TimeZone(secondsFromGMT: 1*60*60)!
        date = calendar.date(from: components)!

        formattedDateString = CASModel.timestampDateFormatter().string(from: date)
        XCTAssertEqual(formattedDateString, "1984-05-27T11:45:45.455Z");
    }

    func testUserAgent() throws {
        let userAgent = Castle.userAgent()
        let pattern = "[a-zA-Z0-9\\s._-]+/[0-9]+\\.[0-9]+\\.?[0-9]* \\([a-zA-Z0-9-_.]+\\) \\([a-zA-Z0-9\\s,]+; iOS [0-9]+\\.?[0-9]+.?[0-9]*; Castle [0-9]+\\.[0-9]+\\.?[0-9]*\\)"

        let regex = try NSRegularExpression(pattern: pattern, options: .init())
        let matches = regex.numberOfMatches(in: userAgent, options: .init(), range: NSMakeRange(0, userAgent.count))
        XCTAssert(matches == 1);
    }

    func testConfiguration() throws {
        let publishableKey = "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"
        let baseURLAllowList = [URL(string:"https://google.com/")!];
        let configuration = CastleConfiguration(publishableKey: publishableKey)

        // Check that all default values are set correctly
        XCTAssertEqual(configuration.isScreenTrackingEnabled, false);
        XCTAssertEqual(configuration.isDebugLoggingEnabled, false);
        XCTAssertEqual(configuration.flushLimit, 20);
        XCTAssertEqual(configuration.maxQueueLimit, 1000);
        XCTAssertNil(configuration.baseURLAllowList);
        XCTAssertEqual(configuration.isAdvertisingTrackingEnabled, true);
        XCTAssertEqual(configuration.isApplicationLifecycleTrackingEnabled, true);
        
        // Check ad tracking state, set ad support block with mock IDFA
        XCTAssertEqual(Castle.isAdTrackingEnabled(), false);
        configuration.adSupportBlock = { () -> String in
            return "00000000-0000-0000-0000-000000000000";
        };
        
        // Update configuration and check ad tracking enabled
        Castle.configure(configuration);
        XCTAssertEqual(Castle.isAdTrackingEnabled(), true);

        // Update configuration
        configuration.isScreenTrackingEnabled = true;
        configuration.isDebugLoggingEnabled = true;
        configuration.isDeviceIDAutoForwardingEnabled = true;
        configuration.flushLimit = 10;
        configuration.maxQueueLimit = 20;
        configuration.baseURLAllowList = baseURLAllowList;
        configuration.isAdvertisingTrackingEnabled = false;
        configuration.isApplicationLifecycleTrackingEnabled = false;

        // Check that all the configuration parameters where set correctly
        XCTAssertTrue(configuration.publishableKey == publishableKey)
        XCTAssertEqual(configuration.isScreenTrackingEnabled, true)
        XCTAssertEqual(configuration.isDebugLoggingEnabled, true)
        XCTAssertEqual(configuration.isDeviceIDAutoForwardingEnabled, true)
        XCTAssertEqual(configuration.flushLimit, 10)
        XCTAssertEqual(configuration.maxQueueLimit, 20)
        XCTAssertEqual(configuration.baseURLAllowList!.count, 1)
        XCTAssertTrue(configuration.baseURLAllowList![0].absoluteString == "https://google.com/")
        XCTAssertTrue(configuration.baseURL.absoluteString == "https://m.castle.io/v1/")

        configuration.baseURLAllowList = [URL(string: "https://google.com/somethingelse")!]
        XCTAssertFalse(configuration.baseURLAllowList![0].absoluteString  == "https://google.com/somethingelse")

        XCTAssertEqual(configuration.isAdvertisingTrackingEnabled, false);
        XCTAssertEqual(configuration.isApplicationLifecycleTrackingEnabled, false);
        
        // Setup Castle SDK with publishable key
        Castle.configure(withPublishableKey: publishableKey)

        XCTAssertFalse(Castle.isAllowlistURL(URL(string:"https://google.com/somethingelse")!))

        // Setup Castle SDK with provided configuration
        Castle.configure(configuration)

        // Check allowlisting on configured instance
        XCTAssertTrue(Castle.isAllowlistURL(URL(string:"https://google.com/somethingelse")!))
        XCTAssertFalse(Castle.isAllowlistURL(nil))

        Castle.resetConfiguration()
        
        // Test invalid publishable key validation error
        XCTAssertNotNil(tryBlock { Castle.configure(withPublishableKey: "") })
        XCTAssertNotNil(tryBlock { Castle.configure(withPublishableKey: "ab_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA") })
    }
    
    func testHighwindNilUUID() {
        Castle.reset()
        
        // Swizzle device identifier to simulate [[UIDevice currentDevice] identifierForVendor] returning nil
        Castle.enableSwizzle(true)
        
        let publishableKey = "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA"
        let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0";
        Castle.configure(withPublishableKey: publishableKey)
        Castle.userJwt(jwt)
        
        let count = Castle.queueSize()
        XCTAssertEqual(count, 0)
        
        // Tracking a custom event with the device identifier being nil should not add the event to the queue
        Castle.custom(name: "custom event")
        
        let newCount = Castle.queueSize()
        XCTAssertEqual(newCount, 0)
        
        // Disable swizzle, deviceIdentifier should now return a valid UUID
        Castle.enableSwizzle(false)
        
        // Track another event, Highwind instance should now be initialized (deviceIdentifier returned non-null UUID)
        Castle.custom(name: "custom event")
        
        let finalCount = Castle.queueSize()
        XCTAssertGreaterThan(finalCount, 0)
    }

    func testDeviceIdentifier() throws {
        // Check device ID
        XCTAssertNotNil(Castle.createRequestToken())
    }

    func testUserIdPersistance() throws {
        // Make sure the user id is persisted correctly after identify
        Castle.userJwt( "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")

        // Check that the stored identity is the same as the identity we tracked
        let userJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"
        XCTAssertEqual(Castle.userJwt(), userJwt)
    }

    func testReset() throws {
        Castle.reset()

        // Check to see if the user id and user signature was cleared on reset
        XCTAssertNil(Castle.userJwt());
    }

    func testTracking() throws {
        Castle.reset()

        // This should lead to no event being tracked since empty string isn't a valid name
        var count = Castle.queueSize()
        Castle.screen(name: "")
        var newCount = Castle.queueSize()
        XCTAssertTrue(count == newCount);

        // This should lead to no event being tracked since identity can't be an empty string
        count = Castle.queueSize()
        Castle.userJwt("")
        newCount = Castle.queueSize()
        XCTAssertTrue(count == newCount) // Count should be unchanged
        XCTAssertNil(Castle.userJwt()) // User jwt should be nil

        // This should lead to no event being tracked properties can't be nil
        count = Castle.queueSize()
        Castle.userJwt( "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")
        newCount = Castle.queueSize()
        XCTAssertTrue(count == newCount) // Count should be unchanged
        XCTAssertNotNil(Castle.userJwt()) // User jwt should not be nil

        let screen = CASScreen(name: "Main")
        XCTAssertNotNil(screen)
        XCTAssertTrue(screen!.type == "$screen")
        
        let properties = ["key": "value"]
        let custom = CASCustom.event(withName: "Custom", properties: properties)
        XCTAssertNotNil(custom)
        XCTAssertTrue(custom!.type == "$custom")
        XCTAssertEqual(custom!.properties as! [String: String], properties)
    }

    func testViewControllerSwizzle() throws {
        // Check to see if UIViewController responds to ca_viewDidAppear
        var viewController = UIViewController()
        XCTAssertTrue(viewController.responds(to: #selector(UIViewController.ca_viewDidAppear(_:))))

        // Check if view identifier is working correctly
        XCTAssertTrue(viewController.ca_viewIdentifier() == "Unknown");

        viewController.title = "Test View Controller";
        XCTAssertTrue(viewController.ca_viewIdentifier() == viewController.ca_viewIdentifier());

        viewController = MainViewController()
        XCTAssertTrue(viewController.ca_viewIdentifier() == "Main");
    }

    func testModels() throws {
        let monitor1 = CASMonitor(events: nil)
        XCTAssertNil(monitor1)

        let monitor2 = CASMonitor(events: [])
        XCTAssertNil(monitor2)

        let event1 = CASCustom(name: nil)
        XCTAssertNil(event1)

        let event2 = CASCustom(name: "")
        XCTAssertNil(event2)

        let screen1 = CASScreen(name: nil)
        XCTAssertNil(screen1)

        let screen2 = CASScreen(name: "")
        XCTAssertNil(screen2)

        let user1 = CASUserJwt.user(withJwt: "")
        XCTAssertNil(user1)
        
        XCTAssertTrue(CASEvent.supportsSecureCoding)
        XCTAssertTrue(CASMonitor.supportsSecureCoding)
        XCTAssertTrue(CASModel.supportsSecureCoding)
    }
    
    func testModelInvalidData() {
        let data = NSData()
        let properties = ["key": data];
        var event: CASEvent? = CASCustom.event(withName: "event", properties: properties)
        XCTAssertNil(event);
        
        event = CASScreen(name: "")
        XCTAssertNil(event);
        
        let user = CASUserJwt.user(withJwt: "")
        XCTAssertNil(user);
    }

    func testObjectSerializationForScreen() throws {
        Castle.reset()
        Castle.userJwt( "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")
        
        // Create screen view
        let event = CASScreen(name: "Main")!
        XCTAssertNotNil(event);
        XCTAssertTrue(event.name == "Main")
        
        // Validate payload
        let payload = event.jsonPayload() as! NSDictionary
        XCTAssertTrue(payload["name"]! as! String == "Main")
        XCTAssertTrue(payload["type"]! as! String == "$screen")
        XCTAssertNil(payload["properties"])
        XCTAssertNotNil(payload["timestamp"]!)
        
        // Token should be set
        let token = payload["request_token"] as! String
        XCTAssertNotNil(token);
        
        // Payload should not include these parameters
        XCTAssertNil(payload["event"])
        
        // Check parameters of screen model
        let event2 = CASScreen(name: "Second")!
        XCTAssertTrue(event2.type == "$screen")
        XCTAssertTrue(event2.name == "Second")
        
        // Archive screen object
        let data = try! NSKeyedArchiver.archivedData(withRootObject:event2 as Any, requiringSecureCoding: true)
        
        // Unarchived data should match model before archive
        let event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASScreen.self, from: data)
        XCTAssertTrue(event2.name == event3!.name)
        XCTAssertTrue(event2.type == event3!.type)
    }

    func testObjectSerializationForIdentify() {
        let userJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"
        Castle.reset()
        Castle.userJwt(userJwt)

        // Create user identity
        let event = CASUserJwt.user(withJwt: userJwt)!

        // Validate payload
        let payload = event.jsonPayload() as! NSDictionary
        XCTAssertTrue(payload["jwt"] as! String == userJwt)
        
        // Validate jwt payload
        let event2 = CASUserJwt.user(withJwt: userJwt)!
        XCTAssertTrue(event2.jwt == userJwt);
    }

    func testObjectSerializationForEvent() {
        Castle.reset()
        Castle.userJwt("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")

        let model = CASModel()
        XCTAssertNil(model.jsonPayload());
        XCTAssertNil(model.jsonData());

        // Create basic event with valid data
        let event = CASCustom(name: "testevent1")!
        XCTAssertNotNil(event);
        XCTAssertTrue(event.name == "testevent1");

        // Validate simple factory method
        let event1 = CASCustom(name: "testevent2")!
        XCTAssertTrue(event1.name == "testevent2");

        // Validate payload
        let payload = event.jsonPayload()! as! NSDictionary
        XCTAssertTrue(payload["name"] as! String == "testevent1")
        XCTAssertTrue(payload["type"] as! String == "$custom")
        XCTAssertNil(payload["properties"])
        XCTAssertNotNil(payload["timestamp"])
        XCTAssertNotNil(payload["request_token"])

        // Validate JSON Serialization success
        XCTAssertNotNil(event.jsonData());

        let invalidEvent1 = CASCustom.event(withName: "testevent2", properties: [ "invalidparam": NSObject() ])
        XCTAssertNil(invalidEvent1)

        // Event will skip any nested dictionaries
        let validEventSkipNested = CASCustom.event(withName: "testevent2", properties: [ "invalidParamContainer": [ "invalidParam": NSObject() ] ])
        XCTAssertNotNil(validEventSkipNested)

        // Check parameters of custom model
        let event2 = CASCustom(name: "event2")!
        XCTAssertTrue(event2.name == "event2")
        XCTAssertTrue(event2.type == "$custom");

        // Archive screen object
        let data = try! NSKeyedArchiver.archivedData(withRootObject:event2 as Any, requiringSecureCoding: true)
        
        // Unarchived data should match model before archive
        let event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASCustom.self, from: data)
        XCTAssertTrue(event2.name == event3?.name);
        XCTAssertTrue(event2.type == event3?.type);
    }

    func testPersistance() throws {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let path = paths[0].appending("/castle/events")

        let eventQueue = CASEventQueue()
        
        // Track a single event to trigger the persistance
        Castle.screen(name: "example screen")
        waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self) { queue in
            XCTAssertTrue(fileManager.fileExists(atPath: path))
        }

        // Remove event queue data file and verify
        XCTAssertNoThrow(try fileManager.removeItem(atPath: path))
        XCTAssertFalse(fileManager.fileExists(atPath: path))

        // Track a single event to trigger the persistance
        Castle.screen(name: "example screen")
        waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self) { queue in
            XCTAssertTrue(fileManager.fileExists(atPath: path))
        }

        let currentQueueSize = Castle.queueSize()

        // Unarchive stored event queue and check that the queue count is the same as the current size of the in memory queue
        waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self) { queue in
            let currentQueueSize = Castle.queueSize()
            XCTAssertTrue(currentQueueSize == queue.count)
        }

        // Tracking a new event should increase queue size by one
        Castle.screen(name: "example screen")
        XCTAssertTrue(Castle.queueSize() == currentQueueSize + 1)
        
        // Tracking a new event should increase queue size by one
        Castle.custom(name: "custom event")
        XCTAssertTrue(Castle.queueSize() == currentQueueSize + 2)
        
        // Tracking a new event should increase queue size by one
        Castle.custom(name: "custom event", properties: ["key": "value"])
        XCTAssertTrue(Castle.queueSize() == currentQueueSize + 3)
    }
    
    func verifyStorage(oldStorageDir: String, oldStoragePath: String, newStorageDir: String, newStoragePath: String) {
        let fileManager = FileManager.default
        let eventQueue = CASEventQueue()
        
        // Check that old storage directory doesn't exist
        var isOldStorageDir: ObjCBool = false
        XCTAssertTrue(!fileManager.fileExists(atPath: oldStorageDir, isDirectory: &isOldStorageDir) && !isOldStorageDir.boolValue)
        
        // Check that old storage file doesn't exist
        XCTAssertTrue(!fileManager.fileExists(atPath: oldStoragePath))
        
        // Check that new storage directory exists
        var isNewStorageDir: ObjCBool = false
        XCTAssertTrue(fileManager.fileExists(atPath: newStorageDir, isDirectory: &isNewStorageDir) && isNewStorageDir.boolValue)
        
        // Check that new storage file exists
        waitForEventPersistenceWithQueue(eventQueue, 1.0, 0.2, self) { queue in
            XCTAssertTrue(fileManager.fileExists(atPath: newStoragePath))
        }
    }
    
    func testStorageMigration() {
        let fileManager = FileManager.default
        let eventQueue = CASEventQueue()
        let _ = eventQueue.storedQueueSync()
        
        // Fetch and persist the queue to make sure that the storage structure is correct according to new storage structure
        eventQueue.persistQueue(eventQueue.storedQueueSync())
        
        let documentsPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let oldStorageDir = documentsPaths[0].appending("/castle")
        let oldStoragePath = oldStorageDir.appending("/events")
        
        let applicationSupportPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let newStorageDir = applicationSupportPaths[0].appending("/castle")
        let newStoragePath = newStorageDir.appending("/events")
        
        // Verify storage structure, migration should already have happened in earlier tests
        verifyStorage(oldStorageDir: oldStorageDir, oldStoragePath: oldStoragePath, newStorageDir: newStorageDir, newStoragePath: newStoragePath)
        
        // Remove new event storage file and verify deletion
        try? fileManager.removeItem(atPath: newStoragePath)
        XCTAssertTrue(!fileManager.fileExists(atPath: newStoragePath))
        
        // Copy migration file from bundle to old storage path
        let bundlePath = Bundle.main.path(forResource: "events_migration_file", ofType: nil)
        try! fileManager.createDirectory(atPath: oldStorageDir, withIntermediateDirectories: false)
        try! fileManager.copyItem(atPath: bundlePath!, toPath: oldStoragePath)
        
        // Calling storedQueue will trigger the migration, check event count to see that the migration was successful
        let queue = eventQueue.storedQueueSync()
        XCTAssertTrue(queue.count == 1)
        
        eventQueue.persistQueue(queue);
        
        // Verify storage structure again to determine that the migration was successful
        verifyStorage(oldStorageDir: oldStorageDir, oldStoragePath: oldStoragePath, newStorageDir: newStorageDir, newStoragePath: newStoragePath)
        
        // Check event count, should be the same after persisting the queue
        XCTAssertTrue(queue.count == 1);
    }
    
    func testRequestTokenUninitialized() throws {
        XCTAssertNotNil(Castle.createRequestToken())
        
        Castle.resetConfiguration()
        XCTAssertNotNil(tryBlock { Castle.createRequestToken() })
    }
    
    func testNonConfiguredInstance() throws {
        Castle.resetConfiguration()
        
        XCTAssertNotNil(tryBlock { Castle.screen(name: "Screen name") })
        XCTAssertNotNil(tryBlock { Castle.custom(name: "Custom event") })
        XCTAssertNotNil(tryBlock { Castle.userJwt() })
        XCTAssertNotNil(tryBlock { Castle.userJwt("invalid_jwt_token_string") })
        XCTAssertNotNil(tryBlock { Castle.queueSize() })
        XCTAssertNotNil(tryBlock { Castle.flush() })
        XCTAssertNotNil(tryBlock { Castle.flushIfNeeded(URL(string: "https://google.com/")!) })
        XCTAssertNotNil(tryBlock { Castle.isAllowlistURL(URL(string: "https://google.com/")!) })
        XCTAssertNotNil(tryBlock { Castle.baseURL() })
        XCTAssertNotNil(tryBlock { Castle.createRequestToken() })
    }

    func testDefaultHeaders() throws {
        XCTAssertNotNil(Castle.createRequestToken());
        XCTAssertTrue(CastleRequestTokenHeaderName == "X-Castle-Request-Token");
    }

    func testRequestInterceptor() throws {
        // Create configuration object
        let configuration = CastleConfiguration(publishableKey: "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA")
        
        let baseURLAllowList = [URL(string: "https://google.com/")!]

        // Update configuration
        configuration.isScreenTrackingEnabled = true
        configuration.isDebugLoggingEnabled = true
        configuration.isDeviceIDAutoForwardingEnabled = true
        configuration.flushLimit = 10
        configuration.baseURLAllowList = baseURLAllowList

        Castle.configure(configuration)

        let request1 = URLRequest(url: URL(string: "https://google.com/")!)
        XCTAssertTrue(CASRequestInterceptor.canInit(with: request1))
        XCTAssertEqual(CASRequestInterceptor.canonicalRequest(for: request1), request1)

        let request2 = URLRequest(url: URL(string:"https://example.com/")!)
        XCTAssertFalse(CASRequestInterceptor.canInit(with: request2))
        XCTAssertEqual(CASRequestInterceptor.canonicalRequest(for: request2), request2)

        XCTAssertTrue(CASRequestInterceptor.requestIsCacheEquivalent(request2, to: request2))

        let urlSession = URLSession(configuration: Castle.urlSessionInterceptConfiguration())
        XCTAssertNotNil(urlSession);

        let expectation = self.expectation(description: "Test interceptor: google.com")

        let url = URL(string:"https://google.com")!
        var request = URLRequest(url: url)

        // Get required header from the Castle SDK if you don't want to use the request interceptor
        request.setValue(Castle.createRequestToken(), forHTTPHeaderField: CastleRequestTokenHeaderName)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            XCTAssertNil(error, "error should be nil");
            
            if let httpResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse");
            }

            expectation.fulfill()
        }
        task.resume()

        Castle.flushIfNeeded(url)
        
        self.waitForExpectations(timeout: task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                NSLog("Error: %@", error.localizedDescription);
            }
            task.cancel()
        }
    }

    func testNetworking() throws {
        // Must identify, otherwise CASMonitor constructor will return nil
        Castle.userJwt("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")
        
        let event = CASCustom(name: "Example event")!
        let monitorModel = CASMonitor(events: [event])!
        XCTAssertNotNil(monitorModel);

        let expectation = self.expectation(description: "GET /monitor")

        // Create configuration object
        let configuration = CastleConfiguration(publishableKey: "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA")
        let client = CASAPIClient(configuration: configuration)

        // Perform monitor network request
        let task = client.dataTask(withPath: "monitor", post: monitorModel.jsonData()!, completion: { (responseObject, response, error) in
            XCTAssertNil(error, "error should be nil");

            if let httpResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 204, "HTTP response status code should be 204 (no response body)")
            } else {
                XCTFail("Response was not NSHTTPURLResponse");
            }

            expectation.fulfill()
        })
        task.resume()

        self.waitForExpectations(timeout: task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                NSLog("Error: %@", error.localizedDescription);
            }
            task.cancel()
        }
    }

    func testMaxQueueLength() throws {
        let configuration = CastleConfiguration(publishableKey: "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA")

        // Update configuration and set max queue limit to less than the flush limit.
        configuration.isDebugLoggingEnabled = true
        configuration.flushLimit = 10
        configuration.maxQueueLimit = 8

        Castle.configure(configuration)
        
        Castle.userJwt("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0")

        // Fill the queue
        for i in 0...configuration.maxQueueLimit {
            Castle.screen(name: String(format: "Screen %d", i))
        }

        // The queue size should be equal to maxQueueLimit
        XCTAssertTrue(configuration.maxQueueLimit == Castle.queueSize());

        // Track a new event so the maxQueueLimit is reached
        Castle.screen(name: "Screen")

        // Add one more event so the oldest event in the queue is evicted
        // The queue size should still be equal to maxQueueLimit
        XCTAssertTrue(configuration.maxQueueLimit == Castle.queueSize());
    }

    func testAppUpdateDetection() throws {
        // Set current app version to semething old
        let defaults = UserDefaults.standard
        defaults.setValue("0.1.1", forKey: "CastleAppVersionKey")
        defaults.synchronize()

        Castle.resetConfiguration()
        Castle.configure(withPublishableKey: "pk_CTsfAeRTqxGgA7HHxqpEESvjfPp4QAKA")

        // Check to see if the installed version was updated correctly i.e. the SDK detected an app update.
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let installedVersion = defaults.value(forKey: "CastleAppVersionKey") as! String
        XCTAssertEqual(currentVersion, installedVersion)
    }
}
