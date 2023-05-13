//
//  AddGoalViewTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 5/12/23.
//

import Foundation
import XCTest
import SwiftUI
@testable import GoalWizard

class AddGoalViewTests: XCTestCase {

    func testInitialProperties() {
        let addGoalView = AddGoalView(parentGoal: Goal.start)
        let mirror = Mirror(reflecting: addGoalView)
        XCTAssertNil(mirror.descendant("title"), "State properties can't be reflected")
        XCTAssertNil(mirror.descendant("daysEstimate"), "State properties can't be reflected")
    }

    func testAddGoalViewPreview() {
        let addGoalView = AddGoalView(parentGoal: Goal.start)

        // Test that the AddGoalView's parentGoal is the same as Goal.start
        XCTAssertEqual(addGoalView.parentGoal, Goal.start)
    }

    func testTitleAndDaysEstimate() throws {
        let view = AddGoalView(parentGoal: Goal.start) // Replace YourView with the actual name of your view
        XCTAssertEqual(view.title, "")
        XCTAssertEqual(view.daysEstimate, "")
    }
}
