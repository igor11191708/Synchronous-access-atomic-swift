//
//  ICounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 19.11.24.
//


protocol ISyncCounter {
    
    var value: Int { get set }
    
    func increase()
    
    var getValue: Int { get }
    
    init()
}
