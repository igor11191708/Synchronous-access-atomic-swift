//
//  ConcurrentQueueBarrierCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

final class ConcurrentQueueBarrierCounter : ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "com.example.counterQueue", attributes: .concurrent)
    
    func increase() {
        queue.async(flags: .barrier){
            self.value += 1
        }
    }
    
    var getValue: Int{
        return queue.sync{
            value
        }
    }
}
