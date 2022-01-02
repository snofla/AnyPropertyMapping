//
//  AnyPropertyMapping.swift
//
//  Created by Alfons Hoogervorst on 02/12/2021.
//  Copyright © 2021 Elastique. All rights reserved.
//

import Foundation


/// Type erasing base protocol
public protocol AnyPropertyMapping {
    
    /// Adapts mapping from right-hand side argument to left-hand side argument. The type of
    /// both arguments is defined by the conforming classes.
    @discardableResult
    func adapt(to lhs: Any, from rhs: Any) -> Any
    
    /// Applies mapping from left-hand side argument to right-hand side argument. The type of
    /// both arguments is defined by the conforming classes.
    @discardableResult
    func apply(from lhs: Any, to rhs: Any) -> Any
    
    /// Checks if left-hand and righ-hand side arguments are different. The type of
    /// both arguments is defined by the conforming classes.
    func differs(_ lhs: Any, _ rhs: Any) -> Bool
    
    /// Returns the inverse of a property mapping
    func inverted() -> AnyPropertyMapping
    
    /// Left keypath. This can be cast to a writable keypath if the Root and
    /// Value are known.
    var leftKeyPath: AnyKeyPath { get }
    
    /// Right keypath. This can be cast to a writable keypath if the Root and
    /// Value are known.
    var rightKeyPath: AnyKeyPath { get }
}
