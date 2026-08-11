/**
 * Base class for all Exceptions. Every exception and its subclasses
 * indicates conditions that a reasonable application might want to catch.
 *
 * @author jfernandes
 * @since 1.0
 */
class Exception {
  /** specified detail message. */
  @Type(name="String") 
  const property message = null

  /** specified cause */
  @Type(name="Exception") 
  const property cause = null

  override method initialize() native

  /** Prints this exception and its backtrace to the console */
  @Type(name="Void") 
  method printStackTrace() { self.printStackTrace(console) }

  /** Prints this exception and its backtrace as a string value */
  @Type(name="String") 
  method getStackTraceAsString() {
    const printer = new StringPrinter()
    self.printStackTrace(printer)
    return printer.getBuffer()
  }

  /**
   * @private
   * Prints this exception and its backtrace to the specified printer
   */
  @Type(name="Void") 
  method printStackTrace(@Type(name="(console | StringPrinter)") printer) { self.printStackTraceWithPrefix("", printer) }

  /** @private */
  @Type(name="Void") 
  method printStackTraceWithPrefix(@Type(name="String") prefix, @Type(name="(console | StringPrinter)") printer) {
    printer.println(prefix + self.className() + (if (message != null) (": " + message.toString()) else ""))

    // TODO: eventually we will need a stringbuffer or something to avoid memory consumption
    self.getStackTrace().forEach { e =>
      printer.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
    }

    if (cause != null)
      cause.printStackTraceWithPrefix("Caused by: ", printer)
  }

  /** @private */
  @Type(name="StackTraceElement") 
  method createStackTraceElement(@Type(name="String") contextDescription, @Type(name="String") location) = new StackTraceElement(contextDescription = contextDescription, location = location)

  /** Provides programmatic access to the stack trace information
   * printed by printStackTrace() with full path files for linking
   */
  @Type(name="List<String>") 
  method getFullStackTrace() native

  /** Provides programmatic access to the stack trace information
   * printed by printStackTrace().
   */
  @Type(name="List<String>") 
  method getStackTrace() native

  /** Overrides the behavior to compare exceptions */
  override method ==(other) = other.className() == self.className() && other.message() == self.message()
}

/**
 * Thrown when a stack overflow occurs because an application recurses too deeply.
 *
 * @author jfernandes
 * @since 1.5.1
 */
class StackOverflowException inherits Exception {}

/**
 * An exception that is thrown when a specified element cannot be found
 */
class ElementNotFoundException inherits Exception {}

/**
 * An exception that is thrown for domain purpose
 */
class DomainException inherits Exception {
  const property source = null
}

/**
 * (added by wollok-ts) An exception thrown whenever the interpreter fails to evaluate an expression
 */
class EvaluationError inherits Exception {}

/**
 * An exception that is thrown when an object cannot understand a certain message
 */
class MessageNotUnderstoodException inherits Exception {}

/**
 * An element in a stack trace, represented by a context and a location
 * of a method where a message was sent
 */
class StackTraceElement {
  @Type(name="String") 
  const property contextDescription
  @Type(name="String") 
  const property location
}

/**
 *
 * Representation of Wollok Object
 *
 * Class Object is the root of the class hierarchy.
 * Every class has Object as a superclass.
 *
 * @author jfernandes
 * since 1.0
 */
class Object {

  /**
   * This method is called when any object is instanciated
   */
  @Type(name="Void")
  method initialize() { }

  /**
   * Answers object identity of a Wollok object, represented by
   * a unique number in Wollok environment
   */
  @Type(name="String")
  method identity() native

  /** Object description in english/spanish/... (depending on i18n configuration)
   *
   * Examples:
   *     "2".kindName()  => Answers "a String"
   *    2.kindName()    => Answers "a Integer"
   *
   * @private
   */
  @Type(name="String")
  method kindName() native

  /**
   * Full name of Wollok object class
   * @private
   */
  @Type(name="String")
  method className() native

  /**
   * Tells whether self object is "equal" to the given object
   *
   * This method implements an equivalence relation on non-null object references:
   *
   * - It is reflexive: for any non-null reference value x, x == x should return true.
   * - It is symmetric: for any non-null reference values x and y, x == y
   *   should return true if and only if y == x returns true.
   * - It is transitive: for any non-null reference values x, y, and z,
   *   if x == y returns true and y == z returns true,
   *   then x == z should return true.
   * - It is consistent: for any non-null reference values x and y, multiple invocations
   *   of x == y consistently return true or consistently return false,
   *   provided no information used in equals comparisons on the objects is modified.
   * - For any non-null reference value x, x == null should return false.
   *
   * The default behavior compares them in terms of identity (===)
   */
  @Type(name="Boolean")
  method ==(other) = self === other

  /** Tells whether self object is not equal to the given one */
  @Type(name="Boolean")
  method !=(other) = ! (self == other)

  /**
   * Tells whether self object is identical (the same) to the given one.
   * It does it by comparing their identities.
   * So self basically relies on the wollok.lang.Integer equality (which is native)
   */
  @Type(name="Boolean")
  method ===(other) = self.identity() == other.identity()

  /**
   * Tells whether self object is not identical (the same) to the given one.
   * @See === message.
   */
  @Type(name="Boolean")
  method !==(other) = ! (self === other)

  /**
   * o1.equals(o2) is a synonym for o1 == o2
   */
  @Type(name="Boolean")
  method equals(other) = self == other

  /**
   * Generates a Pair key-value association. @see Pair.
   */
  @Type(variable="Other", name="Pair<Self,Other>")
  method ->(@Type(name="Other") other) {
    return new Pair(x = self, y = other)
  }

  /**
   * String representation of Wollok object
   */
  @Type(name="String") 
  method toString() {
    return self.kindName()
  }

  /**
   * Shows a short, internal representation
   */
  @Type(name="String")
  method shortDescription() = self.toString()

  /**
   * Provides a visual representation of Wollok Object
   * By default, same as toString but can be overridden
   * like in String
   */
  @Type(name="String")
  method printString() = self.toString()

  /** 
   * Throws MessageNotUnderstoodException using self as target object
   * @private 
   */
  method messageNotUnderstood(@Type(name="String") messageName, @Type(name="List<Object>") parameters) {
    const target = if (messageName != "toString")
          self.toString()
         else
           self.kindName()
    const aMessage = self.generateDoesNotUnderstandMessage(target, messageName, parameters.size())
    throw new MessageNotUnderstoodException(message = aMessage)
  }

