//
//  NSManagedObjectContext.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import CoreData

extension NSManagedObjectContext {

    var topGoal: Goal? {
        // Can't extract this into an extension because objective c can't
        // access associated generics in extensions.
        // Don't need to check for multiple because swiftlint rule protects.
        // Difficult to trigger, app crashes instead of throwing an error when attempting, not worth it for tests.
        // swiftlint: disable force_try
        try! fetch(.topGoalRequest).first
        // swiftlint: enable force_try
    }

    var goals: [Goal] {
        allGoals.filter { !$0.isUserMarkedForDeletion }
    }

    var allGoals: [Goal] {
        elements(entityName: "Goal")
    }

    func elements<T: NSFetchRequestResult>(entityName: String) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        // Can't extract this into an extension because objective c can't
        // access associated generics in extensions.
        // swiftlint: disable force_try
        return try! fetch(request)
        // swiftlint: enable force_try
    }

    @discardableResult
    func createAndSaveGoal(
        title: String,
        estimatedTime: Int64 = 0,
        isTopGoal: Bool = false,
        parent: Goal? = nil
    ) -> Goal {
        // Create a new Goal object in the context
        let newGoal = Goal.empty

        newGoal.topGoal = isTopGoal
        newGoal.parent = parent
        parent?.steps = parent?.steps?.addElement(newGoal)
        newGoal.title = title
        newGoal.daysEstimate = estimatedTime

        newGoal.updateProgressUpTheTree()
        newGoal.updateCompletionDateUpTheTree()
        saveHandleErrors()
        return newGoal
    }

    func saveHandleErrors() {
        do {
            try save()
        } catch {
        }
    }

    func deleteGoal(atOffsets offsets: IndexSet, goal: Goal) {
        // This always succeeds, difficult to test.

        // steps automatically sets to empty set
        // can't turn it nil for the life of me.
        let mutableSteps = goal.steps!.mutableOrderedSet
        // it is better to delete from the back to front so that the indices don't shift while deleting.
        for index in offsets.sorted(by: >) {
            // Ensure the index is within the range of mutableSteps
            guard index >= 0, index < mutableSteps.count,
                    let subGoal = mutableSteps.object(at: index) as? Goal else {
                continue
            }
            print(subGoal.title as Any)
            deleteGoal(goal: subGoal)
            mutableSteps.removeObject(at: index)
        }

        goal.steps = NSOrderedSet(orderedSet: mutableSteps)
        saveHandleErrors()
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
    }

    func deleteGoal(goal: Goal) {
        goal.steps.goals.forEach { step in
            deleteGoal(goal: step)
        }
        // still need to call save state
        // delete(goal)
        goal.isUserMarkedForDeletion = true
    }

    func updateGoal(
        goal: Goal,
        title: String,
        estimatedTime: Int64,
        importance: NSDecimalNumber?
    ) {
        // Modify the properties of the goal object
        goal.title = title
        goal.daysEstimate = estimatedTime
        goal.importance = importance
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
        saveHandleErrors()
    }
}
