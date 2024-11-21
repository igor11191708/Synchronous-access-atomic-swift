//
//  LockCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class LockCounter: ISyncCounter, @unchecked Sendable {

    /// The counter value that is shared and modified across multiple threads.
    /// Access to this value is synchronized using a lock.
    var value: Int = 0

    /// An `NSLock` instance used to synchronize access to the `value`.
    /// Ensures that only one thread can access or modify the `value` at a time.
    let lock = NSLock()

    /// Increments the counter value by 1.
    ///
    /// This method uses the `NSLock` to ensure thread-safe access and modification
    /// of the `value`. The lock is acquired before incrementing and released afterward.
    func increase() {
        lock.lock()       // Acquire the lock
        value += 1        // Modify the value
        lock.unlock()     // Release the lock
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method uses the `NSLock` to ensure thread-safe access to the `value`.
    /// The lock is acquired before reading the value and released afterward.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        lock.lock()           // Acquire the lock
        let currentValue = value // Read the value
        lock.unlock()         // Release the lock
        return currentValue
    }
}
