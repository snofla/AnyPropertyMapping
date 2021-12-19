//
//  PropertyMapping+Forwarder.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 19/12/2021.
//

import Foundation


extension PropertyMapping {
    
    enum Forwarder<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable> {
        case asIs(ForwarderAsIs<L, R, V>)
        case lhs(ForwarderOptionalLhs<L, R, V>)
        case rhs(ForwarderOptionalRhs<L, R, V>)
        case both(ForwarderOptionalBoth<L, R, V>)
    }
    
    // Forwarders are hard to type-erase because of constructors receiving
    // an optional on either the lhs or rhs.
    
    // As-is forwarder, with either L and R *both* non-optional.
    // Operations adapt, apply, differs are implemented by TypePropertyMapping.
    struct ForwarderAsIs<L: AnyObject, R: AnyObject, V: Equatable>: TypePropertyMapping {
        typealias Left = L
        typealias Right = R
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V>, rightKeyPath: WritableKeyPath<R, V>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = rightKeyPath
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
    
    // Left-hand optional forwarder; this is a *class* because the left-hand
    // side leftKeyPath will point to a stub in this class: since our keypaths
    // are writable, we have to satisfy mutability.
    // Note that the Left associated type points to the class it self, whereas
    // the L generic parameter is used as an lhs to adapt/apply/differ.
    class ForwarderOptionalLhs<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: TypePropertyMapping {

        // For the LHS we don't want to use L, because that would mean that
        // _leftKeyPath would be pointing to a V, and not a V?. _leftKeyPath
        // becomes a dummy, and we introduce _realLeftKeyPath to point to
        // a WritableKeyPath<L, V?>
        typealias Left = ForwarderOptionalLhs
        typealias Right = R
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V?>, rightKeyPath: WritableKeyPath<R, V>) {
            self._realLeftKeyPath = leftKeyPath
            self._leftKeyPath = \Self._stub
            self._rightKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning non optional (rhs) to optional (lhs) is always possible
            _lhs[keyPath: self._realLeftKeyPath] = _rhs[keyPath: self._rightKeyPath]
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning optional value (lhs) to non-optional (rhs) is not
            // allowed: use the default value
            _rhs[keyPath: self._rightKeyPath] = _lhs[keyPath: self._realLeftKeyPath] ?? V()
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return _lhs[keyPath: self._realLeftKeyPath] ?? V() != _rhs[keyPath: self._rightKeyPath]
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
    
    
    // Forwarder for when right-hand side is an optional
    class ForwarderOptionalRhs<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: TypePropertyMapping {

        // For the RHS we don't want to use R, because that would mean that
        // _rightKeyPath would be pointing to a V, and not a V?. _rightKeyPath
        // becomes a dummy, and we introduce _realRightKeyPath to point to
        // a WritableKeyPath<R, V?>
        typealias Left = L
        typealias Right = ForwarderOptionalRhs
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V>, rightKeyPath: WritableKeyPath<R, V?>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = \Self._stub
            self._realRighKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning optional to non-optional requires a default value
            _lhs[keyPath: self._leftKeyPath] = _rhs[keyPath: self._realRighKeyPath] ?? V()
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning non-optional to optional is always possible
            _rhs[keyPath: self._realRighKeyPath] = _lhs[keyPath: self._leftKeyPath]
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return _lhs[keyPath: self._leftKeyPath] != (_rhs[keyPath: self._realRighKeyPath] ?? V())
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
    
    
    class ForwarderOptionalBoth<L: AnyObject, R: AnyObject, V: Equatable & DefaultConstructable>: TypePropertyMapping {

        typealias Left = ForwarderOptionalBoth
        typealias Right = ForwarderOptionalBoth
        typealias Value = V
        
        init(leftKeyPath: WritableKeyPath<L, V?>, rightKeyPath: WritableKeyPath<R, V?>) {
            self._leftKeyPath = \Self._stub
            self._rightKeyPath = \Self._stub
            self._realLeftKeyPath = leftKeyPath
            self._realRighKeyPath = rightKeyPath
        }

        public func adapt(to lhs: Any, from rhs: Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning non-optional to non-optional is always possible
            _lhs[keyPath: self._realLeftKeyPath] = _rhs[keyPath: self._realRighKeyPath] ?? V()
        }
        
        public func apply(from lhs: Any, to rhs:  Any) {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning non-optional to non-optional is always possible
            _rhs[keyPath: self._realRighKeyPath] = _lhs[keyPath: self._realLeftKeyPath]
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            PropertyMapping.testArguments(#function, lhs, rhs: rhs)
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            // unwrap if needed, choose default value
            return (_lhs[keyPath: self._realLeftKeyPath] ?? V()) != (_rhs[keyPath: self._realRighKeyPath] ?? V())
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._realLeftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._realRighKeyPath
        }

        let _leftKeyPath: WritableKeyPath<Left, V>
        let _rightKeyPath: WritableKeyPath<Right, V>

        fileprivate let _realLeftKeyPath: WritableKeyPath<L, V?>
        fileprivate let _realRighKeyPath: WritableKeyPath<R, V?>
        fileprivate var _stub = V()
    }
}


extension PropertyMapping.ForwarderOptionalLhs {
    
    func adapt(to lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, from rhs: R) {
        fatalError("Never called")
    }
    
    func apply(from lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, to rhs: R) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: PropertyMapping<L, R, V>.ForwarderOptionalLhs<L, R, V>, _ rhs: R) -> Bool {
        fatalError("Never called")
    }
    
}


extension PropertyMapping.ForwarderOptionalRhs {
    
    func adapt(to lhs: L, from rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) {
        fatalError("Never called")
    }
    
    func apply(from lhs: L, to rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: L, _ rhs: PropertyMapping<L, R, V>.ForwarderOptionalRhs<L, R, V>) -> Bool {
        fatalError("Never called")
    }
    
}


extension PropertyMapping.ForwarderOptionalBoth {
    
    func adapt(to lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, from rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) {
        fatalError("Never called")
    }
    
    func apply(from lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, to rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) {
        fatalError("Never called")
    }
    
    func differs(_ lhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>, _ rhs: PropertyMapping<L, R, V>.ForwarderOptionalBoth<L, R, V>) -> Bool {
        fatalError("Never called")
    }
    
}

