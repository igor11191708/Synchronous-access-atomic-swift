//
//  WorkItemCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

/// A counter implementation that uses `DispatchWorkItem` and `DispatchGroup` to synchronize access to the shared `value`.
/// The combination of a serial `DispatchQueue` and `DispatchGroup` ensures thread-safe updates and reads of `value`.
final class WorkItemCounter: ICounter, @unchecked Sendable {

    /// The counter value shared across threads.
    /// Access to this value is synchronized using `DispatchWorkItem` and `DispatchGroup`.
    var value: Int = 0

    /// A serial `DispatchQueue` used to manage and execute `DispatchWorkItem` operations.
    /// Ensures that operations are executed sequentially and thread-safe.
    let queue = DispatchQueue(label: "my.example.workItemQueue")

    /// A `DispatchGroup` used to track and wait for the completion of all ongoing operations.
    /// Guarantees that `getValue` returns a consistent value only after all pending updates are finished.
    let group = DispatchGroup()

    /// Increments the counter value by 1.
    ///
    /// A `DispatchWorkItem` is created to increment the `value`. The work item is added to the `queue` and
    /// tracked by the `group`. This ensures sequential execution and proper synchronization.
    func increase() {
        group.enter() // Notify the group that a new operation is starting
        let workItem = DispatchWorkItem {
            self.value += 1       // Increment the value
            self.group.leave()    // Notify the group that the operation is finished
        }
        queue.async(execute: workItem) // Schedule the work item for execution
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method waits for all pending operations tracked by the `group` to complete before reading the `value`.
    /// The read operation is performed synchronously on the `queue` to ensure thread safety.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        group.wait() // Wait for all pending operations to complete
        var currentValue: Int = 0
        queue.sync {
            currentValue = self.value // Safely read the value
        }
        return currentValue
    }
}
