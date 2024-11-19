//
//  SemaphoreCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

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