  /**
   * Generates a does not understand message
   * parametersSize must be an integer value
   * @private
   */
  @Type(name="String")
  method generateDoesNotUnderstandMessage(@Type(name="String") target, @Type(name="String") messageName, @Type(name="Number") parametersSize) native

  /** Throws a DomainException with a message */
  method error(@Type(name="String") aMessage) {
    throw new DomainException(message = aMessage, source = self)
  }

  /** @private */
  @Type(name="Void")
  method checkNotNull(value, @Type(name="String") message) native
}

/** Representation for methods that only have side effects */
object void { }

/**
 * Representation of a Key -> Value Association.
 */
@Type(variables="Key,Value")
class Pair {
  @Type(name="Key")
  const property x
  @Type(name="Value")
  const property y

  @Type(name="Key")
  method key() = x
  @Type(name="Value")
  method value() = y

  /**
   * Two pairs are equal if they have the same values
   *
   * Example:
   *    new Pair(x = 1, y = 2) == new Pair(x = 1, y = 2)  ==> Answers true
   */
  override method ==(other) {
    if(other == null) return false

    return x == other.x() && y == other.y()
  }

  /** String representation of a Pair */
  override method toString() = x.toString() + " -> " + y.toString()
}

/**
 * The root class in the collection hierarchy.
 * A collection represents a group of objects, known as its elements.
 */
@Type(variable="Element")
class Collection {

  /**
   * Answers the element that is considered to be/have the maximum value.
   * The criteria is given by a closure that receives a single element
   * as input (one of the element). The closure must return a comparable
   * value (something that understands the >, >= messages).
   * If collection is empty, an ElementNotFound exception is thrown.
   *
   * Example:
   *       ["a", "ab", "abc", "d" ].max({ e => e.length() })
   *            => Answers "abc"
   *
   *       [].max({ e => e.length() })
   *            => Throws error, list must not be empty
   */
  @Type(name="Element")
  method max(@Type(name="{ (Element) => (Date | Number | String) }") closure) {
    self.checkNotNull(closure, "max")
    return self.maxIfEmpty(closure, { throw new ElementNotFoundException(message = "collection is empty") })
  }

  /**
   * Answers the element that represents the maximum value in the collection.
   * The criteria is by direct comparison of the elements (they must be sortable).
   * If collection is empty, an ElementNotFound exception is thrown.
   *
   * Example:
   *       [11, 1, 4, 8, 3, 15, 6].max() =>  Answers 15
   *       [].max()                      =>  Throws error, list must not be empty
   */
  @Type(name="Element")
  method max() = self.max({it => it})

  /**
   * Answers the element that is considered to be/have the maximum value,
   * or applies a closure if the collection is empty.
   * The criteria is given by a closure that receives a single element
   * as input (one of the element). The closure must return a comparable
   * value (something that understands the >, >= messages).
   * The closure to execute when the collection is empty is given as a second
   * argument.
   *
   * Example:
   *       ["a", "ab", "abc", "d" ].maxIfEmpty({ e => e.length() }, { "default" })
   *            => Answers "abc"
   *
   *       [].maxIfEmpty({ e => e.length() }, { "default" })
   *            => Answers "default"
   */
  @Type(name="Element")
  method maxIfEmpty(@Type(name="{ (Element) => (Date | Number | String) }") toComparableClosure, @Type(name="{ () => Element }") emptyCaseClosure) {
    self.checkNotNull(toComparableClosure, "maxIfEmpty")
    self.checkNotNull(emptyCaseClosure, "maxIfEmpty")
    return self.absolute(toComparableClosure, { a, b => a > b }, emptyCaseClosure)
  }

  /**
   * Answers the element that is considered to be/have the maximum value,
   * or applies a closure if the collection is empty.
   * The criteria is by direct comparison of the elements.
   * The closure to execute when the collection is empty is given as a second
   * argument.
   *
   * Example:
   *       [11, 1, 4, 8, 3, 15, 6].maxIfEmpty({ 99 }) =>  Answers 15
   *       [].maxIfEmpty({ 99 })                      =>  Answers 99
   */
  @Type(name="Element")
  method maxIfEmpty(@Type(name="{ () => Element }") emptyCaseClosure) = self.maxIfEmpty({it => it}, emptyCaseClosure)

  /**
   * Answers the element that is considered to be/have the minimum value.
   * The criteria is given by a closure that receives a single element
   * as input (one of the element). The closure must return a comparable
   * value (something that understands the <, <= messages).
   *
   * Example:
   *       ["ab", "abc", "hello", "wollok world"].min({ e => e.length() })
   *             =>  Answers "ab"
   *
   *       [].min({ e => e.length() })
   *             => Throws error, list must not be empty
   */
  @Type(name="Element")
  method min(@Type(name="{ (Element) => (Date | Number | String) }") closure) {
    self.checkNotNull(closure, "min")
    return self.absolute(closure, { a, b => a < b }, { throw new ElementNotFoundException(message = "collection is empty") })
  }

  /**
   * Answers the element that represents the minimum value in the
   * non-empty collection.
   * The criteria is by direct comparison of the elements.
   *
   * Example:
   *       [11, 1, 4, 8, 3, 15, 6].min()  => Answers 1
   *       [].min()                       => Throws error, list must not be empty
   */
  @Type(name="Element")
  method min() = self.min({it => it})

  /**
   * Answers the element that is considered to be/have the minimum value,
   * or applies a closure if the collection is empty.
   * The criteria is given by a closure that receives a single element
   * as input (one of the element). The closure must return a comparable
   * value (something that understands the >, >= messages).
   * The closure to execute when the collection is empty is given as a second
   * argument.
   *
   * Example:
   *       ["ab", "abc", "hello", "wollok world"].minIfEmpty({ e => e.length() }, { "default" })
   *             =>  Answers "ab"
   *
   *       [].minIfEmpty({ e => e.length() }, { "default" })
   *             => Answers "default"
   */
  @Type(name="Element")
  method minIfEmpty(@Type(name="{ (Element) => (Date | Number | String) }") toComparableClosure, @Type(name="{ () => Element }") emptyCaseClosure) {
    self.checkNotNull(toComparableClosure, "minIfEmpty")
    self.checkNotNull(emptyCaseClosure, "minIfEmpty")
    return self.absolute(toComparableClosure, { a, b => a < b }, emptyCaseClosure)
  }

  /**
   * Answers the element that is considered to be/have the minimum value,
   * or applies a closure if the collection is empty.
   * The criteria is by direct comparison of the elements.
   * The closure to execute when the collection is empty is given as a second
   * argument.
   *
   * Example:
   *       [11, 1, 4, 8, 3, 15, 6].minIfEmpty({ 99 })  => Answers 1
   *       [].minIfEmpty({ 99 })                       => Answers 99
   */
  @Type(name="Element")
  method minIfEmpty(@Type(name="{ () => Element }") emptyCaseClosure) {
    self.checkNotNull(emptyCaseClosure, "minIfEmpty")
    return self.minIfEmpty({it => it}, emptyCaseClosure)
  }

