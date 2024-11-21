//
//  ViewModel.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//

import SwiftUI

// MARK: - Function Implementation

func runCounterGroup(counter: AnyCounter, max: Int = 8) async -> AnyCounter {
    await withTaskGroup(of: Void.self) { group in
        for _ in 1..<max {
            group.addTask {
                print(Thread.current)
                await counter.increase()
            }
        }
        await group.waitForAll()
    }
    return counter
}

// MARK: - ViewModel

@Observable
class ViewModel {
    func runCounter(type: Any.Type, max: Int) async -> Int {
        
        let counter: AnyCounter

        if let counterType = type as? ISyncCounter.Type {
            counter = AnyCounter(counter: counterType.init())
        } else if let counterType = type as? IAsyncCounter.Type {
            counter = AnyCounter(counter: counterType.init())
        } else {
            fatalError("Unsupported counter type")
        }

        let result = await runCounterGroup(counter: counter, max: max)
        return await result.getValue()
    }
}
