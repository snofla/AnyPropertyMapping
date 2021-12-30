//
//  AnyPropertyMappingTransformTests.swift
//  
//
//  Created by Alfons Hoogervorst on 26/12/2021.
//

import Foundation
import XCTest
import AnyPropertyMapping


class AnyPropertyMappingTransformTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_Simple_KeyPaths_Tests() {
        let nonOptionals = PropertyMapping(\A.i, \B.xx, transformer: PropertyTransformers.intDouble)
        XCTAssert(nonOptionals.leftKeyPath == \A.i && nonOptionals.rightKeyPath == \B.xx)
        let optionalLhs = PropertyMapping(\A.optV, \B.xx, transformer: PropertyTransformers.intDouble)
        XCTAssert(optionalLhs.leftKeyPath == \A.optV && optionalLhs.rightKeyPath == \B.xx)
        let optionalRhs = PropertyMapping(\A.i, \B.optWW, transformer: PropertyTransformers.intDouble)
        XCTAssert(optionalRhs.leftKeyPath == \A.i && optionalRhs.rightKeyPath == \B.optWW)
        let optionalBoth = PropertyMapping(\A.optV, \B.optWW, transformer: PropertyTransformers.intDouble)
        XCTAssert(optionalBoth.leftKeyPath == \A.optV && optionalBoth.rightKeyPath == \B.optWW)
    }

    
    func test_Int_String_Transformation_Failure() {
        class A {
            var int: Int = 10
        }
        class B {
            // this fails conversion
            var string: String = "XXX"
        }
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.int, \B.string, transformer: PropertyTransformers.intString)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.int == 10, "Original value should stay the same")
    }

    func test_Mapping_Mismatching_Types() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.tt, transformer: PropertyTransformers.intString)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.i == Int(b.tt), "a.i == b.tt (transformed from string)")
        a.i = 300
        mapping.apply(from: a, to: b)
        XCTAssert("\(a.i)" == b.tt, "a.i == b.tt (transformed from string)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == false, "a.i == b.tt (transformed from string)")
    }
    
    func test_Mapping_Mismatching_Types_With_Always_Failing_Transform() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.tt, transformer: .alwaysFailing)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.i != Int(b.tt), "always failing: a.i == b.tt (transformed from string)")
        a.i = 300
        mapping.apply(from: a, to: b)
        XCTAssert("\(a.i)" != b.tt, "always failing: a.i == b.tt (transformed from string)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == true, "always failing: a.i == b.tt (transformed from string)")
    }
    
    func test_Mapping_Mismatching_Types_With_None_Transform() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.tt, transformer: .none),
            PropertyMapping(\A.optW, \B.jj, transformer: PropertyTransformers.intDouble.inverted())
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.i != Int(b.tt), "always failing: a.i == b.tt (transformed from string)")
        XCTAssert(Int(a.optW!) == b.jj , "a.optW == b.jj")
        a.i = 300
        a.optW = nil
        mapping.apply(from: a, to: b)
        XCTAssert("\(a.i)" != b.tt, "always failing: a.i == b.tt (transformed from string)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == true, "always failing: a.i == b.tt (transformed from string)")
        XCTAssert(b.jj == 0, "b.jj == 0 (a.optW is nil and converts to Double() (value 0.0)")
    }
    
    func test_Mapping_Mismatching_Types_OptionalLhs() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.optV, \B.tt, transformer: PropertyTransformers.intString)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.optV! == Int(b.tt)!, "a.optV == b.tt (transformed from string)")
        a.optV = 300
        mapping.apply(from: a, to: b)
        XCTAssert(a.optV! == Int(b.tt)!, "a.optV == b.tt (transformed from string)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == false, "a.optV == b.tt (transformed from string)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        a.optV = nil
        mapping.apply(from: a, to: b)
        XCTAssert(Int(b.tt)! == 0, "Should have 0")
    }
    
    func test_Inverted_Mapping_Mismatching_Types_OptionalLhs() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.optWW, transformer: PropertyTransformers.intDouble).inverted()
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: b, from: a)
        XCTAssert(Int(b.optWW!) == a.i, "b.optWW == a.i  (transformed from double)")
        a.i = 300
        mapping.apply(from: b, to: a)
        XCTAssert(Int(b.optWW!) == a.i, "b.optWW == a.i  (transformed from double)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(b, a) == false, "a.optV == b.tt (transformed from double)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        b.optWW = nil
        mapping.apply(from: b, to: a)
        XCTAssert(Int(a.i) == 0, "Should have 0")
    }
    
    func test_Mapping_Inverted_Mismatching_Types() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.tt, transformer: PropertyTransformers.intString).inverted()
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: b, from: a)
        XCTAssert(a.i == Int(b.tt), "a.i == b.tt (transformed from string)")
        b.tt = "999"
        mapping.apply(from: b, to: a)
        XCTAssert("\(a.i)" == b.tt, "a.i == b.tt (transformed from string)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(b, a) == false, "a.i == b.tt (transformed from string)")
    }
    
    func test_Mapping_Inverted_Mismatching_Types_With_Always_Failing_Transform() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\B.tt, \A.i, transformer: .alwaysFailing)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: b, from: a)
        XCTAssert(a.i != Int(b.tt), "a.i == b.tt (transformed from int)")
        b.tt = "999"
        mapping.apply(from: b, to: a)
        XCTAssert("\(a.i)" != b.tt, "a.i == b.tt (transformed from int)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(b, a) != false, "a.i == b.tt (transformed from int)")
    }
    
    func test_Mapping_Mismatching_Types_OptionalRhs() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.i, \B.optWW, transformer: PropertyTransformers.intDouble)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.i == Int(b.optWW!), "a.i == b.optW (transformed from Double)")
        a.i = 300
        mapping.apply(from: a, to: b)
        XCTAssert(a.i == Int(b.optWW!), "a.i == b.optW (transformed from Double)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == false, "a.i == b.optW (transformed from Double)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        b.optWW = nil
        mapping.adapt(to: a, from: b)
        XCTAssert(Int(a.i) == 0, "Should have 0")
    }
    
    func test_Inverted_Mapping_Mismatching_Types_OptionalRhs() {
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.optV, \B.xx, transformer: PropertyTransformers.intDouble).inverted()
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: b, from: a)
        XCTAssert(a.optV! == Int(b.xx), "a.optV == b.xx (transformed from Double)")
        a.optV = 300
        mapping.apply(from: b, to: a)
        XCTAssert(a.optV! == Int(b.xx), "a.optV == b.xx (transformed from Double)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(b, a) == false, "a.optV == b.xx (transformed from Double)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        a.optV = nil
        mapping.adapt(to: b, from: a)
        XCTAssert(Int(b.xx) == 0, "Should have 0")
    }
    
    func test_Mapping_Mismatching_Types_OptionalBoth() {
        class A {
            var int: Int? = 0
        }
        class B {
            var double: Double? = 1
        }
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(\A.int, \B.double, transformer: PropertyTransformers.intDouble)
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: a, from: b)
        XCTAssert(a.int == Int(b.double!), "a.int == b.double (transformed from Double)")
        a.int = 300
        mapping.apply(from: a, to: b)
        XCTAssert(a.int == Int(b.double!), "a.int == b.double (transformed from Double)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(a, b) == false, "a.int == b.double (transformed from Double)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        b.double = nil
        mapping.adapt(to: a, from: b)
        XCTAssert(a.int! == 0, "Should have 0")
        // Now use optional left value to
        a.int = nil
        b.double = 100
        mapping.apply(from: a, to: b)
        XCTAssert(Int(b.double!) == 0, "Should have 0")
    }
    
    
    func test_Inverted_Mapping_Mismatching_Types_OptionalBoth() {
        class A {
            var int: Int? = 0
        }
        class B {
            var double: Double? = 1
        }
        let mapping: [AnyPropertyMapping] = [
            PropertyMapping(
                \A.int,
                \B.double,
                transformer: PropertyTransformers.intDouble)
            .inverted()
        ]
        let a = A()
        let b = B()
        mapping.adapt(to: b, from: a)
        XCTAssert(a.int == Int(b.double!), "a.int == b.double (transformed from Double)")
        b.double = 300
        mapping.apply(from: b, to: a)
        XCTAssert(a.int == Int(b.double!), "a.int == b.double (transformed from Double)")
        // check whether they differ (they should not)
        XCTAssert(mapping.differs(b, a) == false, "a.int == b.double (transformed from Double)")
        // Now use optional nil value, and see whether it converts
        // back to 0
        a.int = nil
        mapping.adapt(to: b, from: a)
        XCTAssert(Int(b.double!) == 0, "Should have 0")
        // Now use optional left value to nil
        a.int = 3
        b.double = nil
        mapping.apply(from: b, to: a)
        XCTAssert(Int(a.int!) == 0, "Should have 0")
    }
    
}


