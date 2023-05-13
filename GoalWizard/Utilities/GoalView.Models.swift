//
//  GoalView.Models.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/10/23.
//

import SwiftUI
import CoreData
import Callable
import CommonExtensions
import Foundation
import Dispatch

enum ModifyState: Int, Identifiable {
    case edit, add
    var id: Int { rawValue }
}

// MARK: - Goal
struct GoalStruct: Codable {
    let title: String
    let daysEstimate: Int
    let steps: [GoalStruct]
}

struct OpenAIResponse<T: Codable>: Codable {
    let choices: [Choice<T>]
    let id: String
    let model: String
    let usage: Usage
    let object: String
    let created: TimeInterval
}

struct Choice<T: Codable>: Codable {
    let message: Message<T>
    let finishReason: String?
    let index: Int
}

struct Message<T: Codable>: Codable {
    let content: String
    let role: String
    var contentT: T? {
        try? content.decodedContent()
    }
}

struct Usage: Codable {
    let totalTokens: Int
    let completionTokens: Int
    let promptTokens: Int

    private enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
    }
}

enum OpenAIError: Error {
    case invalidResponse
}

// MARK: - Choices
struct Choices: Codable {
    let thisSteps: [ThisStep]
}

extension Choices {
    var goals: [Goal] {
        var result = [Goal]()
        for thisStep in thisSteps {
            let goal = Goal.empty
            goal.title = thisStep.title
            goal.daysEstimate = Int64(thisStep.daysEstimate)
            goal.parent = nil

            var subGoals = [Goal]()
            for step in thisStep.steps {
                let subGoal = Goal.empty
                subGoal.title = step.subtitle
                subGoal.daysEstimate = Int64(step.subdaysEstimate)
                subGoal.parent = goal
                subGoals.append(subGoal)
            }
            goal.steps = NSOrderedSet(array: subGoals)
            result.append(goal)
        }
        return result
    }
}

// MARK: - ThisStep
struct ThisStep: Codable {
    let title: String
    let daysEstimate: Int
    let steps: [Step]
}

// MARK: - Step
struct Step: Codable {
    let subtitle: String
    let subdaysEstimate: Int
}

enum ButtonState {
    case normal
    case loading
    case hidden
}
