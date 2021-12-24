//
//  PropertyMapping+Box.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 19/12/2021.
//

import Foundation


extension PropertyMapping {
    
    // As-is box, with either L and R *both* non-optional.
    // Operations adapt, apply, differs are implemented by PropertyMappingBox default extension methods.
    struct PropertyMappingBoxAsIs<L: AnyObject, R: AnyObject, V: Equatable>: PropertyMappingBox {
        typealias Left = L
        typealias Right = R
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V>, rightKeyPath: WritableKeyPath<R, V>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = rightKeyPath
        }
        
        func inverted() -> AnyPropertyMapping {
            // This formally should use the PropertyMapping<R, L, V>.PropertyMappingBoxAsIs<R, L, V>
            // subclass, but PropertyMapping<> requires its V parameter to
            // be default constructable, which is not needed for this
            // specialised case. 
            return PropertyMappingBoxAsIs<R, L, V>.init(leftKeyPath: self._rightKeyPath, rightKeyPath: self._leftKeyPath)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._leftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._rightKeyPath
        }
        
        let _leftKeyPath: WritableKeyPath<L, V>
        let _rightKeyPath: WritableKeyPath<R, V>
    }
    
    // Left-hand optional box; this is a *class* because the left-hand
    // side leftKeyPath will point to a stub in this class: since our keypaths
    // are writable, we have to satisfy mutability.
    // Note that the Left associated type points to the class it self, whereas
    // the L generic parameter is used as an lhs to adapt/apply/differ.
    final class PropertyMappingBoxOptionalLhs<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: PropertyMappingBox {

        // For the LHS we don't want to use L, because that would mean that
        // _leftKeyPath would be pointing to a V, and not a V?. _leftKeyPath
        // becomes a dummy, and we introduce _realLeftKeyPath to point to
        // a WritableKeyPath<L, V?>
        typealias Left = PropertyMappingBoxOptionalLhs
        typealias Right = R
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V?>, rightKeyPath: WritableKeyPath<R, V>) {
            self._realLeftKeyPath = leftKeyPath
            self._leftKeyPath = \Self._stub
            self._rightKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning non optional (rhs) to optional (lhs) is always possible
            _lhs[keyPath: self._realLeftKeyPath] = _rhs[keyPath: self._rightKeyPath]
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning optional value (lhs) to non-optional (rhs) is not
            // allowed: use the default value
            _rhs[keyPath: self._rightKeyPath] = _lhs[keyPath: self._realLeftKeyPath] ?? V()
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return _lhs[keyPath: self._realLeftKeyPath] ?? V() != _rhs[keyPath: self._rightKeyPath]
        }
        
        public func inverted() -> AnyPropertyMapping {
            return PropertyMapping<R, L, V, V>.PropertyMappingBoxOptionalRhs<R, L, V>.init(leftKeyPath: self._rightKeyPath, rightKeyPath: self._realLeftKeyPath)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._realLeftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._rightKeyPath
        }
        
        // We make _leftKeyPath just point to a _stub to be conformant
        // to base protocol
        var _leftKeyPath: WritableKeyPath<Left, V>
        let _rightKeyPath: WritableKeyPath<R, V>
        fileprivate let _realLeftKeyPath: WritableKeyPath<L, V?>
        fileprivate var _stub = V()
    }
    
    
    // Box for when right-hand side is an optional
    final class PropertyMappingBoxOptionalRhs<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: PropertyMappingBox {

        // For the RHS we don't want to use R, because that would mean that
        // _rightKeyPath would be pointing to a V, and not a V?. _rightKeyPath
        // becomes a dummy, and we introduce _realRightKeyPath to point to
        // a WritableKeyPath<R, V?>
        typealias Left = L
        typealias Right = PropertyMappingBoxOptionalRhs
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V>, rightKeyPath: WritableKeyPath<R, V?>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = \Self._stub
            self._realRighKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning optional to non-optional requires a default value
            _lhs[keyPath: self._leftKeyPath] = _rhs[keyPath: self._realRighKeyPath] ?? V()
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning non-optional to optional is always possible
            _rhs[keyPath: self._realRighKeyPath] = _lhs[keyPath: self._leftKeyPath]
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return _lhs[keyPath: self._leftKeyPath] != (_rhs[keyPath: self._realRighKeyPath] ?? V())
        }
        
        public func inverted() -> AnyPropertyMapping {
            return PropertyMapping<R, L, V, V>.PropertyMappingBoxOptionalLhs<R, L, V>.init(leftKeyPath: self._realRighKeyPath, rightKeyPath: self._leftKeyPath)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._leftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._realRighKeyPath
        }
        
        let _leftKeyPath: WritableKeyPath<L, V>
        let _rightKeyPath: WritableKeyPath<Right, V>
        fileprivate let _realRighKeyPath: WritableKeyPath<R, V?>
        fileprivate var _stub = V()
    }
    
    /// Class handling the case were both LHS and RHS values are optional types.
    final class PropertyMappingBoxOptionalBoth<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: PropertyMappingBox {

        typealias Left = PropertyMappingBoxOptionalBoth
        typealias Right = PropertyMappingBoxOptionalBoth
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V?>, rightKeyPath: WritableKeyPath<R, V?>) {
            self._leftKeyPath = \Self._stub
            self._rightKeyPath = \Self._stub
            self._realLeftKeyPath = leftKeyPath
            self._realRighKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning non-optional to non-optional is always possible
            _lhs[keyPath: self._realLeftKeyPath] = _rhs[keyPath: self._realRighKeyPath]
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning non-optional to non-optional is always possible
            _rhs[keyPath: self._realRighKeyPath] = _lhs[keyPath: self._realLeftKeyPath]
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return (_lhs[keyPath: self._realLeftKeyPath] ?? V()) != (_rhs[keyPath: self._realRighKeyPath] ?? V())
        }
        
        public func inverted() -> AnyPropertyMapping {
            return PropertyMapping<R, L, V, V>.PropertyMappingBoxOptionalBoth<R, L, V>.init(leftKeyPath: self._realRighKeyPath, rightKeyPath: self._realLeftKeyPath)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._realLeftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._realRighKeyPath
        }

        /// Unused for the both optional L, R case
        let _leftKeyPath: WritableKeyPath<Left, V>
        
        /// Unused for the both optional L, R case
        let _rightKeyPath: WritableKeyPath<Right, V>

        fileprivate let _realLeftKeyPath: WritableKeyPath<L, V?>
        fileprivate let _realRighKeyPath: WritableKeyPath<R, V?>
        fileprivate var _stub = V()
    }
}

