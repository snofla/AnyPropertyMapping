//
//  PropertyTransformer.swift
//  
//
//  Created by Alfons Hoogervorst on 24/12/2021.
//

import Foundation

public enum PropertyTransformerError: Error {
    /// Not implemented
    case notImplemented
    /// Either lhs or rhs has the wrong type
    case invalidInput
    /// Transformation was not successful
    case invalidTransformation
}


public struct PropertyTransformer<LhsValue, RhsValue>: _AnyPropertyTransformer, _AnyPropertyTransformerOperations {
    
    /// Construct a transformer with `adapt` and `apply` functions.
    /// - Parameters:
    ///   - adapt: `adapt` function
    ///   - apply: `apply` function
    public init(adapt: ((RhsValue) throws -> LhsValue)?, apply: ((LhsValue) throws -> RhsValue)?) {
        self._adapt = adapt
        self._apply = apply
    }
    
    /// Returns the inverse of a transformer
    /// - Returns: Inverse transformer
    public func inverted() -> PropertyTransformer<RhsValue, LhsValue> {
        return PropertyTransformer<RhsValue, LhsValue>(adapt: self._apply, apply: self._adapt)
    }
    
    internal var _adapt: ((RhsValue) throws -> LhsValue)?
    internal var _apply: ((LhsValue) throws -> RhsValue)?
}



