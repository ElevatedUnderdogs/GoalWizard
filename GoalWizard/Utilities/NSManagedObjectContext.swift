//
//  NSManagedObjectContext.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import CoreData

extension NSManagedObjectContext {

    var topGoal: Goal? {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "topGoal == %@", NSNumber(value: true))
        // Can't extract this into an extension because objective c can't
        // access associated generics in extensions.
        do {
            let goals = try fetch(fetchRequest)
            if goals.count > 1 {
                // Clear the goals, and then read from topGoal. 
                print("TopGoalError.multipleTopGoals.localizedDescription")
                return nil
            }
            return goals.first
        } catch {
            // Difficult to trigger, app crashes instead of throwing an error when attempting, not worth it for tests.
            print("Failed to fetch top goal: \(error.localizedDescription)")
            return nil
        }
    }

    var goals: [Goal] {
        elements(entityName: "Goal").filter { !$0.isUserMarkedForDeletion }
    }

    func elements<T: NSFetchRequestResult>(entityName: String) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        // Can't extract this into an extension because objective c can't
        // access associated generics in extensions.
        do {
            return try fetch(request)
        } catch {
            // Difficult to trigger, app crashes instead of throwing an error when attempting, not worth it for tests.
            print("Could not load data: \(error.localizedDescription)")
            return []
        }
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
        try! save()
        return newGoal
    }

    func deleteGoal(atOffsets offsets: IndexSet, goal: Goal) {
        // This always succeeds, difficult to test.
        let mutableSteps = goal.steps?.mutableCopy() as? NSMutableOrderedSet ?? NSMutableOrderedSet()

        // it is better to delete from the back to front so that the indices don't shift while deleting.
        for index in offsets.sorted(by: >) {
            guard let subGoal = mutableSteps.object(at: index) as? Goal else { continue }
            print(subGoal.title as Any)
            deleteGoal(goal: subGoal)
            mutableSteps.removeObject(at: index)
        }

        goal.steps = mutableSteps.copy() as? NSOrderedSet
        // still need to call save state.
        try! save()
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
        estimatedTime: Int64
    ) {
        // Modify the properties of the goal object
        goal.title = title
        goal.daysEstimate = estimatedTime
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
        try! save()
    }
}