  /** @private */
  @Type(name="Element")
  method absolute(@Type(name="{ (Element) => (Date | Number | String) }") closure, @Type(name="{ ((Date | Number | String), (Date | Number | String)) => Boolean }") criteria, @Type(name="{ () => Element }") emptyCaseClosure) {
    self.checkNotNull(closure, "absolute")
    self.checkNotNull(criteria, "absolute")
    self.checkNotNull(emptyCaseClosure, "absolute")
    if (self.isEmpty()) {
      return emptyCaseClosure.apply()
    }
    const result = self.fold(null, { acc, e =>
      const n = closure.apply(e)
      if (acc == null)
        e -> n
      else {
        if (criteria.apply(n, acc.y()))
          e -> n
        else
          acc
      }
    })
    return result.x()
  }

  /**
   * Answers the unique element in the collection.
   * If collection is empty, an error is thrown.
   * If collection has more than one element, an error is thrown.
   *
   * Example:
   *       [1].uniqueElement()    => Answers 1
   *       [].uniqueElement()     => Throws error, list must not be empty
   *       [1, 2].uniqueElement() => Throws error, list must have one element
   */
  @Type(name="Element")
  method uniqueElement() {
    self.validateNotEmpty("uniqueElement")
    const size = self.size()
    if (size > 1)
      throw new Exception(message = "Illegal operation 'uniqueElement' on collection with " + size.toString() + " elements")
    return self.anyOne()
  }

  /**
   * Concatenates this collection to all elements from the given
   * collection parameter giving a new collection
   * (no side effect)
   *
   * Example:
   *    [1, 2] + [3]   => Answers [1, 2, 3]
   *    [1, 2] + #{3}  => supports concatenation between lists and sets, answers [1, 2, 3]
   *    #{} + []       => Answers #{}
   */
  @Type(name="Self")
  method +(@Type(name="Collection<Element>") elements) {
    const newCol = self.copy()
    newCol.addAll(elements)
    return newCol
  }

  /**
   * Adds all elements from the given collection parameter to self collection.
   * This is a side effect operation.
   *
   * Example:
   *    const list = []
   *    list.addAll(#{2, 4})  => list == [2, 4], always pointing to a list
   */
  @Type(name="Void")
  method addAll(@Type(name="Collection<Element>") elements) {
    self.checkNotNull(elements, "addAll")
    elements.forEach { element => self.add(element) }
  }

  /**
   * Removes all elements of the given collection parameter from self collection.
   * This is a side effect operation.
   *
   * Example:
   *    const list = [1, 6, 5]
   *    list.removeAll([6]) => list == [1, 5]
   */
  @Type(name="Void")
  method removeAll(@Type(name="Collection<Element>") elements) {
    self.checkNotNull(elements, "removeAll")
    elements.forEach { element => self.remove(element) }
  }

  /**
  * Removes those elements that meet a given condition.
  * This is a side effect operation.
  * Supports empty collections.
  *
  * Example:
  *    const list = [1, 6, 5]
  *    list.removeAllSuchThat { e => e.even() } => list == [1, 5]
  */
  @Type(name="Void")
  method removeAllSuchThat(@Type(name="{ (Element) => Boolean }") closure) {
    self.checkNotNull(closure, "removeAllSuchThat")
    self.removeAll( self.filter(closure) )
  }

  /**
   * Tells whether self collection has no elements
   *
   * Example:
   *    [1, 6, 5].isEmpty() => Answers false
   *    [].isEmpty()        => Answers true
   */
  @Type(name="Boolean")
  method isEmpty() = self.size() == 0

  /**
   * @private
   * Throws error if self collection is empty
   */
  @Type(name="Void")
  method validateNotEmpty(@Type(name="String") operation) {
    if (self.isEmpty())
      throw new Exception(message = "Illegal operation '" + operation + "' on empty collection")
  }

  /**
   * Performs an operation on every element of self collection.
   * The logic to execute is passed as a closure that takes a single parameter.
   * Supports empty collections.
   * @returns nothing
   *
   * Example:
   *      plants.forEach { plant => plant.takeSomeWater() }
   */
  @Type(name="Void")
  method forEach(@Type(name="{ (Element) => Void }") closure) {
    self.checkNotNull(closure, "forEach")
    self.fold(null, { seed, element =>
      closure.apply(element)
      seed
    })
  }

  /**
   * Answers whether all the elements of self collection satisfy a given
   * condition. The condition is a closure argument that takes a single
   * element and answers a boolean value.
   *
   * @returns true/false
   *
   * Example:
   *      plants.all({ plant => plant.hasFlowers() })
   *      [1, 3, 5].all { number => number.odd() }    => Answers true
   *      [].all { number => number.odd() }           => Answers true
   */
  @Type(name="Boolean")
  method all(@Type(name="{ (Element) => Boolean }") predicate) {
    self.checkNotNull(predicate, "all")
    return self.fold(true, { seed, element => 
      if (!seed) 
        seed
      else 
        predicate.apply(element)
      }
    )
  }

  /**
   * Tells whether at least one element of self collection satisfies a
   * given condition. The condition is a closure argument that takes a
   * single element and answers a boolean value.
   * @returns true/false
   *
   * Example:
   *      plants.any({ plant => plant.hasFlowers() })
   *      [1, 2, 3].any { number => number.even() }   ==> Answers true
   *      [].any { number => number.even() }          ==> Answers false
   */
  @Type(name="Boolean")
  method any(@Type(name="{ (Element) => Boolean }") predicate) {
    self.checkNotNull(predicate, "any")
    return self.fold(false, { seed, element => 
      if (seed)
        seed
      else 
        predicate.apply(element)
      }
    )
  }

  /**
   * Answers the element of self collection that satisfies a given condition.
   * If more than one element satisfies the condition then it depends
   * on the specific collection class which element will be returned.
   *
   * @returns the element that complies the condition
   * @throws ElementNotFoundException if no element matched the given predicate
   *
   * Example:
   *      users.find { user => user.name() == "Cosme Fulanito" }
   *      #{1, 4, 5}.find { number => number.even() }  => Answers 4
   *      #{1, 3}.find { number => number.even() }     => Throws ElementNotFoundException
   *      #{}.find { number => number.even() }         => Throws ElementNotFoundException
   */
  @Type(name="Element")
  method find(@Type(name="{ (Element) => Boolean }") predicate) {
    self.checkNotNull(predicate, "find")
    return self.findOrElse(predicate, {
      throw new ElementNotFoundException(message = "there is no element that satisfies the predicate")
    })
  }

