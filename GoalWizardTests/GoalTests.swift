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

    override class func tearDown() {
        super.tearDown()
        var count = 0
        Goal.context.goals.forEach {
            count += 1
            print("Count: \(count)")
            $0.title = ""
            $0.delete()
        }
    }

    func testTearDown() {
        var count = 0
        Goal.context.goals.forEach {
            count += 1
            print("Count: \(count)")
            $0.title = ""
            $0.delete()
        }
    }

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

    func testAddGoalViewHasCancel() {
        let first = Goal.start
        let goalView = AddGoalView(parentGoal: first)
    }

    func testSetTitle() {
        let first = Goal.start
        first.notOptionalTitle = "Cows"
        XCTAssertEqual(first.title, "Cows")
        first.notOptionalTitle = "Not"
        XCTAssertEqual(first.title, "Not")
    }

    func testAddSubGoal() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.notOptionalTitle = buffer1
        let buffer2 = String(describing: UUID())
        let second = Goal.empty
        second.notOptionalTitle = buffer2
        first.add(sub: second)
        XCTAssertEqual(first.steps.goals.first?.title, buffer2)
    }

    func testAddToNilSteps() {
        let first = Goal.empty
        first.steps = nil
        let buffer = String(describing: UUID())
        let second = Goal.empty
        second.title = buffer
        first.add(sub: second)
        XCTAssertEqual(first.steps.goals.first?.title, second.title)
    }

    func testAddSubGoals() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.notOptionalTitle = buffer1
        let buffer2 = String(describing: UUID())
        let second = Goal.empty
        second.notOptionalTitle = buffer2
        let buffer3 = String(describing: UUID())
        let third = Goal.empty
        third.notOptionalTitle = buffer3
        first.add(subGoals: [second, third])
        let titlesFromContext = Goal.context.goals.map(\.notOptionalTitle)
        [buffer2, buffer3].forEach { bufffer in
            XCTAssertTrue(titlesFromContext.contains(bufffer))
        }
        let firstFromContext = Goal.context.goals.first { goal in
            goal.title == buffer1
        }
        let bufferSet: Set<String> = [buffer2, buffer3]
        let subGoalTitles: Set<String> = Set(firstFromContext?.steps.goals.map(\.notOptionalTitle) ?? [])
        XCTAssertEqual(bufferSet, subGoalTitles)
    }

    
    func testAddSubGoalTitle() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.addSuBGoal(title: buffer1, estimatedTime: 3)
        XCTAssertEqual(first.steps.goals.first?.title, buffer1)
        XCTAssertEqual(first.steps.goals.first?.daysEstimate, 3)
    }

    func testNonOptionalGetter() {
        let first = Goal.empty
        first.title = nil
        XCTAssertEqual(first.notOptionalTitle, "")
    }

    func testStartGoal() {
        let first = Goal.start
        XCTAssertEqual(first.title, "All Goals")
        XCTAssertTrue(first.topGoal)
        let idBuffer = first.id
        let next = Goal.start
        XCTAssertEqual(next.id, idBuffer)
    }

    func testUnitTestFunction() {
        XCTAssertEqual(Goal.context.goals.count, 0)
    }

}
