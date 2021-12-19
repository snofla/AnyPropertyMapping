//
//  AnyPropertyMappingTests.swift
//  AnyPropertyMappingTests
//
//  Created by Alfons Hoogervorst on 16/12/2021.
//

import XCTest
import AnyPropertyMapping

class AnyPropertyMappingTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Adapt_B_From_A() throws {
        let source = B()
        let target = A()

        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.ii),
            PropertyMapping(\A.t, \B.tt)
        ]

        mappings.forEach { mapping in
            mapping.adapt(to: target, from: source)
        }
        
        XCTAssert(source.ii == target.i, "ii == i")
        XCTAssert(source.tt == target.t, "tt == t")
        XCTAssert(source.jj != target.j, "jj != j")
    }
    
    func test_Apply_A_To_B() throws {
        let source = A()
        let target = B()
        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.ii),
            PropertyMapping(\A.t, \B.tt)
        ]
        
        mappings.forEach { mapping in
            mapping.apply(from: source, to: target)
        }
        
        XCTAssert(target.ii == source.i, "ii == i")
        XCTAssert(target.tt == source.t, "tt == t")
        XCTAssert(target.jj != source.j, "jj != j")
    }

    // Maps an optional property, with the optional property lhs
    func test_Adapt_Optional_B_From_A() {
        let source = B()
        let target = A()

        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\B.optU, \A.u)
        ]
        
        mappings.forEach { mapping in
            mapping.apply(from: source, to: target)
        }
        
        XCTAssert(target.u == Int.init(), "Source has nil, should set default value")
        
        let new = A()
        mappings.forEach { mapping in
            mapping.adapt(to: source, from: new)
        }
        
        XCTAssert(new.u == source.optU, "Source optional should be set")
    }
    
    
    func test_Differs_A_From_B() {
        let source = B()
        let target = A()
        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.ii),
            PropertyMapping(\A.t, \B.tt)
        ]
        let differencesBetweenAB = mappings.reduce(into: Array<AnyPropertyMapping>()) { partialResult, mapping in
            if mapping.differs(target, source) {
                partialResult.append(mapping)
            }
        }
        XCTAssert(!differencesBetweenAB.isEmpty, "A & B should be different")
        // apply mapping, moving data from B to A
        mappings.forEach { mapping in
            mapping.adapt(to: target, from: source)
        }
        let noDifferencesBetweenAB = mappings.reduce(into: Array<AnyPropertyMapping>()) { partialResult, mapping in
            if mapping.differs(target, source) {
                partialResult.append(mapping)
            }
        }
        XCTAssert(noDifferencesBetweenAB.isEmpty, "A & B should not be different")
    }
    
    
    func test_Sequence_Apply_Differs() {
        let a = A()
        let b = B()
        let bb = B()
        // apply
        defaultMappings.apply(from: a, to: b)
        // check a == b
        XCTAssert(defaultMappings.differs(a, b) == false, "a should be b")
        // check b != bb
        XCTAssert(defaultEqualityMappingForB.differs(b, bb) == true, "b should not be equal to bb")
        let differencesbBb = defaultEqualityMappingForB.differences(b, bb) ?? []
        XCTAssert(differencesbBb.count == defaultEqualityMappingForB.count, "all mapped fields should have been changed")
        // get all the keypaths for bb
        let bKeyPaths = defaultMappings.reduce(into: Set<AnyKeyPath>()) { partialResult, mapping in
            partialResult.insert(mapping.rightKeyPath)
        }
        // get all the keypats for bb differences
        let bbKeyPaths = differencesbBb.reduce(into: Set<AnyKeyPath>()) { partialResult, diffs in
            partialResult.insert(diffs.right)
        }
        // see if they are the same (all mapped properties should have changed)
        XCTAssert(bbKeyPaths == bKeyPaths, "All fields in bb should have changed")
    }
    
    
    func test_Sequence_Adapt_Differs() {
        let a = A()
        let b = B()
        let aa = A()
        defaultMappings.adapt(to: a, from: b)
        // check a == b
        XCTAssert(defaultMappings.differs(a, b) == false, "a should be b")
        // check a != aa
        XCTAssert(defaultEqualityMappingForA.differs(a, aa) == true, "a should not be equal to aa")
        let differencesaAa = defaultEqualityMappingForA.differences(a, aa) ?? []
        // get all the keypaths for a
        let aKeyPaths = defaultMappings.reduce(into: Set<AnyKeyPath>()) { partialResult, mapping in
            partialResult.insert(mapping.leftKeyPath)
        }
        // get all the keypats for aa differences
        let aaKeyPaths = differencesaAa.reduce(into: Set<AnyKeyPath>()) { partialResult, diffs in
            partialResult.insert(diffs.left)
        }
        // see if they are the same (all mapped properties should have changed)
        XCTAssert(aaKeyPaths == aKeyPaths, "All fields in aa should have changed")
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


}

class A {
    
    var i: Int = 1
    var j: Int = 2
    var t: String = "t"
    var u: Int = 3
    var optV: Int? = 4
    var optW: Double? = 9
}

class B {
    
    var ii: Int = 2
    var jj: Int = 1
    var tt: String = "tt"
    var optU: Int?
    var vv: Int = 5
    var optWW: Double? = 10
}


