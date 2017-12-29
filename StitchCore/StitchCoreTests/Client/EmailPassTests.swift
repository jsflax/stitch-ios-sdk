//
//  EmailPassTests.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/29/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import XCTest

class EmailPassTests: XCTestCase {
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

    func testRegister() {
        
    }
}
