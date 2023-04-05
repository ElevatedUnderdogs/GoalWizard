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

    var goals: [Goal] { elements() }

    func elements<T: NSFetchRequestResult>() -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(
            entityName: String(describing: type(of: T.self))
        )
        do {
            return try fetch(request)
        } catch {
            print("Could not load data: \(error.localizedDescription)")
            return []
        }
    }

    /// Lets you save whatever you pass though saveState.
    func saveState() {
        if hasChanges {
            do {
                try save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error: \(error.localizedDescription), \(nsError.userInfo)")
            }
        }
    }

    /// Lets user save a new question that they created.
    /// - Parameters:
    ///   - text: Lets user save text to new question that they created.
    ///   - isTrueFalse: Lets user save true or false answer to new question that they created.
    ///   - subject: Lets you save a new question from a one to many relationship with that specidic subject.
    func save(goal: Goal) {
       // let Goal = goal.coreData
        saveState()
    }
}
