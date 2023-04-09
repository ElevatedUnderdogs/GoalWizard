//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Combine
import CoreData

extension Goal {

    static private(set) var context: NSManagedObjectContext = NSPersistentContainer.goalTable.viewContext

    var goalForRequest: String {
        var result: String = notOptionalTitle
        var parent = parent
        while let strongParent = parent {
            result += ", a subgoal of: \(strongParent.notOptionalTitle )"
            parent = parent?.parent
        }
        return result
    }

    public var notOptionalTitle: String {
        get {
            return title ?? ""
        }
        set {
            title = newValue
        }
    }

    static var empty: Goal {
        let newGoal = Goal(context: Goal.context)
        newGoal.timeStamp = Date()
        newGoal.estimatedCompletionDate = ""
        newGoal.id = UUID()
        newGoal.thisCompleted = false
        newGoal.progress = 0
        newGoal.progressPercentage = ""
        newGoal.steps = []
        newGoal.updateProgressUpTheTree()
        newGoal.updateCompletionDateUpTheTree()
        return newGoal
    }

    var subGoalCount: Int {
        steps.goals.count + steps.goals.reduce(0) { $0 + $1.subGoalCount }
    }

    func addSuBGoal(title: String, estimatedTime: Int64) {
        Goal.context.createAndSaveGoal(
            title: title,
            estimatedTime: estimatedTime,
            parent: self
        )
    }

    func add(sub goal: Goal) {
        goal.parent = self
        steps = steps?.addElement(goal) ?? []
        updateProgressUpTheTree()
        updateCompletionDateUpTheTree()
    }

    func add(subGoals: [Goal]) {
        subGoals.forEach { $0.parent = self }
        steps = steps?.addElements(subGoals)
        updateProgressUpTheTree()
        updateCompletionDateUpTheTree()
        Goal.context.saveState()
    }

    static var start: Goal {
        Goal.context.topGoal ?? Goal.context.createAndSaveGoal(title: "All Goals", isTopGoal: true)
    }
    
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "daysEstimate" || key == "thisCompleted" {
            updateProgressUpTheTree()
            updateCompletionDateUpTheTree()
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

        Goal.context.updateGoal(
            goal: self,
            title: self.notOptionalTitle,
            estimatedTime: self.daysEstimate
        )
    }

    private func updateProgressProperties() {
        progress = steps.goals.isEmpty ? (thisCompleted ? 1 : 0) : steps.goals.progress
        progressPercentage = "\(Int((progress / 1) * 100))%"
    }

    func updateProgressUpTheTree() {
        var up: Goal = self
        updateProgressProperties()
        while let next = up.parent {
            up = next
            up.updateProgressProperties()
        }
    }

    private func updateCompletionDateProperties() {
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

    func updateCompletionDateUpTheTree() {
        var up: Goal = self
        updateCompletionDateProperties()
        while let next = up.parent {
            up = next
            up.updateCompletionDateProperties()
        }
    }

    static func fromJson(json: [String: Any]) -> Goal? {
        guard let title = json["title"] as? String else {
            return nil
        }

        let daysEstimate = json["daysEstimate"] as? Int64 ?? 0

        let goal = Goal(context: Goal.context)
        goal.title = title
        goal.daysEstimate = daysEstimate

        if let stepsJson = json["steps"] as? [[String: Any]] {
            var steps: [Goal] = []

            for stepJson in stepsJson {
                guard let step = Goal.fromJson(json: stepJson) else {
                    continue
                }

                steps.append(step)
            }

            goal.steps = NSOrderedSet(array: steps)
        }

        return goal
    }

    static func fromJsonIterative(json: [String: Any]) -> Goal? {
        guard let title = json["title"] as? String else {
            return nil
        }

        let daysEstimate = json["daysEstimate"] as? Int64 ?? 0

        let goal = Goal(context: Goal.context)
        goal.title = title
        goal.daysEstimate = daysEstimate

        if let stepsJson = json["steps"] as? [[String: Any]] {
            var steps: [Goal] = []
            var queue = stepsJson

            while !queue.isEmpty {
                let stepJson = queue.removeFirst()

                guard let step = Goal.fromJson(json: stepJson) else {
                    continue
                }

                steps.append(step)

                if let subStepsJson = stepJson["steps"] as? [[String: Any]] {
                    for subStepJson in subStepsJson {
                        queue.append(subStepJson)
                    }
                }
            }

            goal.steps = NSOrderedSet(array: steps)
        }

        return goal
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
