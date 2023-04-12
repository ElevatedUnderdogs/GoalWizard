//
//  NSManagedObjectContext.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/4/23.
//

import CoreData

extension NSManagedObjectContext {

//    func deleteGoals(_ goals: [Goal]) {
//        print(goals.map(\.title))
//        goals.forEach { deleteGoal(goal: $0) }
//        saveState()
//    }

    var topGoal: Goal? {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "topGoal == %@", NSNumber(value: true))

        do {
            let goals = try fetch(fetchRequest)
            if goals.count > 1 {
                print("TopGoalError.multipleTopGoals.localizedDescription")
                return nil
            }
            return goals.first
        } catch {
            print("Failed to fetch top goal: \(error)")
            return nil
        }
    }

    var goals: [Goal] { elements(entityName: "Goal") }

    func elements<T: NSFetchRequestResult>(entityName: String) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        do {
            return try fetch(request)
        } catch {
            print("Could not load data: \(error.localizedDescription)")
            return []
        }
    }

    /// If there are changes, it saves the current NSManagedOBjects to CoreData storage. 
    func saveState() {
       // if hasChanges {
            do {
                try save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error: \(error.localizedDescription), \(nsError.userInfo)")
            }
       // }
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
        saveState()
        return newGoal
    }

    func deleteGoal(atOffsets offsets: IndexSet, goal: Goal) {
        let mutableSteps = goal.steps?.mutableCopy() as? NSMutableOrderedSet ?? NSMutableOrderedSet()

        for index in offsets.sorted(by: >) {
            guard let subGoal = mutableSteps.object(at: index) as? Goal else { continue }
            print(subGoal.title as Any)
            deleteGoal(goal: subGoal)
            mutableSteps.removeObject(at: index)
        }

        goal.steps = mutableSteps.copy() as? NSOrderedSet
        // still need to call save state.
        saveState()
    }

    func deleteGoal(goal: Goal) {
        goal.steps?.forEach { step in
            guard let subGoal = step as? Goal else { return }
            deleteGoal(goal: subGoal)
        }
        // still need to call save state
        delete(goal)
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
        saveState()
    }
}
