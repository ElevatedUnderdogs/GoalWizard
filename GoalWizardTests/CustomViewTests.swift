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
}

struct GoalCellWrapper: View {
    @State private var goal: Goal = .start
    var searchText: String
    var index: Int

    var body: some View {
        GoalCell(
            step: $goal,
            pathPresentation: nil,
            searchText: searchText,
            index: index,
            pasteBoard: GoalPasteBoard()
        )
    }
}

class GoalCellTests: XCTestCase {
    func testGoalCellPreview() {
        let wrapperView = GoalCellWrapper(searchText: "", index: 2)
        XCTAssert(wrapperView.searchText.isEmpty)
        XCTAssertEqual(wrapperView.index, 2)
    }
}
