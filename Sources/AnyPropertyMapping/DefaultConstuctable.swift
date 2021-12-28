//
//  DefaultConstuctable.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 17/12/2021.
//

import Foundation


/// Types that have a default constructor
public protocol DefaultConstructable {
    init()
}


// Optional is a special case, and doesn't have a default constructor
extension Optional: DefaultConstructable where Wrapped: DefaultConstructable {
    
    /// Adds a default constructor for `Optional`, where  it is assigned`.some` with the default value
    /// for the `Wrapped` type (where `Wrapped` conforms to `DefaultConstructable`).
    public init() {
        self = .some(Wrapped())
    }

}


// Scalars
extension Bool: DefaultConstructable {}
extension Int8: DefaultConstructable {}
extension UInt8: DefaultConstructable {}
extension Int: DefaultConstructable {}
extension Int32: DefaultConstructable {}
extension Int64: DefaultConstructable {}
extension UInt: DefaultConstructable {}
extension UInt32: DefaultConstructable {}
extension UInt64: DefaultConstructable {}

extension Float: DefaultConstructable {}
extension Double: DefaultConstructable {}

extension UUID: DefaultConstructable {}
extension Date: DefaultConstructable {}
extension String: DefaultConstructable {}




