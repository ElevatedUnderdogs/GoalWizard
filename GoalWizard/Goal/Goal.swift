//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Foundation
import Combine
import CoreData

extension Goal {

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

    var totalDays: Int64 {
        steps.goals.isEmpty ? daysEstimate : steps.goals.totalDays
    }

    var daysLeft: Int64 {
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
