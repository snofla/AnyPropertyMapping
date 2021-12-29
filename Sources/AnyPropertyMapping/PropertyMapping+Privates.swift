//
//  PropertyMapping+Privates.swift
//  
//
//  Created by Alfons Hoogervorst on 19/12/2021.
//

import Foundation


extension PropertyMapping {
 
    static func testArguments(_ function: StaticString, _ lhs: Any, _ rhs: Any) {
        assert(lhs is L && rhs is R, "\(function): Mapping was <(\(L.self), \(R.self))>, operation arguments (\(type(of: lhs)), \(type(of: rhs)))")
    }
    
}


extension PropertyMapping {
    
    func adapt(to lhs: L, from rhs: R) {
        self.boxedImpl.adapt(to: lhs, from: rhs)
    }
        
    func apply(from lhs: L, to rhs: R) {
        self.boxedImpl.apply(from: lhs, to: rhs)
    }
    
    func differs(_ lhs: L, _ rhs: R) -> Bool {
        return self.boxedImpl.differs(lhs, rhs)
    }
    
}
