//
//  DispatchSemaphoresCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class DispatchSemaphoresCounter: ICounter, @unchecked Sendable {
    
    var value: Int = 0
    
    let semaphore = DispatchSemaphore(value: 1)
    
    let queue = DispatchQueue(label: "my.queue.Example", attributes: .concurrent)
    
    func increase() {
        queue.async {
            self.semaphore.wait()
            self.value += 1
            self.semaphore.signal()
        }
    }
    
    var getValue: Int{
        semaphore.wait()
        let currentValue = value
        semaphore.signal()
        return currentValue
    }
    
    func getValue(callback: @escaping (Int) -> Void){
        queue.async {
            self.semaphore.signal()
            let currentValue = self.value
            self.semaphore.signal()
            callback(currentValue)
        }
    }    
}
