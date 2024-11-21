//
//  AnyCounter.swift
//  SynchronousAccess
//
//  Created by Igor Shelopaev on 21.11.24.
//

import Foundation

struct AnyCounter {
    
    private let _increase: () async -> Void
    
    private let _getValue: () async -> Int

    init(counter: ISyncCounter) {
        _increase = { counter.increase() }
        _getValue = { counter.getValue }
    }

    init(counter: IAsyncCounter) {
        _increase = { await counter.increase() }
        _getValue = { await counter.getValue }
    }

    func increase() async {
        await _increase()
    }

    func getValue() async -> Int {
        await _getValue()
    }
}
