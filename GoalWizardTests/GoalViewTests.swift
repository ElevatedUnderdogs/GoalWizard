//
//  GoalViewTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/11/23.
//

import XCTest
@testable import GoalWizard
import CoreData

final class GoalViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        self.clearGoals()
#if os(iOS)
    #if !targetEnvironment(simulator)
        fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
    }

    override func tearDown() {
        super.tearDown()
        self.clearGoals()
    }

    func testDeleteGoalInView() {
        let goal: Goal = .start
        let text1 = "Become attorney"
        goal.title = text1
        let goalView = GoalView(goal: goal, pasteBoard: GoalPasteBoard())

        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2

        let goal3: Goal = .empty
        let text3 = "Research law schools"
        goal3.title = text3
        goal.add(sub: goal2)
        goal2.add(sub: goal3)
        XCTAssertEqual(Set(Goal.context.goals.map(\.title)), Set([text1, text2, text3]))
        goalView.delete(impcomplete: IndexSet([0]))
        XCTAssertEqual(Goal.context.goals.map(\.title), [text1])
    }

    /// Tests adding subggoals, completing one, deleting the completed one, and delteing an incomplete goal.
    func testCompletedIncompleteDelete() {
        let goal: Goal = .start
        let text1 = "Become attorney"
        goal.title = text1
        let goalView = GoalView(goal: goal, pasteBoard: GoalPasteBoard())

        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2

        let goal3: Goal = .empty
        let text3 = "Research law schools"
        goal3.title = text3

        let goal4: Goal = .empty
        let text4 = "sell yourself"
        goal4.title = text4
        goal.add(sub: goal2)
        goal.add(sub: goal3)
        goal.add(sub: goal4)

        goal4.thisCompleted = true
        XCTAssertEqual(goalView.filteredSteps.completed, [goal4])
        goalView.delete(complete: [0])
        XCTAssertEqual(goalView.filteredSteps.completed, [])

        XCTAssertEqual(Set(Goal.context.goals.map(\.title)), Set([text1, text2, text3]))

        XCTAssertEqual(Set(goalView.filteredSteps.incomplete.map(\.title)), Set([text2, text3]))
        goalView.delete(impcomplete: [0])
        XCTAssertEqual(Set(goalView.filteredSteps.incomplete.map(\.title)), Set([text3]))
        XCTAssertEqual(Set(Goal.context.goals.map(\.title)), Set([text1, text3]))
    }

    func testUpParentsAfterDelete() {
        let goal: Goal = .start
        let goalView = GoalView(goal: goal, pasteBoard: GoalPasteBoard())

        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2

        let goal3: Goal = .empty
        let text3 = "Research law schools"
        goal3.title = text3

        let goal4: Goal = .empty
        let text4 = "Sell yourself"
        goal4.title = text4

        // Add subgoals to the parent goal
        goal.add(sub: goal2)
        goal.add(sub: goal3)
        goal.add(sub: goal4)

        // Set goal3 and goal4 as completed
        goal3.thisCompleted = true
        goal4.thisCompleted = true

        goal4.updateProgressUpTheTree()
        goal4.updateCompletionDateUpTheTree()

        // Verify that the parent goal's progress has updated
        XCTAssertEqual(goal.progress, 2.0 / 3.0, "Parent goal's progress should be 2/3 after completing two subgoals")

        // Delete goal3 (a completed subgoal)
        goalView.delete(complete: IndexSet([0]))

        // Verify that the parent goal's progress has updated again
        XCTAssertEqual(
            goal.progress, 1.0 / 2.0,
            "Parent goal's progress should be 1/2 after deleting one of the completed subgoals"
        )
    }

    func testGoalViewWithNonTopGoal() {
        // Set up a non-topGoal with one or more goals in its steps property
        let nonTopGoal = Goal.empty

        // Initialize the GoalView with the non-topGoal
        let goalView: some View & TestableView = GoalView(goal: nonTopGoal, pasteBoard: GoalPasteBoard())

        // Test that the goal in the GoalView is the same as the nonTopGoal you created
        XCTAssertEqual(goalView.model as? Goal, nonTopGoal)
    }

    // Why isn't the modify state being set in unit tests!?

//    func testGoalViewStateEdit() {
//        // Set up your view model, observed objects, or any other required data
//        // Initialize the GoalView with the necessary data
//        let goalView = GoalView(goal: .empty)
//
//
//
//        // Set the state to edit
//        goalView.modifyState = .edit
//
//        // Test that the state is indeed edit
//        XCTAssertEqual(goalView.modifyState, .edit)
//        let _ = goalView.body
//    }
//
//
//    func testShowSearchView() {
//        // Set up your view model, observed objects, or any other required data
//        // Initialize the GoalView with the necessary data
//        let goalView = GoalView(goal: .empty)
//
//        // Set the showSearchView state to true
//        goalView.showSearchView.toggle()
//
//
//        // Test that the showSearchView state is indeed true
//        XCTAssertTrue(goalView.showSearchView)
//        let _ = goalView.body
//    }
}

protocol TestableView {
    associatedtype Model
    var model: Model { get }
}

extension GoalView: TestableView {
    // TestableView
    typealias Model = Goal
    var model: Model { goal }
}

import SwiftUI

class PreviewProviderTests: XCTestCase {

    func testGoalCellPreview() {
        let goalCellPreview = GoalCell_Previews.previews as? GoalCell
        XCTAssertNotNil(goalCellPreview)

        XCTAssertEqual(goalCellPreview?.$step.wrappedValue, .start)
        XCTAssertEqual(goalCellPreview?.searchText, "")
        XCTAssertEqual(goalCellPreview?.index, 2)
    }

    func testAddGoalViewPreview() {
        let addGoalViewPreview = AddGoalView_Previews.previews as? AddGoalView
        XCTAssertNotNil(addGoalViewPreview)

        XCTAssertEqual(addGoalViewPreview?.parentGoal, Goal.start)
    }
}
