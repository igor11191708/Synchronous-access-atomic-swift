//
//  OperationQueueCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class OperationQueueCounter: ICounter, @unchecked Sendable {
    
    /// The counter value shared across threads.
    /// Access to this value is synchronized through an `OperationQueue`.
    var value: Int = 0

    /// An operation queue used to serialize access to the `value`.
    /// By limiting the maximum concurrent operations to 1, this ensures thread-safe updates.
    let operationQueue = OperationQueue()

    /// Initializes the counter.
    ///
    /// Sets the maximum number of concurrent operations to 1,
    /// ensuring sequential execution of operations and preventing race conditions.
    init() {
        operationQueue.maxConcurrentOperationCount = 1
    }

    /// Increments the counter value by 1.
    ///
    /// Adds an operation to the `operationQueue` to increment the `value`.
    /// The serialized nature of the queue ensures that no two operations
    /// can access or modify `value` simultaneously.
    func increase() {
        operationQueue.addOperation {
            self.value += 1
        }
    }

    /// Retrieves the current value of the counter.
    ///
    /// Adds a read operation to the `operationQueue` and waits for it to finish
    /// before returning the result. This ensures the read operation is synchronized
    /// with any pending write operations.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        var currentValue: Int = 0
        let operation = BlockOperation {
            currentValue = self.value
        }
        operationQueue.addOperations([operation], waitUntilFinished: true)
        return currentValue
    }
}