  /**
   * Answers the element of self collection that satisfies a given condition,
   * or the given default otherwise, if no element matched the predicate.
   * If more than one element satisfies the condition then it depends on the specific
   * collection class which element will be returned.
   *
   * @returns the element that complies the condition or the default value
   *
   * Example:
   *      users.findOrDefault({ user => user.name() == "Cosme Fulanito" }, homer)
   *      [1, 3, 5].findOrDefault({ number => number.even() }, 0)  => Answers 0
   *      [].findOrDefault({ number => number.even() }, 0)         => Answers 0
   */
  @Type(name="Element")
  method findOrDefault(@Type(name="{ (Element) => Boolean }") predicate, @Type(name="Element") value) =  self.findOrElse(predicate, { value })

  /**
   * Answers the element of self collection that satisfies a given condition,
   * or the the result of evaluating the given continuation.
   * If more than one element satisfies the condition then it depends on the
   * specific collection class which element will be returned.
   *
   * @returns the element that complies the condition or the result
   * of evaluating the continuation
   *
   * Example:
   *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, { homer })
   *      [1, 3, 5].findOrElse({ number => number.even() }, { 6.max(4) }) => Answers 6
   *      [].findOrElse({ number => number.even() }, { false })           => Answers false
   */
  @Type(name="Element")
  method findOrElse(@Type(name="{ (Element) => Boolean }") predicate, @Type(name="{ () => Element }") continuation) native

  /**
   * Counts all elements of self collection that satisfies a given condition
   * The condition is a closure argument that takes a single element and
   * answers a number.
   * @returns an integer number
   *
   * Example:
   *      plants.count { plant => plant.hasFlowers() }
   *      #{1, 2, 3, 4, 5}.count { number => number.odd() }  => Answers 3
   *      #{}.count { number => number.odd() }               => Answers 0
   */
  @Type(name="Number")
  method count(@Type(name="{ (Element) => Boolean }") predicate) {
    self.checkNotNull(predicate, "count")
    return self.fold(0, { total, element =>
      if (predicate.apply(element)) total+1 else total
    })
  }

  /**
   * Counts the occurrences of a given element in self collection.
   * @returns an integer number
   *
   * Example:
   *      [1, 8, 4, 1].occurrencesOf(1)  => Answers 2
   *      [].occurrencesOf(2)            => Answers 0
   */
  @Type(name="Number")
  method occurrencesOf(@Type(name="Element") element) = self.count({it => it == element})

  /**
   * Collects the sum of each value for all elements.
   * This is similar to call a map {} to transform each element into a
   * number object and then adding all those numbers.
   * The condition is a closure argument that takes a single element and
   * answers a boolean value.
   *
   * @returns an integer
   *
   * Example:
   *      const totalNumberOfFlowers = plants.sum{ plant => plant.numberOfFlowers() }
   *      [].sum { employee => employee.salary() }   => Answers 0
   */
  @Type(name="Number")
  method sum(@Type(name="{ (Element) => Number }") closure) {
    self.checkNotNull(closure, "sum")
    return self.fold(0, { total, element => 
      total + closure.apply(element)
    })
  }

  /**
   * Sums all elements in the collection.
   * @returns a number
   *
   * Example:
   *      [1, 2, 3, 4, 5].sum()  => Answers 15
   *      [].sum()               => Answers 0
   */
  @Type(name="Number")
  method sum() = self.sum( {it => it} )
  
  /**
   * Calculates the average of the transformation of each element into a numerical value
   * This is similar to call a map {} to transform each element into a
   * number and calculates the average value of the resulting list.
   * The condition is a closure argument that takes a single element and 
   * returns a number
   * @returns a number
   *
   * Example:
   *   const averageNumberOfFlowers = plants.average{ plant => plant.numberOfFlowers() }
   *   [].average { employee => employee.salary() }         => throws an error
   */
  @Type(name="Number")
  method average(@Type(name="{ (Element) => Number }") closure) {
    if (self.size() == 0)
      throw new Exception(message = "You cannot calculate the average of an empty list")
    return self.sum(closure) / self.size()
  }  

  /**
   * Calculates the average of all elements in the collection.
   * @returns a number
   *
   * Example:
   *      [1, 2, 3, 4, 5].average() => Answers 3
   *      [].average()              => throws an error
   */
  @Type(name="Number")
  method average() = self.average( {it => it} )

  /**
   * Answers a new collection that contains the result of transforming
   * each of self collection's elements using a given closure.
   * The condition is a closure argument that takes a single element
   * and answers an object.
   * @returns another list
   *
   * Example:
   *      const ages = users.map({ user => user.age() })
   *      [1, 2, 3].map { number => number.odd() }  => Answers [true, false, true]
   *      [].map { number => number.odd() }         => Answers []
   */
  @Type(variable="Map", name="List<Map>")
  method map(@Type(name="{ (Element) => Map }") closure) {
    self.checkNotNull(closure, "map")
    return self.fold([], { newCollection, element =>
      newCollection.add(closure.apply(element))
      newCollection
    })
  }

  /**
   * Flattens a collection of collections: Map + flatten operation.
   *
   * It always returns a list, because the elements in the resulting list could be duplicated.
   * If you need to remove the duplicates, you can take the result and send asSet() message to it.
   *
   * @see map
   * @see flatten
   *
   * Example:
   *     object klaus {
   *       method languages() = ["c", "cobol", "pascal"]
   *     }
   *
   *     object fritz {
   *       method languages() = ["java", "perl"]
   *     }
   *
   *
   *     [klaus, fritz].flatMap({ person => person.languages() })
   *       => Answers ["c", "cobol", "pascal", "java", "perl"]
   *
   *     #{klaus, fritz}.flatMap({ person => person.languages() })
   *       => Answers ["c", "cobol", "pascal", "java", "perl"]
   *
   */
  @Type(variable="Map", name="List<Map>")  
  method flatMap(@Type(name="{ (Element) => Collection<Map> }") closure) {
    self.checkNotNull(closure, "flatMap")
    return self.fold([], { flattenedList, element =>
      flattenedList.addAll(closure.apply(element))
      flattenedList
    })
  }

