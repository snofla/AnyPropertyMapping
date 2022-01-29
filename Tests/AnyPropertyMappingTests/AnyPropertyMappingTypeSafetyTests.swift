//
//  AnyPropertyMappingTypeSafetyTests.swift
//  
//
//  Created by Alfons Hoogervorst on 27/12/2021.
//

import XCTest
import AnyPropertyMapping


class AnyPropertyMappingTypeSafetyTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_A_B_Type_Safety() {
        // Infers [PropertyMapping<A, B>]
        let mapping = [
            PropertyMapping(\A.i, \B.optU),
            PropertyMapping(\A.j, \B.jj)
        ]
        let a1 = A()
        let b1 = B()
        let mappings = mapping as [AnyPropertyMapping]
        mappings.adapt(to: a1, from: b1)
        let b2 = B()
        XCTAssert(mappings.differs(a1, b2) == false, "Should be equal to original")
    }
    
    func test_A_B_C_Type_Safety_Fails() {
        class C {
            var i: Int = 0
            var j: Int = 1
        }
        let mapping: [AnyPropertyMapping] = [
            // insert a mapping A <- B
            PropertyMapping(\A.i, \B.ii),
            // insert a mapping A <- C
            PropertyMapping(\A.i, \C.i)
        ]
        // Since we added an A <- C mapping the conditional cast to
        // [A <- B] should fail
        XCTAssertNil(mapping as? [PropertyMapping<A, B>], "Type safety check")
        
        let mapping1: [AnyPropertyMapping] = [
            // insert a mapping A <- B
            PropertyMapping(\A.i, \B.ii),
            // insert a mapping A <- B
            PropertyMapping(\A.i, \B.optU),
        ]
        XCTAssertNotNil(mapping1 as? [PropertyMapping<A, B>], "Type safety check")
    }

    func test_Optional_Default_Constructable() {
        let i: Int? = 2
        XCTAssertNotNil(i, "i is not nil")
        let j: Int? = nil
        XCTAssertNil(j, "j is nil")
        let k: Int? = Int?()
        XCTAssertNotNil(k, "k is not nil")
        XCTAssert(k! == 0, "k should have default value 0, because Int is default constructable")
    }
    
    func test_Hashable_Equality() {
        XCTAssert(PropertyMapping(\A.i, \B.ii) == PropertyMapping(\A.i, \B.ii), "Should be equal")
        XCTAssert(PropertyMapping(\A.i, \B.ii) != PropertyMapping(\A.optV, \B.ii), "Should not be equal")
        let set = Set<PropertyMapping>([
            PropertyMapping(\A.i, \B.ii),
            PropertyMapping(\A.j, \B.jj),
            PropertyMapping(\A.optV, \B.vv),
            // insert duplicate
            PropertyMapping(\A.i, \B.ii),
        ])
        XCTAssert(set.count == 3, "Should be three in set")
        var dictionary: [PropertyMapping<A, B>: Int] = [
            PropertyMapping(\A.i, \B.ii): 1,
            PropertyMapping(\A.j, \B.jj): 2,
            PropertyMapping(\A.optV, \B.vv): 3,
        ]
        XCTAssert(dictionary.count == 3, "Should be three in dictionary")
        dictionary[PropertyMapping(\A.i, \B.ii)] = 4
        XCTAssert(dictionary.count == 3, "Should still be three in dictionary")
        let value = dictionary[PropertyMapping(\A.i, \B.ii)]
        XCTAssert(value! == 4, "Dictionary value should be 4")
    }
    
    func test_Sequence_Array_A_B_Adapt_Apply_Differs() {
        
        func performTests<S: Sequence>(with mapping: S) where S.Element == PropertyMapping<A, B> {
            let a1 = A()
            let b1 = B()
            mapping.adapt(to: a1, from: b1)
            XCTAssert(mapping.differs(a1, b1) == false, "Should be equal")
            let a2 = A()
            let b2 = B()
            mapping.apply(from: a2, to: b2)
            XCTAssert(mapping.differs(a2, b2) == false, "Should be equal")
        }
        
        performTests(with: defaultMappingsTS)
        performTests(with: Set<PropertyMapping>(defaultMappingsTS))
    }
    
    func test_Mapping_Sequence_Differences() {
        
        func performTests<S: Sequence>(with mapping: S) where S.Element == PropertyMapping<A, B> {
            let a = A()
            let b = B()
            mapping.adapt(to: a, from: b)
            XCTAssert(mapping.differs(a, b) == false, "a == b")
            // Same comparison, but now using differences
            XCTAssert(mapping.differences(a, b) == nil, "a == b")
            a.i = #line
            if let differences = mapping.differences(a, b) {
                XCTAssert(differences.count == 1, "One difference")
            } else {
                XCTFail("No differences found, there should be 1")
            }
        }
        
        performTests(with: defaultMappingsTS) // array of PropertyMapping<A, B>
        performTests(with: Set<PropertyMapping>(defaultMappingsTS)) // set of PropertyMapping<A, B>
    }
    
    func test_Mapping_Sequence_DifferencesIndex() {
        let a = A()
        let b = B()
        // make a == b according to mapping
        defaultMappingsTS.adapt(to: a, from: b)
        XCTAssert(defaultMappingsTS.differs(a, b) == false, "a == b")
        // change a
        a.i = #line
        a.u = #line
        let index = defaultMappingsTS.differencesIndex(a, b)
        XCTAssert(index.count == 2, "Two differences in a vs b")
        // find in default mappings
        if let a_i_index = defaultMappingsTS.firstIndex(where: { mapping in
            return mapping.leftKeyPath == \A.i
        }), let a_u_index = defaultMappingsTS.firstIndex(where:  { mapping in
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
        let mappingsSet = Set<PropertyMapping>(defaultMappingsTS)
        mappingsSet.adapt(to: emptyA, from: emptyB)
        XCTAssert(mappingsSet.differs(emptyA, emptyB) == false, "Empty")
        mappingsSet.adapt(to: a, from: b)
        XCTAssert(mappingsSet.differs(a, b) == false, "a == b")
        mappingsSet.apply(from: emptyA, to: emptyB)
        XCTAssert(mappingsSet.differs(emptyA, emptyB) == false, "Empty")
        a = copyA
        mappingsSet.apply(from: a, to: b)
        XCTAssert(mappingsSet.differs(a, b) == false, "a == b")
    }

    func test_sequence_invert() {
        let mappingSetAB = defaultMappings
        let mappingSetBA = Set<PropertyMapping>(defaultMappingsTS).inverted()
        // mappingSetBA.apply() should result the same result as mappingSetAB.adapt()
        let aab = A()
        let bab = B()
        // (A <- B).adapt changes A
        mappingSetAB.adapt(to: aab, from: bab)
        let aba = A()
        let bba = B()
        // (B <- A).apply changes A
        mappingSetBA.apply(from: bba, to: aba)
        // See if aba and aab are equivalent
        XCTAssert(defaultEqualityMappingForATS.differs(aba, aab) == false, "Should not be different")        
        XCTAssert(defaultEqualityMappingForATS.differences(aba, aab) == nil, "Same but now checking if there are no differences returned")
        // Change one aba field
        aba.i = #line
        XCTAssert(defaultEqualityMappingForATS.differs(aba, aab) == true, "Should  be different")
        // Check if the changed index path is what we expect
        if let kp = defaultEqualityMappingForATS.differences(aba, aab)?.first, kp == \A.i {
        } else {
            XCTFail("No changes, we should have one")
        }        
    }
 
    func test_Sequence_Differs_Mapping_With_Array() {
        // test boundary conditions
        let a = (0...9).map { _ in
            return A()
        }
        let b = (0...9).map { _ in
            return B()
        }
        let mappingsSet = Set<PropertyMapping>(defaultMappingsTS)
        // empty arrays are equal
        XCTAssert(mappingsSet.differs([A](), [B]()) == false, "[] == []")
        // a != b
        XCTAssert(mappingsSet.differs(a, b) == true, "a != b")
        // different array sizes
        XCTAssert(mappingsSet.differs(Array(a.prefix(2)), b) == true, "Array count mismatch")
        // copying items from b to a, makes them equal
        // set up an array where As are set to Bs
        let equalAB = a
        mappingsSet.adapt(to: equalAB, from: b)
        XCTAssert(mappingsSet.differs(equalAB, b) == false, "a == b")
        // change first item
        mappingsSet.adapt(to: equalAB, from: b)
        equalAB.first?.t = "Test String"
        XCTAssert(mappingsSet.differs(equalAB, b) == true, "a != b")
        // change last item
        mappingsSet.adapt(to: equalAB, from: b)
        equalAB.last?.optV = 8
        XCTAssert(mappingsSet.differs(equalAB, b) == true, "a != b")
        // change something in the middle
        mappingsSet.adapt(to: equalAB, from: b)
        equalAB[(1..<equalAB.count - 2).randomElement()!].u = 3
        XCTAssert(mappingsSet.differs(equalAB, b) == true, "a != b")
    }
    
    func test_Mapping_Same_Object() {
        class A {
            init(int: Int = 0, double: Double? = nil) {
                self.int = int
                self.double = double
            }
            var int: Int = 0
            var double: Double? = 1
        }
        // non-optional
        let mapping1: [PropertyMapping<A, A>] = [
            PropertyMapping(\A.int)
        ]
        // optional
        let mapping2: [PropertyMapping<A, A>] = [
            PropertyMapping(\A.double)
        ]
        var a1 = A()
        var a2 = A(int: 4, double: 2)
        // adapt
        mapping1.adapt(to: a1, from: a2)
        XCTAssertTrue(a1.int == a2.int)
        XCTAssertTrue(a1.double != a2.double)
        a1 = A()
        a2 = A(int: 4, double: 2)
        mapping2.adapt(to: a1, from: a2)
        XCTAssertTrue(a1.int != a2.int)
        XCTAssertTrue(a1.double == a2.double)
        // apply
        a2 = A(int: #line, double: Double(#line))
        mapping1.apply(from: a1, to: a2)
        XCTAssertTrue(a1.int == a2.int && a1.double != a2.double)
        a2 = A(int: #line, double: Double(#line))
        mapping2.apply(from: a1, to: a2)
        XCTAssertTrue(a1.int != a2.int && a1.double == a2.double)
        // check nils
        a1 = A(int: 0, double: 1)
        a2 = A(int: 0, double: nil)
        mapping2.adapt(to: a1, from: a2)
        XCTAssertTrue(a1.double == a2.double && a1.double == nil)
        a1 = A(int: 0, double: nil)
        a2 = A(int: 0, double: 1)
        mapping2.apply(from: a1, to: a2)
        XCTAssertTrue(a1.double == a2.double && a1.double == nil)
    }
    
}
