//
//  CodableGoal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 6/4/23.
//

import CommonExtensions

struct CodableGoal: Codable {
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
                print($0.notOptionalTitle)
                return nil
            }
        }
        return CodableGoal(
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
            steps: check
        )
    }
}

import CoreData

extension NSManagedObjectContext {

    func allCodableGoals() throws -> [CodableGoal] {
        allGoals.compactMap {
            do {
                return try $0.codableGoal()
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
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
        guard let rootGoal = self.first(where: { $0.parentId == nil }) else { return [:] }
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


func saveAndPrintMigration() {
    func loadDataFromFile(filename: String) -> [CodableGoal]? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first?.appendingPathComponent(filename) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let goals = try decoder.decode([CodableGoal].self, from: data)
                return goals
            } catch {
                print("Error reading file: \(error)")
                return nil
            }
        }
        return nil
    }

    do {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let url = urls.first?.appendingPathComponent("goal_migration") else { return }
        let allCodableGoals = try Goal.context.allCodableGoals()
        try allCodableGoals.jsonString?.saveTo(path: url)
        let loaded = loadDataFromFile(filename: "goal_migration")
        assert(allCodableGoals.count == loaded!.count)
        loaded?.forEach {
            dump($0)
        }
        let goalTree = try loaded?.goalTree()
        print(goalTree?.notOptionalTitle as Any)
        print(goalTree?.subGoalCount)
        print("all goals retrieved: \(loaded!.count)")
    } catch {
        print(error.localizedDescription)
    }
}
