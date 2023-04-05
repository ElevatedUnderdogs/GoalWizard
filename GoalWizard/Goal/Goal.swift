//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Foundation
import Combine
import CoreData

enum TopGoalError: Error {
    case multipleTopGoals
}

extension NSManagedObjectContext {
    var topGoal: Goal? {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "topGoal == %@", NSNumber(value: true))

        do {
            let goals = try fetch(fetchRequest)
            if goals.count > 1 {
                print(TopGoalError.multipleTopGoals.localizedDescription)
                return nil
            }
            return goals.first
        } catch {
            print("Failed to fetch top goal: \(error)")
            return nil
        }
    }
}

extension NSOrderedSet {

    func addElement(_ element: Any) -> NSOrderedSet {
        let mutableSet = mutableCopy() as! NSMutableOrderedSet
        mutableSet.add(element)
        return mutableSet.copy() as! NSOrderedSet
    }

    func removeElement(at index: Int) -> NSOrderedSet {
        let mutableSet = mutableCopy() as! NSMutableOrderedSet
        mutableSet.removeObject(at: index)
        return mutableSet.copy() as! NSOrderedSet
    }

}

extension Goal {
    // @NSManaged public var nonOptionalTitle: String

    public var notOptionalTitle: String {
        get {
            return title ?? ""
        }
        set {
            title = newValue
        }
    }

    var subGoalCount: Int {
        steps.goals.count + steps.goals.reduce(0) { $0 + $1.subGoalCount }
    }
}

extension Goal {
    
    //    let id: UUID
    //    let topGoal: Bool
    //
    //    weak var parent: Goal?
    //    @Published var title: String
    //    @Published var steps: [Goal]
    //    @Published var daysEstimate: Int {
    //        didSet {
    //            updateProgress()
    //            updateCompletionDate()
    //        }
    //    }
    //    @Published var thisCompleted: Bool {
    //        didSet {
    //            updateProgress()
    //            updateCompletionDate()
    //        }
    //    }
    //    @Published private(set) var progress: Double
    //    @Published private(set) var progressPercentage: String
    //    @Published private(set) var estimatedCompletionDate: String



     func add(sub goal: Goal) {
         goal.parent = self
         steps = steps?.addElement(goal) ?? []
         updateProgress()
         updateCompletionDate()
     }

    static func new(title: String, daysEstimate: Int64 = 1) -> Goal {
        let goal = Goal(context: NSPersistentContainer.goalTable.viewContext)
        goal.estimatedCompletionDate = ""
        goal.id = UUID()
        goal.title = title
        goal.daysEstimate = daysEstimate
        goal.thisCompleted = false
        goal.progress = 0
        goal.progressPercentage = ""
        goal.steps = []
        goal.topGoal = true
        goal.updateProgressProperties()
        goal.updateCompletionDate()
        return goal
    }

    private static var origin: Goal {
        let goal = Goal(context: NSPersistentContainer.goalTable.viewContext)
        goal.estimatedCompletionDate = ""
        goal.id = UUID()
        goal.title = "All Goals"
        goal.daysEstimate = 1
        goal.thisCompleted = false
        goal.progress = 0
        goal.progressPercentage = ""
        goal.steps = []
        goal.topGoal = true
        goal.updateProgressProperties()
        goal.updateCompletionDate()
        return goal
    }

    static var start: Goal {
        NSPersistentContainer.goalTable.viewContext.topGoal ?? .origin
    }
    
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "daysEstimate" || key == "thisCompleted" {
            updateProgress()
            updateCompletionDate()
        }
    }

    fileprivate var totalDays: Int64 {
        steps.goals.isEmpty ? daysEstimate : steps.goals.totalDays
    }

    fileprivate var daysLeft: Int64 {
        steps.goals.isEmpty ? (thisCompleted ? 0 : daysEstimate) : steps.goals.daysLeft
    }

    var isCompleted: Bool {
        steps.isEmpty ? thisCompleted : daysLeft == 0
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        guard let mutableSteps = steps?.mutableCopy() as? NSMutableOrderedSet else {
            return
        }
        mutableSteps.moveObjects(at: source, to: destination)
        steps = mutableSteps.copy() as? NSOrderedSet
        updateProgress()
        updateCompletionDate()
    }

    func delete(at offsets: IndexSet) {
        guard let mutableSteps = steps?.mutableCopy() as? NSMutableOrderedSet else {
            return
        }
        for index in offsets.sorted(by: >) {
            mutableSteps.removeObject(at: index)
        }
        steps = mutableSteps.copy() as? NSOrderedSet
        updateProgress()
        updateCompletionDate()
    }

    func updateProgressProperties() {
        progress = steps.goals.isEmpty ? (thisCompleted ? 1 : 0) : steps.goals.progress
        progressPercentage = "\(Int((progress / 1) * 100))%"
    }

    func updateProgress() {
        var up: Goal = self
        updateProgressProperties()
        while let next = up.parent {
            up = next
            up.updateProgressProperties()
        }
    }

    func updateCompletionDateProperties() {
        let today = Date()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: Int(daysLeft), to: today)!
        if daysLeft < 7 {
            estimatedCompletionDate = DateFormatter.dayOfWeekString(from: date)
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: today) {
            estimatedCompletionDate = DateFormatter.monthDayDayOfWeekString(from: date)
        } else {
            estimatedCompletionDate = DateFormatter.monthDayYearString(from: date)
        }
    }

    func updateCompletionDate() {
        var up: Goal = self
        updateCompletionDateProperties()
        while let next = up.parent {
            up = next
            up.updateCompletionDateProperties()
        }
    }
}


extension Optional<NSOrderedSet> {
    var goals: [Goal] {
        guard let self else { return [] }
        return self.array as? [Goal] ?? []
    }
}

// Provided in this file because of fileprivate computed properties.
extension [Goal] {

    var totalDays: Int64 {
        reduce(0) { $0 + $1.totalDays }
    }

    var daysLeft: Int64 {
        reduce(0) { $0 + $1.daysLeft }
    }

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(totalDays - daysLeft) / Double(totalDays)
    }
}
