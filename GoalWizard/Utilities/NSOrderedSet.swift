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

    /// Fails when the elements do not conform to Hashable.
    var mutableSet: NSMutableSet {
        NSMutableSet(set: self)
    }

    var mutableOrderedSet: NSMutableOrderedSet {
        NSMutableOrderedSet(array: allObjects)
    }
}
