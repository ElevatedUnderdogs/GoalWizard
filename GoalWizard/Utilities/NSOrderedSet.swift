//
//  NSSet.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import Foundation
import Combine
import CoreData

extension NSSet {

    /// Do not use: @discardableResult, because you need to reassign the set.
    func addElement(_ element: Any) -> NSSet {
        let mutableSet = NSMutableSet(set: self)
        mutableSet.add(element)
        return NSSet(set: mutableSet)
    }

    func addElements(_ elements: [Any]) -> NSSet {
        let mutableSet = NSMutableSet(set: self)
        mutableSet.addObjects(from: elements)
        return NSSet(set: mutableSet)
    }

    func union(_ elements: NSSet) -> NSSet? {
        let mutableSet = NSMutableSet(set: self)
        mutableSet.union(elements.hashableSet)
        return NSSet(set: mutableSet)
    }

    var hashableSet: Set<AnyHashable> {
        self as? Set<AnyHashable> ?? []
    }

    var mutableSet: NSMutableSet {
        NSMutableSet(set: self)
    }
}
