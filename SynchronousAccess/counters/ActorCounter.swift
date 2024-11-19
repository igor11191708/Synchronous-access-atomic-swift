//
//  ActorCounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

import Foundation

actor ActorCounter: Sendable {
    
    var value : Int = 0

    func increase() {
        value += 1
    }

    var getValue: Int {
        return value
    }    
}
