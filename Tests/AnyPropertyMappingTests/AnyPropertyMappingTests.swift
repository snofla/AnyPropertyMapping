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
    
    func test_Differs_With_Left_Optional() {
        class A {
            init(_ value: Int? = 1) { self.optInt = value }
            var optInt: Int?
        }
        class B {
            var nonOptInt: Int = 2
        }
        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\A.optInt, \B.nonOptInt)
        ]
        let diff = mappings.differs(A(), B())
        XCTAssert(diff == true, "Defaults A differs from B")
        let diff1 = mappings.differs(A(2), B())
        XCTAssert(diff1 == false, "A(2) is equal to B()")
        let diff2 = mappings.differs(A(nil), B())
        XCTAssert(diff2 == true, "A(nil) is not equal to B()")
    }
    
    func test_Left_Right_Optional() {
        class A {
            init(_ value: Int? = 1) { self.optInt = value }
            var optInt: Int?
        }
        class B {
            init(_ value: Int? = 2) { self.optInt = value }
            var optInt: Int?
        }
        let mappings: [AnyPropertyMapping] = [
            PropertyMapping(\A.optInt, \B.optInt)
        ]
        let diff = mappings.differs(A(), B())
        XCTAssert(diff == true, "A() differs from B()")
        let diff1 = mappings.differs(A(1), B(1))
        XCTAssert(diff1 == false, "A(1) does not differ from B(1)")
        let diff2 = mappings.differs(A(nil), B(nil))
        XCTAssert(diff2 == false, "A(nil) is equal to B(nil)")
        let diff3 = mappings.differs(A(nil), B(1))
        XCTAssert(diff3 == true, "A(nil) differs from B(1)")
        let diff4 = mappings.differs(A(1), B(nil))
        XCTAssert(diff4 == true, "A(1) differs from B(nil)")
        var a = A(nil)
        var b = B(2)
        mappings.adapt(to: a, from: b)
        XCTAssert(mappings.differs(a, b) == false, "A(nil) adapting B(2) should result in A(2)")
        b = B(nil)
        mappings.apply(from: a, to: b)
        XCTAssert(mappings.differs(a, b) == false, "A(2) applying to B(nil) should result in B(2)")
        b = B(nil)
        a = A(3)
        mappings.adapt(to: a, from: b)
        // test fix for #d549ada
        XCTAssert(a.optInt == nil, "A() should have received nil")
    }
    
    func test_Mapping_Sequence_Differences() {
        let a = A()
        let b = B()
        // make a == b according to mapping
        defaultMappings.adapt(to: a, from: b)
        XCTAssert(defaultMappings.differs(a, b) == false, "a == b")
        // change a
        a.i = #line
        if let differences = defaultMappings.differences(a, b) {
            XCTAssert(differences.count == 1, "One difference")
        } else {
            XCTFail("No differences found, there should be 1")
        }
    }
    
    func test_Mapping_Sequence_DifferencesIndex() {
        let a = A()
        let b = B()
        // make a == b according to mapping
        defaultMappings.adapt(to: a, from: b)
        XCTAssert(defaultMappings.differs(a, b) == false, "a == b")
        // change a
        a.i = #line
        a.u = #line
        let index = defaultMappings.differencesIndex(a, b)
        XCTAssert(index.count == 2, "Two differences in a vs b")
        // find in default mappings
        if let a_i_index = defaultMappings.firstIndex(where: { mapping in
            return mapping.leftKeyPath == \A.i
        }), let a_u_index = defaultMappings.firstIndex(where:  { mapping in
            return mapping.leftKeyPath == \A.u
        }) {
            XCTAssert(index.contains(a_i_index), "\\A.i is different")
            XCTAssert(index.contains(a_u_index), "\\A.u is different")
        } else {
            XCTFail("Could not find \\A.i and \\A.u in defaultMappings")
        }
    }
    
    func test_Adapt_Apply_Mappings_With_Arrays() {
        let emptyA: [A] = []
        let emptyB: [B] = []
        let copyA = [A(), A(), A(), A()]
        let copyB = [B(), B(), B(), B()]
        var a = copyA
        let b = copyB
        defaultMappings.adapt(to: emptyA, from: emptyB)
        XCTAssert(equal(emptyA, b: emptyB), "Empty")
        defaultMappings.adapt(to: a, from: b)
        XCTAssert(equal(a, b: b), "a == b")
        defaultMappings.apply(from: emptyA, to: emptyB)
        XCTAssert(equal(emptyA, b: emptyB), "Empty")
        a = copyA
        defaultMappings.apply(from: a, to: b)
        XCTAssert(equal(a, b: b), "a == b")
    }
    
    func test_Adapt_Apply_Tuples_Array() {
        let copyAB: [(A, B)] = (0...3).map { _ in
            return (A(), B())
        }
        let arrayA = copyAB.map { a_ in
            return a_.0
        }
        let arrayB = copyAB.map { _b in
            return _b.1
        }
        var tuples = copyAB
        tuples.adapt(mappings: defaultMappings)
        let newA = tuples.map { a_ in
            return a_.0
        }
        XCTAssert(equal(newA, b: arrayB), "a == b")
        tuples = copyAB
        tuples.apply(mappings: defaultMappings)
        let newB = tuples.map { _b in
            return _b.1
        }
        XCTAssert(equal(arrayA, b: newB), "a == b")
    }
    
    fileprivate func equal(_ a: [A], b: [B]) -> Bool {
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


