//
//  ICounter.swift
//  SynchronousAccess
//
//  Created by Igor  on 19.11.24.
//

protocol ICounter{
    
    var value : Int { get set }
    
    func increase()
    
    var getValue : Int { get }
    
    init()
}
