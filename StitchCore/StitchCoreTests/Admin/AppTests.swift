//
//  AppTests.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/23/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import XCTest
@testable import StitchCore

class AppTests: XCTestCase {
    let testAppName = "testapp"

    var fixture: StitchFixture!
    var th: TestHarness!

    override func setUp() {
        if self.fixture == nil {
            let (fixtureM, err) = await(try! StitchFixture.newFixture())
            guard let fixture = fixtureM else { fatalError(err!.localizedDescription) }
            self.fixture = fixture
        }
        let (apiKey, groupId, baseUrl) = fixture.extractDataPoints()
        let (th, err) = await(TestHarness.newAdminHarness(isSeedTestApp: false,
                                                          apiKey: apiKey,
                                                          groupId: groupId,
                                                          serverUrl: baseUrl))
        guard let harness = th else { fatalError(err!.localizedDescription) }
        self.th = harness
    }

    override func tearDown() {
        await(th!.cleanup())
    }

    func testListingAppsShouldReturnAnEmptyList() throws {
        let (appsM, err) = await(th.apps.list())
        guard let apps = appsM else { throw err! }
        XCTAssertEqual(apps.count, 0)
    }

    func testCanCreateAppSuccessfully() throws {
        let (appM, err) = await(th.createApp(testAppName: testAppName))
        guard let app = appM else { throw err! }
        XCTAssertEqual(app.name, testAppName)
    }

    func testNewlyCreatedAppShouldAppearInAList() throws {
        let app = try trust(th.createApp(testAppName: testAppName))
        let apps = try trust(th.apps.list()).filter { $0.id == app.id }
        XCTAssertEqual(apps.count, 1)
        XCTAssertEqual(apps[0], app)
    }

    func testCanFetchFetchExistingApp() throws {
        let app = try trust(th.createApp(testAppName: testAppName))
        let appFetched = try trust(th.app.get())
        XCTAssertEqual(app, appFetched)
    }

    func testCanDeleteAnApp() throws {
        let app = try trust(th.createApp(testAppName: testAppName))
        let (_, err) = await(th.appRemove())
        guard err == nil else { throw err! }
        let apps = try trust(th.apps.list()).filter { $0.id == app.id }
        XCTAssertEqual(apps.count, 0)
    }
}
