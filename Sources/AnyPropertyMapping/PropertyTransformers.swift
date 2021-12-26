//
//  PropertyTransformers-Impl.swift
//  
//
//  Created by Alfons Hoogervorst on 24/12/2021.
//

import Foundation


public extension PropertyTransformer {
    
    /// Returns a property transformer that always fails
    static var alwaysFailing: PropertyTransformer<LhsValue, RhsValue> {
        return PropertyTransformer<LhsValue, RhsValue> { _ in
            throw PropertyTransformerError.invalidTransformation
        } apply: { _ in
            throw PropertyTransformerError.invalidTransformation
        }
    }
    
    /// Returns a nil transformer
    static var none: PropertyTransformer<LhsValue, RhsValue> {
        return PropertyTransformer(adapt: nil, apply: nil)
    }
    
}


public struct PropertyTransformers {
    
    /// Converts a string to an int and vice versa
    public static let intString = PropertyTransformer<Int, String>.init { string in
        guard let int = Int(string) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return int
    } apply: { int in
        return String(int)
    }

    /// Converts a double to an int
    public static let intDouble = PropertyTransformer<Int, Double>.init { double in
        return Int(double.rounded())
    } apply: { int in
        return Double(int)
    }
    
}





