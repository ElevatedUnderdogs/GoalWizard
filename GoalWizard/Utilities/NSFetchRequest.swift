//
//  NSFetchRequest.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/13/23.
//

import CoreData

extension NSFetchRequest where ResultType == Goal {

    /// Extracted because of Objective C generic capabilities.
    static var topGoalRequest: NSFetchRequest<Goal> {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "topGoal == %@", NSNumber(value: true))
        return fetchRequest
    }
}
