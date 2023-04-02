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
                queue.append(contentsOf: currentGoal.steps)
            }
        }
        return nil
    }
}

final class GoalTests: XCTestCase {

    func testTotalDays() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)
        XCTAssertEqual(goal.totalDays, 5)

        let subgoal1 = Goal(title: "Subgoal 1", daysEstimate: 2)
        let subgoal2 = Goal(title: "Subgoal 2", daysEstimate: 3)

        goal.add(sub: subgoal1)
        goal.add(sub: subgoal2)

        XCTAssertEqual(goal.totalDays, 5)
    }

    func testDaysLeft() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)
        XCTAssertEqual(goal.daysLeft, 5)

        let subgoal1 = Goal(title: "Subgoal 1", daysEstimate: 2)
        let subgoal2 = Goal(title: "Subgoal 2", daysEstimate: 3)

        goal.add(sub: subgoal1)
        goal.add(sub: subgoal2)

        subgoal1.thisCompleted = true

        XCTAssertEqual(goal.daysLeft, 3)
    }

    func testAddingSubgoal() {
        let goal = Goal(title: "Test Goal")
        let subgoal = Goal(title: "Subgoal", daysEstimate: 2)

        goal.add(sub: subgoal)

        XCTAssertEqual(goal.steps.count, 1)
        XCTAssertEqual(goal.steps.first?.title, "Subgoal")
    }

    func testFindChildGoal() {
        let goal = Goal(title: "Test Goal")
        let subgoal1 = Goal(title: "Subgoal 1")
        let subgoal2 = Goal(title: "Subgoal 2")

        goal.add(sub: subgoal1)
        subgoal1.add(sub: subgoal2)

        let foundSubgoal1 = goal.findChildGoal(withTitle: "Subgoal 1")
        XCTAssertNotNil(foundSubgoal1)
        XCTAssertEqual(foundSubgoal1?.title, "Subgoal 1")

        let foundSubgoal2 = goal.findChildGoal(withTitle: "Subgoal 2")
        XCTAssertNotNil(foundSubgoal2)
        XCTAssertEqual(foundSubgoal2?.title, "Subgoal 2")
    }

    func testDaysLeftWhenCompleted() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)
        goal.thisCompleted = true
        XCTAssertEqual(goal.daysLeft, 0)
    }

    func testTotalDaysWithSubgoals() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)
        XCTAssertEqual(goal.totalDays, 5)

        let subgoal1 = Goal(title: "Subgoal 1", daysEstimate: 2)
        let subgoal2 = Goal(title: "Subgoal 2", daysEstimate: 3)

        goal.add(sub: subgoal1)
        goal.add(sub: subgoal2)

        XCTAssertEqual(goal.totalDays, 5)
        XCTAssertEqual(subgoal1.totalDays, 2)
        XCTAssertEqual(subgoal2.totalDays, 3)
    }

    func testAddMultipleSubgoals() {
        let goal = Goal(title: "Test Goal")

        let subgoal1 = Goal(title: "Subgoal 1")
        let subgoal2 = Goal(title: "Subgoal 2")
        let subgoal3 = Goal(title: "Subgoal 3")

        goal.add(sub: subgoal1)
        goal.add(sub: subgoal2)
        goal.add(sub: subgoal3)

        XCTAssertEqual(goal.steps.count, 3)
        XCTAssertEqual(goal.steps[0].title, "Subgoal 1")
        XCTAssertEqual(goal.steps[1].title, "Subgoal 2")
        XCTAssertEqual(goal.steps[2].title, "Subgoal 3")
    }

    func testFindChildGoalNotPresent() {
        let goal = Goal(title: "Test Goal")
        let subgoal1 = Goal(title: "Subgoal 1")
        let subgoal2 = Goal(title: "Subgoal 2")

        goal.add(sub: subgoal1)
        subgoal1.add(sub: subgoal2)

        let foundSubgoal = goal.findChildGoal(withTitle: "Subgoal 3")
        XCTAssertNil(foundSubgoal)
    }

    func testDaysLeftWithNoDaysEstimate() {
        let goal = Goal(title: "Test Goal")

        XCTAssertEqual(goal.daysLeft, 0)

        goal.thisCompleted = true

        XCTAssertEqual(goal.daysLeft, 0)
    }

    func testTotalDaysWithNoDaysEstimate() {
        let goal = Goal(title: "Test Goal")

        XCTAssertEqual(goal.totalDays, 0)
    }

    func testDaysLeftWhenSubgoalDaysEstimateIsZero() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)

        let subgoal = Goal(title: "Subgoal", daysEstimate: 1)

        goal.add(sub: subgoal)

        XCTAssertEqual(goal.daysLeft, 1)
    }

    func testTotalDaysWhenSubgoalDaysEstimateIsZero() {
        let goal = Goal(title: "Test Goal", daysEstimate: 5)

        let subgoal = Goal(title: "Subgoal", daysEstimate: 1)

        goal.add(sub: subgoal)

        XCTAssertEqual(goal.totalDays, 1)
    }

    func testIsComplete() {
        let goal = Goal(title: "Test Goal")

        let subgoal1 = Goal(title: "Subgoal 1", daysEstimate: 2)
        let subgoal2 = Goal(title: "Subgoal 2", daysEstimate: 3)
        let subgoal3 = Goal(title: "Subgoal 3", daysEstimate: 1)

        goal.add(sub: subgoal1)
        goal.add(sub: subgoal2)
        goal.add(sub: subgoal3)

        subgoal1.thisCompleted = true
        subgoal2.thisCompleted = true
        XCTAssertFalse(goal.isCompleted)
        subgoal3.thisCompleted = true
        XCTAssertTrue(goal.isCompleted)
        subgoal3.thisCompleted = false
        XCTAssertFalse(goal.isCompleted)

        subgoal1.add(sub: Goal(title: "SubGoal 4"))
        XCTAssertFalse(goal.isCompleted)
    }
}
