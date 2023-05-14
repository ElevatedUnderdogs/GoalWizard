//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Combine
import CoreData

extension Goal {

    var closedDates: [Date] {
        get {
            closedDatesObject as? [Date] ?? []
        }
        set {
            closedDatesObject = newValue as NSObject
            willChangeValue(forKey: "closedDatesObject")
        }
    }

    var completedDates: [Date] {
        get {
            completedDatesObject as? [Date] ?? []
        }
        set {
            completedDatesObject = newValue as NSObject
            willChangeValue(forKey: "completedDatesObject")
        }
    }

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

    public var notOptionalEstimatedCompletionDate: String {
        estimatedCompletionDate ?? "-"
    }

    public var notOptionalProgressPercentage: String {
        progressPercentage ?? "-"
    }

    static var empty: Goal {
        let newGoal = Goal(context: Goal.context)
        newGoal.isUserMarkedForDeletion = false
        newGoal.timeStamp = Date()
        newGoal.closedDatesObject = [Date]() as NSObject
        newGoal.completedDatesObject = [Date]() as NSObject
        newGoal.estimatedCompletionDate = ""
        newGoal.id = UUID()
        newGoal.thisCompleted = false
        newGoal.progress = 0
        newGoal.progressPercentage = ""
        newGoal.steps = []
        newGoal.topGoal = false
        newGoal.daysEstimate = 1
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

    func cutOut() -> Goal {
        isUserMarkedForDeletion = true
        updateProgressUpTheTree()
        updateCompletionDateUpTheTree()
        // You must update the tree before attaching from it!
        parent = nil
        Goal.context.saveHandleErrors()
        return self
    }

    func add(sub goal: Goal) {
        guard goal.title != nil && goal.title != "" else { return }
        goal.parent = self
        // We can't force assign this to nil, this always defaults to empty set.
        steps = steps!.addElement(goal)
        Goal.context.saveHandleErrors()
        updateProgressUpTheTree()
        updateCompletionDateUpTheTree()
    }

    func add(subGoals: [Goal]) {
        subGoals.forEach { $0.parent = self }
        steps = steps?.addElements(subGoals)
        updateProgressUpTheTree()
        updateCompletionDateUpTheTree()
        Goal.context.saveHandleErrors()
    }

    static var start: Goal {
        Goal.context.topGoal ??
        Goal.context.createAndSaveGoal(title: "All Goals", isTopGoal: true)
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

    private func updateProgressProperties() {
        progress = steps.goals.isEmpty ? (thisCompleted ? 1 : 0) : steps.goals.progress
        progressPercentage = "\(Int((progress / 1) * 100))%"
    }

    func updateProgressUpTheTree() {
        var upward: Goal = self
        updateProgressProperties()
        while let next = upward.parent {
            upward = next
            upward.updateProgressProperties()
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
        var upward: Goal = self
        updateCompletionDateProperties()
        while let next = upward.parent {
            upward = next
            upward.updateCompletionDateProperties()
        }
    }

    /// testable method
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - hasAsync: <#hasAsync description#>
    ///   - completion: <#completion description#>
    func gptAddSubGoals(
        request: (_ text: String) -> HasCallCodable = URLRequest.gptBuilder,
        hasAsync: HasAsync = DispatchQueue.main,
        completion: @escaping ErrorAction
    ) {
        request(notOptionalTitle).callCodable(expressive: false) { (response: OpenAIResponse<Choices>?) in
            hasAsync.async { [weak self] in
                // The decodedContent always succeeds because it was converted from data and back to it.
                let newGoals: [Goal] = response?.choices.first?.message.contentT?.goals ?? []
                self?.add(subGoals: newGoals)
                completion(nil)
            }
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
        // Set the total days to steps as 0, just 1 step
        // with 0 estimatedDays force assign it, then read the progress from the list.
        guard totalDays > 0 else { return 0 }
        return Double(totalDays - daysLeft) / Double(totalDays)
    }

    func filteredSteps(with searchText: String) -> (incomplete: [Goal], completed: [Goal]) {
        let filteredGoals: [Goal]

        if searchText.isEmpty {
            filteredGoals = Array(self)
        } else {
            filteredGoals = filter { goal in
                goal.title?.lowercased().contains(searchText.lowercased()) == true
            }
        }

        let incompleteGoals = filteredGoals
            .filter { $0.progress < 1 }
            .sorted { lhs, rhs -> Bool in
                if lhs.progress == rhs.progress {
                    return lhs.daysLeft < rhs.daysLeft
                }
                return lhs.progress > rhs.progress
            }

        let completedGoals = filteredGoals.filter { $0.progress == 1 }
        return (incomplete: incompleteGoals, completed: completedGoals)
    }
}
