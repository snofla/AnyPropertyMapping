# AnyPropertyMapping

[![CocoaPods](https://img.shields.io/cocoapods/v/AnyPropertyMapping.svg?maxAge=2592000?style=flat-square)]()
![Build](https://github.com/snofla/AnyPropertyMapping/actions/workflows/swift.yml/badge.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)


<!--ts-->
* [AnyPropertyMapping](#anypropertymapping)
   * [Installation](#installation)
   * [Usage](#usage)
      * [Simplest case: mapping object properties of the same type](#simplest-case-mapping-object-properties-of-the-same-type)
      * [General case: mapping object properties of different types](#general-case-mapping-object-properties-of-different-types)
   * [Convenience functions](#convenience-functions)
   * [Notes](#notes)
   * [Author(s)](#authors)
   * [Thanks](#thanks)
   * [License](#license)

<!-- Added by: alfons, at: Sun Dec 26 18:27:52 CET 2021 -->

<!--te-->


AnyPropertyMapping provides a convenient way to map properties of class types, and perform operations on instances of them, in both directions. The mapping is entirely based on keypaths. Optional properties are supported out of the box. Since the library depends heavily on keypaths: if the keypath syntax supports it, the library will support it.

Inspiration came from the need to quickly create mocking or intermediate objects between different layers (network or data, or even UI). There's a fairly comprehensive, but not complete, set of utility functions available, and the core functionality (handling keypaths and type erasure especially) are covered by unit tests.

This library uses generics and leans heavily on type erasure: Swift 5+ only, not sure if this is conceptually possible at all with older Swift versions. Swift's static typing makes this rather ... let's call it euphemistically: non-trivial.



## Installation

Add the following dependency to your **Package.swift** file:

```swift
.package(url: "https://github.com/snofla/AnyPropertyMapping.git", from: "1.1.0")
```

Or, if you're using CocoaPods, add the following line to your **Podfile**:

````ruby
pod 'AnyPropertyMapping'
````



## Usage

### Simplest case: mapping object properties of the same type

The simplest case is where the left-hand side object properties are of the same type as the right-hand side object properties. It doesn't matter whether either side's properties are *optional or not* (and the objects themselves may even be of the same type).

Set up a mapping table between two classes, and it works automagically. Promised!

Just kidding.

Suppose you have one class in a network layer:

```swift
class UserAdressFromNetwork {
  var userName: String?
  var address: String
  var id: Int
}
```

Your own layer may have a slightly different implementation:

```swift
class UserAddressInUI {

  class Technical {
    var id: Int = -1
  }
  
  init(id: Int, familyName: String, address: String?) {    
    self.technical.id = id
    self.familyName = familyName
    self.address = address
  }
  
  var familyName: String
  var address: String?  
  var technical = Technical()  
}
```

*Of particular note*: the classes use optionals, and there's an inner class involved.

`AnyPropertyMapping` provides four operations, but the most important two are: 

* `adapt(to:from)`: which moves data into left-hand side class instances (direction: ←)
* `apply(from:to:)`: which moves data into right-hand side class instances (direction: →)

You can just set up a mapping as follows, and call the mapping operations:

```swift
let mapping: [AnyPropertyMapping] = [
  // Remember: the direction is ←
  PropertyMapping(\UserAddressInUI.familyName, \UserAdressFromNetwork.userName),
  PropertyMapping(\UserAddressInUI.address, \UserAddressFromNetwork.address),
  PropertyMapping(\UserAddressInUI.technical.id, \UserAddressFromNetwork.id)
]

let a: UserAddressInUI = ...
let b: UserAdressFromNetwork = ...
// adapt from network layer data ←
mapping.forEach { $0.adapt(to: a, from: b) }
...
// make changes to a
...
// apply after changes → (move back into rhs):
mapping.forEach { $0.apply(from: a, to: b)  }

```

That's basically it.

### General case: mapping object properties of different types

A more common case is that the target and source have fields of different types; in that case some sort of transformation has to take place. This is also supported by **AnyPropertyMapping** by way of a special generic class called a **PropertyTransformer**. The **PropertyMapping** class has constructors that accept an instance of **PropertyTransformer**.

The **PropertyTransformer** constructor accepts two closures: 

*  **adapt(_:)** which accepts an instance of the type of the source (right-hand side) and returns an instance of the type of the target (left-hand side). 
* **apply(_:)**  which does the inverse of **adapt(_:)** and accepts an instance of the target (left-hand side), returning an instance of the source (right-hand side).

Here's an example of what a transformer for **Double** to **Int** looks like:

````swift
class YourTransformers {
    /// Converts a double to an int
    public static let intDouble = PropertyTransformer<Int, Double>(adapt: { double in
        return Int(double.rounded())
    } apply: { int in
        return Double(int)
    })
}
````

Let's demonstrate how to setup a mapping using a transformer use this with actual classes:

````swift
class A {
  var optionalInt: Int? = 1
}

class B {
  var nonOptionalDouble: Double = 3.0
}

let mapping: [AnyPropertyMapping] = [
    PropertyMapping(
      \A.optionalInt, 
      \B.nonOptionalDouble, 
      transformer: YourTransformers.intDouble
    )  
]
let a = A()
let b = B()
mapping.adapt(to: a, from: b)
// do something
mapping.apply(from: a, to: b)
````

If the operations involve *optional* properties (either-hand side), those are implicitly transformed using default values. This is the reason why transformers don't need to handle optional types in any special way.

Notice how the the transformer's **adapt** and **apply** operations closely mirror those of a property mapping. If you have two clasess **A** and **B** then an **adapt** always has the ← direction (rhs to lhs), and **apply** the other way around (→,  lhs to rhs):

* **adapt = A ← B**
* **apply = A → B**

To handle the inverse scenario, **PropertyTransformer** offers the **inverted()** operation. Using the classes in the above example, we can also define an inverse mapping like this: 

````swift
// Map lhs B to rhs A
let mappingBA: [AnyPropertyMapping] = [
    PropertyMapping(
      \B.nonOptionalDouble, 
      \A.optionalInt,       
      transformer: YourTransformers.intDouble.inverted()
    )  
]

// NOTE 1: Another version would look like this, and inverts
// an entire property mapping:
let mappingBA_Alt1: [AnyPropertyMapping] = [
    PropertyMapping(
      \B.nonOptionalDouble, 
      \A.optionalInt,       
      transformer: YourTransformers.intDouble
    ).inverted()  
]

// NOTE 2: Yet another version would look like this, and inverts
// the entire array of property mappings:
let mappingBA_Alt2: [AnyPropertyMapping] = [
    PropertyMapping(
      \B.nonOptionalDouble, 
      \A.optionalInt,       
      transformer: YourTransformers.intDouble
    )
].inverted()  
````

**AnyPropertyMapping** does not offer a lot of transformers; there are too many possible and most certainly bound by the developer's use-cases (and imagination). However, one can easily create new ones: think about converting date format strings to actual Swift **Date**s, or custom classes to scalars (e.g. class specific hashes).

## Convenience functions

An extension on `Sequence` where the Element is `AnyPropertyMapping` provides  the following functions:

```swift
func adapt(to:from:) // adapts property mappings from RHS to LHS - can both be arrays
func apply(from:to:) // adapts property mappings to LHS from RHS - can both be arrays
func differs(_:_:) -> Bool  // checks if there are differences in properties mapped between LHS and RHS
func inverted() // returns the inverse of a sequence of property mappings
func differences(_:_:) -> [(left: AnyKeyPath, right: AnyKeyPath)]? // returns the differences
func differenceIndex(_:_:) -> IndexSet // returns the indices that are different

```

An extension on `Sequence` where the Element is a tuple of LHS and RHS classes, and where you provide a `Sequence` of mappings:

```swift
Sequence<(LHS, RHS)> func adapt(mappings:) // adapts mappings to a sequence of tuples of LHS and RHS
Sequence<(LHS, RHS)> func apply(mappings:) // applies mappings to a sequence of tuples of LHS and RHS
```

More documentation is forthcoming, but also take a look at the unit tests.



## Notes

* The argument order in the `PropertyMapping` should be the same for all `PropertyMapping`s. The flow direction of data is determined by the first item in a property mapping sequence.

  I.e. this will not work:

  ```swift
  [
    PropertyMapping(\A.field1, \B.field1),
    PropertyMapping(\B.field2, \A.field2) // *wrong*
  ]
  ```

* Optional properties are supported, where LHS and RHS properties may even have different `optionality`. In that case all operations instantiate a new default instance of the property's type and use that as the default value in the operations. If this is not what you want, exclude optionals from your mappings sequence. See also: https://github.com/snofla/AnyPropertyMapping/wiki/TODO:-DefaultConstructable-and-default-values-for-optional-values



## Author(s)

Alfons Hoogervorst



## Thanks

Elastique (https://www.elastique.nl); we do really interesting things.



## License

MIT.

Any inadvertently mentioned trademarks are properties of their respective owners.
