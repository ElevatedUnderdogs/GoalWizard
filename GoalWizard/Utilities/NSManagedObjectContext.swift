//
//  NSManagedObjectContext.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import CoreData

extension NSManagedObjectContext {

    func mergeTopGoals(
        topGoals: [Goal] = Goal.context.allGoals.filter(\.topGoal)
    ) {
        guard let firstNotMarked = topGoals.filter { !$0.isUserMarkedForDeletion }.first else {
            return
        }

        for topGoal in topGoals where topGoal != firstNotMarked {
            let topGoalSteps = topGoal.steps ?? []
            let firstTopSteps = firstNotMarked.steps ?? []
            firstNotMarked.steps = topGoalSteps.union(firstTopSteps)
            Goal.context.deleteGoal(goals: [topGoal])
        }
        saveHandleErrors()
    }

    var topGoal: Goal? {
        // Can't extract this into an extension because objective c can't
        // access associated generics in extensions.
        // Don't need to check for multiple because swiftlint rule protects.
        // Difficult to trigger, app crashes instead of throwing an error when attempting, not worth it for tests.
        // swiftlint: disable force_try
        try! fetch(.topGoalRequest).filter { !$0.isUserMarkedForDeletion }.first
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
        importance: String = "1",
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
        newGoal.importance = importance
        newGoal.updateProgressUpTheTree()
        newGoal.updateCompletionDateUpTheTree()
        saveHandleErrors()
        return newGoal
    }

    func saveHandleErrors() {
        do {
            try save()
        } catch {
            #if DEBUG
            print((error as? NSError)?.userInfo as Any)
            #endif
        }
    }

    func deleteGoal(goals: [Goal]) {
        goals.forEach {
            deleteGoal(goal: $0)
            $0.updateProgressUpTheTree()
            $0.updateCompletionDateUpTheTree()
            saveHandleErrors()
        }
    }

    func deleteGoal(goal: Goal) {
        goal.subGoals.forEach { step in
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
        importance: String?
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
