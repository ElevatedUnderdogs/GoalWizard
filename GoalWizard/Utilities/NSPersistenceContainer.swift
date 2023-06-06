//
//  NSPersistenceContainer.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/3/23.
//

import CoreData

// MARK: - Extension
extension NSPersistentCloudKitContainer {

    static var goalTable: NSPersistentCloudKitContainer = {
        table(name: "Goal")
    }()

    static private func table(
        name: String,
        exposeError: (((any Error)?) -> Void)? = nil
    ) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: name)
        container.loadPersistentStores { _, error in
            if let nsError = error as? NSError {
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            exposeError?(error)
        }
        return container
    }
}
