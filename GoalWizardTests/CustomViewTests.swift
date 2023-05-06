//
//  CustomViewTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//

import Foundation
import XCTest
import SwiftUI
@testable import GoalWizard

class CustomViewTests: XCTestCase {

    func testOptionalArrayIsEmpty() {
        let emptyArray: [Int]? = []
        XCTAssertTrue(emptyArray.isEmpty)

        let nilArray: [Int]? = nil
        XCTAssertTrue(nilArray.isEmpty)

        let nonEmptyArray: [Int]? = [1, 2, 3]
        XCTAssertFalse(nonEmptyArray.isEmpty)
    }

    func testRadioButtonToggle() {
        class TestObject: ObservableObject {
            @Published var isChecked = false
        }

        let testObject = TestObject()

        // Create a simple wrapper view that embeds the RadioButton
        struct RadioButtonWrapper: View {
            @ObservedObject var testObject: TestObject

            var body: some View {
                RadioButton(isChecked: $testObject.isChecked)
            }
        }

        _ = RadioButtonWrapper(testObject: testObject)

        // Test that isChecked is initially false
        XCTAssertFalse(testObject.isChecked)

        // Simulate a tap action by toggling isChecked manually
        testObject.isChecked.toggle()

        // Test that isChecked is true after the toggle
        XCTAssertTrue(testObject.isChecked)
    }


    func testAddGoalViewPreview() {
        let addGoalView = AddGoalView(parentGoal: Goal.start)

        // Test that the AddGoalView's parentGoal is the same as Goal.start
        XCTAssertEqual(addGoalView.parentGoal, Goal.start)
    }
    // Add any other required setup or teardown methods if needed
}


struct GoalCellWrapper: View {
    @State private var goal: Goal = .start
    var searchText: String
    var index: Int

    var body: some View {
        GoalCell(step: $goal, searchText: searchText, index: index)
    }
}

class GoalCellTests: XCTestCase {
    func testGoalCellPreview() {
        let wrapperView = GoalCellWrapper(searchText: "", index: 2)
        XCTAssert(wrapperView.searchText.isEmpty)
        XCTAssertEqual(wrapperView.index, 2)
    }
}
