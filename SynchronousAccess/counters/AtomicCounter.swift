//
//  AtomicCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import Foundation

final class AtomicCounter: ISyncCounter, @unchecked Sendable {
    
    /// The shared counter value, protected by the `Atomic` property wrapper for thread safety.
    @Atomic var value: Int = 0

    /// Increments the counter value atomically.
    ///
    /// This method uses the `mutate` function provided by the `Atomic` wrapper to ensure
    /// thread-safe access and modification of the `value`.
    func increase() {
        $value.mutate { $0 += 1 }
    }

    /// Retrieves the current value of the counter.
    ///
    /// The `value` property is accessed through the `Atomic` wrapper, ensuring thread-safe
    /// reads.
    var getValue: Int {
        return value
    }
}

@propertyWrapper
struct Atomic<Value> {
    
    /// A reference type that holds the value and a lock to protect it.
    private var ref: AtomicReference<Value>

    /// Initializes the property wrapper with an initial value.
    ///
    /// - Parameter wrappedValue: The initial value to store, which will be thread-safe.
    init(wrappedValue: Value) {
        self.ref = AtomicReference(value: wrappedValue)
    }

    /// Provides thread-safe access to the wrapped value.
    var wrappedValue: Value {
        get {
            // Locks access to the value for reading, ensuring no other thread writes simultaneously.
            ref.lock.lock()
            defer { ref.lock.unlock() }
            return ref.value
        }
        set {
            // Locks access to the value for writing, ensuring no other thread reads or writes simultaneously.
            ref.lock.lock()
            ref.value = newValue
            ref.lock.unlock()
        }
    }

    /// Exposes the property wrapper instance itself through `$` syntax.
    ///
    /// This allows external code to access additional methods, such as `mutate`, for thread-safe operations.
    var projectedValue: Atomic<Value> {
        return self
    }

    /// Performs a thread-safe mutation of the value.
    ///
    /// - Parameter mutation: A closure that modifies the value. The closure is executed
    ///   while holding a lock to ensure atomicity.
    func mutate(_ mutation: (inout Value) -> Void) {
        ref.lock.lock()
        mutation(&ref.value)
        ref.lock.unlock()
    }
}

fileprivate final class AtomicReference<Value> {
    
    /// The value being protected by the lock.
    var value: Value
    
    /// An `NSLock` instance that ensures thread-safe access to the `value`.
    let lock = NSLock()

    /// Initializes the reference with an initial value.
    ///
    /// - Parameter value: The initial value to store in the reference.
    init(value: Value) {
        self.value = value
    }
}
