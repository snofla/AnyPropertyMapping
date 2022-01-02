//
//  PropertyMapping+TransformerBox.swift
//  
//
//  Created by Alfons Hoogervorst on 24/12/2021.
//

import Foundation


extension PropertyMapping {
    
    struct _PropertyMappingTransformerBoxAsIs<L: AnyObject, R: AnyObject, LV: Equatable, RV: Equatable>: _PropertyMappingBox {
        
        typealias Left = L
        typealias Right = R
        typealias LValue = LV
        typealias RValue = RV
        
        init(leftKeyPath: WritableKeyPath<L, LValue>, rightKeyPath: WritableKeyPath<R, RValue>, transformer: PropertyTransformer<LValue, RValue>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = rightKeyPath
            self._transformer = transformer
        }
        
        func adapt(to lhs: Any, from rhs: Any) -> Any {
            var lhs = lhs as! Left
            let rhs = rhs as! Right
            guard let transformedLhsValue = try? self._transformer._adapt(from: rhs[keyPath: self._rightKeyPath]) as? LValue else {
                return lhs
            }
            lhs[keyPath: self._leftKeyPath] = transformedLhsValue
            return lhs
        }
        
        func apply(from lhs: Any, to rhs: Any) -> Any {
            let lhs = lhs as! Left
            var rhs = rhs as! Right
            guard let transformedRhsValue = try? self._transformer._apply(from: lhs[keyPath: self._leftKeyPath]) as? RValue else {
                return rhs
            }
            rhs[keyPath: self._rightKeyPath] = transformedRhsValue
            return rhs
        }
        
        func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            let lhs = lhs as! Left
            let rhs = rhs as! Right
            guard let transformedLhsValue = try? self._transformer._adapt(from: rhs[keyPath: self._rightKeyPath]) as? LValue else {
                return true
            }
            return lhs[keyPath: self._leftKeyPath] != transformedLhsValue
        }
        
        func inverted() -> AnyPropertyMapping {
            typealias InvertedSelf = _PropertyMappingTransformerBoxAsIs<R, L, RValue, LValue>
            // note: InvertedSelf.LValue == R
            typealias InvertedTransformer = PropertyTransformer<InvertedSelf.LValue, InvertedSelf.RValue>
            let invertedTransformer = self._transformer._inverted() as! InvertedTransformer
            return InvertedSelf.init(leftKeyPath: self._rightKeyPath, rightKeyPath: self._leftKeyPath, transformer: invertedTransformer)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._leftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._rightKeyPath
        }
        
