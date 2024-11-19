# Synchronize Access to Mutable State

## 1. Serial Dispatch Queue as Synchronization

**Advantages:**
- Simple implementation for thread safety.
- No risk of deadlocks; serial queue ensures exclusive execution.

**Disadvantages:**
- Synchronous execution can block the calling thread.
- May lead to performance bottlenecks under heavy contention.

```swift

final class SerialQueueCounter: ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "my.example.counterQueue")
    
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


## 2. Locks (`NSLock`) as Synchronization

**Advantages:**
- Easy to implement and widely used.
- Provides explicit control over critical sections.

**Disadvantages:**
- Susceptible to deadlocks if locking and unlocking are mismanaged.
- Performance is slightly worse than modern low-level primitives.

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

## 3. Concurrent Queue with Barrier as Synchronization

**Advantages:**
- Allows concurrent reads for better performance.
- Writes are safely serialized using a barrier.

**Disadvantages:**
- Requires careful usage of barrier flags.
- Complexity increases compared to a serial queue.

```swift

final class ConcurrentQueueBarrierCounter : ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "my.example.counterQueue", attributes: .concurrent)
    
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


## 4. Atomic Property Wrapper as Synchronization

**Advantages:**
- Abstracts away synchronization logic.
- Cleaner syntax with property-wrapper-based encapsulation.

**Disadvantages:**
- Implementation complexity is hidden, making debugging harder.
- May not support advanced use cases like operation dependencies.

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

## 5. Actors as Synchronization

**Advantages:**
- Built-in Swift concurrency model support.
- Provides safe and intuitive access to isolated state.

**Disadvantages:**
- Requires Swift 5.5 or later.
- Limited to the actor’s concurrency domain, reducing flexibility.

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

## 6. Semaphore as Synchronization

**Advantages:**
- Simple and effective for limiting access to shared resources.
- Works well for scenarios requiring fine-grained control.

**Disadvantages:**
- Potential for deadlocks if `wait` and `signal` are mismanaged.
- Less intuitive compared to higher-level abstractions.


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

## 7. Dispatch Semaphores as Synchronization

**Advantages:**
- Combines semaphores with a dispatch queue for asynchronous execution.
- Allows for both synchronous and asynchronous reads.

**Disadvantages:**
- Adds complexity due to combining semaphores with a queue.
- Difficult to debug semaphore misuse.

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

## 8. `os_unfair_lock` as Synchronization

**Advantages:**
- Fast and efficient low-level locking primitive.
- Ideal for performance-critical scenarios.

**Disadvantages:**
- Cannot be reentrant; deadlocks occur if the same thread tries to lock twice.
- Requires careful usage to avoid misuse.

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

## 9. NSRecursiveLock as Synchronization

**Advantages:**
- Allows the same thread to acquire the lock multiple times.
- Prevents deadlocks in recursive function calls.

**Disadvantages:**
- Slightly slower than `NSLock` due to added recursion checks.
- Overhead is unnecessary for non-recursive scenarios.

```swift
final class RecursiveLockCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    let lock = NSRecursiveLock()

    func increase() {
        lock.lock()
        value += 1
        lock.unlock()
    }

    var getValue: Int {
        lock.lock()
        let currentValue = value
        lock.unlock()
        return currentValue
    }
}
```

## 10. pthread Mutex as Synchronization

**Advantages:**
- Portable and compatible with POSIX-compliant systems.
- Flexible and configurable for advanced use cases.

**Disadvantages:**
- Low-level API with more boilerplate code.
- Requires manual initialization and destruction of the mutex.

```swift
final class PThreadMutexCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    var mutex = pthread_mutex_t()

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    func increase() {
        pthread_mutex_lock(&mutex)
        value += 1
        pthread_mutex_unlock(&mutex)
    }

    var getValue: Int {
        pthread_mutex_lock(&mutex)
        let currentValue = value
        pthread_mutex_unlock(&mutex)
        return currentValue
    }
}
```

## 11. OperationQueue with Max Concurrent Operation Count

**Advantages:**
- Simplifies task serialization with maximum concurrency control.
- Built-in support for dependencies between operations.

**Disadvantages:**
- Overhead due to the `OperationQueue` and `BlockOperation` abstraction.
- Less performant for lightweight operations compared to locks or queues.

```swift
final class OperationQueueCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    let operationQueue = OperationQueue()

    init() {
        operationQueue.maxConcurrentOperationCount = 1
    }

    func increase() {
        operationQueue.addOperation {
            self.value += 1
        }
    }

    var getValue: Int {
        var currentValue: Int = 0
        let operation = BlockOperation {
            currentValue = self.value
        }
        operationQueue.addOperations([operation], waitUntilFinished: true)
        return currentValue
    }
}
```

## 12. DispatchWorkItem with DispatchGroup as Synchronization

**Advantages:**
- Combines work items with a group to manage task dependencies.
- Supports asynchronous operations with completion handlers.

**Disadvantages:**
- Requires careful management of group enter/leave calls.

