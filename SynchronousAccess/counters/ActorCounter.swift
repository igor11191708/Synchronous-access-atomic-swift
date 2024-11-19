//
//  ActorCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

actor ActorCounter: Sendable {
    
    /// The counter value stored in the actor.
    /// Access to this value is isolated to the actor, ensuring thread safety.
    var value: Int = 0

    /// Increments the counter value by 1.
    ///
    /// Since this method runs within the actor's concurrency domain,
    /// it is inherently thread-safe. Multiple callers will execute this
    /// function sequentially, ensuring no race conditions occur.
    func increase() {
        value += 1
    }

    /// Retrieves the current value of the counter.
    ///
    /// Reading this value is safe because the actor isolates access
    /// to the `value` property. The value can only be accessed within
    /// the actor's concurrency domain.
    var getValue: Int {
        return value
    }
}
