//
//  Storage.swift
//  StitchCore
//
//  Created by Jason Flax on 1/2/18.
//  Copyright © 2018 MongoDB. All rights reserved.
//

import Foundation

public protocol Storage {
    func get<T>(forKey key: String) -> T?
    func set(_ value: Any, forKey key: String)
    func remove(forKey key: String)
}

internal class MemoryStorage: Storage {
    private var storage: [String: Any] = [:]
    func get<T>(forKey key: String) -> T? {
        guard let obj = self.storage[key],
            let val = obj as? T else {
            return nil
        }

        return val
    }

    func set(_ value: Any, forKey key: String) {
        self.storage[key] = value
    }

    func remove(forKey key: String) {
        self.storage.removeValue(forKey: key)
    }
}

extension UserDefaults: Storage {
    public func get<T>(forKey key: String) -> T? {
        guard let obj = self.object(forKey: key),
            let val = obj as? T else {
            return nil
        }
        return val
    }

    public func set(_ value: Any, forKey key: String) {
        self.setValue(_: value, forKey: key)
    }

    public func remove(forKey key: String) {
        self.removeObject(forKey: key)
    }
}
