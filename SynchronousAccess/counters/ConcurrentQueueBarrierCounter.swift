//
//  ConcurrentQueueBarrierCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class ConcurrentQueueBarrierCounter : ICounter, @unchecked Sendable {
    
    /// The counter value shared between threads.
    /// Access to this value is synchronized using a concurrent dispatch queue.
    var value: Int = 0
    
    /// A concurrent queue used to synchronize access to the `value`.
    /// Write operations are performed exclusively using barrier blocks,
    /// while read operations can occur concurrently.
    let queue = DispatchQueue(label: "my.example.counterQueue", attributes: .concurrent)
    
    /// Increments the counter value by 1.
    ///
    /// This operation uses a barrier block to ensure exclusive access
    /// to the `value` property. While the barrier block is executing,
    /// no other read or write operations can occur on the queue.
    func increase() {
        queue.async(flags: .barrier) {
            self.value += 1
        }
    }
    
    /// Retrieves the current value of the counter.
    ///
    /// This operation uses a synchronous read on the queue, allowing
    /// multiple threads to read the `value` concurrently without blocking each other.
    /// The synchronous nature ensures the read operation completes
    /// before the result is returned.
    var getValue: Int {
        return queue.sync {
            value
        }
    }
}
