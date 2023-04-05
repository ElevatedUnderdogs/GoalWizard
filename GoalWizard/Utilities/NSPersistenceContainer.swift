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

