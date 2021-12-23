//
//  PropertyMappingBox.swift
//  
//
//  Created by Alfons Hoogervorst on 23/12/2021.
//

import Foundation

/// Declares an internal protocol that helps to define the generic property
/// mapping. It used as a base class for "concrete" generic class `PropertyMapping`
/// and as a class to box the actual fowarded implementation of `PropertyMapping`
/// to support optional properties.
protocol PropertyMappingBox: AnyPropertyMapping {

    /// Constraints (requirements)
    associatedtype Left: AnyObject
    associatedtype Right: AnyObject
    associatedtype Value: Equatable

    /// Internal left keypath
    var _leftKeyPath: WritableKeyPath<Left, Value> { get }
    /// Internal right keypath
    var _rightKeyPath: WritableKeyPath<Right, Value> { get }
}


extension PropertyMappingBox {
    
    // - MARK: public default implementation for AnyPropertyMapping conformance
    
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
    
    public func inverted() -> AnyPropertyMapping {
        fatalError("Never called, should be overloaded")
    }

    // - MARK: private default implementation
    
    fileprivate func adapt(to lhs:  Left, from rhs: Right) {
        var _lhs = lhs // need temp (Xcode 13)
        _lhs[keyPath: self._leftKeyPath] = rhs[keyPath: self._rightKeyPath]
    }
    
    fileprivate func apply(from lhs: Left, to rhs:  Right) {
        var _rhs = rhs // need temp (Xcode 13)
        _rhs[keyPath: self._rightKeyPath] = lhs[keyPath: self._leftKeyPath]
    }

    fileprivate func differs(_ lhs: Left, _ rhs: Right) -> Bool {
        return lhs[keyPath: self._leftKeyPath] != rhs[keyPath: self._rightKeyPath]
    }
    
    
}

