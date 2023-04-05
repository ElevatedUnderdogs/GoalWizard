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

    func addElement(_ element: Any) -> NSOrderedSet {
        let mutableSet = mutableCopy() as! NSMutableOrderedSet
        mutableSet.add(element)
        return mutableSet.copy() as! NSOrderedSet
    }

    func removeElement(at index: Int) -> NSOrderedSet {
        let mutableSet = mutableCopy() as! NSMutableOrderedSet
        mutableSet.removeObject(at: index)
        return mutableSet.copy() as! NSOrderedSet
    }
}
