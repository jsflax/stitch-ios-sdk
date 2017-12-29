//
//  StitchAdminClient.swift
//  StitchCore
//
//  Created by Jason Flax on 12/18/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import PromiseKit
import StitchLogger
import ExtendedJson

enum AdminOps {
    case list, get, remove, update, create
}

public class BoxedView<Model: Codable> {
    fileprivate let httpClient: StitchHTTPClient
    fileprivate let url: String

    fileprivate var _list: () -> Promise<[Model]> = { fatalError("list not enabled") }
    fileprivate var _get: () -> Promise<Model> = { fatalError("get not enabled") }
    fileprivate var _remove: () -> Promise<Void> = { fatalError("remove not enabled") }
    fileprivate var _update: (_ data: Model) -> Promise<Model> = { _ in fatalError("update not enabled") }
    fileprivate var _create: (_ data: Model) -> Promise<Model> = { _ in fatalError("create not enabled") }

    fileprivate init(_ httpClient: StitchHTTPClient,
                     _ url: String,
                     ops: AdminOps...) {
        self.httpClient = httpClient
        self.url = url

        for op in ops {
            switch op {
            case .list: self._list = {
                httpClient.doRequest {
                    $0.endpoint = url
                }.flatMap {
                    return try JSONDecoder().decode([Model].self,
                                                    from: JSONSerialization.data(withJSONObject: $0))
                }
            }
            case .get: self._get = {
                return httpClient.doRequest {
                    $0.endpoint = url
                }.flatMap {
                    return try JSONDecoder().decode(Model.self,
                                                    from: JSONSerialization.data(withJSONObject: $0))
                }
            }
            case .remove: self._remove = {
                return httpClient.doRequest {
                    $0.endpoint = url
                    $0.method = .delete
                }.asVoid()
            }
            case .update: self._update = { (data: Model) -> Promise<Model> in
                return httpClient.doRequest {
                    $0.endpoint = url
                    $0.method = .put
                    try $0.encode(withData: data)
                }.flatMap {
                        return try JSONDecoder().decode(Model.self,
                                                        from: JSONSerialization.data(withJSONObject: $0))
                }
            }
            case .create: self._create = {  (data: Model) -> Promise<Model> in
                return httpClient.doRequest {
                    $0.endpoint = url
                    $0.method = .post
                    try $0.encode(withData: data)
                }.flatMap {
                    return try JSONDecoder().decode(Model.self,
                                                    from: JSONSerialization.data(withJSONObject: $0))
                }
            }
            }
        }
    }
}


public struct AnyUser: Codable {
    let email: String?
    let password: String?

    public init(email: String?, password: String?) {
        self.email = email
        self.password = password
    }
}
public struct Value: Codable {

}
public struct App: Codable, Equatable {
    public static func ==(lhs: App, rhs: App) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id", name, clientAppId = "client_app_id"
    }
    public let id: String?
    public let clientAppId: String?
    let name: String

    public init(name: String,
                clientAppId: String? = nil,
                id: String? = nil) {
        self.id = id
        self.name = name
        self.clientAppId = clientAppId
    }
}
public struct AnyAuthProvider: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, config, type, disabled
    }
    let id: String?
    let name: String?
    let config: Document
    let type: String
    let disabled: Bool?

    public init(type: String,
                config: Document,
                id: String? = nil,
                name: String? = nil,
                disabled: Bool? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.config = config
        self.disabled = disabled
    }
}

public final class ValueView: BoxedView<Value> {
    public lazy var get = self._get
    public lazy var remove = self._remove
    public lazy var update = self._update

    fileprivate init(httpClient: StitchHTTPClient,
                     valueUrl: String) {
        super.init(httpClient, valueUrl, ops: .get, .remove, .update)
    }
}

public final class ValuesView: BoxedView<Value> {
    typealias Model = Value

    public lazy var list = self._list
    public lazy var create = self._create

    fileprivate init(httpClient: StitchHTTPClient,
                     appUrl: String) {
        super.init(httpClient, appUrl, ops: .list, .create)
    }

    func value(withId id: String) -> ValueView {
        return ValueView.init(httpClient: self.httpClient, valueUrl: "\(url)/\(id)")
    }
}

public final class AuthProviderView: BoxedView<AnyAuthProvider> {
    typealias Model = AnyAuthProvider

    public lazy var get = self._get
    public lazy var update = self._update
    public lazy var remove = self._remove

    fileprivate init(httpClient: StitchHTTPClient,
                     authProviderUrl: String) {
        super.init(httpClient, authProviderUrl, ops: .get, .update, .remove)
    }
}

