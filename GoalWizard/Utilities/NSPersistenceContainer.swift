//
//  NSPersistenceContainer.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/3/23.
//

import CoreData

// MARK: - Extension
extension NSPersistentContainer {

    static var goalTable: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Goal")
        container.loadPersistentStores { description, error in
            guard let error = error as? NSError else { return }
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return container
    }()
}


// MARK: - Extension
extension NSManagedObjectContext {

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

public extension Optional where Wrapped: ExpressibleByArrayLiteral, Wrapped: Equatable {
    var isEmpty: Bool {
        self == [] || self == nil
    }
}

/*
 func add(sub goal: Goal) {
     goal.parent = self
     steps.append(goal)
     updateProgress()
     updateCompletionDate()
 }
 */

/*
 Set this as the first one if there is none. 
 static var topGoal: Goal {
     Goal(title: "All Goals", topGoal: true)
 }
 */

/*

 private convenience init(title: String, daysEstimate: Int = 0, topGoal: Bool) {
     self.estimatedCompletionDate = ""
     self.id = UUID()
     self.title = title
     self.daysEstimate = Int64(daysEstimate)
     self.thisCompleted = false
     self.progress = 0
     self.progressPercentage = "0%"
     self.steps = []
     self.topGoal = topGoal
 }

 convenience init(title: String, daysEstimate: Int = 1) {
     self.estimatedCompletionDate = ""
     self.id = UUID()
     self.title = title
     self.daysEstimate = Int64(daysEstimate)
     self.thisCompleted = false
     self.progress = 0
     self.progressPercentage = "0%"
     self.steps = []
     self.topGoal = false
     self.updateProgressProperties()
     self.updateCompletionDate()
 }
 */
