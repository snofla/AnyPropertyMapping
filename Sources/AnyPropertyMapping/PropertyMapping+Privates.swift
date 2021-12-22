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
    
    // Overloads of TypePropertyMapping that will never be called
    
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


extension PropertyMapping.ForwarderOptionalLhs {
    
    // Overloads of TypePropertyMapping that will never be called
    
    func adapt(to lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, from rhs: R) {
        fatalError("Never called")
    }
    
    func apply(from lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, to rhs: R) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, _ rhs: R) -> Bool {
        fatalError("Never called")
    }
    
}


extension PropertyMapping.ForwarderOptionalRhs {
    
    // Overloads of TypePropertyMapping that will never be called
    
    func adapt(to lhs: L, from rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) {
        fatalError("Never called")
    }
    
    func apply(from lhs: L, to rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: L, _ rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) -> Bool {
        fatalError("Never called")
    }
    
}


extension PropertyMapping.ForwarderOptionalBoth {
    
    // Overloads of TypePropertyMapping that will never be called
    
    func adapt(to lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, from rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) {
        fatalError("Never called")
    }
    
    func apply(from lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, to rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, _ rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) -> Bool {
        fatalError("Never called")
    }
    
}

