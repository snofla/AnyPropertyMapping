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
protocol _PropertyMappingBox: AnyPropertyMapping {

    /// Constraints (requirements)
    associatedtype Left: AnyObject
    associatedtype Right: AnyObject
    associatedtype LValue: Equatable
    associatedtype RValue: Equatable

    /// Internal left keypath
    var _leftKeyPath: WritableKeyPath<Left, LValue> { get }
    /// Internal right keypath
    var _rightKeyPath: WritableKeyPath<Right, RValue> { get }
}


extension _PropertyMappingBox {
    
    // - MARK: public default implementation for AnyPropertyMapping conformance
    
    public func adapt(to lhs:  Any, from rhs: Any) -> Any {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        return self.adapt(to: _lhs, from: _rhs)
    }

    public func apply(from lhs: Any, to rhs:  Any) -> Any {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        return self.apply(from: _lhs, to: _rhs)
    }

    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        let _lhs = lhs as! Self.Left
        let _rhs = rhs as! Self.Right
        return self.differs(_lhs, _rhs)
    }
    
    // - MARK: private default implementation. These are
    // the default methods called when LValue == RValue == Value
    
    fileprivate func adapt(to lhs:  Left, from rhs: Right) -> Left {
        assert(LValue.self == RValue.self)
        assert((self._rightKeyPath as? WritableKeyPath<Right, LValue>) != nil)
        let rkp = self._rightKeyPath as! WritableKeyPath<Right, LValue>
        var _lhs = lhs // need temp (Xcode 13)
        _lhs[keyPath: self._leftKeyPath] = rhs[keyPath: rkp]
        return _lhs
    }
    
    fileprivate func apply(from lhs: Left, to rhs:  Right) -> Right {
        assert(LValue.self == RValue.self)
        assert((self._rightKeyPath as? WritableKeyPath<Right, LValue>) != nil)
        let rkp = self._rightKeyPath as! WritableKeyPath<Right, LValue>
        var _rhs = rhs // need temp (Xcode 13)
        _rhs[keyPath: rkp] = lhs[keyPath: self._leftKeyPath]
        return _rhs
    }

    fileprivate func differs(_ lhs: Left, _ rhs: Right) -> Bool {
        assert(LValue.self == RValue.self)
        assert((self._rightKeyPath as? WritableKeyPath<Right, LValue>) != nil)
        let rkp = self._rightKeyPath as! WritableKeyPath<Right, LValue>
        return lhs[keyPath: self._leftKeyPath] != rhs[keyPath: rkp]
    }
    
    
}

