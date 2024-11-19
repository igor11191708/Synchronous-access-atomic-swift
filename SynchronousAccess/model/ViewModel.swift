//
//  ViewModel.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import SwiftUI

func runCounterGroup(counter : ICounter, max : Int = 8) async -> ICounter {
    await withTaskGroup(of: Void.self){ group in
        for _ in 1..<max{
            group.addTask {
                print(Thread.current)
                counter.increase()
            }
        }
        
        await group.waitForAll()
        
        return counter
    }
}

@Observable
class ViewModel {
    
    func runCounter(type : ICounter.Type, max : Int) async -> Int {
        let counter = type.init()
        
        let result = await runCounterGroup(counter: counter, max: max)
        
        return result.getValue
    }
    
}
