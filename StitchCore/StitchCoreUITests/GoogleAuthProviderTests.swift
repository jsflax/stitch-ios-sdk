//
//  StitchCoreUITests.swift
//  StitchCoreUITests
//
//  Created by Jason Flax on 1/8/18.
//  Copyright © 2018 MongoDB. All rights reserved.
//

import XCTest

class GoogleAuthProviderTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        //continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignIn() {
        let exp = expectation(description: "Alert")
        let pred = NSPredicate.init(format: "exists == 1")
        let app = XCUIApplication()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        addUIInterruptionMonitor(withDescription: "“StitchCoreUITestApp” Wants to Use “google.com“ to Sign In") { (alert) -> Bool in
            alert.buttons["Continue"].tap()
            let email = app.textFields["Email or phone"]
            self.wait(for: [self.expectation(for: pred, evaluatedWith: email, handler: nil)], timeout: 10)
            app.textFields.allElementsBoundByIndex.forEach { print($0) }
            print(email.exists)
            email.tap()
            email.typeText("stitch.test@gmail.com")
            exp.fulfill()
            return true
        }

        app.launch()

        app.alerts.element.collectionViews.buttons["Continue"].tap()
        waitForExpectations(timeout: 50, handler: nil)
    }
}
