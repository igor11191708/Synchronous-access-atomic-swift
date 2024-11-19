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
        NavigationStack{
            VStack(alignment: .leading){
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
            }
            .navigationTitle("Synchronize Access to Mutable State")
            
        }
    }
    
}
