//
//  DispatchSemaphoresCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class DispatchSemaphoresCounter: ISyncCounter, @unchecked Sendable {
    
    /// The counter value shared across multiple threads.
    /// Access to this value is synchronized using a semaphore.
    var value: Int = 0
    
    /// A semaphore to control access to the `value`.
    /// It ensures only one thread can modify or read the `value` at a time.
    let semaphore = DispatchSemaphore(value: 1)
    
    /// A concurrent dispatch queue used for asynchronous operations.
    /// Tasks can be executed concurrently, but access to `value` is controlled by the semaphore.
    let queue = DispatchQueue(label: "my.queue.Example", attributes: .concurrent)
    
    /// Increments the counter value by 1.
    ///
    /// The operation is executed asynchronously on the `queue`, and access to `value`
    /// is synchronized using the semaphore to ensure thread safety.
    func increase() {
        queue.async {
            self.semaphore.wait() // Acquire semaphore
            self.value += 1       // Modify the value
            self.semaphore.signal() // Release semaphore
        }
    }
    
    /// Retrieves the current value of the counter.
    ///
    /// This method waits for the semaphore to ensure exclusive access to `value`,
    /// reads the current value, and then releases the semaphore.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        semaphore.wait()           // Acquire semaphore
        let currentValue = value   // Read value
        semaphore.signal()         // Release semaphore
        return currentValue
    }
    
    /// Retrieves the current value of the counter asynchronously.
    ///
    /// The operation is executed on the `queue`, and the current value is passed to the
    /// provided callback closure. Access to `value` is synchronized using the semaphore.
    ///
    /// - Parameter callback: A closure that receives the current value of the counter.
    func getValue(callback: @escaping (Int) -> Void) {
        queue.async {
            self.semaphore.wait()              // Acquire semaphore
            let currentValue = self.value      // Read value
            self.semaphore.signal()            // Release semaphore
            callback(currentValue)             // Call the callback with the value
        }
    }
}
