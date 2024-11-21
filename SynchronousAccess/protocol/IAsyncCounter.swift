//
//  IAsyncCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 21.11.24.
//

import Foundation

protocol IAsyncCounter {
    
    init()
    
    func increase() async
    
    var getValue: Int { get async }
    
}
