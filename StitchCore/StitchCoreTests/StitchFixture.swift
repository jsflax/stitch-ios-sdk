//
//  StitchFixture.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/23/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import MongoKitten
import CryptoKitten
import StitchCore
import PromiseKit

let defaultUri = "mongodb://localhost:26000/test"
let defaultServerUrl = "http://localhost:9090"

private func randomString(_ length: Int) -> String {
    let chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".map { $0 }
    var result = "";
    for _ in stride(from: length, to: 0, by: -1) {
        result += String(chars[Int(arc4random_uniform(UInt32(chars.count - 1)))])
    }
    return result
}

let testSalt = "DQOWene1723baqD!_@#"
private func hashValue(key: String, salt: String) throws -> String {
    return try PBKDF2_HMAC<SHA256>.derive(fromPassword: [UInt8].init(key.data(using: .utf8)!),
                                          saltedWith: [UInt8].init(salt.data(using: .utf8)!),
                                          iterating: 4096, derivedKeyLength: 32).hexString
}

private func generateTestRootUser() throws -> Document {
    let rootId = try ObjectId("000000000000000000000000")
    let rootProviderId = try ObjectId("000000000000000000000001")
    let apiKeyId = ObjectId()
    let userId = ObjectId().hexString
    let groupId = ObjectId().hexString
    let testUser: Document = [
        "userId": ObjectId().hexString,
        "domainId": rootId,
        "identities": [ [ "id": apiKeyId.hexString, "providerType": "api-key", "providerId": rootProviderId ] ],
        "roles": [["roleName": "groupOwner", "groupId": groupId]]
    ]

    let key = randomString(64)
    let hashedKey = try hashValue(key: key, salt: testSalt)

    let testAPIKey: Document = [
        "_id": apiKeyId,
        "domainId": rootId,
        "userId": userId,
        "appId": rootId,
        "key": key,
        "hashedKey": hashedKey,
        "name": apiKeyId.description,
        "disabled": false,
        "visible": true
    ]

    let testGroup: Document = [
        "domainId": rootId,
        "groupId": groupId
    ]

    return [ "user": testUser, "apiKey": testAPIKey, "group": testGroup ]
}

internal class StitchFixture {
    private struct Namespace {
        let db: String
        let collection: String
    }

    private let baseUrl: String
    private let server: Server
    private let userData: Document
    var admin: StitchAdminClient
    private var testNamespaces: [Namespace] = []

    static func newFixture(withMongoUri mongoUri: String = defaultUri,
                           withBaseUrl baseUrl: String = defaultServerUrl) throws -> Promise<StitchFixture> {
        let fixture = try StitchFixture(mongoUri, baseUrl)
        return fixture.admin.authenticate(apiKey: (fixture.userData["apiKey"] as! Document)["key"] as! String).flatMap { _ in
            return fixture
        }
    }

    private init(_ mongoUri: String = defaultUri, _ baseUrl: String = defaultServerUrl) throws {
        self.server = try Server.init(mongoUri)
        self.baseUrl = baseUrl

        // bootstrap auth database with a root user
        let userData = try generateTestRootUser()
        try self.server["auth"]["users"].insert(userData["user"] as! Document)
        try self.server["auth"]["apiKeys"].insert(userData["apiKey"] as! Document)
        try self.server["auth"]["groups"].insert(userData["group"] as! Document)
        self.userData = userData

        self.admin = StitchAdminClient(baseUrl: self.baseUrl)
    }

    public func extractDataPoints() -> (String, String, String) {
        return (((userData["apiKey"] as! Document)["key"] as! String),
        ((userData["group"] as! Document)["groupId"] as! String),
        baseUrl)
    }
    
    deinit {
        if self.server.isConnected {
            do {
                try self.server.disconnect()
            } catch {
                print("Error disconnecting")
            }
        }
    }

    internal func registerTestNamespace(db: String, collection: String) {
        self.testNamespaces.append(Namespace(db: db,
                                             collection: collection))
    }

    internal func cleanTestNamespaces() throws {
        try self.testNamespaces.forEach {
            try self.server[$0.db][$0.collection].remove()
        }
        self.testNamespaces.removeAll()
    }
}
