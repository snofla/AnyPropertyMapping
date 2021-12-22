//
//  AnyPropertyMapping.swift
//
//  Created by Alfons Hoogervorst on 02/12/2021.
//  Copyright © 2021 Elastique. All rights reserved.
//

import Foundation


/// Type erasing base protocol
public protocol AnyPropertyMapping {
    
    /// Adapts mapping from right-hand side argument to left-hand side argument. The type of
    /// both arguments is defined by the conforming classes.
    func adapt(to lhs: Any, from rhs: Any)
    
    /// Applies mapping from left-hand side argument to right-hand side argument. The type of
    /// both arguments is defined by the conforming classes.
    func apply(from lhs: Any, to rhs: Any)
    
    /// Checks if left-hand and righ-hand side arguments are different. The type of
    /// both arguments is defined by the conforming classes.
    func differs(_ lhs: Any, _ rhs: Any) -> Bool
    
    /// Returns the inverse of a property mapping
    func inverted() -> AnyPropertyMapping
    
    var leftKeyPath: AnyKeyPath { get }
    
    /// Right keypath
    var rightKeyPath: AnyKeyPath { get }
}

// - MARK: Internals

protocol TypePropertyMappingBase: AnyPropertyMapping {

    /// Constraints (requires)
    associatedtype Left: AnyObject
    associatedtype Right: AnyObject
    associatedtype Value: Equatable
    
    func adapt(to lhs:  Left, from rhs: Right)
    func apply(from lhs: Left, to rhs:  Right)
    func differs(_ lhs: Left, _ rhs: Right) -> Bool
}


protocol TypePropertyMapping: TypePropertyMappingBase {    
    var _leftKeyPath: WritableKeyPath<Left, Value> { get }
    var _rightKeyPath: WritableKeyPath<Right, Value> { get }
}


extension TypePropertyMapping {
    
    // We can't shadow, but we can implement the Any varieties, and
    // then call actual implementation.
    
    public func adapt(to lhs:  Any, from rhs: Any) {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        self.adapt(to: _lhs, from: _rhs)
    }

    public func apply(from lhs: Any, to rhs:  Any) {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        self.apply(from: _lhs, to: _rhs)
    }

    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        return self.differs(_lhs, _rhs)
    }
    
    func adapt(to lhs:  Left, from rhs: Right) {
        var _lhs = lhs // need temp (Xcode 13)
        _lhs[keyPath: self._leftKeyPath] = rhs[keyPath: self._rightKeyPath]
    }
    
    func apply(from lhs: Left, to rhs:  Right) {
        var _rhs = rhs // need temp (Xcode 13)
        _rhs[keyPath: self._rightKeyPath] = lhs[keyPath: self._leftKeyPath]
    }

    func differs(_ lhs: Left, _ rhs: Right) -> Bool {
        return lhs[keyPath: self._leftKeyPath] != rhs[keyPath: self._rightKeyPath]
    }
    
}

