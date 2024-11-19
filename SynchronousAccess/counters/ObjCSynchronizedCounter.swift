//
//  ObjCSynchronizedCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class ObjCSynchronizedCounter: ICounter, @unchecked Sendable {

    /// The counter value that is shared across threads.
    /// Access to this value is synchronized using Objective-C's `objc_sync_enter` and `objc_sync_exit`.
    var value: Int = 0

    /// An `NSObject` instance used as a synchronization lock.
    /// This acts as the monitor object for the Objective-C synchronization mechanism.
    let lock = NSObject()

    /// Increments the counter value by 1.
    ///
    /// The method uses `objc_sync_enter` to acquire a lock on the `lock` object
    /// before modifying the `value`. The lock is released using `objc_sync_exit` after the operation.
    func increase() {
        objc_sync_enter(lock) // Acquire the lock
        value += 1            // Modify the value
        objc_sync_exit(lock)  // Release the lock
    }

    /// Retrieves the current value of the counter.
    ///
    /// The method uses `objc_sync_enter` to acquire a lock on the `lock` object
    /// before reading the `value`. The lock is released using `objc_sync_exit` after the operation.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        objc_sync_enter(lock)           // Acquire the lock
        let currentValue = value        // Read the value
        objc_sync_exit(lock)            // Release the lock
        return currentValue
    }
}
