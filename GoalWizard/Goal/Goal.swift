//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Foundation
import Combine

class Goal: Codable, Identifiable, Equatable, ObservableObject, Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let title: String
    let topGoal: Bool
    private weak var parent: Goal?

    private var root: Goal {
        var up: Goal = self
        while let parent = up.parent {
            up = parent
        }
        return up
    }

    @Published var steps: [Goal] {
        didSet {
            progress = steps.isEmpty ? (thisCompleted ? 1 : 0) : steps.progress
            progressPercentage = "\(progress / 1)%"
        }
    }

    // The following properties are ignored in favor of children.
    @Published var daysEstimate: Int
    @Published var thisCompleted: Bool {
        didSet {
            let buffer = root.steps
            root.steps = buffer
        }
    }

    @Published private(set) var progress: Double
    @Published private(set) var progressPercentage: String

    static var topGoal: Goal {
        Goal(title: "All Goals", topGoal: true)
    }

    private init(title: String, daysEstimate: Int = 0, topGoal: Bool) {
        self.id = UUID()
        self.title = title
        self.daysEstimate = daysEstimate
        self.thisCompleted = false
        self.progress = 0
        self.progressPercentage = ""
        self.steps = []
        self.topGoal = topGoal
    }

    init(title: String, daysEstimate: Int = 0) {
        self.id = UUID()
        self.title = title
        self.daysEstimate = daysEstimate
        self.thisCompleted = false
        self.progress = 0
        self.progressPercentage = ""
        self.steps = []
        self.topGoal = false
    }

    var totalDays: Int {
        steps.isEmpty ? daysEstimate : steps.totalDays
    }

    var daysLeft: Int {
        steps.isEmpty ? (thisCompleted ? 0 : daysEstimate) : steps.daysLeft
    }

    var isCompleted: Bool {
        steps.isEmpty ? thisCompleted : daysLeft == 0
    }

    func add(sub goal: Goal) {
        goal.parent = self
        steps.append(goal)
    }

    enum CodingKeys: CodingKey {
        case id, title, steps, daysEstimate, completed, topGoal, progress, progressPercentage
    }

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
    }
}
