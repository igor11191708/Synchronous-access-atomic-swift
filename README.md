# Synchronize Access to Mutable State

1. Using a Serial Dispatch Queue

```swift
final class Counter: Sendable {
    private var value: Int = 0
    private let queue = DispatchQueue(label: "com.example.counterQueue")

    func increase() {
        queue.sync {
            value += 1
        }
    }

    func getValue() -> Int {
        return queue.sync {
            value
        }
    }
}
```

2. Using Locks (NSLock)
```swift
final class Counter: Sendable {
    private var value: Int = 0
    private let lock = NSLock()

    func increase() {
        lock.lock()
        value += 1
        lock.unlock()
    }

    func getValue() -> Int {
        lock.lock()
        let currentValue = value
        lock.unlock()
        return currentValue
    }
}
```