  /**
   * Answers a new collection that contains the elements that
   * meet a given condition. The condition is a closure argument that
   * takes a single element and answers a boolean.
   * @returns another collection (same type as self one)
   *
   * Example:
   *      const overageUsers = users.filter({ user => user.age() >= 18 })
   *      #{1, 2, 3, 4, 5}.filter { number => number.even() }   => Answers #{2, 4}
   *      [1, 2, 3].filter { number => number.even() }          => Answers [2]
   *      #{}.filter { number => number.even() }                => Answers #{}
   */
  // @Type(name="Self<Element>") 
  @Type(name="Self") 
  method filter(@Type(name="{ (Element) => Boolean }") closure) {
    self.checkNotNull(closure, "filter")
    return self.fold(self.newInstance(), { newCollection, element =>
      if (closure.apply(element)) {
        newCollection.add(element)
      }
      newCollection
    })
  }

  /**
   * Answers whether this collection contains the specified element.
   *
   * Example:
   *      [].contains(3)        => Answers false
   *      [1, 2, 3].contains(2) => Answers true
   */
  @Type(name="Boolean")
  method contains(@Type(name="Element") element) = self.any {one => element == one }

  /**
   * Flattens a collection of collections. 
   *
   * It always returns a list, because the elements in the resulting list could be duplicated.
   * If you need to remove the duplicates, you can take the result and send asSet() message to it.
   *
   * Example:
   *     [ [1, 2], [3], [4, 0], [] ].flatten()
   *       => Answers [1, 2, 3, 4, 0]
   *
   *     #{ [1, 2], [1], [2, 3], [] }.flatten()
   *       => Answers [1, 2, 1, 2, 3]
   
   *
   */
  method flatten() = self.flatMap { it => it }

  /** @private */
  /*
   * String representation of this collection object.
   * Optimized version for long collections
   *
   * @see Object#toString()
   */
  override method toString() {
    const size = self.size()
    const internalCollection = if (size > 20) "..." + size + " elements" else self.map{ e => if (e === null) "null" else e.printString() }.join(", ")
    return self.toStringPrefix() + internalCollection + self.toStringSuffix()
  }

  /** @private */
  @Type(name="String")
  method toStringPrefix()

  /** @private */
  @Type(name="String")
  method toStringSuffix()

  /**
  * Provides a (short) visual representation of this collection.
  */
  override method printString() {
    return self.toStringPrefix() + self.kindName() + " (" + self.size() + ")" + self.toStringSuffix()
  }

  /** Converts a collection to a list */
  @Type(name="List<Element>")
  method asList()

  /** Converts a collection to a set (removing duplicates if necessary)
   *
   * Examples:
   *    [1, 2, 3].asSet()       => Answers #{1, 2, 3}
   *    [].asSet()              => Answers #{}
   *    [1, 2, 1, 1, 2].asSet() => Answers #{1, 2}
   *
   *    #{1, 2, 3}.asSet()      => Answers #{1, 2, 3}
   *    #{}.asSet()             => Answers #{}
   *
   * @see Set
   */
  @Type(name="Set<Element>")
  method asSet()

  /**
   * Answers a new collection of the same type and with the same content
   * as self. Supports empty collections.
   *
   * @returns a new collection
   *
   * Example:
   *      const usersCopy = users.copy()
   */
  @Type(name="Self")
  method copy() {
    const copy = self.newInstance()
    copy.addAll(self)
    return copy
  }

  /**
   * Answers a new collection without element that is passed by parameter.
   * If the element occurs more than once in the collection, all occurrences
   * will be removed.
   *
   * @returns a new Collection
   *
   * Example:
   *      [1, 5, 9, 2, 4].copyWithout(9) => Answers [1, 5, 2, 4]
   *      [1, 5, 9, 2, 9].copyWithout(9) => Answers [1, 5, 2]
   *
   */
  @Type(name="Self")
  method copyWithout(@Type(name="Element") elementToRemove) {
    return self.filter{ element => element != elementToRemove }
  }

  /**
   * Answers a new collection with the added element which is received by parameter.
   *
   * @returns a new Collection
   *
   * Example:
   *      [1, 5, 9, 2, 4].copyWith(9) => Answers [1, 5, 2, 4, 9]
   *
   */
  @Type(name="Self")
  method copyWith(@Type(name="Element") elementToAdd) {
    const copy = self.copy()
    copy.add(elementToAdd)
    return copy
  }

  /**
   * Answers a new List that contains the elements of self collection
   * sorted by a criteria given by a closure. The closure receives two objects
   * X and Y and answers a boolean, true if X should come before Y in the
   * resulting collection. Supports empty collections.
   *
   * @returns a new List
   *
   * Example:
   *      const usersByAge = users.sortedBy({ a, b => a.age() < b.age() })
   *      const studentsByNameDesc = students.sortedBy({ a, b => a.name() > b.name() })
   *      [1, 5, 9, 2, 4].sortedBy { a, b => a < b } => Answers [1, 2, 4, 5, 9]
   *      [1, 5, 9, 2, 4].sortedBy { a, b => a > b } => Answers [9, 5, 4, 2, 1]
   *      [].sortedBy { a, b => a > b }              => Answers []
   *
   */
  @Type(name="List<Element>")
  method sortedBy(@Type(name="{ (Element, Element) => Boolean }") closure) {
    const copy = self.copy().asList()
    copy.sortBy(closure)
    return copy
  }


  /**
   * Answers a new, empty collection of the same type as self.
   * @returns a new collection
   *
   * Example:
   *      const newCollection = users.newInstance()
   */
  method newInstance()

  /**
  * @see subclasses implementations
  */
  @Type(name="Element")
  method anyOne() = throw new Exception(message = "Should be implemented by the subclasses")

  /**
  * @see subclasses implementations
  */
  @Type(name="Void")
  method add(@Type(name="Element") element) = throw new Exception(message = "Should be implemented by the subclasses")

  /**
  * @see subclasses implementations
  */
  @Type(name="Void")
  method remove(@Type(name="Element") element) = throw new Exception(message = "Should be implemented by the subclasses")

  /**
  * @see subclasses implementations
  */
  method fold(element, closure) = throw new Exception(message = "Should be implemented by the subclasses")

  /**
   * @see subclasses implementations
   */
  @Type(name="Number")
  method size() = throw new Exception(message = "Should be implemented by the subclasses")

  /**
   * Removes all of the elements from this set. This is a side effect operation.
   *
   * @see subclasses implementations
   */
  @Type(name="Void")
  method clear()

  /**
   * Answers the concatenated string representation of the elements in the given set.
   * You can pass an optional character as an element separator (default is ",")
   *
   * Example:
   *      ["hola", "como", "estas"].join(" ") ==> Answers "hola como estas"
   */
  @Type(name="String")
  method join(@Type(name="String") separator) {
    if (self.isEmpty()) return ""
    const newList = self.asList()
    return newList.subList(1).fold(newList.first().toString(), { string, element => string + separator + element.toString() })
  }

