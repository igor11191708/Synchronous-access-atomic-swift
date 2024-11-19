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
