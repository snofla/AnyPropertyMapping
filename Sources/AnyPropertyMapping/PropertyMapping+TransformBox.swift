//
//  PropertyMapping+TransformBox.swift
//  
//
//  Created by Alfons Hoogervorst on 24/12/2021.
//

import Foundation


extension PropertyMapping {
    
    struct PropertyMappingTransformBoxAsIs<L: AnyObject, R: AnyObject, LV: Equatable, RV: Equatable>: PropertyMappingBox {
        
        typealias Left = L
        typealias Right = R
        typealias LValue = LV
        typealias RValue = RV
        
        init(leftKeyPath: WritableKeyPath<L, LValue>, rightKeyPath: WritableKeyPath<R, RValue>, transformer: PropertyTransformer<LValue, RValue>) {
            self._leftKeyPath = leftKeyPath
            self._rightKeyPath = rightKeyPath
            self._transformer = transformer
        }
        
        func adapt(to lhs: Any, from rhs: Any) {
            var lhs = lhs as! Left
            let rhs = rhs as! Right
            guard let transformedLhsValue = try? self._transformer._adapt(from: rhs[keyPath: self._rightKeyPath]) as? LValue else {
                return
            }
            lhs[keyPath: self._leftKeyPath] = transformedLhsValue
        }
        
        func apply(from lhs: Any, to rhs: Any) {
            let lhs = lhs as! Left
            var rhs = rhs as! Right
            guard let transformedRhsValue = try? self._transformer._apply(from: lhs[keyPath: self._leftKeyPath]) as? RValue else {
                return
            }
            rhs[keyPath: self._rightKeyPath] = transformedRhsValue
        }
        
        func inverted() -> AnyPropertyMapping {
            typealias InvertedSelf = PropertyMappingTransformBoxAsIs<R, L, RValue, LValue>
            // note: InvertedSelf.LValue == R
            typealias InvertedTransformer = PropertyTransformer<InvertedSelf.LValue, InvertedSelf.RValue>
            let invertedTransformer = self._transformer.inverted() as! InvertedTransformer
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
        let _transformer: AnyPropertyTransformer
    }
    
}
