//
//  PropertyMapping.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 18/12/2021.
//

import Foundation

/// Sets up a mapping between two properties of two different classes. This is used as
/// a concrete generic implementation. Swift's type inference will make sure the correct
/// constructor is chosen depending on the use of the class.
public final class PropertyMapping<L: AnyObject, R: AnyObject, LV: Equatable & DefaultConstructable, RV: Equatable & DefaultConstructable>: AnyPropertyMapping  {
    
    // Implementation: we forward operations to a box class,
    // each having a different constructor to support optionals in
    // either the lhs or rhs keypath value, or both.
    
    /// Constructs a mapping between two object's properties. Properties are either _both_ non-optional,
    /// or optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, LV>, _ rhs: WritableKeyPath<R, RV>) where LV == RV {
        self.boxedImpl = PropertyMappingBoxAsIs(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties. The lefr-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, LV?>, _ rhs: WritableKeyPath<R, RV>) where LV == RV {
        self.boxedImpl = PropertyMappingBoxOptionalLhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties. The right-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, LV>, _ rhs: WritableKeyPath<R, RV?>) where LV == RV {
        self.boxedImpl = PropertyMappingBoxOptionalRhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }

    /// Constructs a mapping between two object's properties. Both left-hand side and  right-hand side object's
    /// properties are optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, LV?>, _ rhs: WritableKeyPath<R, RV?>) where LV == RV {
        self.boxedImpl = PropertyMappingBoxOptionalBoth(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Left-hand side keypath
    public var leftKeyPath: AnyKeyPath {
        return self.boxedImpl.leftKeyPath
    }
    
    /// Right-hand side keypath
    public var rightKeyPath: AnyKeyPath {
        return self.boxedImpl.rightKeyPath
    }
    
    private let boxedImpl: AnyPropertyMapping
}


extension PropertyMapping {
    
    public func adapt(to lhs: Any, from rhs: Any) {
        PropertyMapping.testArguments(#function, lhs, rhs)
        self.boxedImpl.adapt(to: lhs, from: rhs)
    }
    
    public func apply(from lhs: Any, to rhs: Any) {
        PropertyMapping.testArguments(#function, lhs, rhs)
        self.boxedImpl.apply(from: lhs, to: rhs)
    }
    
    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        PropertyMapping.testArguments(#function, lhs, rhs)
        return self.boxedImpl.differs(lhs, rhs)
    }
    
    public func inverted() -> AnyPropertyMapping {
        return self.boxedImpl.inverted()
    }
    
}

