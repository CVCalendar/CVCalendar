//
//  CVSet.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 17/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

/**
  *  Deprecated since Swift 1.2.
  *  Instead use native Swift Set<T> collection.
*/

public struct CVSet<T: AnyObject>: NilLiteralConvertible {
    // MARK: - Private properties
    private var storage = [T]()
    
    // MARK: - Public properties
    var count: Int {
        return storage.count
    }
    
    var last: T? {
        return storage.last
    }
    
    // MARK: - Initialization
    public init(nilLiteral: ()) { }
    init() { }
    
    // MARK: - Subscript
    subscript(index: Int) -> T? {
        get {
            if index < storage.count {
                return storage[index]
            } else {
                return nil
            }
        }
    }
}

// MARK: - Mutating methods

public extension CVSet {
    mutating func addObject(object: T) {
        if indexObject(object) == nil {
            storage.append(object)
        }
    }
    
    mutating func removeObject(object: T) {
        if let index = indexObject(object) {
            storage.removeAtIndex(index)
        }
    }
    
    mutating func removeAll(keepCapacity: Bool) {
        storage.removeAll(keepCapacity: keepCapacity)
    }
}

// MARK: - Util 

private extension CVSet {
    func indexObject(object: T) -> Int? {
        for (index, storageObj) in storage.enumerate() {
            if storageObj === object {
                return index
            }
        }
        
        return nil
    }
}


// MARK: - SequenceType
 extension CVSet: SequenceType {
    public func generate() -> AnyGenerator<T> {
        var power = 0
        let nextClosure : () -> T? = {
            (power < self.count) ? self.storage[power++] : nil
        }
        return anyGenerator(nextClosure)
    }
}