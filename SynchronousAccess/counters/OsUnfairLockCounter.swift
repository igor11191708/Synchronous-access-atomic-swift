//
//  OsUnfairLockCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class OsUnfairLockCounter: ICounter, @unchecked Sendable {
    
    /// The counter value shared across threads.
    /// Access to this value is synchronized using `os_unfair_lock`.
    var value: Int = 0
    
    /// An `os_unfair_lock_s` instance used for thread-safe access to `value`.
    /// This lock provides fast, low-level locking and is suitable for protecting shared resources.
    var lock = os_unfair_lock_s()

    /// Increments the counter value by 1.
    ///
    /// This method locks the `os_unfair_lock` before modifying the `value`,
    /// ensuring that no other thread can access `value` during the operation.
    /// The lock is released immediately after the modification.
    func increase() {
        os_unfair_lock_lock(&lock)  // Acquire the lock
        value += 1                  // Modify the value
        os_unfair_lock_unlock(&lock) // Release the lock
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method locks the `os_unfair_lock` before reading the `value`,
    /// ensuring that no other thread can modify `value` during the read operation.
    /// The lock is released immediately after reading the value.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        os_unfair_lock_lock(&lock)         // Acquire the lock
        let currentValue = value           // Read the value
        os_unfair_lock_unlock(&lock)       // Release the lock
        return currentValue
    }
}