public final class AuthProvidersView: BoxedView<AnyAuthProvider> {
    typealias Model = AnyAuthProvider

    public lazy var list = self._list
    public lazy var create = self._create

    fileprivate init(httpClient: StitchHTTPClient,
                     authProvidersUrl: String) {
        super.init(httpClient, authProvidersUrl, ops: .list, .create)
    }

    func authProvider(withId id: String) -> AuthProviderView {
        return AuthProviderView.init(httpClient: self.httpClient, authProviderUrl: "\(url)/\(id)")
    }
}

public final class UserView: BoxedView<AnyUser> {
    typealias Model = AnyUser

    public lazy var get = self._get
    public lazy var remove = self._remove

    fileprivate init(httpClient: StitchHTTPClient,
                     userUrl: String) {
        super.init(httpClient, userUrl, ops: .get, .remove)
    }
}

public final class UsersView: BoxedView<AnyUser> {
    typealias Model = AnyUser

    public lazy var list = self._list
    public lazy var create = self._create

    fileprivate init(httpClient: StitchHTTPClient,
                     usersUrl: String) {
        super.init(httpClient, usersUrl, ops: .list, .create)
    }

    public func user(withId id: String) -> UserView {
        return UserView.init(httpClient: self.httpClient, userUrl: "\(url)/\(id)")
    }
}

public final class AppView: BoxedView<App> {
    typealias Model = App

    public lazy var get = self._get
    public lazy var remove = self._remove

    fileprivate init(httpClient: StitchHTTPClient,
                     appUrl: String) {
        super.init(httpClient, appUrl, ops: .get, .remove)
    }

    public var values: ValuesView {
        return ValuesView.init(httpClient: httpClient, appUrl: "\(url)/values")
    }

    public var authProviders: AuthProvidersView {
        return AuthProvidersView.init(httpClient: httpClient, authProvidersUrl: "\(url)/auth_providers")
    }

    public var users: UsersView {
        return UsersView.init(httpClient: httpClient, usersUrl: "\(url)/users")
    }
}

public final class AppsView: BoxedView<App> {
    typealias Model = App

    public lazy var list: () -> Promise<[App]> = self._list

    fileprivate init(httpClient: StitchHTTPClient,
                     groupUrl: String) {
        super.init(httpClient, groupUrl, ops: .list)
    }

    public func create(data: App, defaults: Bool = false) -> Promise<App> {
        return httpClient.doRequest {
            $0.endpoint = "\(self.url)?defaults=\(defaults)"
            $0.method = .post
            try $0.encode(withData: data)
        }.flatMap {
                return try JSONDecoder().decode(Model.self,
                                                from: JSONSerialization.data(withJSONObject: $0))
        }
    }

    public func app(withAppId appId: String) -> AppView {
        return AppView.init(httpClient: self.httpClient, appUrl: "\(url)/\(appId)")
    }
}

public class StitchAdminClient {
    let baseUrl: String
    let httpClient: StitchHTTPClient
    internal lazy var routes = StitchClient.Routes(appId: "")

    public init(baseUrl: String) {
        self.baseUrl = baseUrl
        self.httpClient = StitchHTTPClient.init(baseUrl: baseUrl,
                                                networkAdapter: StitchNetworkAdapter(),
                                                isAdmin: true)
    }

    public func apps(withGroupId groupId: String) -> AppsView {
        return AppsView.init(httpClient: httpClient, groupUrl: "groups/\(groupId)/apps")
    }

    /**
     Logs the current user in using a specific auth provider.

     - Parameters:
     - withProvider: The provider that will handle the login.
     - link: Whether or not to link a new auth provider.
     - Returns: A task containing whether or not the login as successful
     */
    @discardableResult
    private func login(withProvider provider: AuthProvider) -> Promise<UserId> {
        if self.httpClient.isAuthenticated {
            printLog(.info, text: "Already logged in, using cached token.")
            return Promise.init(value: self.httpClient.authInfo!.userId)
        }

        return httpClient.doRequest {
            $0.method = .post
            $0.endpoint = "auth/providers/\(provider.type)/login"
            $0.isAuthenticatedRequest = false
            try $0.encode(withData: provider.payload)
        }.flatMap { [weak self] any in
                guard let strongSelf = self else { throw StitchError.clientReleased }
                let authInfo = try JSONDecoder().decode(AuthInfo.self,
                                                        from: JSONSerialization.data(withJSONObject: any))
                strongSelf.httpClient.authInfo = authInfo
                return authInfo.userId
        }
    }

    public func authenticate(apiKey: String) -> Promise<UserId> {
        return login(withProvider: ApiKeyAuthProvider.init(key: apiKey))
    }
}
