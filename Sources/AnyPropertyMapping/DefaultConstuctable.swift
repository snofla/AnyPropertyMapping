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




