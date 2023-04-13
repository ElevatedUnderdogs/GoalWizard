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
        let mutableSet = mutableCopy() as! NSMutableOrderedSet
        mutableSet.add(element)
        return mutableSet.copy() as! NSOrderedSet
    }

    func addElements(_ elements: [Any]) -> NSOrderedSet {
        let mutableSet = NSMutableOrderedSet(orderedSet: self)
        mutableSet.addObjects(from: elements)
        return NSOrderedSet(orderedSet: mutableSet)
    }
}
