//
//  ApiKeyAuthProvider.swift
//  StitchCore
//
//  Created by Jason Flax on 10/18/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//

import Foundation
import ExtendedJson

public struct ApiKeyAuthProvider: AuthProvider {
    private let key: String

    public var type: String = "api-key"
    public var name: String = "api-key"

    public var payload: Document {
        return ["key": key]
    }

    public init(key: String) {
        self.key = key
    }
}
