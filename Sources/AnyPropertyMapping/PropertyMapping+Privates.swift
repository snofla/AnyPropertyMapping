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
    
    // Overloads that will never be called
    
    func adapt(to lhs: L, from rhs: R) {
        fatalError("Never called")
    }
        
    func apply(from lhs: L, to rhs: R) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: L, _ rhs: R) -> Bool {
        fatalError("Never called")
    }
    
}
