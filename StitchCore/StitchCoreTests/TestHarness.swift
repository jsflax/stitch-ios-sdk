//
//  TestHarness.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/23/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import StitchCore
import PromiseKit
import ExtendedJson

internal struct UserpassConfig: Codable {
    let emailConfirmationUrl: String
    let resetPasswordUrl: String
    let confirmEmailSubject: String
    let resetPasswordSubject: String
}

internal class TestHarness {
    private let apiKey, groupId, serverUrl: String
    public let adminClient: StitchAdminClient
    public var stitchClient: StitchClient?
    private var testApp: App?
    private var userCredentials: EmailPasswordAuthProvider? = nil
    private var user: AnyUser?

    public static func newAdminHarness(isSeedTestApp: Bool, apiKey: String, groupId: String, serverUrl: String) -> Promise<TestHarness> {
        let harness = TestHarness.init(apiKey: apiKey, groupId: groupId, serverUrl: serverUrl)
        return harness.authenticate().then { _ -> Promise<App> in
            if isSeedTestApp {
                return harness.createApp()
            }
            return Promise.init(value: App.init(name: ""))
        }.flatMap { _ -> TestHarness in
            return harness
        }
    }

    private init(apiKey: String, groupId: String, serverUrl: String = defaultServerUrl) {
        self.apiKey = apiKey
        self.groupId = groupId
        self.serverUrl = serverUrl
        self.adminClient = StitchAdminClient(baseUrl: self.serverUrl)
    }

    func authenticate() -> Promise<UserId> {
        return self.adminClient.authenticate(apiKey: self.apiKey)
    }

    func configureUserpass(userpassConfig: UserpassConfig = UserpassConfig(
        emailConfirmationUrl: "http://emailConfirmURL.com",
        resetPasswordUrl: "http://resetPasswordURL.com",
        confirmEmailSubject: "email subject",
        resetPasswordSubject: "password subject"
    )) throws -> Promise<AnyAuthProvider> {
        return self.app.authProviders.create(AnyAuthProvider(
            type: "local-userpass",
            config: try BSONEncoder().encode(userpassConfig)
        ))
    }

    func createApp(testAppName: String = "test-app") -> Promise<App> {
        return self.apps.create(data: App(name: testAppName)).get {
            self.testApp = $0
        }
    }

    func createUser(email: String = "test_user@domain.com", password: String = "password") -> Promise<AnyUser> {
        self.userCredentials = EmailPasswordAuthProvider.init(username: email, password: password)
        return self.app.users.create(AnyUser.init(email: email, password: password)).get {
            self.user = $0
        }
    }

    func setupStitchClient() throws -> Promise<UserId> {
        return try self.configureUserpass().then { _ -> Promise<AnyUser> in
            return self.createUser()
        }.then { _ -> Promise<UserId> in
            self.stitchClient = StitchClient(appId: self.testApp!.clientAppId!, baseUrl: self.serverUrl)
            return self.stitchClient!.login(withProvider: self.userCredentials!)
        }
    }

    func cleanup() -> Promise<Void> {
        if self.testApp != nil {
            return self.appRemove()
        }

        return Promise.init(value: Void())
    }

    var apps: AppsView {
        return self.adminClient.apps(withGroupId: self.groupId)
    }

    var app: AppView {
        return self.apps.app(withAppId: self.testApp!.id!)
    }

    func appRemove() -> Promise<Void> {
        return self.app.remove().done { _ in
            self.testApp = nil
        }
    }
}
