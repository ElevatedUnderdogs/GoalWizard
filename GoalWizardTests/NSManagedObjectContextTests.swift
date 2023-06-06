//
//  NSManagedObjectContextTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 5/12/23.
//
import XCTest
@testable import GoalWizard
import CoreData

class MockContext: NSManagedObjectContext {
    var shouldThrowError = false

    override func save() throws {
        if shouldThrowError {
            throw NSError(
                domain: "",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Mocked Error"
                ]
            )
        }
    }
}

class NSManagedObjectContextTests: XCTestCase {

    func testGoals() {
        _ = Goal.start
        let empty = Goal.empty
        // its okay for tests.
        // swiftlint: disable disallow_topGoal_set_true
        empty.topGoal = true
        // swiftlint: enable disallow_topGoal_set_true
        _ = Goal.start
    }

    func testSaveHandleErrors() {
        let mockContext = MockContext(concurrencyType: .mainQueueConcurrencyType)
        mockContext.shouldThrowError = true
        mockContext.saveHandleErrors()
    }

    func testSortedIndices() {
        let goal1 = Goal.empty
        goal1.title = "Goal 1"
        goal1.importance = "3"
        let goal2 = Goal.empty
        goal2.title = "Goal 2"
        goal2.importance = "2"
        let goal3 = Goal.empty
        goal3.title = "Eat food"
        goal3.importance = "1"

        let empty: Goal = .empty
        empty.add(subGoals: [goal1, goal2, goal3])
        Goal.context.deleteGoal(goals: [goal1, goal2])
        XCTAssertEqual(empty.stepCount, 1)
        XCTAssertEqual(empty.subGoals.first?.notOptionalTitle, "Eat food")
    }
}
