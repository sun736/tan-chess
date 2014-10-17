/**
 * This is an implementation the `SetType` protocol creates a unique collection of unordered elements that contain an
 * integer value that counts the number of times the item has been stored in the `SetType`.
 */
public struct CountedSet<T: Hashable> : SetType {
    public typealias ElementType = T
    
    private var data: Dictionary<T, Int>
    
    /// The starting index value for the set.
    public var startIndex: Int { return 0 }
    
    /// The last index value for the set.
    public var endIndex: Int { return data.count }
    
    //
    // MARK: Set methods
    //
    
    public init() {
        data = [T:Int]()
    }
    
    public func isSubsetOfSet(set: CountedSet<T>) -> Bool {
        for item in data.keys {
            if set.contains(item) == false {
                return false
            }
        }
        return true
    }
    
    public func contains(item: T) -> Bool {
        return data[item] == nil ? false : true
    }
    
    public var isEmpty: Bool {
        return data.count == 0
    }
    
    public var size: Int {
        return data.count
    }
    
    public mutating func add(item: T) -> CountedSet<T> {
        if let count = data[item] {
            data[item] = count + 1
        }
        else {
            data[item] = 1
        }
        
        return self
    }
    
    public mutating func add(item: T, numberOfTimes: Int) -> CountedSet<T> {
        assert(numberOfTimes > 0);
        for i in 0..<numberOfTimes {
            self.add(item)
        }
        
        return self
    }
    
    public mutating func remove(item: T) -> CountedSet<T> {
        data.removeValueForKey(item)
        return self
    }
    
    public mutating func removeAll() -> CountedSet<T> {
        data.removeAll(keepCapacity: false)
        return self
    }
}

extension CountedSet: SequenceType {
    public typealias CountedSetPair = (T, Int)
    
    public func generate() -> GeneratorOf<CountedSetPair> {
        var keyGenerator = self.data.keys.generate()
        return GeneratorOf<CountedSetPair> {
            if let key = keyGenerator.next() {
                return (key, self.data[key]!)
            }
            else {
                return .None
            }
        }
    }
}

//extension CountedSet : ArrayLiteralConvertible {
//    public static func convertFromArrayLiteral(elements: T...) -> CountedSet<T> {
//        var set = CountedSet<T>()
//        
//        for element in elements {
//            set.add(element)
//        }
//        
//        return set
//    }
//}

/// Returns a new `Set` that contains the unique values of both `rhs` and `lhs`.
public func ∪<T>(rhs: CountedSet<T>, lhs: CountedSet<T>) -> CountedSet<T> {
    var union = rhs
    for item in lhs {
        union.add(item.0, numberOfTimes: item.1)
    }
    
    return union
}

/// Returns a new `Set` that contains the common values between both `rhs` and `lhs`.
public func ∩<T>(rhs: CountedSet<T>, lhs: CountedSet<T>) -> CountedSet<T> {
    var intersect = CountedSet<T>()
    for item in rhs {
        if lhs.contains(item.0) {
            intersect.add(item.0, numberOfTimes: item.1)
        }
    }
    
    return intersect
}
