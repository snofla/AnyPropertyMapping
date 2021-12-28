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

}
