//
//  File.swift
//  
//
//  Created by Alfons Hoogervorst on 29/01/2022.
//

import Foundation

// Swift 5.5 can not infer constructor when L == R, so rather
// use a convenience constructor.
// See: https://bugs.swift.org/browse/SR-15706

#if (swift(>=5.5) && swift(<5.6))
public extension PropertyMapping where L == R {
    
    /// Constructs a mapping between two instances of the same object. This is useful for selectively "copying"
    /// fields between two instances. Depending on the type of the value the keypath is referring to an actual
    /// copy is created (value types), or a reference is stored (class types).
    /// The keypath refers to non-optional properties.
    ///
    /// - Parameters:
    ///   - lhs: Object's keypath
    ///
    /// - Remark:
    /// Available only for Swift 5.4, and Swift 5.6+. For Swift 5.5 see: https://bugs.swift.org/browse/SR-15706
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    ///     var double: Double
    /// }
    ///
    /// // will only copy the `double` property when mapping is used.
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.double),
    /// ]
    /// ````
    convenience init<LV>(_ lhs: WritableKeyPath<L, LV>) where LV: (Equatable & DefaultConstructable) {
        self.init(lhs, lhs)
    }
    
    
    /// Constructs a mapping between two instances of the same object. This is useful for selectively "copying"
    /// fields between two instances. Depending on the type of the value the keypath is referring to an actual
    /// copy is created (value types), or a reference is stored (class types).
    /// The keypath refers to optional properties.
    ///
    /// - Parameters:
    ///   - lhs: Object's keypath
    /// - Remark:
    /// Available only for Swift 5.4, and Swift 5.6+. For Swift 5.5 see: https://bugs.swift.org/browse/SR-15706
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    ///     var double: Double
    /// }
    ///
    /// // will only copy the `int` property when mapping is used.
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.int),
    /// ]
    /// ````
    convenience init<LV>(_ lhs: WritableKeyPath<L, LV?>) where LV: (Equatable & DefaultConstructable), R == L {
        self.init(lhs, lhs)
    }
    
}
#endif
