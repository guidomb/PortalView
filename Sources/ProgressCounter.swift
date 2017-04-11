//
//  ProgressCounter.swift
//  PortalView
//
//  Created by Cristian Ames on 4/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public struct ProgressCounter {
    
    public var partial: UInt
    public let total: UInt
    public var progress: Float {
        return Float(partial) / Float(total)
    }
    public var remaining: UInt {
        return total - partial
    }
    
    public init?(partial: UInt, total: UInt) {
        guard partial <= total else { return nil }
        
        self.partial = partial
        self.total = total
    }
    
}
