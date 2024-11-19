//
//  OsUnfairLockCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

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
