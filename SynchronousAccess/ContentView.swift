//
//  ContentView.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var model = ViewModel()
    
    var body: some View {
        let title = Text("Synchronize Access to Mutable State")
        
        NavigationStack{
            VStack(alignment: .leading, spacing: 15){
                Button("Serial queue counter"){
                    Task{
                        let value = await model.runCounter(type: SerialQueueCounter.self, max : 8)
                        print(value)
                    }
                }
                Button("Lock counter"){
                    Task{
                        let value = await model.runCounter(type: LockCounter.self, max : 15)
                        print(value)
                    }
                }
                Button("Concurrent Queue with Barrier counter"){
                    Task{
                        let value = await model.runCounter(type: ConcurrentQueueBarrierCounter.self, max : 6)
                        print(value)
                    }
                }
                Button("Atomic Property Wrapper counter"){
                    Task{
                        let value = await model.runCounter(type: AtomicCounter.self, max : 8)
                        print(value)
                    }
                }
                Button("Actors as Synchronization"){
                    Task{
                        let counter = ActorCounter()
                        await withTaskGroup(of: Void.self){ group in
                            for _ in 1..<8{ group.addTask {
                                await counter.increase()
                            } }
                            await group.waitForAll()
                            await print(counter.getValue)
                        }
                    }
                }
                Button("Semaphore as Synchronization"){
                    Task{
                        let value = await model.runCounter(type: SemaphoreCounter.self, max : 12)
                        print(value)
                    }
                }
                Button("Dispatch Semaphores as Synchronization"){
                    Task{
                        let value = await model.runCounter(type: DispatchSemaphoresCounter.self, max : 8)
                        print(value)
                    }
                }
                Button("os_unfair_lock as Synchronization"){
                    Task{
                        let value = await model.runCounter(type: OsUnfairLockCounter.self, max : 8)
                        print(value)
                    }
                }
            }
            .navigationTitle(title)
            
        }
    }
    
}
