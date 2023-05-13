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

    func testDeleteOutOfRange() {
        Goal.context.deleteGoal(atOffsets: IndexSet(integer: 1), goal: .empty)
    }

    func testSortedIndices() {
        let goal1 = Goal.empty
        goal1.title = "Goal 1"
        let goal2 = Goal.empty
        goal2.title = "Goal 2"
        let goal3 = Goal.empty
        goal3.title = "Eat food"
        let empty: Goal = .empty
        empty.add(subGoals: [goal1, goal2, goal3])
        Goal.context.deleteGoal(
            atOffsets: IndexSet(integersIn: 1...2),
            goal: empty
        )
        XCTAssertEqual(empty.steps?.count, 1)
        XCTAssertEqual(empty.steps.goals.first?.notOptionalTitle, "Goal 1")
    }
}

/*
 func deleteGoal(atOffsets offsets: IndexSet, goal: Goal) {
     // This always succeeds, difficult to test.

     // steps automatically sets to empty set
     // can't turn it nil for the life of me.
     let mutableSteps = goal.steps!.mutableOrderedSet
     // it is better to delete from the back to front so that the indices don't shift while deleting.
     for index in offsets.sorted(by: >) {
         // Ensure the index is within the range of mutableSteps
         guard index >= 0, index < mutableSteps.count,
                 let subGoal = mutableSteps.object(at: index) as? Goal else {
             continue
         }
         print(subGoal.title as Any)
         deleteGoal(goal: subGoal)
         mutableSteps.removeObject(at: index)
     }

     goal.steps = NSOrderedSet(orderedSet: mutableSteps)
     saveHandleErrors()
     goal.updateProgressUpTheTree()
     goal.updateCompletionDateUpTheTree()
 }
 */
