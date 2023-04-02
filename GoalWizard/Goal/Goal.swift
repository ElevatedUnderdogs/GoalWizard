//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Foundation
import Combine

class Goal: Identifiable, ObservableObject {

    let id: UUID
    let topGoal: Bool

    private weak var parent: Goal?
    @Published var title: String
    @Published var steps: [Goal]
    @Published var daysEstimate: Int {
        didSet {
            updateProgress()
            updateCompletionDate()
        }
    }
    @Published var thisCompleted: Bool {
        didSet {
            updateProgress()
            updateCompletionDate()
        }
    }
    @Published private(set) var progress: Double
    @Published private(set) var progressPercentage: String
    @Published private(set) var estimatedCompletionDate: String

    static var topGoal: Goal {
        Goal(title: "All Goals", topGoal: true)
    }

    private init(title: String, daysEstimate: Int = 0, topGoal: Bool) {
        self.estimatedCompletionDate = ""
        self.id = UUID()
        self.title = title
        self.daysEstimate = daysEstimate
        self.thisCompleted = false
        self.progress = 0
        self.progressPercentage = "0%"
        self.steps = []
        self.topGoal = topGoal
    }

    init(title: String, daysEstimate: Int = 1) {
        self.estimatedCompletionDate = ""
        self.id = UUID()
        self.title = title
        self.daysEstimate = daysEstimate
        self.thisCompleted = false
        self.progress = 0
        self.progressPercentage = "0%"
        self.steps = []
        self.topGoal = false
        self.updateProgressProperties()
        self.updateCompletionDate()
    }

    fileprivate var totalDays: Int {
        steps.isEmpty ? daysEstimate : steps.totalDays
    }

    fileprivate var daysLeft: Int {
        steps.isEmpty ? (thisCompleted ? 0 : daysEstimate) : steps.daysLeft
    }

    var isCompleted: Bool {
        steps.isEmpty ? thisCompleted : daysLeft == 0
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
        updateProgress()
        updateCompletionDate()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { steps.remove(at: $0) }
        updateProgress()
        updateCompletionDate()
    }

    func add(sub goal: Goal) {
        goal.parent = self
        steps.append(goal)
        updateProgress()
        updateCompletionDate()
    }

    func updateProgressProperties() {
        progress = steps.isEmpty ? (thisCompleted ? 1 : 0) : steps.progress
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
        let date = calendar.date(byAdding: .day, value: daysLeft, to: today)!
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

    // Required must be declared directly in class not extension.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        steps = try container.decode([Goal].self, forKey: .steps)
        daysEstimate = try container.decode(Int.self, forKey: .daysEstimate)
        thisCompleted = try container.decode(Bool.self, forKey: .completed)
        topGoal = try container.decode(Bool.self, forKey: .topGoal)
        progress = try container.decode(Double.self, forKey: .progress)
        progressPercentage = try container.decode(String.self, forKey: .progressPercentage)
        estimatedCompletionDate = try container.decode(String.self, forKey: .estimatedCompletionDate)
    }
}

extension Goal: Codable {

    enum CodingKeys: CodingKey {
        case id, title, steps, daysEstimate, completed, topGoal, progress, progressPercentage, estimatedCompletionDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(steps, forKey: .steps)
        try container.encode(daysEstimate, forKey: .daysEstimate)
        try container.encode(thisCompleted, forKey: .completed)
        try container.encode(topGoal, forKey: .topGoal)
        try container.encode(progress, forKey: .progress)
        try container.encode(progressPercentage, forKey: .progressPercentage)
        try container.encode(estimatedCompletionDate, forKey: .estimatedCompletionDate)
    }
}

extension Goal: Equatable {

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }
}

extension Goal: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Provided in this file because of fileprivate computed properties.
extension [Goal] {

    var totalDays: Int {
        reduce(0) { $0 + $1.totalDays }
    }

    var daysLeft: Int {
        reduce(0) { $0 + $1.daysLeft }
    }

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(totalDays - daysLeft) / Double(totalDays)
    }
}
