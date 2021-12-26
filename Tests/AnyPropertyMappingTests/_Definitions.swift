//
//  _Definitions.swift
//  
//
//  Created by Alfons Hoogervorst on 26/12/2021.
//

import Foundation
import AnyPropertyMapping


class A {
    
    var i: Int = 1
    var j: Int = 2
    var t: String = "1"
    var u: Int = 3
    var optV: Int? = 4
    var optW: Double? = 9
    var x: Double = 100.0
}


class B {
    
    var ii: Int = 2
    var jj: Int = 1
    var tt: String = "12"
    var optU: Int?
    var vv: Int = 5
    var optWW: Double? = 10
    var xx: Double = 300.0
}


let defaultMappings: [AnyPropertyMapping] = [
    PropertyMapping(\A.i, \B.ii),
    PropertyMapping(\A.j, \B.jj),
    PropertyMapping(\A.t, \B.tt),
    PropertyMapping(\A.u, \B.optU),
    PropertyMapping(\A.optV, \B.vv),
    PropertyMapping(\A.optW, \B.optWW)
]


let defaultEqualityMappingForB: [AnyPropertyMapping] = [
    PropertyMapping(\B.ii, \B.ii),
    PropertyMapping(\B.jj, \B.jj),
    PropertyMapping(\B.tt, \B.tt),
    PropertyMapping(\B.optU, \B.optU),
    PropertyMapping(\B.vv, \B.vv),
    PropertyMapping(\B.optWW, \B.optWW)
]


let defaultEqualityMappingForA: [AnyPropertyMapping] = [
    PropertyMapping(\A.i, \A.i),
    PropertyMapping(\A.j, \A.j),
    PropertyMapping(\A.t, \A.t),
    PropertyMapping(\A.u, \A.u),
    PropertyMapping(\A.optV, \A.optV),
    PropertyMapping(\A.optW, \A.optW)
]

func invertedMappingAdaptApplyIsEqual(with mapping: AnyPropertyMapping) -> Bool  {
    let mappingAB = mapping
    let mappingBA = mappingAB.inverted()
    // objects for <A, B> mapping
    let aAB = A()
    let bAB = B()
    // objects for <B, A> mapping
    let aBA = A()
    let bBA = B()
    // Inverse means that opposite operations
    // should return equivalent results
    mappingAB.adapt(to: aAB, from: bAB)
    mappingBA.apply(from: bBA, to: aBA)
    return defaultEqualityMappingForA.differs(aAB, aBA) == false
}

func defaultTupleArray() -> [(A, B)] {
    let a = (0...9).map { _ in
        return A()
    }
    let b = (0...9).map { _ in
        return B()
    }
    let result = zip(a, b).map { tuple in
        return tuple
    }
    return result
}

func equal(_ a: [A], b: [B]) -> Bool {
    guard a.count == b.count else {
        return false
    }
    guard a.count != 0 else {
        return true
    }
    let differences = a.enumerated().reduce(0) { result, item in
        if defaultMappings.differs(item.element, b[item.offset]) {
            return result + 1
        } else {
            return result
        }
    }
    return differences == 0
}
