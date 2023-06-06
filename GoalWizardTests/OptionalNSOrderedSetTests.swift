//
//  OptionalNSSetTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//
import XCTest
@testable import GoalWizard
import CoreData

class OptionalNSSetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        clearGoals()
    }

    override func tearDown() {
        super.tearDown()
        clearGoals()
    }

    func testGoals_whenOptionalIsNil() {
        let orderedSet: NSSet? = nil
        let goals = orderedSet.goals
        XCTAssertTrue(goals.isEmpty)
    }

    class CustomObject: NSManagedObject {}

    func testFailedCastToGoalArray() {
        let customObject = CustomObject()
        let set: NSSet? = NSSet(object: customObject)

        let result: [Goal] = set.goals

        XCTAssertTrue(result.isEmpty, "The result should be an empty array when the cast to [Goal] fails.")
    }
}
