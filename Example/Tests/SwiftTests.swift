//
//  SwiftTests.swift
//  Castle_Tests
//
//  Created by Alexander Simson on 2021-01-13.
//  Copyright © 2021 Alexander Simson. All rights reserved.
//

import XCTest

import Castle

class SwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let baseURLAllowList = [URL(string: "https://google.com/")!]
        let configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        configuration.baseURLAllowList = baseURLAllowList
        
        Castle.configure(configuration)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
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
        let baseURLAllowList = [URL(string:"https://google.com/")!];
        var configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")

        // Check that all default values are set correctly
        XCTAssertEqual(configuration.isScreenTrackingEnabled, true);
        XCTAssertEqual(configuration.isDebugLoggingEnabled, false);
        XCTAssertEqual(configuration.flushLimit, 20);
        XCTAssertEqual(configuration.maxQueueLimit, 1000);
        XCTAssertNil(configuration.baseURLAllowList);

        // Update configuration
        configuration.isScreenTrackingEnabled = true;
        configuration.isDebugLoggingEnabled = true;
        configuration.isDeviceIDAutoForwardingEnabled = true;
        configuration.flushLimit = 10;
        configuration.maxQueueLimit = 20;
        configuration.baseURLAllowList = baseURLAllowList;

        // Check that all the configuration parameters where set correctly
        XCTAssertTrue(configuration.publishableKey == "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        XCTAssertEqual(configuration.isScreenTrackingEnabled, true)
        XCTAssertEqual(configuration.isDebugLoggingEnabled, true)
        XCTAssertEqual(configuration.isDeviceIDAutoForwardingEnabled, true)
        XCTAssertEqual(configuration.flushLimit, 10)
        XCTAssertEqual(configuration.maxQueueLimit, 20)
        XCTAssertEqual(configuration.baseURLAllowList!.count, 1)
        XCTAssertTrue(configuration.baseURLAllowList![0].absoluteString == "https://google.com/")
        XCTAssertFalse(configuration.useCloudflareApp)
        XCTAssertTrue(configuration.baseURL.absoluteString == "https://api.castle.io/v1/")

        configuration.baseURLAllowList = [URL(string: "https://google.com/somethingelse")!]
        XCTAssertFalse(configuration.baseURLAllowList![0].absoluteString  == "https://google.com/somethingelse")

        // Setup Castle SDK with publishable key
        Castle.configure(withPublishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")

        // Configuration reset
        Castle.resetConfiguration()
        XCTAssertFalse(Castle.isAllowlistURL(URL(string:"https://google.com/somethingelse")!))

        // Setup Castle SDK with provided configuration
        Castle.configure(configuration)

        // Check allowlisting on configured instance
        XCTAssertTrue(Castle.isAllowlistURL(URL(string:"https://google.com/somethingelse")!))
        XCTAssertFalse(Castle.isAllowlistURL(nil))

        Castle.resetConfiguration()

        configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        configuration.apiDomain = "example.com"
        configuration.useCloudflareApp = true

        XCTAssertTrue(configuration.useCloudflareApp)
        XCTAssertTrue(configuration.apiDomain == "example.com")
        XCTAssertTrue(configuration.apiPath == "v1/c/mobile/")
        XCTAssertTrue(configuration.baseURL.absoluteString == "https://example.com/v1/c/mobile/")

        Castle.configure(configuration)

        XCTAssertTrue(Castle.baseURL().absoluteString == "https://example.com/v1/c/mobile/");

        Castle.resetConfiguration()

        configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        configuration.apiDomain = "example.com"
        configuration.apiPath = "v1/test/"
        configuration.useCloudflareApp = true

        XCTAssertTrue(configuration.useCloudflareApp);
        XCTAssertTrue(configuration.apiDomain == "example.com");
        XCTAssertTrue(configuration.baseURL.absoluteString == "https://example.com/v1/test/");
        
        Castle.resetConfiguration()

        Castle.configure(withPublishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
    }

    func testDeviceIdentifier() throws {
        // Check device ID
        XCTAssertNotNil(Castle.createRequestToken())
    }

    func testUserIdPersistance() throws {
        // Make sure the user id is persisted correctly after identify
        Castle.identify("thisisatestuser")

        // Check that the stored identity is the same as the identity we tracked
        XCTAssertEqual(Castle.userId(), "thisisatestuser")
    }

    func testSignaturePersistance() throws {
        // Call secure to save the signature
        Castle.secure("944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52")
        
        // Check that the stored user signature is the same as the user signature we provided
        XCTAssertEqual(Castle.userSignature(), "944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52")
    }

    func testReset() throws {
        Castle.reset()

        // Check to see if the user id and user signature was cleared on reset
        XCTAssertNil(Castle.userId());
        XCTAssertNil(Castle.userSignature());
    }

    func testTracking() throws {
        Castle.reset()

        // This should lead to no event being tracked since empty string isn't a valid name
        var count = CASEventStorage.storedQueue().count
        Castle.screen("")
        var newCount = CASEventStorage.storedQueue().count
        XCTAssertTrue(count == newCount);

        // This should lead to no event being tracked since identity can't be an empty string
        count = CASEventStorage.storedQueue().count
        Castle.identify("")
        newCount = CASEventStorage.storedQueue().count
        XCTAssertTrue(count == newCount) // Count should be unchanced
        XCTAssertNil(Castle.userId()) // User id should be nil

        // This should lead to no event being tracked properties can't be nil
        count = CASEventStorage.storedQueue().count
        Castle.identify("testuser1", traits: nil)
        newCount = CASEventStorage.storedQueue().count
        XCTAssertTrue(count == newCount) // Count should be unchanced
        XCTAssertNil(Castle.userId()) // User id should be nil

        let screen = CASScreen(name: "Main");
        XCTAssertNotNil(screen);
        XCTAssertTrue(screen!.type == "screen");
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
        let batch1 = CASBatch(events: nil)
        XCTAssertNil(batch1)

        let batch2 = CASBatch(events: [])
        XCTAssertNil(batch2)

        let event1 = CASEvent(name: nil)
        XCTAssertNil(event1)

        let event2 = CASEvent(name: "")
        XCTAssertNil(event2)

        let screen1 = CASScreen(name: nil)
        XCTAssertNil(screen1)

        let screen2 = CASScreen(name: "")
        XCTAssertNil(screen2)

        let identity1 = CASIdentity(userId: "", traits: [:])
        XCTAssertNil(identity1)

        let identity2 = CASIdentity(userId:"testuser", traits: [:])

        let identity2Data = try! NSKeyedArchiver.archivedData(withRootObject: identity2 as Any, requiringSecureCoding: true)
        XCTAssertNotNil(identity2Data)

        let identity3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASIdentity.self, from: identity2Data)
        XCTAssertNotNil(identity3)

        XCTAssertTrue(CASEvent.supportsSecureCoding)
    }

    func testSecureMode() throws {
        // Calling secure with a nil user signature should not store or replace any previous signature
        Castle.secure(nil)
        XCTAssertNil(Castle.userSignature())
        
        // User signature should be stored
        Castle.secure("944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52")
        XCTAssertEqual(Castle.userSignature(), "944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52");
        
        // Calling secure again should override previously stored signature
        Castle.secure("844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52")
        XCTAssertEqual(Castle.userSignature(), "844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52")
    }

    func testObjectSerializationForScreen() throws {
        Castle.reset()
        Castle.identify("thisisatestuser1")
        
        // Create screen view
        let event = CASScreen(name: "Main")!
        XCTAssertNotNil(event);
        XCTAssertTrue(event.name == "Main")
        
        // Validate payload
        let payload = event.jsonPayload()!
        XCTAssertTrue(payload["name"]! as! String == "Main")
        XCTAssertTrue(payload["type"]! as! String == "screen")
        XCTAssertNil(payload["properties"])
        XCTAssertNotNil(payload["timestamp"]!)
        XCTAssertNotNil(payload["context"]!)
        XCTAssertNil(payload["user_signature"])
        
        // Client id should be set
        let context = payload["context"] as! [AnyHashable:Any]
        let clientId = context["client_id"] as! String
        XCTAssertNotNil(clientId);
        
        // Payload should not include these parameters
        XCTAssertNil(payload["event"])
        
        // Enable secure mode
        let signature = "944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature)
        
        // The user signature should be included in any new event objects
        let event2 = CASScreen(name: "Second")!
        XCTAssertTrue(event2.userId == "thisisatestuser1")
        XCTAssertTrue(event2.userSignature == signature)
        
        // Archive identity object
        var data = try! NSKeyedArchiver.archivedData(withRootObject:event2 as Any, requiringSecureCoding: true)
        var event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASScreen.self, from: data)
        XCTAssertTrue(event2.userId == event3!.userId)
        XCTAssertTrue(event2.userSignature == event3!.userSignature)
        
        // Update user identity
        Castle.identify("thisisatestuser2")
        
        // Update user signature
        let signature2 = "844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature2)
        
        // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
        data = try! NSKeyedArchiver.archivedData(withRootObject: event2, requiringSecureCoding: true)
        event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASScreen.self, from: data)
        XCTAssertTrue(event3?.userId == "thisisatestuser1");
        XCTAssertTrue(event3?.userSignature == signature);
        
        // Create a new event that should have the new updated user id and signature
        let event4 = CASScreen(name: "Third")!
        data = try! NSKeyedArchiver.archivedData(withRootObject: event4, requiringSecureCoding: true)
        let event5 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASScreen.self, from: data)
        XCTAssertTrue(event5?.userId == "thisisatestuser2")
        XCTAssertTrue(event5?.userSignature == signature2)
    }

    func testObjectSerializationForIdentify() {
        Castle.reset()
        Castle.identify("thisisatestuser1")
        
        // Create user identity
        let traits = ["trait": "value"];
        let event = CASIdentity(userId: "123", traits: traits)!

        // Validate payload
        let payload = event.jsonPayload()!
        XCTAssertTrue(payload["user_id"] as! String == "123")
        XCTAssertTrue(payload["type"] as! String  == "identify")
        XCTAssertTrue(payload["traits"]! as! [String:String] == traits)
        XCTAssertNotNil(payload["timestamp"])
        XCTAssertNotNil(payload["context"])
        XCTAssertNil(payload["user_signature"])
        
        // Payload should not include these parameters
        XCTAssertNil(payload["properties"])
        XCTAssertNil(payload["event"])
        
        // Enable secure mode
        let signature = "944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature)
        
        // The user signature should be included in any new event objects
        let event2 = CASIdentity(userId: "456", traits: traits)!
        XCTAssertTrue(event2.userId == "456");
        XCTAssertTrue(event2.userSignature == signature);
        
        // Archive identity object
        var data = try! NSKeyedArchiver.archivedData(withRootObject: event2, requiringSecureCoding: true)
        var event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASIdentity.self, from: data)
        XCTAssertTrue(event2.userId == event3?.userId)
        XCTAssertTrue(event2.userSignature == event3?.userSignature)
        
        // Update user identity
        Castle.identify("thisisatestuser2")
        
        // Update user signature
        let signature2 = "844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature2)
        
        // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
        data = try! NSKeyedArchiver.archivedData(withRootObject: event2, requiringSecureCoding: true)
        event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASIdentity.self, from: data)
        XCTAssertTrue(event3?.userId == event2.userId);
        XCTAssertTrue(event3?.userSignature == signature);
        
        // Create a new event that should have the new updated user id and signature
        let event4 = CASIdentity(userId:"789", traits:traits)!
        data = try! NSKeyedArchiver.archivedData(withRootObject: event4, requiringSecureCoding: true)
        let event5 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASIdentity.self, from: data)
        XCTAssertTrue(event5?.userId == "789");
        XCTAssertTrue(event5?.userSignature == signature2);
    }

    func testObjectSerializationForEvent() {
        Castle.reset()
        Castle.identify("thisisatestuser1")

        let model = CASModel()
        XCTAssertNil(model.jsonPayload());
        XCTAssertNil(model.jsonData());

        // Create basic event with valid data
        let event = CASEvent(name: "testevent1", properties:["param1": "value1", "param2": [ "param3": 2 ] ])!
        XCTAssertNotNil(event);
        XCTAssertTrue(event.name == "testevent1");
        XCTAssertNotNil(event.properties);

        // Validate simple factory method
        let event1 = CASEvent(name: "testevent2")!
        XCTAssertTrue(event1.name == "testevent2");
        XCTAssertNotNil(event1.properties);

        // Validate payload
        let payload = event.jsonPayload()!
        XCTAssertTrue(payload["event"] as! String == "testevent1")
        XCTAssertTrue(payload["type"] as! String == "track")
        XCTAssertNil(payload["properties"])
        XCTAssertNotNil(payload["timestamp"])
        XCTAssertNotNil(payload["context"])
        XCTAssertNil(payload["user_signature"])

        // Validate JSON Serialization success
        XCTAssertNotNil(event.jsonData());

        let invalidEvent1 = CASEvent(name: "testevent2", properties: [ "invalidparam": NSObject() ])
        XCTAssertNil(invalidEvent1)

        let invalidEvent2 = CASEvent(name: "testevent2", properties: [ "invalidParamContainer": [ "invalidParam": NSObject() ] ])
        XCTAssertNil(invalidEvent2)

        // Enable secure mode
        let signature = "944d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature)

        // The user signature should be included in any new event objects
        let event2 =  CASEvent(name: "event2")!
        XCTAssertTrue(event2.userId == "thisisatestuser1")
        XCTAssertTrue(event2.userSignature == signature);

        // Archive identity object
        var data = try! NSKeyedArchiver.archivedData(withRootObject: event2, requiringSecureCoding: true)
        var event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASEvent.self, from: data)
        XCTAssertTrue(event2.userId == event3?.userId);
        XCTAssertTrue(event2.userSignature == event3?.userSignature);

        // Update user identity
        Castle.identify("thisisatestuser2")

        // Update user signature
        let signature2 = "844d7d6c5187cafac297785bbf6de0136a2e10f31788e92b2822f5cfd407fa52"
        Castle.secure(signature2)

        // Verify that the user id and token are the same after archiving and unarchiving after updating the user id and signature
        data = try! NSKeyedArchiver.archivedData(withRootObject: event2, requiringSecureCoding: true)
        event3 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASEvent.self, from: data)
        XCTAssertTrue(event3?.userId == "thisisatestuser1")
        XCTAssertTrue(event3?.userSignature == signature)

        // Create a new event that should have the new updated user id and signature
        let event4 = CASEvent(name: "event4")!
        data = try! NSKeyedArchiver.archivedData(withRootObject: event4, requiringSecureCoding: true)
        let event5 = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CASEvent.self, from: data)
        XCTAssertTrue(event5?.userId == "thisisatestuser2")
        XCTAssertTrue(event5?.userSignature == signature2)
    }

    func testPersistance() throws {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0].appending("/castle/events")

        // Track a single event to trigger the persistance
        Castle.screen("example screen")
        XCTAssertTrue(fileManager.fileExists(atPath: path));

        // Remove event queue data file and verify
        XCTAssertNoThrow(try fileManager.removeItem(atPath: path))
        XCTAssertFalse(fileManager.fileExists(atPath: path))

        // Track a single event to trigger the persistance
        Castle.screen("example screen")
        XCTAssertTrue(fileManager.fileExists(atPath: path))

        let currentQueueSize = Castle.queueSize()

        // Unarchive stored event queue and check that the queue count is the same as the current size of the in memory queue
        var queue = CASEventStorage.storedQueue()
        XCTAssertTrue(currentQueueSize == queue.count);

        // Tracking a new event should increase queue size by one
        Castle.screen("example screen")
        queue = CASEventStorage.storedQueue()
        XCTAssertTrue(queue.count == currentQueueSize+1);
    }

    func testDefaultHeaders() throws {
        XCTAssertNotNil(Castle.createRequestToken());
        XCTAssertTrue(CastleRequestTokenHeaderName == "X-Castle-Request-Token");
    }

    func testRequestInterceptor() throws {
        // Create configuration object
        let configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        
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
        let event = CASEvent(name: "Example event")!
        let batchModel = CASBatch(events: [event])!
        XCTAssertNotNil(batchModel);

        let expectation = self.expectation(description: "GET /batch")

        // Create configuration object
        let configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")
        let client = CASAPIClient(configuration: configuration)

        // Perform batch network request
        let task = client.dataTask(withPath: "batch", post: batchModel.jsonData()!, completion: { (responseObject, response, error) in
            XCTAssertNil(error, "error should be nil");

            if let httpResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 202, "HTTP response status code should be 202")
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
        let configuration = CastleConfiguration(publishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")

        // Update configuration and set max queue limit to less than the flush limit.
        configuration.isDebugLoggingEnabled = true
        configuration.flushLimit = 10
        configuration.maxQueueLimit = 8

        Castle.configure(configuration)

        // Fill the queue
        for i in 0...configuration.maxQueueLimit {
            Castle.screen(String(format: "Screen %d", i))
        }

        // The queue size should be equal to maxQueueLimit
        XCTAssertTrue(configuration.maxQueueLimit == Castle.queueSize());

        // Track a new event so the maxQueueLimit is reached
        Castle.screen("Screen")

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
        Castle.configure(withPublishableKey: "pk_SE5aTeotKZpDEn8kurzBYquRZyy21fvZ")

        // Check to see if the installed version was updated correctly i.e. the SDK detected an app update.
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let installedVersion = defaults.value(forKey: "CastleAppVersionKey") as! String
        XCTAssertEqual(currentVersion, installedVersion)
    }

    func testReachabilityValidHost() throws {
        let validHostName = "google.com"

        let reachability = CASReachability(hostname: validHostName)

        if (reachability == nil) {
            XCTFail("Unable to create reachability");
        }

        let expectation = self.expectation(description: "Check valid host")
        
        reachability!.reachableBlock = { (reachability: CASReachability?) -> Void in
            NSLog("Pass: %@ is reachable", validHostName)
            expectation.fulfill()
        }
        
        reachability!.unreachableBlock = { (reachability: CASReachability?) -> Void in
            NSLog("%@ is initially unreachable", validHostName);
        }
        
        XCTAssertNoThrow(reachability!.startNotifier())

        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        reachability!.stopNotifier()
    }

    func testReachabilityInvalidHost() throws {
        let validHostName = "invalidhost"

        let reachability = CASReachability.init(hostname: validHostName)

        if (reachability == nil) {
            XCTFail("Unable to create reachability")
        }
        
        let expectation = self.expectation(description: "Check valid host")
        
        reachability!.reachableBlock = { (reachability: CASReachability?) -> Void in
            NSLog("Pass: %@ is reachable", validHostName)
        }
        
        reachability!.unreachableBlock = { (reachability: CASReachability?) -> Void in
            NSLog("%@ is initially unreachable", validHostName);
            expectation.fulfill()
        }

        XCTAssertNoThrow(reachability!.startNotifier())

        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        reachability!.stopNotifier()
    }
}
