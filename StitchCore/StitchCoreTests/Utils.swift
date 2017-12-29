//
//  Utils.swift
//  StitchCoreTests
//
//  Created by Jason Flax on 12/28/17.
//  Copyright © 2017 MongoDB. All rights reserved.
//
import XCTest
import PromiseKit

extension XCTestCase {
    @discardableResult
    func await<T>(_ promise: Promise<T>,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) -> (T?, Error?) {
        let exp = expectation(description: "\(file)#\(function)#\(line)")
        var item: T?
        var err: Error?

        promise.done {
            item = $0
            exp.fulfill()
        }.catch {
            err = $0
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        return (item, err)
    }

    func trust<T>(_ promise: Promise<T>,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) throws -> T {
        let (itemM, err) = await(promise, file: file, function: function, line: line)
        guard let item = itemM else { throw err! }
        return item
    }
}
