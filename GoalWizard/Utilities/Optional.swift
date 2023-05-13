//
//  Optional.NSOrderedSet.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import Foundation
import Combine
import CoreData

extension Optional<NSOrderedSet> {

    var goals: [Goal] {
        guard let self else { return [] }
        return (self.array as? [Goal])?.filter { !$0.isUserMarkedForDeletion} ?? []
    }
}

public extension Optional where Wrapped: ExpressibleByArrayLiteral, Wrapped: Equatable {
    var isEmpty: Bool {
        self == [] || self == nil
    }
}
