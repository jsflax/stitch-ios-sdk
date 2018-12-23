import Foundation
import Dispatch

public class ReadWriteLock {
    private let queue: DispatchQueue
    private let preconditionKey = DispatchSpecificKey<ObjectIdentifier>()

    public init(label: String) {
        self.queue = DispatchQueue(label: label, attributes: .concurrent)
        queue.setSpecific(key: preconditionKey, value: ObjectIdentifier(self))

    }

    public func read<T>(_ closure: () -> T) -> T {
        return self.queue.sync(execute: closure)
    }

    public func read<T>(_ closure: () throws -> T) rethrows -> T {
        return try self.queue.sync(execute: closure)
    }

    public func write<T>(_ closure: () -> T) -> T {
        return self.queue.sync(flags: .barrier, execute: closure)
    }

    public func write<T>(_ closure: () throws -> T) rethrows -> T {
        return try self.queue.sync(flags: .barrier, execute: closure)
    }

    public func assertLocked() {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            dispatchPrecondition(condition: .onQueue(queue))
        }
        else {
            precondition(DispatchQueue.getSpecific(key: preconditionKey) == ObjectIdentifier(self))
        }
    }

    public func assertWriteLocked() {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            dispatchPrecondition(condition: .onQueueAsBarrier(queue))
        }
        else {
            precondition(DispatchQueue.getSpecific(key: preconditionKey) == ObjectIdentifier(self))
        }
    }

    public func assertUnlocked() {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            dispatchPrecondition(condition: .notOnQueue(queue))
        }
        else {
            precondition(DispatchQueue.getSpecific(key: preconditionKey) != ObjectIdentifier(self))
        }
    }
}
