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
        self.forwarder = .asIs(.init(leftKeyPath: lhs, rightKeyPath: rhs))
    }
    
    /// Constructs a mapping between two object's properties. The lefr-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V>) {
        self.forwarder = .lhs(.init(leftKeyPath: lhs, rightKeyPath: rhs))
    }
    
    /// Constructs a mapping between two object's properties. The right-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V>, _ rhs: WritableKeyPath<R, V?>) {
        self.forwarder = .rhs(.init(leftKeyPath: lhs, rightKeyPath: rhs))
    }

    /// Constructs a mapping between two object's properties. Both left-hand side and  right-hand side object's
    /// properties are optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    public init(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V?>) {
        self.forwarder = .both(.init(leftKeyPath: lhs, rightKeyPath: rhs))
    }
    
    /// Left-hand side keypath
    public var leftKeyPath: AnyKeyPath {
        switch self.forwarder {
        case .asIs(let forwarder):
            return forwarder.leftKeyPath
        case .lhs(let forwarder):
            return forwarder.leftKeyPath
        case .rhs(let forwarder):
            return forwarder.leftKeyPath
        case .both(let forwarder):
            return forwarder.leftKeyPath
        }
    }
    
    /// Right-hand side keypath
    public var rightKeyPath: AnyKeyPath {
        switch self.forwarder {
        case .asIs(let forwarder):
            return forwarder.rightKeyPath
        case .lhs(let forwarder):
            return forwarder.rightKeyPath
        case .rhs(let forwarder):
            return forwarder.rightKeyPath
        case .both(let forwarder):
            return forwarder.rightKeyPath
        }
    }
    
    private let forwarder: Forwarder<L, R, V>
}


extension PropertyMapping {
    
    func adapt(to lhs: L, from rhs: R) {
        fatalError("Never called")
    }
        
    func apply(from lhs: L, to rhs: R) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: L, _ rhs: R) -> Bool {
        fatalError("Never called")
    }
    
    public func adapt(to lhs: Any, from rhs: Any) {
        switch self.forwarder {
        case .asIs(let forwarder):
            forwarder.adapt(to: lhs, from: rhs)
        case .lhs(let forwarder):
            forwarder.adapt(to: lhs, from: rhs)
        case .rhs(let forwarder):
            forwarder.adapt(to: lhs, from: rhs)
        case .both(let forwarder):
            forwarder.adapt(to: lhs, from: rhs)
        }
    }
    
    public func apply(from lhs: Any, to rhs: Any) {
        switch self.forwarder {
        case .asIs(let forwarder):
            forwarder.apply(from: lhs, to: rhs)
        case .lhs(let forwarder):
            forwarder.apply(from: lhs, to: rhs)
        case .rhs(let forwarder):
            forwarder.apply(from: lhs, to: rhs)
        case .both(let forwarder):
            forwarder.apply(from: lhs, to: rhs)
        }
    }
    
    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        switch self.forwarder {
        case .asIs(let forwarder):
            return forwarder.differs(lhs, rhs)
        case .lhs(let forwarder):
            return forwarder.differs(lhs, rhs)
        case .rhs(let forwarder):
            return forwarder.differs(lhs, rhs)
        case .both(let forwarder):
            return forwarder.differs(lhs, rhs)
        }
    }
    
}


extension PropertyMapping {
    
    static func testArguments(_ function: StaticString, _ lhs: Any, rhs: Any) {
        assert(lhs is L, "\(function): Type of left-hand side should match with the left-hand side mapping argument")
        assert(rhs is R, "\(function): Type of right-hand side shouuld match with the right-hand side mapping argument")
    }
    
}

