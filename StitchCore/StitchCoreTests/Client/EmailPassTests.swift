//
//  EmailPassTests.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/29/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import XCTest

//private func setUpSMTP() {
//    let session = MCOIMAPSession.init()
//    session.hostname = "gmail.com"
//    //session.port = 587
//    session.username = "stitch.tester@gmail.com"
//    session.password = "st123456"
//    session.connectionType = MCOConnectionType.TLS
//
//    let requestKind = MCOIMAPMessagesRequestKind.headers
//    let folder = "INBOX"
//    let uids = MCOIndexSet.init(range: MCORangeMake(1, UInt64.max))
//
//    session.connectOperation().start { err in
//        print(err)
//    }
//
//    let fetchOperation = session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: uids)
//    fetchOperation?.start { (err, messages, indexSet) in
//        if let err = err {
//            print(err)
//        }
//
//        print(messages)
//    }
//}

class EmailPassTests: XCTestCase {
    let testAppName = "testapp"
    let testEmail = "stitch.tester@gmail.com"

    var fixture: StitchFixture!
    var th: TestHarness!

    override func setUp() {
        if self.fixture == nil {
            let (fixtureM, err) = await(try! StitchFixture.newFixture())
            guard let fixture = fixtureM else { fatalError(err!.localizedDescription) }
            self.fixture = fixture
        }
        let (apiKey, groupId, baseUrl) = fixture.extractDataPoints()
        var (th, err) = await(TestHarness.newAdminHarness(isSeedTestApp: true,
                                                          apiKey: apiKey,
                                                          groupId: groupId,
                                                          serverUrl: baseUrl))
        guard let harness = th else { fatalError(err!.localizedDescription) }
        (_, err) = await(try! harness.setupStitchClient())
        guard err == nil else { fatalError(err!.localizedDescription) }
        self.th = harness
        //setUpSMTP()
    }

    override func tearDown() {
        await(th!.cleanup())
    }

    func testRegister() throws {
        await(th.createApp())
        let (_, err) = await(th.stitchClient!.register(email: testEmail,
                                                       password: "password"))
        XCTAssertNil(err)
    }

    func testSendEmailConfirm() throws {
        try self.testRegister()
        let (_, err) = await(th.stitchClient!.sendEmailConfirm(toEmail: testEmail))
        XCTAssertNil(err)
    }

    func testSendResetPassword() throws {
        try self.testRegister()
        let (_, err) = await(th.stitchClient!.sendResetPassword(toEmail: testEmail))
        XCTAssertNil(err)
    }
}
