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
        table(name: "Goal")
    }()

    static private func table(
        name: String,
        exposeError: (((any Error)?) -> Void)? = nil
    ) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { _, error in
            exposeError?(error)
        }
        return container
    }
}
