# AnyPropertyMapping

![Build](https://github.com/snofla/AnyPropertyMapping/actions/workflows/swift.yml/badge.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

AnyPropertyMapping provides a convenient way to map properties of class types, and perform operations on instances of them, in both directions. The mapping is entirely based on keypaths. Optional properties are supported out of the box. Since the library depends heavily on keypaths: if the keypath syntax supports it, the library will support it.

Inspiration came from the need to quickly create mocking or intermediate objects between different layers (network or data, or even UI). There's a fairly comprehensive, but not complete, set of utility functions available, and the core functionality (handling keypaths and type erasure especially) are covered by unit tests.

This library uses generics and leans heavily on type erasure: Swift 5+ only, not sure if this is conceptually possible at all with older Swift versions. Swift's static typing makes this rather ... let's call it euphemistically: non-trivial.



## Installation

Right now only Swift Package Manager (SPM) is supported, CocoaPods support is underway. 

Add the following dependency to your **Package.swift** file:

```swift
.package(url: "https://github.com/snofla/AnyPropertyMapping.git", from: "1.0.0")
```



## Usage

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

`AnyPropertyMapping` provides three operations: 

* `adapt(to:from)`: which moves data into left-hand side class instances (direction: ←)
* `apply(from:to:)`: which moves data into right-hand side class instances (direction: →)
* `differs(_:_:)`: which checks if data from left-hand and right-hand side class instances are different

You can just set up a mapping as follows, and call the mapping operations:

```swift
let mapping: [AnyPropertyMapping] = [
  PropertyMapping(\UserAddressInUI.familyName, \UserAdressFromNetwork.userName),
  PropertyMapping(\UserAddressInUI.address, \UserAddressFromNetwork.address),
  PropertyMapping(\UserAddressInUI.technical.id, \UserAddressFromNetwork.id)
]

let a: UserAddressInUI = ...
let b: UserAdressFromNetwork = ...
// adapt from network layer data
mapping.forEach { $0.adapt(to: a, from: b) }
...
// make changes to a
...
// apply after changes (move back into rhs):
mapping.forEach { $0.apply(from: a, to: b)  }

```

That's basically it.



## Convenience functions

An extension on `Sequence` where the Element is `AnyPropertyMapping` provides  the following functions:

```swift
func adapt(to:from:) // adapts property mappings from RHS to LHS - can both be arrays
func apply(from:to:) // adapts propertymappings to LHS from RHS - can both be arrays
func differs(_:_:) -> Bool  // checks if there are differences in properties mapped between LHS and RHS
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

* Optional properties are supported, where LHS and RHS properties may even have different `optionality`. In that case all operations instantiate a new default instance of the property's type and use that as the default value in the operations. If this is not what you want, exclude optionals from your mappings sequence. 



## Author(s)

Alfons Hoogervorst



## Thanks

Elastique (https://www.elastique.nl); we do really interesting things.



## License

MIT.

Any inadvertently mentioned trademarks are properties of their respective owners.