  /**
   * Answers the concatenated string representation of the elements in the given set
   * with default element separator (",")
   *
   * Example:
   *      ["hola", "como", "estas"].join()    ==> Answers "hola,como,estas"
   */
  @Type(name="String")
  method join() = self.join(",")

}

/**
* Builder object for collections.
* It compensates for the lack of vararg constructors.
*/
object collection {
  method list(elements...) = elements
  method set(elements...) = elements.asSet()
}

/**
 *
 * A collection that contains no duplicate elements.
 * It models the mathematical set abstraction.
 * A Set guarantees no order of elements.
 *
 * Note: Great care must be exercised if mutable objects are used as set elements.
 * The behavior of a set is not specified if the value of an object is changed in
 * a manner that affects equals comparisons while the object is an element in the set.
 * A special case of this prohibition is that it is not permissible for a set to contain
 * itself as an element.
 *
 * @author jfernandes
 * @since 1.3
 */
@Type(variable="Element")
class Set inherits Collection {

  /** @private */
  @Type(name="Set<Any>")
  override method newInstance() = #{}

  /** @private */
  override method toStringPrefix() = "#{"

  /** @private */
  override method toStringSuffix() = "}"

  /**
   * Converts this set to a list.
   *
   * Examples
   *    #{1, 2, 3}.asList() => Answers [1, 2, 3]
   *    #{}.asList()        => Answers []
   *
   * @see List
   */
  override method asList() {
    const result = []
    result.addAll(self)
    return result
  }

  /** Converts a collection to a set (removing duplicates if necessary)
   *
   * Examples:
   *    [1, 2, 3].asSet()       => Answers #{1, 2, 3}
   *    [].asSet()              => Answers #{}
   *    [1, 2, 1, 1, 2].asSet() => Answers #{1, 2}
   *
   *    #{1, 2, 3}.asSet()      => Answers #{1, 2, 3}
   *    #{}.asSet()             => Answers #{}
   *
   * @see Set
   */
  override method asSet() {
    return self
  }

  /**
   * Answers any element of a non-empty collection
   *
   * Examples
   *    #{1, 2, 3}.anyOne() => Answers 1, for example
   *    #{}.anyOne()        => Throws error, set must not be empty
   *
   */
  override method anyOne() native

  /**
   * Answers a new Set with the elements of both self and another collection.
   *
   * Examples
   *     #{1, 2}.union(#{5, 2})   => #{1, 2, 5}
   *     #{}.union(#{3})          => #{3}
   *
   * @returns a Set
   */
  @Type(name="Set<Element>")
  method union(@Type(name="Collection<Element>") another) = self + another

  /**
   * Answers a new Set with the elements of self that exist in another collection
   *
   * Examples
   *     #{1, 2}.intersection(#{5, 2})   => #{2}
   *     #{}.intersection(#{3})          => #{}
   *
   * @returns a Set
   */
  @Type(name="Set<Element>")
  method intersection(@Type(name="Collection<Element>") another) =
    self.filter({it => another.contains(it)})

  /**
   * Answers a new Set with the elements of self that don't exist in another collection
   *
   * Examples
   *     #{1, 2}.difference(#{5, 2}) => #{1}
   *     #{3}.difference(#{})        => #{3}
   *
   * @returns a Set
   */
  @Type(name="Set<Element>")
  method difference(@Type(name="Collection<Element>") another) =
    self.filter({it => !another.contains(it)})

  /**
   * Reduce a collection to a certain value, beginning with a seed or initial value.
   *
   * Examples
   *     #{1, 9, 3, 8}.fold(0, {acum, each => acum + each})
   *           => Answers 21, the sum of all elements
   *
   *     #{}.fold(0, {acum, each => acum + each})
   *           => Answers 0, the seed.
   *
   *     var numbers = #{3, 2, 9, 1, 7}
   *     numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) })
   *           => Answers 9, the maximum of all elements
   *
   */
  @Type(variable="Folded", name="Folded")
  override method fold(@Type(name="Folded") initialValue, @Type(name="{ (Folded, Element) => Folded }") closure) native

  /**
   * Answers a new set with the elements meeting
   * a given condition. The condition is a closure argument that
   * takes a single element and answers a boolean.
   *
   * Example:
   *      #{1, 2, 3, 4, 5}.filter { number => number.even() }   => Answers #{2, 4}
   *      #{}.filter { number => number.even() }                => Answers #{}
   *
   * @see Collection#filter(closure)
   */
  // @Type(name="Set<Element>") 
  override method filter(closure) native


  /**
   * Answers the element that represents the maximum value in the collection.
   * The criteria is by direct comparison of the elements.
   * If set is empty, an ElementNotFound exception is thrown.
   *
   * Example:
   *       #{1, 9, 3, 15}.max()  =>  Answers 15
   *       #{}.max()             =>  Throws error, set must not be empty
   *
   * @see Collection#max()
   */
  override method max() native

  /**
   * Tries to find an element in a collection (based on a closure) or
   * applies a continuation closure.
   *
   * Examples:
   *     #{1, 9, 3, 8}.findOrElse({ n => n.even() }, { 100 })  => Answers  8
   *     #{1, 5, 3, 7}.findOrElse({ n => n.even() }, { 100 })  => Answers  100
   */
  override method findOrElse(predicate, continuation) native

  /**
   * Adds the specified element to this set if it is not already present.
   *
   * Example:
   *     const set = #{}
   *     set.add(3)   => set = #{3}
   *     set.add(2)   => set = #{2, 3}
   *     set.add(2)   => set = #{2, 3}, second add produces no effect
   */
  @Type(name="Void")
  override method add(@Type(name="Element")element) native

  /** @private */
  @Type(name="Void")
  method unsafeAdd(@Type(name="Element") element) native

  /**
   * Removes the specified element from this set if it is present.
   *
   * Example:
   *     const set = #{2, 3}
   *     set.remove(3) => set = #{2}
   *     set.remove(4) => set = #{2}, remove operation produces no effect
   */
  override method remove(element) native

  /** Answers the number of elements in this set (its cardinality).
   *
   * Example:
   *     #{2, 3}.size()   => Answers 2
   *     #{}.size()       => Answers 0
   */
  override method size() native

  /**
   * Removes all of the elements from this set. This is a side effect operation.
   *
   * Example:
   *     const set = #{2, 3}
   *     set.clear()         => set = #{}
   */
  override method clear() native

