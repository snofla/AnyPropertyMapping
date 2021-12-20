//
//  PropertyMapping.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 18/12/2021.
//

import Foundation

/// Sets up a mapping between two properties of two different classes.
public final class PropertyMapping<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: TypePropertyMappingBase {
    
    // Implementation: we forward keypath operations to a forwarder class,
    // each having a different constructor to support optionals in
    // either the lhs or rhs keypath value. Ideally we want the forwarder
    // classes to be type-erased, but optionals (and static type requirements)
    // make that impossible.
    
    public typealias Left = L
    public typealias Right = R
    public typealias Value = V
    
    /// Constructs a mapping between two object's properties. Properties are either _both_ non-optional,
    /// or optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V>, _ rhs: WritableKeyPath<R, V>) {
        self.forwarder = ForwarderAsIs(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties. The lefr-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V>) {
        self.forwarder = ForwarderOptionalLhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties. The right-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V>, _ rhs: WritableKeyPath<R, V?>) {
        self.forwarder = ForwarderOptionalRhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }

    /// Constructs a mapping between two object's properties. Both left-hand side and  right-hand side object's
    /// properties are optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V?>) {
        self.forwarder = ForwarderOptionalBoth(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Left-hand side keypath
    public var leftKeyPath: AnyKeyPath {
        return self.forwarder.leftKeyPath
    }
    
    /// Right-hand side keypath
    public var rightKeyPath: AnyKeyPath {
        return self.forwarder.rightKeyPath
    }
    
    private let forwarder: AnyPropertyMapping
}


extension PropertyMapping {
    
    public func adapt(to lhs: Any, from rhs: Any) {
        self.forwarder.adapt(to: lhs, from: rhs)
    }
    
    public func apply(from lhs: Any, to rhs: Any) {
        self.forwarder.apply(from: lhs, to: rhs)
    }
    
    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        self.forwarder.differs(lhs, rhs)
    }
    
}

