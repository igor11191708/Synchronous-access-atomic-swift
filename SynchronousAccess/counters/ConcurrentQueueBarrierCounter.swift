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
    
    /// Writes (increase()) are exclusive and block other operations until they complete.
    func increase() {
        queue.async(flags: .barrier){
            self.value += 1
        }
    }
    
    /// Reads (getValue()) can occur concurrently.
    var getValue: Int{
        return queue.sync{
            value
        }
    }
}
