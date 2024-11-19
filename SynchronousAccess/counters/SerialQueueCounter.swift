//
//  SerialQueueCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

/// A serial DispatchQueue ensures that only one piece of code executes at a time on that queue, effectively synchronizing access to shared resources.
/// All accesses to value happen within queue.sync { ... } blocks, ensuring thread safety.
final class SerialQueueCounter: ICounter, @unchecked Sendable{
    
    var value: Int = 0
    
    let queue = DispatchQueue(label: "com.example.counterQueue")
    
    func increase() {
        queue.sync {
            value += 1
        }
    }
    
    var getValue: Int{
        return queue.sync{
            value
        }
    }
}