```swift
final class WorkItemCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    let queue = DispatchQueue(label: "my.example.workItemQueue")
    let group = DispatchGroup()

    func increase() {
        group.enter()
        let workItem = DispatchWorkItem {
            self.value += 1
            self.group.leave()
        }
        queue.async(execute: workItem)
    }

    var getValue: Int {
        group.wait()
        var currentValue: Int = 0
        queue.sync {
            currentValue = self.value
        }
        return currentValue
    }
}
```
## 13. Objective-C Synchronization (`objc_sync_enter` / `objc_sync_exit`)

**Advantages:**
- Straightforward to use with an `NSObject` lock.
- Compatible with both Objective-C and Swift.

**Disadvantages:**
- Slower than `NSLock` or `os_unfair_lock`.
- Limited flexibility compared to other synchronization mechanisms.

```swift
final class ObjCSynchronizedCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    let lock = NSObject()

    func increase() {
        objc_sync_enter(lock)
        value += 1
        objc_sync_exit(lock)
    }

    var getValue: Int {
        objc_sync_enter(lock)
        let currentValue = value
        objc_sync_exit(lock)
        return currentValue
    }
}
```


## 14. NSOperation Dependencies as Synchronization

**Advantages:**
- Supports dependency management between tasks.
- Ensures sequential execution of dependent operations.

**Disadvantages:**
- Adds complexity compared to simpler synchronization primitives.
- Overhead due to operation and queue management.

```swift
final class OperationDependencyCounter: ICounter, @unchecked Sendable {
    var value: Int = 0
    let operationQueue = OperationQueue()
    var lastOperation: Operation?
    let syncQueue = DispatchQueue(label: "my.example.OperationDependencyCounter", attributes: .concurrent)

    func increase() {
        let operation = BlockOperation {
            self.syncQueue.sync(flags: .barrier) {
                self.value += 1
            }
        }
        
        syncQueue.sync(flags: .barrier) {
            if let lastOp = lastOperation {
                operation.addDependency(lastOp)
            }
            lastOperation = operation
        }

        operationQueue.addOperation(operation)
    }

    var getValue: Int {
        operationQueue.waitUntilAllOperationsAreFinished()
        return syncQueue.sync { value }
    }
}
```

# What to choose?!

## **1. For Simplicity and Ease of Use**
- **Best Method:** Serial Dispatch Queue
- **Why:** 
  - Simple, reliable, and easy to implement.
  - Ensures thread safety without requiring detailed lock management.
- **Use Case:** 
  - Light workloads where blocking threads is acceptable.

---

## **2. For High Performance**
- **Best Method:** os_unfair_lock
- **Why:** 
  - Fastest low-level locking mechanism on Apple platforms.
  - Minimizes overhead, suitable for critical sections with minimal contention.
- **Use Case:** 
  - Performance-critical code with high-frequency read/write access.

---

## **3. For Concurrent Reads and Serialized Writes**
- **Best Method:** Concurrent Queue with Barrier
- **Why:** 
  - Efficiently supports multiple concurrent readers while ensuring exclusive writes.
  - Balances performance and safety effectively.
- **Use Case:** 
  - Read-heavy workloads with occasional writes, such as caching mechanisms.

---

## **4. For Advanced Task Management**
- **Best Method:** OperationQueue with Max Concurrent Operation Count or NSOperation Dependencies
- **Why:** 
  - Built-in support for task dependencies and asynchronous operations.
  - Ensures sequential execution of dependent operations.
- **Use Case:** 
  - Complex workflows requiring task dependency management, such as tasks needing specific execution order.

---

## **5. For Modern Swift Concurrency**
- **Best Method:** Actors
- **Why:** 
  - Part of Swift's native concurrency model, providing safety and simplicity.
  - Automatically manages synchronization, reducing boilerplate code.
- **Use Case:** 
  - Projects using Swift 5.5 or later where isolating mutable state within concurrency domains is sufficient.

---

## **6. For Explicit Locking**
- **Best Method:** NSLock or pthread Mutex
- **Why:** 
  - Provides explicit control over locking behavior.
  - Widely understood and easy to implement for traditional synchronization.
- **Use Case:** 
  - When manual locking is necessary without relying on high-level abstractions.

---

## **Summary Table**

| **Use Case**                          | **Best Method**                     |
|---------------------------------------|-------------------------------------|
| Simple and Reliable                   | Serial Dispatch Queue               |
| Performance-Critical Applications     | os_unfair_lock                      |
| Concurrent Reads with Serialized Writes | Concurrent Queue with Barrier       |
| Task Dependency Management            | OperationQueue or NSOperation       |
| Modern Swift Concurrency              | Actors                              |
| Explicit Locking                      | NSLock or pthread Mutex             |

---

## **General Recommendation**
- **Use Serial Dispatch Queue** for simple scenarios requiring easy-to-read and maintain synchronization.
- **Consider Actors** if using modern Swift and aiming for a cleaner concurrency model.
- **Choose os_unfair_lock** or **Concurrent Queue with Barrier** for performance-critical code with complex read/write patterns.
