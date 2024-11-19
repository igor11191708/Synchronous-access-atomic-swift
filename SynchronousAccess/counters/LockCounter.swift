//
//  LockCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

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



