//
//  Array+PropertyMapping.swift
//  
//
//  Created by Alfons Hoogervorst on 28/12/2021.
//

import Foundation


extension Sequence {
        
    /// Applies mapping to two objects
    ///
    /// Example:
    ///
    /// ````
    /// let a = Object1()
    /// let b = Object2()
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.apply(from: a, to: b)
    /// ````
    public func apply<L: AnyObject, R: AnyObject>(from lhs: L, to rhs: R) where Self.Element == PropertyMapping<L, R> {
        self.forEach { mapping in
            mapping.apply(from: lhs, to: rhs)
        }
    }

    /// Adapts mapping to two object
    ///
    /// Example:
    ///
    /// ````
    /// let a = Object1()
    /// let b = Object2()
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.adapt(to: a, from: b)
    /// ````
    public func adapt<L: AnyObject, R: AnyObject>(to lhs: L, from rhs: R) where Self.Element == PropertyMapping<L, R> {
        self.forEach { mapping in
            mapping.adapt(to: lhs, from: rhs)
        }
    }
    
    /// Returns `true` if two objects differ from each other using the current mapping
    /// - Returns: `true` if objects differ
    ///
    /// Example:
    ///
    /// ````
    /// let a = Object1()
    /// let b = Object2()
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.differs(a, b) // true if objects differ according to mapping
    /// ````
    public func differs<L: AnyObject, R: AnyObject>(_ lhs: L, _ rhs: R) -> Bool where Self.Element == PropertyMapping<L, R> {
        guard let _ = self.first(where: { mapping in
            return mapping.differs(lhs, rhs) == true
        }) else {
            return false
        }
        return true
    }
    
    /// Returns the keypaths differences between two objects L and R as an array of
    /// tuples. L and R refer to objects of different types.
    /// - Parameters:
    ///   - lhs: Left-hand side object
    ///   - rhs: Right-hand side object
    /// - Returns: An array of tuples, where a tuple's `left` and `right` properties
    /// have the keypaths for the properties where the left-hand and right-hand side
    /// objects differ.
    public func differences<L: AnyObject, R: AnyObject>(_ lhs: L, _ rhs: R) -> Array<(left: AnyKeyPath, right: AnyKeyPath)>? where Self.Element == PropertyMapping<L, R> {
        let diffs = self.compactMap { (mapping) -> (left: AnyKeyPath, right: AnyKeyPath)? in
            guard mapping.differs(lhs, rhs) else {
                return nil
            }
            return (left: mapping.leftKeyPath, right: mapping.rightKeyPath)
        }
        return diffs.isEmpty ? nil : diffs
    }
    
    /// Returns the keypaths differences as an array of
    /// keypaths. L and R refer to objects of the same type.
    /// - Parameters:
    ///   - lhs: Left-hand side object
    ///   - rhs: Right-hand side object
    /// - Returns: An array of keypaths
    public func differences<L: AnyObject>(_ lhs: L, _ rhs: L) -> Array<AnyKeyPath>? where Self.Element == PropertyMapping<L, L> {
        let diffs = self.compactMap { (mapping) -> AnyKeyPath? in
            guard mapping.differs(lhs, rhs) else {
                return nil
            }
            return mapping.leftKeyPath
        }
        return diffs.isEmpty ? nil : diffs
    }
    
    public func differencesIndex<L: AnyObject, R: AnyObject>(_ lhs: L, _ rhs: R) -> IndexSet where Self.Element == PropertyMapping<L, R> {
        let diffIndices = self.enumerated().reduce(into: IndexSet()) { partialResult, item in
            let (index, mapping) = item
            if mapping.differs(lhs, rhs) {
                partialResult.insert(index)
            }
        }
        return diffIndices
    }
    
    /// Returns the inverse of a mapping sequence
    public func inverted<L: AnyObject, R: AnyObject>() -> [AnyPropertyMapping] where Self.Element == PropertyMapping<L, R> {
        return self.map { mapping in
            return mapping.inverted()
        }
    }
    
    /// Applies mapping to two arrays of objects. If arrays have not the equal sizes, mappings
    /// are applied to the least number of objects in either of the arrays.
    ///
    /// Example:
    ///
    /// ````
    /// let a: [Object1] = [Object1(), Object1(), Object1()]
    /// let b: [Object2] = [Object2(), Object2(), Object2()]
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.apply(from: a, to: b)
    /// ````
    public func apply<L: AnyObject, R: AnyObject>(from lhs: Array<L>, to rhs: Array<R>) where Self.Element == PropertyMapping<L, R> {
        guard lhs.count != 0 && rhs.count != 0 else {
            return
        }
        let min = Swift.min(lhs.count, rhs.count)
        for i in 0..<min {
            self.apply(from: lhs[i], to: rhs[i])
        }
    }

    /// Adapts mapping to two arrays of objects. If arrays have not the equal sizes, mappings
    /// are applied to the least number of objects in either of the arrays.
    ///
    /// Example:
    ///
    /// ````
    /// let a: [Object1] = [Object1(), Object1(), Object1()]
    /// let b: [Object2] = [Object2(), Object2(), Object2()]
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.adapt(to: a, from: b)
    /// ````
    public func adapt<L: AnyObject, R: AnyObject>(to lhs: Array<L>, from rhs: Array<R>) where Self.Element == PropertyMapping<L, R> {
        guard lhs.count != 0 && rhs.count != 0 else {
            return
        }
        let min = Swift.min(lhs.count, rhs.count)
        for i in 0..<min {
            self.adapt(to: lhs[i], from: rhs[i])
        }
    }

    /// Returns `true` if two arrays of objects differ from each other using the current mapping
    /// - Returns: `true` if objects differ
    ///
    /// Example:
    ///
    /// ````
    /// let a = [Object1(), Object1(), Object1()]
    /// let b = [Object2(), Object2(), Object2()]
    /// let mappings = [
    ///     PropertyMapping(\Object1.field1, \Object2.field1),
    ///     PropertyMapping(\Object1.field2, \Object2.field2)
    /// ]
    /// mappings.differs(a, b) // true if objects differ according to mapping
    /// ````
    public func differs<L: AnyObject, R: AnyObject>(_ lhs: Array<L>, _ rhs: Array<R>) -> Bool where Self.Element == PropertyMapping<L, R> {
        guard lhs.count != 0 && rhs.count != 0 else {
            return false
        }
        guard lhs.count == rhs.count else {
            return true
        }
        guard let _ = zip(lhs, rhs).first(where: { tuple in
            return self.differs(tuple.0, tuple.1) == true
        }) else {
            return false
        }
        return true
    }

}
