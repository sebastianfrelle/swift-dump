/*
Created because
a. `Set` requires that elements conform to `Hashable`. This is super annoying if
you don't want to extend or edit existing models, and because
b. manually uniquing entries in a `Dictionary` using a property on the instances
is cumbersome and unintuitive and needlessly difficult to document.

This 'set' wraps a dictionary and uses a key p
*/

import Foundation

/// Stores elements using one of their properties as a key as specified by a provided key path.
struct KeyPathSet<Key, Element> where Key: Hashable {
  /// The path pointing to the property by which to unique the elements (i.e. the 'key').
  let keyPath: KeyPath<Element, Key>

  /// The elements stored in the set.
  private var elements: [Key: Element]

  init(keyPath: KeyPath<Element, Key>) {
    self.keyPath = keyPath
    elements = [:]
  }

  /// Insert a new element into the set using the local key path. Time complexity: O(1).
  /// - Parameter element: The element to insert.
  mutating func insert(_ element: Element) {
    elements[element[keyPath: self.keyPath]] = element
  }

  /// Removes an element from the set using the local key path. Time complexity: O(1).
  /// - Parameter element: The element to insert.
  mutating func remove(_ element: Element) {
    elements.removeValue(forKey: element[keyPath: self.keyPath])
  }
}


// TESTING

class Person {
  let name: String

  init(name: String) {
    self.name = name
  }
}

// This set will unique all `Person` instances by the `name` property.
var kps = KeyPathSet(keyPath: \Person.name)

// Let's add some people.

assert(kps.count == 0)

let john = Person(name: "John")
let otherJohn = Person(name: "John")
let harris = Person(name: "Harris")


kps.insert(john)
assert(kps.count == 1)

// `otherJohn` has the same name as `john`, so he doesn't get added to the set.
kps.insert(otherJohn)
assert(kps.count == 1)

kps.insert(harris)
assert(kps.count == 2)

/*
Admittedly, it's potentially annoying that `insert(_:)` doesn't indicate that
an insertion failed-- specifically since we're working with reference types. A
reference might be "destroyed" if the programmer believes that the reference
was stored in the set.

We could have `insert(_:)` return a `Result`, or we could have it throw an
error. I don't know which would be better. The standard library `Set` (or,
really, the protocol `SetAlgebra`) defines

```
func insert(Self.Element) -> (inserted: Bool, memberAfterInsert: Self.Element)
```

so I guess we could do that too. And decorate it with `@discardableResult`.
*/