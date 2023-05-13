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
        container.loadPersistentStores { _, error in
            guard let error = error as? NSError else { return }
            // This is a difficult path to reach, if I make this loud, I will have to throw errors everywhere... 
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return container
    }()
}
