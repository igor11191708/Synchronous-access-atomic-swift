//
//  ContentView.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var model = ViewModel()
    
    var body: some View {
        let title = Text("Synchronize Access")
        
        NavigationStack{
            List {
                Section(header: Text("Simple and Reliable")) {
                    Button("1. Serial Queue Counter") {
                        Task {
                            let value = await model.runCounter(type: SerialQueueCounter.self, max: 8)
                            print(value)
                        }
                    }
                    Button("5. Actors as Synchronization") {
                        Task {
                            let counter = ActorCounter()
                            await withTaskGroup(of: Void.self) { group in
                                for _ in 1..<8 {
                                    group.addTask {
                                        await counter.increase()
                                    }
                                }
                                await group.waitForAll()
                                await print(counter.getValue)
                            }
                        }
                    }
                }
                
                Section(header: Text("High Performance")) {
                    Button("8. os_unfair_lock as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: OsUnfairLockCounter.self, max: 8)
                            print(value)
                        }
                    }
                }
                
                Section(header: Text("Concurrent Reads, Serialized Writes")) {
                    Button("3. Concurrent Queue with Barrier Counter") {
                        Task {
                            let value = await model.runCounter(type: ConcurrentQueueBarrierCounter.self, max: 6)
                            print(value)
                        }
                    }
                }
                
                Section(header: Text("Task Dependency Management")) {
                    Button("11. OperationQueue as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: OperationQueueCounter.self, max: 57)
                            print(value)
                        }
                    }
                    Button("14. NSOperation Dependencies as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: OperationDependencyCounter.self, max: 57)
                            print(value)
                        }
                    }
                }
                
                Section(header: Text("Explicit Locking")) {
                    Button("2. Lock Counter") {
                        Task {
                            let value = await model.runCounter(type: LockCounter.self, max: 15)
                            print(value)
                        }
                    }
                    Button("9. RecursiveLock as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: RecursiveLockCounter.self, max: 8)
                            print(value)
                        }
                    }
                    Button("10. PThreadMutex as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: PThreadMutexCounter.self, max: 29)
                            print(value)
                        }
                    }
                }
                
                Section(header: Text("Semaphore-Based Approaches")) {
                    Button("6. Semaphore as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: SemaphoreCounter.self, max: 12)
                            print(value)
                        }
                    }
                    Button("7. Dispatch Semaphores as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: DispatchSemaphoresCounter.self, max: 8)
                            print(value)
                        }
                    }
                }
                
                Section(header: Text("Specialized Approaches")) {
                    Button("4. Atomic Property Wrapper Counter") {
                        Task {
                            let value = await model.runCounter(type: AtomicCounter.self, max: 8)
                            print(value)
                        }
                    }
                    Button("12. DispatchWorkItem with DispatchGroup as Synchronization") {
                        Task {
                            let value = await model.runCounter(type: WorkItemCounter.self, max: 57)
                            print(value)
                        }
                    }
                    Button("13. Objective-C Synchronization") {
                        Task {
                            let value = await model.runCounter(type: ObjCSynchronizedCounter.self, max: 57)
                            print(value)
                        }
                    }
                }
            }
            .navigationTitle(title)
        }
    }
}
