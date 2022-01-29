//
//  PropertyMapping.swift
//  AnyPropertyMapping
//
//  Created by Alfons Hoogervorst on 18/12/2021.
//

import Foundation

/// Sets up a mapping between two properties of two different classes. This is used as
/// a concrete generic implementation. Swift's type inference will make sure the correct
/// constructor is chosen depending on the use of the class.
public final class PropertyMapping<L: AnyObject, R: AnyObject>: AnyPropertyMapping  {
    
    // Implementation: we forward operations to a box class,
    // each having a different constructor to support optionals in
    // either the lhs or rhs keypath value, or both.
    
    /// Constructs a mapping between two object's properties. Both properties are _both_ non-optional, and
    /// are of the same type.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int
    /// }
    ///
    /// class RHS {
    ///     var int: Int
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.int, \RHS.int)
    /// ]
    /// ````
    public init<V>(_ lhs: WritableKeyPath<L, V>, _ rhs: WritableKeyPath<R, V>) where V: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingBoxAsIs(leftKeyPath: lhs, rightKeyPath: rhs)
    }

    /// Constructs a mapping between two object's properties. The lefr-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    /// }
    ///
    /// class RHS {
    ///     var int: Int
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.int, \RHS.int)
    /// ]
    /// ````
    public init<V>(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V>) where V: (Equatable & DefaultConstructable)  {
        self.boxedImpl = _PropertyMappingBoxOptionalLhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties. The right-hand side object's property
    /// is an optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int
    /// }
    ///
    /// class RHS {
    ///     var int: Int?
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.int, \RHS.int)
    /// ]
    /// ````
    public init<V>(_ lhs: WritableKeyPath<L, V>, _ rhs: WritableKeyPath<R, V?>) where V: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingBoxOptionalRhs(leftKeyPath: lhs, rightKeyPath: rhs)
    }

    /// Constructs a mapping between two object's properties. Both left-hand side and  right-hand side object's
    /// properties are optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    /// }
    ///
    /// class RHS {
    ///     var int: Int?
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(\LHS.int, \RHS.int)
    /// ]
    /// ````
    public init<V>(_ lhs: WritableKeyPath<L, V?>, _ rhs: WritableKeyPath<R, V?>) where V: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingBoxOptionalBoth(leftKeyPath: lhs, rightKeyPath: rhs)
    }
    
    /// Constructs a mapping between two object's properties, where the properties
    /// are of different types. Properties are _both_ non-optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath
    ///   - transformer: Transformer to use
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int
    /// }
    ///
    /// class RHS {
    ///     var double: Double
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(
    ///         \LHS.int,
    ///         \RHS.double,
    ///         transformer: PropertyTransformers.intDouble
    ///     )
    /// ]
    /// ````
    public init<LV, RV>(_ lhs: WritableKeyPath<L, LV>, _ rhs: WritableKeyPath<R, RV>, transformer: PropertyTransformer<LV, RV>) where LV: (Equatable & DefaultConstructable), RV: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingTransformerBoxAsIs(leftKeyPath: lhs, rightKeyPath: rhs, transformer: transformer)
    }
    
    /// Constructs a mapping between two object's properties, where the properties
    /// are of different types. The left-hand side property is optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath to optional property
    ///   - rhs: Right-hand side object's keypath
    ///   - transformer: Transformer to use
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    /// }
    ///
    /// class RHS {
    ///     var double: Double
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(
    ///         \LHS.int,
    ///         \RHS.double,
    ///         transformer: PropertyTransformers.intDouble
    ///     )
    /// ]
    /// ````
    public init<LV, RV>(_ lhs: WritableKeyPath<L, LV?>, _ rhs: WritableKeyPath<R, RV>, transformer: PropertyTransformer<LV, RV>) where LV: (Equatable & DefaultConstructable), RV: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingTransformerBoxOptionalLhs(leftKeyPath: lhs, rightKeyPath: rhs, transformer: transformer)
    }

    /// Constructs a mapping between two object's properties, where the properties
    /// are of different types. The right-hand side property is optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath  to optional property
    ///   - transformer: Transformer to use
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int
    /// }
    ///
    /// class RHS {
    ///     var double: Double?
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(
    ///         \LHS.int,
    ///         \RHS.double,
    ///         transformer: PropertyTransformers.intDouble
    ///     )
    /// ]
    /// ````
    public init<LV, RV>(_ lhs: WritableKeyPath<L, LV>, _ rhs: WritableKeyPath<R, RV?>, transformer: PropertyTransformer<LV, RV>) where LV: (Equatable & DefaultConstructable), RV: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingTransformerBoxOptionalRhs(leftKeyPath: lhs, rightKeyPath: rhs, transformer: transformer)
    }

    /// Constructs a mapping between two object's properties, where the properties
    /// are of different types. Both left-hand and right-hand side properties are optional.
    /// - Parameters:
    ///   - lhs: Left-hand side object's keypath
    ///   - rhs: Right-hand side object's keypath  to optional property
    ///   - transformer: Transformer to use
    ///
    /// Example:
    /// ```
    /// class LHS {
    ///     var int: Int?
    /// }
    ///
    /// class RHS {
    ///     var double: Double?
    /// }
    ///
    /// let mapping: [AnyPropertyMapping] = [
    ///     PropertyMapping(
    ///         \LHS.int,
    ///         \RHS.double,
    ///         transformer: PropertyTransformers.intDouble
    ///     )
    /// ]
    /// ````
    public init<LV, RV>(_ lhs: WritableKeyPath<L, LV?>, _ rhs: WritableKeyPath<R, RV?>, transformer: PropertyTransformer<LV, RV>) where LV: (Equatable & DefaultConstructable), RV: (Equatable & DefaultConstructable) {
        self.boxedImpl = _PropertyMappingTransformerBoxOptionalBoth(leftKeyPath: lhs, rightKeyPath: rhs, transformer: transformer)
    }
    
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
    #if (swift(>=5.3) && swift(<5.5)) || swift(>=5.6)
    public init<LV>(_ lhs: WritableKeyPath<L, LV>) where LV: Equatable, R == L {
        self.boxedImpl = _PropertyMappingBoxAsIs(leftKeyPath: lhs, rightKeyPath: lhs)
    }
    #endif
    
    
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
    #if (swift(>=5.3) && swift(<5.5)) || swift(>=5.6)
    public init<LV>(_ lhs: WritableKeyPath<L, LV?>) where LV: (Equatable & DefaultConstructable), R == L {
        self.boxedImpl = _PropertyMappingBoxOptionalBoth(leftKeyPath: lhs, rightKeyPath: lhs)
    }
    #endif
    
    /// Left-hand side keypath
    public var leftKeyPath: AnyKeyPath {
        return self.boxedImpl.leftKeyPath
    }
    
    /// Right-hand side keypath
    public var rightKeyPath: AnyKeyPath {
        return self.boxedImpl.rightKeyPath
    }
    
    internal let boxedImpl: AnyPropertyMapping
}


extension PropertyMapping {
    
    public func adapt(to lhs: Any, from rhs: Any) {
        PropertyMapping.testArguments(#function, lhs, rhs)
        self.boxedImpl.adapt(to: lhs, from: rhs)
    }
    
    public func apply(from lhs: Any, to rhs: Any) {
        PropertyMapping.testArguments(#function, lhs, rhs)
        self.boxedImpl.apply(from: lhs, to: rhs)
    }
    
    public func differs(_ lhs: Any, _ rhs: Any) -> Bool {
        PropertyMapping.testArguments(#function, lhs, rhs)
        return self.boxedImpl.differs(lhs, rhs)
    }
    
    public func inverted() -> AnyPropertyMapping {
        return self.boxedImpl.inverted()
    }
    
}


extension PropertyMapping: Hashable {
    
    public static func == (lhs: PropertyMapping<L, R>, rhs: PropertyMapping<L, R>) -> Bool {
        return lhs.leftKeyPath == rhs.leftKeyPath && lhs.rightKeyPath == rhs.rightKeyPath
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.leftKeyPath)
        hasher.combine(self.rightKeyPath)
    }
    
}
