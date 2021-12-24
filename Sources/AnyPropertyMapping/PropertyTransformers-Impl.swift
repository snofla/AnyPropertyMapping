//
//  PropertyTransformers-Impl.swift
//  
//
//  Created by Alfons Hoogervorst on 24/12/2021.
//

import Foundation


public struct PropertyTransformers {
    
    /// Converts a uuid to string and vice versa
    public static let uuidString = PropertyTransformer<UUID, String>.init { string in
        guard let uuid = UUID(uuidString: string) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return uuid
    } apply: { uuid in
        return uuid.uuidString
    }
    
    /// Converts a string to an int and vice versa
    public static let intString = PropertyTransformer<Int, String>.init { string in
        guard let int = Int(string) else {
            throw PropertyTransformerError.invalidTransformation
        }
        return int
    } apply: { int in
        return String(int)
    }


}





