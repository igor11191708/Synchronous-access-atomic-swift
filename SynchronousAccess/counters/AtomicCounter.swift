//
//  AtomicCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class AtomicCounter: ICounter, @unchecked Sendable {
    
    @Atomic var value: Int = 0

    func increase() {
        $value.mutate { $0 += 1 }
    }

    var getValue: Int {
        return value
    }
}

@propertyWrapper
struct Atomic<Value> {
    
    private var ref: AtomicReference<Value>

    init(wrappedValue: Value) {
        self.ref = AtomicReference(value: wrappedValue)
    }

    var wrappedValue: Value {
        get {
            ref.lock.lock()
            defer { ref.lock.unlock() }
            return ref.value
        }
        set {
            ref.lock.lock()
            ref.value = newValue
            ref.lock.unlock()
        }
    }

    var projectedValue: Atomic<Value> {
        return self
    }

    func mutate(_ mutation: (inout Value) -> Void) {
        ref.lock.lock()
        mutation(&ref.value)
        ref.lock.unlock()
    }
}

fileprivate final class AtomicReference<Value> {
    
    var value: Value
    
    let lock = NSLock()

    init(value: Value) {
        self.value = value
    }
}
