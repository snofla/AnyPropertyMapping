//
//  PropertyTransformer+Privates.swift
//  
//
//  Created by Alfons Hoogervorst on 25/12/2021.
//

import Foundation

internal protocol _AnyPropertyTransformer {

    /// Transformation for adapt operation, returns nil if transformation failed
    func _adapt(from: Any) throws -> Any
    
    /// Transformation for apply operation, returns nil if transformation failed
    func _apply(from: Any) throws -> Any
    
    /// Returns the inverse of a transformer
    func _inverted() -> _AnyPropertyTransformer
}


internal protocol _AnyPropertyTransformerOperations {
    
    associatedtype LhsValue
    associatedtype RhsValue
    
    /// Adapt operation accepting an RHS value, returning an LHS value.
    /// The operation should throw `.invalidTransformation` when
    /// the transformation failed.
    var _adapt: ((RhsValue) throws -> LhsValue)? { get }
    
    /// Adapt operation accepting an RHS value, returning an LHS value.
    /// The operation should throw `.invalidTransformation` when
    /// the transformation failed.
    var _apply: ((LhsValue) throws -> RhsValue)? { get }
}


internal extension PropertyTransformer {
    
    func _adapt(from: Any) throws -> Any {
        assert(from as? RhsValue != nil)
        let from = from as! RhsValue
        guard let result = try self._adapt?(from) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return result
    }
    
    func _apply(from: Any) throws -> Any {
        assert(from as? LhsValue != nil)
        let from = from as! LhsValue
        guard let result = try self._apply?(from) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return result
    }
    
    func _inverted() -> _AnyPropertyTransformer {
        return self.inverted()
    }
    
}

