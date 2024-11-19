//
//  SemaphoreCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class SemaphoreCounter: ICounter, @unchecked Sendable {

    /// The counter value shared across threads.
    /// Access to this value is synchronized using a `DispatchSemaphore`.
    var value: Int = 0

    /// A semaphore used to control access to `value`.
    /// The semaphore ensures that only one thread can access or modify `value` at a time.
    let semaphore = DispatchSemaphore(value: 1)

    /// Increments the counter value by 1.
    ///
    /// This method waits to acquire the semaphore before modifying `value`,
    /// ensuring that no other thread can access or modify `value` during the operation.
    /// The semaphore is signaled (released) immediately after the modification.
    func increase() {
        semaphore.wait()       // Acquire the semaphore
        value += 1             // Modify the value
        semaphore.signal()     // Release the semaphore
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method waits to acquire the semaphore before reading `value`,
    /// ensuring that no other thread can modify `value` during the read operation.
    /// The semaphore is signaled (released) immediately after the read.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        semaphore.wait()               // Acquire the semaphore
        let currentValue = value       // Read the value
        semaphore.signal()             // Release the semaphore
        return currentValue
    }
}
