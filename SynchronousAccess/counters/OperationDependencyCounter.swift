//
//  OperationDependencyCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class OperationDependencyCounter: ICounter, @unchecked Sendable {
    /// The shared counter value that will be incremented.
    var value: Int = 0

    /// An operation queue responsible for managing and executing operations asynchronously.
    let operationQueue = OperationQueue()

    /// Tracks the last operation added to the operation queue.
    /// Used to ensure sequential execution of operations through dependencies.
    var lastOperation: Operation?

    /// A concurrent dispatch queue used to synchronize access to `value` and `lastOperation`.
    /// Ensures thread-safe reads and writes by using barrier flags.
    let syncQueue = DispatchQueue(label: "my.example.OperationDependencyCounter", attributes: .concurrent)

    /// Increments the counter value by creating a new operation.
    ///
    /// The method ensures that:
    /// - Operations modifying the counter execute sequentially.
    /// - Access to shared resources (`value` and `lastOperation`) is thread-safe.
    ///
    /// Each operation is added to the `operationQueue` with a dependency on the last operation.
    func increase() {
        // Create a new operation to increment the counter.
        let operation = BlockOperation {
            // Use a barrier block to safely increment `value`.
            // Ensures that no other read or write operation can occur concurrently.
            self.syncQueue.sync(flags: .barrier) {
                self.value += 1
            }
        }
        
        // Synchronize access to `lastOperation` to safely manage dependencies.
        syncQueue.sync(flags: .barrier) {
            // If there is an existing operation, add it as a dependency for the new operation.
            if let lastOp = lastOperation {
                operation.addDependency(lastOp)
            }
            // Update `lastOperation` to the current operation.
            lastOperation = operation
        }

        // Add the operation to the operation queue for execution.
        operationQueue.addOperation(operation)
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method waits for all operations in the `operationQueue` to complete
    /// before returning the value. The read operation is thread-safe.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        // Wait for all pending operations in the queue to finish.
        operationQueue.waitUntilAllOperationsAreFinished()

        // Safely read the current value using a synchronized block.
        return syncQueue.sync { value }
    }
}
