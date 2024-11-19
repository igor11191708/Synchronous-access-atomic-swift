//
//  SerialQueueCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

/// A counter implementation that uses a serial `DispatchQueue` to synchronize access to the shared `value`.
/// The serial queue ensures that only one operation is executed at a time, making all modifications and reads of `value` thread-safe.
final class SerialQueueCounter: ICounter, @unchecked Sendable {
    
    /// The counter value shared across threads.
    /// Access to this value is synchronized using a serial `DispatchQueue`.
    var value: Int = 0
    
    /// A serial `DispatchQueue` used to synchronize access to the `value`.
    /// Only one block of code can execute at a time on this queue,
    /// effectively ensuring thread-safe access to the shared resource.
    let queue = DispatchQueue(label: "my.example.counterQueue")
    
    /// Increments the counter value by 1.
    ///
    /// The increment operation is performed synchronously on the serial queue,
    /// ensuring that no other read or write operations can occur concurrently.
    func increase() {
        queue.sync {
            value += 1
        }
    }
    
    /// Retrieves the current value of the counter.
    ///
    /// The read operation is performed synchronously on the serial queue,
    /// ensuring that the value is consistent and not being modified concurrently.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        return queue.sync {
            value
        }
    }
}
