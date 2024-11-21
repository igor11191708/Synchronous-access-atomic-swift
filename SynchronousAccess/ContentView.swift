//
//  ContentView.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var model = ViewModel()
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    let title = Text("Synchronize Access")
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section(header: Text("Simple and Reliable")) {
                        Button("1. Serial Queue Counter") {
                            Task {
                                let value = await model.runCounter(type: SerialQueueCounter.self, max: 8)
                                print(value)
                                showToastMessage("Serial Queue Counter finished: \(value)")
                            }
                        }
                        Button("5. Actors as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: ActorCounter.self, max: 12)
   
                                print(value)
                                showToastMessage("Actors Counter finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("High Performance")) {
                        Button("8. os_unfair_lock as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: OsUnfairLockCounter.self, max: 8)
                                print(value)
                                showToastMessage("os_unfair_lock finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("Concurrent Reads, Serialized Writes")) {
                        Button("3. Concurrent Queue with Barrier Counter") {
                            Task {
                                let value = await model.runCounter(type: ConcurrentQueueBarrierCounter.self, max: 6)
                                print(value)
                                showToastMessage("Concurrent Queue with Barrier finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("Task Dependency Management")) {
                        Button("11. OperationQueue as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: OperationQueueCounter.self, max: 57)
                                print(value)
                                showToastMessage("OperationQueue finished: \(value)")
                            }
                        }
                        Button("14. NSOperation Dependencies as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: OperationDependencyCounter.self, max: 56)
                                print(value)
                                showToastMessage("NSOperation Dependencies finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("Explicit Locking")) {
                        Button("2. Lock Counter") {
                            Task {
                                let value = await model.runCounter(type: LockCounter.self, max: 15)
                                print(value)
                                showToastMessage("Lock Counter finished: \(value)")
                            }
                        }
                        Button("9. RecursiveLock as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: RecursiveLockCounter.self, max: 8)
                                print(value)
                                showToastMessage("RecursiveLock finished: \(value)")
                            }
                        }
                        Button("10. PThreadMutex as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: PThreadMutexCounter.self, max: 29)
                                print(value)
                                showToastMessage("PThreadMutex finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("Semaphore-Based Approaches")) {
                        Button("6. Semaphore as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: SemaphoreCounter.self, max: 12)
                                print(value)
                                showToastMessage("Semaphore finished: \(value)")
                            }
                        }
                        Button("7. Dispatch Semaphores as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: DispatchSemaphoresCounter.self, max: 9)
                                print(value)
                                showToastMessage("Dispatch Semaphore finished: \(value)")
                            }
                        }
                    }
                    
                    Section(header: Text("Specialized Approaches")) {
                        Button("4. Atomic Property Wrapper Counter") {
                            Task {
                                let value = await model.runCounter(type: AtomicCounter.self, max: 8)
                                print(value)
                                showToastMessage("Atomic Property Wrapper finished: \(value)")
                            }
                        }
                        Button("12. DispatchWorkItem with DispatchGroup as Synchronization") {
                            Task {
                                let value = await model.runCounter(type: WorkItemCounter.self, max: 57)
                                print(value)
                                showToastMessage("DispatchWorkItem finished: \(value)")
                            }
                        }
                        Button("13. Objective-C Synchronization") {
                            Task {
                                let value = await model.runCounter(type: ObjCSynchronizedCounter.self, max: 102)
                                print(value)
                                showToastMessage("Objective-C Synchronization finished: \(value)")
                            }
                        }
                    }
                }
                .navigationTitle(title)
                
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .padding()
                        .background(Color.indigo.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 40)
                .allowsHitTesting(false)
                .opacity(showToast ? 1 : 0 )                
            }
        }
    }
    
    /// Helper function to show the toast message
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation{
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
    }
}