        let _leftKeyPath: WritableKeyPath<L, LValue>
        let _rightKeyPath: WritableKeyPath<R, RValue>
        let _transformer: _AnyPropertyTransformer
    }
    
    
    final class _PropertyMappingTransformerBoxOptionalLhs<L: AnyObject, R: AnyObject, LV: Equatable & DefaultConstructable, RV: Equatable & DefaultConstructable>: _PropertyMappingBox {

        // For the LHS we don't want to use L, because that would mean that
        // _leftKeyPath would be pointing to a V, and not a V?. _leftKeyPath
        // becomes a dummy, and we introduce _realLeftKeyPath to point to
        // a WritableKeyPath<L, V?>
        typealias Left = _PropertyMappingTransformerBoxOptionalLhs
        typealias Right = R
        typealias LValue = LV
        typealias RValue = RV
        
        init(leftKeyPath: WritableKeyPath<L, LValue?>, rightKeyPath: WritableKeyPath<R, RValue>, transformer: PropertyTransformer<LValue, RValue>) {
            self._realLeftKeyPath = leftKeyPath
            self._leftKeyPath = \Self._stub
            self._rightKeyPath = rightKeyPath
            self._transformer = transformer
        }

        public func adapt(to lhs: Any, from rhs: Any) -> Any {
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            guard let transformedLhsValue = try? self._transformer._adapt(from: _rhs[keyPath: self._rightKeyPath]) as? LValue else {
                return _lhs
            }
            _lhs[keyPath: self._realLeftKeyPath] = transformedLhsValue
            return _lhs
        }
        
        public func apply(from lhs: Any, to rhs:  Any) -> Any {
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning optional value (lhs) to non-optional (rhs) is not
            // allowed: use the default value
            guard let transformedRhsValue = try? self._transformer._apply(from: _lhs[keyPath: self._realLeftKeyPath] ?? LValue()) as? RValue else {
                return _rhs
            }
            _rhs[keyPath: self._rightKeyPath] = transformedRhsValue
            return _rhs
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            guard let transformedLhsValue = try? self._transformer._adapt(from: _rhs[keyPath: self._rightKeyPath]) as? LValue else {
                return true
            }
            let lhsValue = _lhs[keyPath: self._realLeftKeyPath] ?? LValue()
            return lhsValue != transformedLhsValue
        }
        
        public func inverted() -> AnyPropertyMapping {
            typealias InvertedSelf = _PropertyMappingTransformerBoxOptionalRhs<R, L, RValue, LValue>
            // note: InvertedSelf.LValue == R
            typealias InvertedTransformer = PropertyTransformer<InvertedSelf.LValue, InvertedSelf.RValue>
            let invertedTransformer = self._transformer._inverted() as! InvertedTransformer
            return InvertedSelf.init(leftKeyPath: self._rightKeyPath, rightKeyPath: self._realLeftKeyPath, transformer: invertedTransformer)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._realLeftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._rightKeyPath
        }
        
        // We make _leftKeyPath just point to a _stub to be conformant
        // to base protocol
        var _leftKeyPath: WritableKeyPath<Left, LValue>
        let _rightKeyPath: WritableKeyPath<R, RValue>
        fileprivate let _realLeftKeyPath: WritableKeyPath<L, LValue?>
        fileprivate var _stub = LValue()
        let _transformer: _AnyPropertyTransformer
    }
    
    
    final class _PropertyMappingTransformerBoxOptionalRhs<L: AnyObject, R: AnyObject, LValue: Equatable & DefaultConstructable, RValue: Equatable & DefaultConstructable>: _PropertyMappingBox {

        // For the RHS we don't want to use R, because that would mean that
        // _rightKeyPath would be pointing to a V, and not a V?. _rightKeyPath
        // becomes a dummy, and we introduce _realRightKeyPath to point to
        // a WritableKeyPath<R, V?>
        typealias Left = L
        typealias Right = _PropertyMappingTransformerBoxOptionalRhs
        typealias LValue = LValue
        typealias RValue = RValue
        
        init(leftKeyPath: WritableKeyPath<L, LValue>, rightKeyPath: WritableKeyPath<R, RValue?>, transformer: PropertyTransformer<LValue, RValue>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = \Self._stub
            self._realRighKeyPath = rightKeyPath
            self._transformer = transformer
        }

        public func adapt(to lhs: Any, from rhs: Any) -> Any {
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning optional to non-optional requires a default value
            guard let transformedLhsValue = try? self._transformer._adapt(from: _rhs[keyPath: self._realRighKeyPath] ?? RValue()) as? LValue else {
                return _lhs
            }
            _lhs[keyPath: self._leftKeyPath] = transformedLhsValue
            return _lhs
        }
        
        public func apply(from lhs: Any, to rhs:  Any) -> Any {
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning non-optional to optional is always possible
            guard let transformedRhsValue = try? self._transformer._apply(from: _lhs[keyPath: self._leftKeyPath]) as? RValue else {
                return _rhs
            }
            _rhs[keyPath: self._realRighKeyPath] = transformedRhsValue
            return _rhs
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            guard let transformedRhsValue = try? self._transformer._apply(from: _lhs[keyPath: self._leftKeyPath]) as? RValue else {
                return true
            }
            // unwrap if needed, choose default value
            let rhsValue = _rhs[keyPath: self._realRighKeyPath] ?? RValue()
            return transformedRhsValue != rhsValue
        }
        
        public func inverted() -> AnyPropertyMapping {
            typealias InvertedSelf = _PropertyMappingTransformerBoxOptionalLhs<R, L, RValue, LValue>
            // note: InvertedSelf.LValue == R
            typealias InvertedTransformer = PropertyTransformer<InvertedSelf.LValue, InvertedSelf.RValue>
            let invertedTransformer = self._transformer._inverted() as! InvertedTransformer
            return InvertedSelf.init(leftKeyPath: self._realRighKeyPath, rightKeyPath: self._leftKeyPath, transformer: invertedTransformer)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._leftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._realRighKeyPath
        }
        
        let _leftKeyPath: WritableKeyPath<L, LValue>
        let _rightKeyPath: WritableKeyPath<Right, RValue>
        fileprivate let _realRighKeyPath: WritableKeyPath<R, RValue?>
        fileprivate var _stub = RValue()
        fileprivate let _transformer: _AnyPropertyTransformer
    }
    
    
    final class _PropertyMappingTransformerBoxOptionalBoth<L: AnyObject, R: AnyObject, LValue: Equatable & DefaultConstructable, RValue: Equatable & DefaultConstructable>: _PropertyMappingBox {

        typealias Left = _PropertyMappingTransformerBoxOptionalBoth
        typealias Right = _PropertyMappingTransformerBoxOptionalBoth
        typealias LValue = LValue
        typealias RValue = RValue
        
        init(leftKeyPath: WritableKeyPath<L, LValue?>, rightKeyPath: WritableKeyPath<R, RValue?>, transformer: PropertyTransformer<LValue, RValue>) {
            self._leftKeyPath = \Self._lvstub
            self._rightKeyPath = \Self._rvstub
            self._realLeftKeyPath = leftKeyPath
            self._realRighKeyPath = rightKeyPath
            self._transformer = transformer
        }

        public func adapt(to lhs: Any, from rhs: Any) -> Any {
            var _lhs = lhs as! L
            let _rhs = rhs as! R
            // assigning optional to optional is always possible
            let _rhsValue = _rhs[keyPath: self._realRighKeyPath] ?? RValue()
            // transform rhs to make an lhs
            guard let transformedLhsValue = try?  self._transformer._adapt(from: _rhsValue) as? LValue else {
                // failed transformation, don't touch
                return _lhs
            }
            _lhs[keyPath: self._realLeftKeyPath] = transformedLhsValue
            return _lhs
        }
        
        public func apply(from lhs: Any, to rhs:  Any) -> Any {
            let _lhs = lhs as! L
            var _rhs = rhs as! R
            // assigning optional to optional is always possible
            let lhsValue = _lhs[keyPath: self._realLeftKeyPath] ?? LValue()
            guard let transformedRhsValue = try? self._transformer._apply(from: lhsValue) as? RValue else {
                // failed transformation, don't touch
                return _rhs
            }
            _rhs[keyPath: self._realRighKeyPath] = transformedRhsValue
            return _rhs
        }
        
        public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
            let _lhs = lhs as! L
            let _rhs = rhs as! R
            let _lhsValue = _lhs[keyPath: self._realLeftKeyPath]
            let _rhsValue = _rhs[keyPath: self._realRighKeyPath]
            if _lhsValue == nil && _rhsValue == nil {
                return false
            }
            // change rhsValue into lhsValue
            guard let transformedLhsValue = try? self._transformer._adapt(from: _rhsValue ?? RValue()) else {
                // transformation failed, lhs and rhs values
                // are different
                return true
            }
            // unwrap if needed, choose default value
            return (_lhsValue ?? LValue()) != (transformedLhsValue as? LValue ?? LValue())
        }
        
        public func inverted() -> AnyPropertyMapping {
            typealias InvertedSelf = _PropertyMappingTransformerBoxOptionalBoth<R, L, RValue, LValue>
            // note: InvertedSelf.LValue == R
            typealias InvertedTransformer = PropertyTransformer<InvertedSelf.LValue, InvertedSelf.RValue>
            let invertedTransformer = self._transformer._inverted() as! InvertedTransformer
            return InvertedSelf.init(leftKeyPath: self._realRighKeyPath, rightKeyPath: self._realLeftKeyPath, transformer: invertedTransformer)
        }
        
        var leftKeyPath: AnyKeyPath {
            return self._realLeftKeyPath
        }
        
        var rightKeyPath: AnyKeyPath {
            return self._realRighKeyPath
        }

        /// Unused for the both optional L, R case
        let _leftKeyPath: WritableKeyPath<Left, LValue>
        
        /// Unused for the both optional L, R case
        let _rightKeyPath: WritableKeyPath<Right, RValue>

        fileprivate let _realLeftKeyPath: WritableKeyPath<L, LValue?>
        fileprivate let _realRighKeyPath: WritableKeyPath<R, RValue?>
        fileprivate var _lvstub = LValue()
        fileprivate var _rvstub = RValue()
        fileprivate let _transformer: _AnyPropertyTransformer
    }
    
}
