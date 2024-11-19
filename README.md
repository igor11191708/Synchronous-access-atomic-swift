# Synchronize Access to Mutable State

1. Serial Dispatch Queue as Synchronization

```swift

final class SerialQueueCounter: ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "com.example.counterQueue")
    
    func increase() {
        queue.sync {
            value += 1
        }
    }
    
    var getValue: Int{
        return queue.sync{
            value
        }
    }
}

```

2. Locks (NSLock) as Synchronization

```swift

final class LockCounter: ICounter, @unchecked Sendable{
    
    var value : Int = 0
    
    let lock = NSLock()
    
    func increase() {
        lock.lock()
        value += 1
        lock.unlock()
    }
    
    var getValue : Int {
        lock.lock()
        let currentValue = value
        lock.unlock()
        return currentValue
    }
}
```

3. Concurrent Queue with Barrier  as Synchronization
```swift

final class ConcurrentQueueBarrierCounter : ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "com.example.counterQueue", attributes: .concurrent)
    
    /// Writes (increase()) are exclusive and block other operations until they complete.
    func increase() {
        queue.async(flags: .barrier){
            self.value += 1
        }
    }
    
    /// Reads (getValue()) can occur concurrently.
    var getValue: Int{
        return queue.sync{
            value
        }
    }
}
```

4. Atomic Property Wrapper as Synchronization

```swift

final class AtomicCounter: ICounter, @unchecked Sendable {
    @Atomic var value: Int = 0

    func increase() {
        $value.mutate { $0 += 1 }
    }

    var getValue: Int {
        return value
    }
}

```

5. Actors as Synchronization

```swift
actor ActorCounter: Sendable {
    
    var value : Int = 0

    func increase() {
        value += 1
    }

    var getValue: Int {
        return value
    }
}
```

6. Semaphore as Synchronization

```swift
final class SemaphoreCounter: ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let semaphore = DispatchSemaphore(value: 1)
    
    func increase() {
        semaphore.wait()
        value += 1
        semaphore.signal()
    }
    
    var getValue: Int{
        semaphore.wait()
        let currentValue = value
        semaphore.signal()
        return currentValue
    }
}

```

7. Dispatch Semaphores as Synchronization

```swift

final class DispatchSemaphoresCounter: Sendable {
    private var value: Int = 0
    private let semaphore = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue(label: "my.example.counterQueue", attributes: .concurrent)

    func increase() {
        queue.async {
            self.semaphore.wait()
            self.value += 1
            self.semaphore.signal()
        }
    }

    func getValue(completion: @escaping (Int) -> Void) {
        queue.async {
            self.semaphore.wait()
            let currentValue = self.value
            self.semaphore.signal()
            completion(currentValue)
        }
    }
}
```

8. os_unfair_lock as Synchronization

```swift
final class OsUnfairLockCounter : ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    var lock = os_unfair_lock_s()
    
    func increase() {
        os_unfair_lock_lock(&lock)
        value += 1
        os_unfair_lock_unlock(&lock)
    }
    
    var getValue: Int{
        os_unfair_lock_lock(&lock)
        let currentValue = value
        os_unfair_lock_unlock(&lock)
        return currentValue
    }    
}
```
