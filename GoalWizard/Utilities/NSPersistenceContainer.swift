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


    /// Setup taken from Apple doc project.
    var backgroundContext: NSManagedObjectContext {
        // Create a new background context
        let taskContext = newBackgroundContext()

        // Set the merge policy to resolve conflicts in favor of the in-memory (newer) state for properties that have been changed.  Your latest change > persisted state.  Otherwise default would be to throw an error. 
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Disable the undo manager to improve performance since undo/redo functionality is not needed for this context
        taskContext.undoManager = nil

        // Return the configured background context
        return taskContext
    }
}

