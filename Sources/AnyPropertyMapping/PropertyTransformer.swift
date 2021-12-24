//
//  File.swift
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


public protocol AnyPropertyTransformer {

    /// Transformation for adapt operation, returns nil if transformation failed
    func _adapt(from: Any) throws -> Any
    
    /// Transformation for apply operation, returns nil if transformation failed
    func _apply(from: Any) throws -> Any
    
    /// Returns the inverse of a transformer
    func inverted() -> AnyPropertyTransformer
    
}

public protocol AnyPropertyTransformerOperations {
    
    associatedtype LhsValue
    associatedtype RhsValue
    
    /// Adapt operation accepting an RHS value, returning an LHS value.
    /// The operation should throw `.invalidTransformation` when
    /// the transformation failed.
    var adapt: ((RhsValue) throws -> LhsValue)? { get }
    
    /// Adapt operation accepting an RHS value, returning an LHS value.
    /// The operation should throw `.invalidTransformation` when
    /// the transformation failed.
    var apply: ((LhsValue) throws -> RhsValue)? { get }
}


public struct PropertyTransformer<LhsValue, RhsValue>: AnyPropertyTransformer, AnyPropertyTransformerOperations {
    
    public func _adapt(from: Any) throws -> Any {
        guard let from = from as? RhsValue else {
            throw PropertyTransformerError.invalidInput
        }
        guard let result = try self.adapt?(from) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return result
    }
    
    public func _apply(from: Any) throws -> Any {
        guard let from = from as? LhsValue else {
            throw PropertyTransformerError.invalidInput
        }
        guard let result = try self.apply?(from) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return result
    }
    
    public func inverted() -> AnyPropertyTransformer {
        return PropertyTransformer<RhsValue, LhsValue>.init(adapt: self.apply, apply: self.adapt)
    }
    
    public var adapt: ((RhsValue) throws -> LhsValue)?
    public var apply: ((LhsValue) throws -> RhsValue)?
}



