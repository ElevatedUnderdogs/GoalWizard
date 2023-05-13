//
//  NSOrderedSet.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import Foundation
import Combine
import CoreData

extension NSOrderedSet {

    /// Do not use: @discardableResult, because you need to reassign the set.
    func addElement(_ element: Any) -> NSOrderedSet {
        let mutableSet = mutableOrderedSet
        mutableSet.add(element)
        return NSOrderedSet(orderedSet: mutableSet)
    }

    func addElements(_ elements: [Any]) -> NSOrderedSet {
        let mutableSet = mutableOrderedSet
        mutableSet.addObjects(from: elements)
        return NSOrderedSet(orderedSet: mutableSet)
    }
}

extension NSOrderedSet {
    var mutableOrderedSet: NSMutableOrderedSet {
        NSMutableOrderedSet(orderedSet: self)
    }
}
