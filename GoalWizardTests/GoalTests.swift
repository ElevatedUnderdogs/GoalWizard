//
//  GoalTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest
@testable import GoalWizard

extension Goal {

    func findChildGoal(withTitle title: String) -> Goal? {
        var queue: [Goal] = [self]
        while !queue.isEmpty {
            let currentGoal = queue.removeFirst()
            if currentGoal.title == title {
                return currentGoal
            } else {
                queue.append(contentsOf: currentGoal.steps.goals)
            }
        }
        return nil
    }
}

final class GoalTests: XCTestCase {

    func testGoalParents() {
        let goal: Goal = .empty
        let text1 = "Become attorney"
        goal.title = text1
        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2
        let goal3: Goal = .empty
        let text3 = "Research law schools"
        goal3.title = text3
        goal.add(sub: goal2)
        goal2.add(sub: goal3)
        let aSubGoalOf = ", a subgoal of: "
        XCTAssertEqual(goal3.goalForRequest, text3 + aSubGoalOf + text2 + aSubGoalOf + text1)

    }
}
