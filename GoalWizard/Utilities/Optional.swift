//
//  Optional.NSSet.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import Foundation
import Combine
import CoreData

extension Optional<NSSet> {

    var goals: [Goal] {
        guard let self else { return [] }
        return (self.array as? [Goal])?.filter { !$0.isUserMarkedForDeletion} ?? []
    }
}

extension NSSet {

    var goals: [Goal] {
        (self.array as? [Goal])?.filter { !$0.isUserMarkedForDeletion } ?? []
    }
}

public extension Optional where Wrapped: ExpressibleByArrayLiteral, Wrapped: Equatable {
    var isEmpty: Bool {
        self == [] || self == nil
    }
}

extension Optional where Wrapped == Date {

    func reminderText(for version: String) -> String {
        "Reminder" + (self.map { ": \($0.typical), \($0.clockTime)" } ?? " \(version)")
    }
}
