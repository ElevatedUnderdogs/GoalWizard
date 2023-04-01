//
//  Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import Foundation
import Combine

class Goal: Codable, Identifiable, Equatable, ObservableObject {

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let title: String
    @Published var steps: [Goal]

    // The following properties are ignored in favor of children.
    var daysEstimate: Int
    var completed: Bool

    init(title: String, daysEstimate: Int = 0) {
        self.id = UUID()
        self.title = title
        self.daysEstimate = daysEstimate
        self.completed = false
        self.steps = []
    }

    var totalDays: Int {
        steps.isEmpty ? daysEstimate : steps.totalDays
    }

    var daysLeft: Int {
        steps.isEmpty ? (completed ? 0 : daysEstimate) : steps.daysLeft
    }

    var progress: Decimal {
        steps.isEmpty ? (completed ? 1 : 0) : steps.progress
    }

    var isCompleted: Bool {
        daysLeft == 0
    }

    func add(sub goal: Goal) {
        steps.append(goal)
    }

    enum CodingKeys: CodingKey {
        case id, title, steps, daysEstimate, completed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        steps = try container.decode([Goal].self, forKey: .steps)
        daysEstimate = try container.decode(Int.self, forKey: .daysEstimate)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(steps, forKey: .steps)
        try container.encode(daysEstimate, forKey: .daysEstimate)
        try container.encode(completed, forKey: .completed)
    }
}
