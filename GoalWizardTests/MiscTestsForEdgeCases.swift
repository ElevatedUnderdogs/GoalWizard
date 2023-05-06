//
//  MiscTestsForEdgeCases.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//

import XCTest
@testable import GoalWizard
import CoreData

class CoreDataTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        // Set up your test Core Data stack
    }

    func testSaveState() {
        // Test for successful save
    //    XCTAssertNoThrow(context.saveState())

        // Test for error handling
        // Intentionally cause an error, e.g., by using an invalid object or configuration, and then test for the error type
    }

    func testGoalTableLoad() {
        let container = NSPersistentContainer.goalTable
        XCTAssertNotNil(container)
        XCTAssertEqual(container.name, "Goal")
    }
}

class EditGoalViewTests2: XCTestCase {

    func testSetGoal() {
        let goal = Goal.empty
        let view = EditGoalView(goal: goal)
        view.setGoal(title: "New Title")
        XCTAssertEqual(goal.title, "New Title")
    }

    func testSetDayEstimate() {
        let goal = Goal.empty
        let view = EditGoalView(goal: goal)
        view.set(dayEstimate: "5")
        XCTAssertEqual(goal.daysEstimate, 5)
    }
}

class GoalTests2: XCTestCase {

    func testSubGoalCount() {

        let parentGoal = Goal.empty
        let subGoal1 = Goal.empty
        subGoal1.title = "sub goal 1"
        let subGoal2 = Goal.empty
        subGoal2.title = "sub goal 2"

        parentGoal.steps = NSOrderedSet(array: [subGoal1, subGoal2])
        XCTAssertEqual(parentGoal.subGoalCount, 2)
    }

    func testAddSubGoal() {

        let parentGoal = Goal.empty
        let subGoal = Goal.empty
        subGoal.title = "SubGoal"

        parentGoal.add(sub: subGoal)
        XCTAssertEqual(parentGoal.steps?.count, 1)
    }


    func testIsCompleted() {

        let goal = Goal.empty
        goal.daysEstimate = 1
        goal.thisCompleted = true
        XCTAssertTrue(goal.isCompleted)
    }
}

class GoalArrayTests: XCTestCase {

    func testProgress() {

        let goal1 = Goal.empty
        goal1.daysEstimate = 0
        XCTAssertEqual(goal1.progress, 0)
    }
}


class FilteredStepsTests: XCTestCase {
    func testFilteredSteps() {
        let goal1 = Goal.empty
        goal1.title = "Goal 1"
        let goal2 = Goal.empty
        goal2.title = "Goal 2"
        let goal3 = Goal.empty
        goal3.title = "Eat food"
        let goals: [Goal] = [goal1, goal2, goal3]

        let searchText = "Goal"
        var filteredSteps = goals.filteredSteps(with: searchText)

        XCTAssertEqual(filteredSteps.incomplete.count, 2)
        XCTAssertEqual(filteredSteps.completed.count, 0)

        XCTAssertTrue(filteredSteps.incomplete.contains(goal1))
        XCTAssertTrue(filteredSteps.incomplete.contains(goal2))
        XCTAssertFalse(filteredSteps.completed.contains(goal3))
        goal2.add(sub: goal3) // 0/1
        goal3.daysEstimate = 2 // 0/2
        goal3.thisCompleted = true // 2/2
        let goal4 = Goal.empty
        goal4.title = "Watermellon"
        goal2.add(sub: goal4) // 2/3

        print(goal2.progress, goal1.progress)
        filteredSteps = goals.filteredSteps(with: searchText)
        XCTAssertEqual(filteredSteps.incomplete.first, goal2)
        XCTAssertEqual(filteredSteps.incomplete.last, goal1)
    }
}
