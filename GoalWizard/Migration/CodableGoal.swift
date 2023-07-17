////
////  CodableGoal.swift
////  GoalWizard
////
////  Created by Scott Lydon on 6/4/23.
////

import CommonExtensions

struct CodableGoal: Codable {
    let wontFixText: String?
    let id: UUID
    let title: String
    let daysEstimate: Int64
    let estimatedCompletionDate: String?
    let forceUpdate: String?
    let importance: String?
    let isUserMarkedForDeletion: Bool
    let progress: Double
    let progressPercentage: String?
    let thisCompleted: Bool
    let timeStamp: Date?
    let topGoal: Bool
    let parentId: UUID? // use UUID to reference parent
    let steps: [UUID] // use UUID to reference Steps
    let closedDatesObject: [Date]
}

enum GoalError: Error {
    case idISNilforGoal(name: String)
}

extension Goal {

    func codableGoal() -> CodableGoal {
        let check = steps.goals.compactMap {
            if let id = $0.id {
                return id
            } else {
                debugPrint($0.notOptionalTitle)
                return nil
            }
        }
        return CodableGoal(
            wontFixText: wontFixText,
            id: id ?? UUID(),
            title: title ?? "",
            daysEstimate: daysEstimate,
            estimatedCompletionDate: estimatedCompletionDate,
            forceUpdate: forceUpdate,
            importance: importance,
            isUserMarkedForDeletion: isUserMarkedForDeletion,
            progress: progress,
            progressPercentage: progressPercentage,
            thisCompleted: thisCompleted,
            timeStamp: timeStamp ?? Date(),
            topGoal: topGoal,
            parentId: parent?.id,
            steps: check,
            closedDatesObject: closedDates
        )
    }
}

import CoreData

extension NSManagedObjectContext {

    func allCodableGoals() throws -> [CodableGoal] {
        allGoals.compactMap {  $0.codableGoal() }
    }
}

extension Array where Element == CodableGoal {

    var jsonData: Data? {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(self)
        } catch {
            return nil
        }
    }

    var dictionary: [UUID: CodableGoal] {
        guard first(where: { $0.parentId == nil }) != nil else { return [:] }
        var goalDictionary = [UUID: CodableGoal]()
        for goal in self {
            goalDictionary[goal.id] = goal
        }
        return goalDictionary
    }

    func goalTree() throws -> Goal? {
        var resultDictionary: [UUID: Goal] = [:]
        let bufferDictionary: [UUID: CodableGoal] = dictionary
        // Step 1: Convert each CodableGoal to Goal
        for (id, codableGoal) in bufferDictionary {
            // Assuming you have a proper initializer
            resultDictionary[id] = Goal(codableGoal, context: Goal.context)
        }
        // Step 2:
        for (id, codableGoal) in bufferDictionary {
            if let parentId: UUID = codableGoal.parentId,
               let parentGoal: Goal = resultDictionary[parentId] {
                resultDictionary[id]?.parent = parentGoal
            }
            codableGoal.steps.compactMap { resultDictionary[$0] }.forEach {
                resultDictionary[id]?.steps = resultDictionary[id]?.steps?.addElement($0)
            }
        }
        // get the root
        let rootPotentials = resultDictionary.values.filter(\.topGoal)
        assert(rootPotentials.count == 1)
        return rootPotentials.first
    }

}

extension Goal {
    convenience init(_ codableGoal: CodableGoal, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = codableGoal.id
        self.title = codableGoal.title
        self.daysEstimate = codableGoal.daysEstimate
        self.estimatedCompletionDate = codableGoal.estimatedCompletionDate
        self.forceUpdate = codableGoal.forceUpdate
        self.importance = codableGoal.importance
        self.isUserMarkedForDeletion = codableGoal.isUserMarkedForDeletion
        self.progress = codableGoal.progress
        self.progressPercentage = codableGoal.progressPercentage
        self.thisCompleted = codableGoal.thisCompleted
        self.timeStamp = codableGoal.timeStamp
        self.topGoal = codableGoal.topGoal
        // self.parentId = codableGoal.parentId
        // self.steps =
        // You'll have to initialize steps later when you have all the goals, since they reference each other.
    }
}

func loadDataFromFile(filename: String = "goal_migration") -> Goal? {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = urls.first?.appendingPathComponent(filename) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let goals = try decoder.decode([CodableGoal].self, from: data)
            let goalTree = try goals.goalTree()
            debugPrint(goalTree?.notOptionalTitle as Any)
            debugPrint(goalTree?.subGoalCount as Any)
            return goalTree
        } catch {
            debugPrint("Error reading file: \(error)")
            return nil
        }
    }
    return nil
}

func saveAndPrintMigration() {
    do {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let url = urls.first?.appendingPathComponent("goal_migration") else { return }
        let allCodableGoals = try Goal.context.allCodableGoals()
        allCodableGoals.jsonString?.saveTo(path: url)
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func deleteDuplicatesById(goals: [Goal]) {
    // Assuming you have a NSManagedObjectContext instance called 'context'
    let context = Goal.context

    var seenIds = Set<UUID>() // Adjust as per your unique identifier's type
    var duplicates = [Goal]()

    for goal in goals {
        // Assume 'id' is the unique identifier for each goal
        if let id = goal.id {
            if seenIds.contains(id) {
                duplicates.append(goal)
            } else {
                seenIds.insert(id)
            }
        }
    }

    for duplicate in duplicates {
        context.deleteGoal(goal: duplicate)
    }
    context.saveHandleErrors()
}

func saveGoalTreeToCoreData(goal: Goal) {
    let context = Goal.context
    context.perform {
        context.insert(goal)
        do {
            try context.save()
            debugPrint("Goal saved successfully")
        } catch let error {
            debugPrint("Failed to save goal: \(error.localizedDescription)")
        }
    }
}

func saveToCoreData(goals: [Goal]) {
    let context = Goal.context
    context.perform {
        goals.forEach {
            context.insert($0)
        }
        do {
            try context.save()
            debugPrint("Goal saved successfully")
        } catch let error {
            debugPrint("Failed to save goal: \(error.localizedDescription)")
        }
    }
}