  /**
   * Answers the concatenated string representation of the elements in the given set.
   * You can pass an optional character as an element separator (default is ",")
   *
   * Examples:
   *     #{1, 5, 3, 7}.join(":")                   => Answers "1:5:3:7"
   *     #{"you","will","love","wollok"}.join(" ") => Answers "love will wollok you"
   *     #{}.join(",")                             => Answers ""
   */
  override method join(separator) native

  /**
   * Answers the concatenated string representation of the elements in the given set
   * with default element separator (",")
   *
   * Example:
   *     #{"you","will","love","wollok"}.join()    => Answers "love,will,wollok,you"
   */
  override method join() native

  /**
   * Answers whether this collection contains the specified element.
   *
   * Example:
   *      #{}.contains(3)        => Answers false
   *      #{1, 2, 3}.contains(2) => Answers true
   *      #{1, 2, 3}.contains(4) => Answers false
   *
   * @see List#contains(other)
   */
  override method contains(other) native

  /**
   * Two sets are equals if they have the same elements, no matter
   * the order.
   *
   * Examples:
   *     #{} == #{}         => Answers true
   *     #{1, 2} == #{2, 1} => Answers true
   *     #{3, 2} == #{2, 1} => Answers false
   */
  override method ==(other) native

}

/**
 *
 * An ordered collection (also known as a sequence).
 * You iterate the list the same order elements are inserted.
 * The user can access elements by their integer index (position in the list).
 * A List can contain duplicate elements.
 *
 * @author jfernandes
 * @since 1.3
 */
@Type(variable="Element")
class List inherits Collection {

  /**
   * Answers the element at the specified position in this non-empty list.
   *
   * The first char value of the sequence is at index 0,
   * the next at index 1, and so on, as for array indexing.
   * Index must be a positive and integer value.
   *
   * Examples:
   *     [].get(0)        => Throws error, list must not be empty
   *     [1].get(-1)      => Throws error, index must be 0 or positive
   *     [1, 2, 3].get(3) => Throws error, index exceeds list size
   *     [5, 2, 7].get(0) => Answers 5
   */
  @Type(name="Element")
  method get(@Type(name="Number") index) native

  /** Creates a new list */
  @Type(name="List<Any>")
  override method newInstance() = []

  /**
   * Answers any element of a non-empty collection.
   *
   * Examples
   *    #[1, 2, 3].anyOne() => Answers 3, for example
   *    #[].anyOne()        => Throws error, list must not be empty
   */
  @Type(name="Element")
  override method anyOne() {
    self.validateNotEmpty("anyOne")
    return self.get(0.randomUpTo(self.size()).truncate(0))
  }

  /**
   * Answers first element of the non-empty list
   *
   * @returns first element
   *
   * Example:
   *    [1, 2, 3, 4].first()  => Answers 1
   *    [].first()            => Throws error, list must not be empty
   */
  @Type(name="Element")
  method first() = self.head()

  /**
   * Synonym for first method
   */
  @Type(name="Element")
  method head() {
    self.validateNotEmpty("head")
    return self.get(0)
  }

  /**
   * Answers the last element of the non-empty list.
   *
   * @returns last element
   *
   * Examples:
   *    [1, 2, 3, 4].last()  => Answers 4
   *    [].last()            => Throws error, list must not be empty
   */
  @Type(name="Element")
  method last() {
    self.validateNotEmpty("last")
    return self.get(self.size() - 1)
  }

  /** @private */
  override method toStringPrefix() = "["

  /** @private */
  override method toStringSuffix() = "]"

  /**
   * Converts this collection to a list. No effect on Lists.
   *
   * @see List
   */
  override method asList() = self

  /**
   * Converts a collection to a set (removing duplicates if necessary)
   *
   * Examples:
   *    [1, 2, 3].asSet()       => Answers #{1, 2, 3}
   *    [].asSet()              => Answers #{}
   *    [1, 2, 1, 1, 2].asSet() => Answers #{1, 2}
   *
   *    #{1, 2, 3}.asSet()      => Answers #{1, 2, 3}
   *    #{}.asSet()             => Answers #{}
   *
   * @see Set
   */
  override method asSet() {
    const result = #{}
    result.addAll(self.withoutDuplicates())
    return result
  }

  /**
   * Answers a view of the portion of this list between the specified start index
   * and the end of the list. Remember first element is position 0,
   * second is position 1, and so on.
   * If toIndex exceeds length of list, no error is thrown.
   *
   * Example:
   *    [1, 5, 3, 2, 7, 9].subList(2) => Answers [3, 2, 7, 9]
   *    [1, 5, 3, 2, 7, 9].subList(4) => Answers [7, 9]
   *    [].subList(1)                 => Answers []
   */
  @Type(name="List<Element>")
  method subList(@Type(name="Number") start) {
    if (self.isEmpty()) return []
    if (start >= self.size()) return []
    return self.subList(start, self.size() - 1)
  }

  /**
   * Answers a view of the portion of this list between the specified fromIndex
   * and toIndex, both inclusive. Remember first element is position 0,
   * second is position 1, and so on.
   * If toIndex exceeds length of list, no error is thrown.
   *
   * Example:
   *    [1, 5, 3, 2, 7, 9].subList(2, 3) => Answers [3, 2]
   *    [1, 5, 3, 2, 7, 9].subList(4, 6) => Answers [7, 9]
   *    [].subList(1, 2)                 => Answers []
   */
  @Type(name="List<Element>")
  method subList(@Type(name="Number") start, @Type(name="Number") end) {
    self.checkNotNull(start, "subList")
    self.checkNotNull(end, "subList")
    if (self.isEmpty() || start >= self.size())
      return self.newInstance()

    const newList = self.newInstance()
    const _start = start.coerceToInteger().limitBetween(0, self.size() - 1)
    const _end = end.coerceToInteger().limitBetween(0, self.size() - 1)
    (_start.._end).forEach { i => newList.add(self.get(i)) }
    return newList
  }

  /**
   *
   * Sorts elements of a list by a specific closure.
   * Order of elements is modified (produces effect).
   *
   * Examples:
   *    const list = [2, 9, 3]
   *    list.sortBy { el1, el2 => el1 > el2 }
   *    list.get(0)            => Answers 9
   *
   * @see List#sortedBy
   */
  @Type(name="Void")
  method sortBy(@Type(name="{ (Element, Element) => Boolean }") closure) native

