//
//  PThreadMutexCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class PThreadMutexCounter: ISyncCounter, @unchecked Sendable {

    /// The counter value shared across threads.
    /// Access to this value is synchronized using a POSIX `pthread_mutex_t`.
    var value: Int = 0

    /// A POSIX mutex used to synchronize access to `value`.
    /// This provides low-level thread-safe locking and unlocking.
    var mutex = pthread_mutex_t()

    /// Initializes the counter and sets up the `pthread_mutex_t`.
    ///
    /// The `pthread_mutex_init` function initializes the mutex,
    /// ensuring it is ready for use.
    init() {
        pthread_mutex_init(&mutex, nil)
    }

    /// Destroys the mutex when the counter is deallocated.
    ///
    /// The `pthread_mutex_destroy` function ensures the resources
    /// associated with the mutex are released.
    deinit {
        pthread_mutex_destroy(&mutex)
    }

    /// Increments the counter value by 1.
    ///
    /// This method locks the mutex before modifying `value`,
    /// ensuring that no other thread can access `value` during the operation.
    /// The mutex is unlocked immediately after the modification.
    func increase() {
        pthread_mutex_lock(&mutex)  // Acquire the lock
        value += 1                  // Modify the value
        pthread_mutex_unlock(&mutex) // Release the lock
    }

    /// Retrieves the current value of the counter.
    ///
    /// This method locks the mutex before reading `value`,
    /// ensuring that no other thread can modify `value` during the read operation.
    /// The mutex is unlocked immediately after the read.
    ///
    /// - Returns: The current value of the counter.
    var getValue: Int {
        pthread_mutex_lock(&mutex)         // Acquire the lock
        let currentValue = value           // Read the value
        pthread_mutex_unlock(&mutex)       // Release the lock
        return currentValue
    }
}
