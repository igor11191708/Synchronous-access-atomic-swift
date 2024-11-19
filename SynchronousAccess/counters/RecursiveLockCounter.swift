//
//  RecursiveLockCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class RecursiveLockCounter: ICounter, @unchecked Sendable {

    /// The counter value shared across threads.
    /// Access to this value is synchronized using an `NSRecursiveLock`.
    var value: Int = 0

    /// An `NSRecursiveLock` instance used to synchronize access to `value`.
    /// Recursive locks allow the same thread to acquire the lock multiple times
    /// without causing a deadlock.
    let lock = NSRecursiveLock()

    /// Increments the counter value by 1.
    ///
    /// This method locks the `NSRecursiveLock` before modifying `value`,
    /// ensuring that no other thread can access `value` during the operation.
    /// The lock is released immediately after the modification.
    func increase() {
        lock.lock()       // Acquire the lock
        value += 1        // Modify the value
        lock.unlock()     // Release the lock
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method locks the `NSRecursiveLock` before reading `value`,
    /// ensuring that no other thread can modify `value` during the read operation.
    /// The lock is released immediately after the read.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        lock.lock()               // Acquire the lock
        let currentValue = value  // Read the value
        lock.unlock()             // Release the lock
        return currentValue
    }
}