  /**
   * Takes first n elements of a list.
   *
   * Examples:
   *    [1,9,2,3].take(5)  ==> Answers [1, 9, 2, 3]
   *    [1,9,2,3].take(2)  ==> Answers [1, 9]
   *    [1,9,2,3].take(-2) ==> Answers []
   *    [].take(2)         ==> Answers []
   */
  @Type(name="List<Element>")
  method take(@Type(name="Number") n) {
    self.checkNotNull(n, "take")
    return if (n <= 0) self.newInstance() else self.subList(0, n - 1)
  }

  /**
   * Answers a new list dropping first n elements of a list.
   * This operation has no side effect.
   *
   * Examples:
   *     [1, 9, 2, 3].drop(3)  ==> Answers [3]
   *     [1, 9, 2, 3].drop(1)  ==> Answers [9, 2, 3]
   *     [1, 9, 2, 3].drop(-2) ==> Answers [1, 9, 2, 3]
   *     [].drop(2)            ==> Answers []
   */
  @Type(name="List<Element>")
  method drop(@Type(name="Number") n) {
    self.checkNotNull(n, "drop")
    return if (n >= self.size()) self.newInstance() else self.subList(n, self.size() - 1)
  }

  /**
   * Answers a new list reversing the elements,
   * so that first element becomes last element of the new list and so on.
   * This operation has no side effect.
   *
   * Example:
   *    [1, 9, 2, 3].reverse()  ==> Answers [3, 2, 9, 1]
   *    [1, 2].reverse()        ==> Answers [2, 1]
   *    [].reverse()            ==> Answers []
   *
   */
  @Type(name="List<Element>")
  method reverse() = self.subList(self.size() - 1, 0)

  /**
   *
   * Answers a new list with the elements meeting
   * a given condition. The condition is a closure argument that
   * takes a single element and answers a boolean.
   *
   * Example:
   *      [1, 2, 3, 4, 5].filter { number => number.even() }   => Answers [2, 4]
   *      [].filter { number => number.even() }                => Answers []
   *
   * @see Collection#filter(closure)
   */
  // @Type(name="List<Element>") 
  override method filter(closure) native

  /**
   * Answers whether this collection contains the specified element.
   *
   * Example:
   *      [].contains(3)        => Answers false
   *      [1, 2, 3].contains(2) => Answers true
   *      [1, 2, 3].contains(4) => Answers false
   *
   * @see Collection#contains(obj)
   */
  override method contains(obj) native

  /**
   * Answers the element that represents the maximum value in the collection.
   * The criteria is by direct comparison of the elements (they must be sortable).
   * If collection is empty, an ElementNotFound exception is thrown.
   *
   * Example:
   *       [11, 1, 4, 8, 3, 15, 6].max() =>  Answers 15
   *       [].max()                      =>  Throws error, list must not be empty
   *
   * @see Collection#max()
   */
  override method max() native

  /**
   * Reduce a collection to a certain value, beginning with a seed or initial value
   *
   * Examples
   *     [1, 9, 3, 8].fold(0, {acum, each => acum + each})
   *           => Answers 21, the sum of all elements
   *
   *     [].fold(0, {acum, each => acum + each})
   *           => Answers 0, the seed.
   *
   *     const numbers = [3, 2, 9, 1, 7]
   *     numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) })
   *           => Answers 9, the maximum of all elements
   *
   */
  @Type(variable="Folded", name="Folded")
  override method fold(@Type(name="Folded") initialValue, @Type(name="{ (Folded, Element) => Folded }") closure) native

  /**
   * Finds the first element matching the boolean closure,
   * or evaluates the continuation block closure if no element is found
   *
   * Examples:
   *     [1, 9, 3, 8].findOrElse({ n => n.even() }, { 100 })  => Answers  8
   *     [1, 5, 3, 7].findOrElse({ n => n.even() }, { 100 })  => Answers  100
   */
  override method findOrElse(predicate, continuation) native

  /**
   * Adds the specified element as last one
   *
   * Example:
   *     const list = []
   *     list.add(3)   => list = [3]
   *     list.add(2)   => list = [3, 2]
   *     list.add(2)   => list = [3, 2, 2]
   */
  @Type(name="Void")
  override method add(@Type(name="Element") element) native

  /**
   * Removes an element in this list, if it is present.
   *
   * Example:
   *     const list = [2, 3]
   *     list.remove(3) => list = [2]
   *     list.remove(4) => list = [2], remove operation produces no effect
   */
  override method remove(element) native

  /**
   * Answers the number of elements
   *
   * Example:
   *     [2, 3].size()   => Answers 2
   *     [].size()       => Answers 0
   */
  override method size() native

  /**
   * Removes all of the mappings from this Dictionary.
   * This is a side effect operation.
   *
   * Example:
   *     const list = [2, 3]
   *     list.clear()     => list = []
   */
  override method clear() native

  /**
   * Answers the concatenated string representation of the elements in the given set.
   * You can pass an optional character as an element separator (default is ",")
   *
   * Examples:
   *     [1, 5, 3, 7].join(":") => Answers "1:5:3:7"
   *     ["you","will","love","wollok"].join(" ") => Answers "you will love wollok"
   */
  override method join(separator) native

  /**
   *
   * Answers the concatenated string representation of the elements in the given set,
   * using default element separator (",")
   *
   * Examples:
   *     ["you","will","love","wollok"].join()    => Answers "you,will,love,wollok"
   */
  override method join() native

  /**
   * A list is == another list if all elements are equal (defined by == message)
   *
   *
   * Examples:
   *     [] == []         => Answers true
   *     [1, 2] == [2, 1] => Answers false
   *     [1, 2] == [1, 2] => Answers true
   */
  override method ==(other) native

  /**
   * Answers the list without duplicate elements. Preserves order of elements.
   *
   * [1, 3, 1, 5, 1, 3, 2, 5].withoutDuplicates() => Answers [1, 3, 5, 2]
   * [].withoutDuplicates()                       => Answers []
   */
  @Type(name="List<Element>")
  method withoutDuplicates() native

  /**
  * Shuffles the order of the elements in the list.
  * This is a side effect operation.
  *
  * Examples:
  *     const list = [1, 2 ,3]
  *     list.randomize()     => list = [2, 1, 3]
  */
  @Type(name="Void")
  method randomize() {
    self.sortBy{_,__ => [true,false].anyOne()
    }
  }

  /**
  * Answers a new list of the same type and with the same content in a random order
  *
  *
  * Examples:
  *     [1, 2, 3, 4].randomized() => Answers [2, 3, 1, 4]
  *     [1, 2, 3, 4].randomized() => Answers [2, 1 ,4 ,3]
  */
  @Type(name="List<Element>")
  method randomized() {
    const copy = self.copy().asList()
    copy.randomize()
    return copy
  }

}
