//
//  CodableGoalMatchTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 7/9/23.
//

import XCTest
@testable import GoalWizard
import CoreData

class CodableGoalTests: XCTestCase {

    func testGoalAndCodableGoalHaveSameProperties() {

        // Assuming you have a reference to your persistent container
        let codableGoalMirror = Mirror(reflecting: Goal.start.codableGoal())
        let codableGoalProperties = codableGoalMirror.children.compactMap { $0.label }

        // Retrieve entity description of Goal
        let entityDescription = NSEntityDescription.entity(forEntityName: "Goal", in: Goal.context)

        // Get names of all attributes (properties) in Goal
        guard let goalProperties = entityDescription?.attributesByName.keys else {
            XCTFail("There were no keys for the entity")
            return
        }

        // Make sure they have the same count of properties
        XCTAssertEqual(
            goalProperties.count,
            codableGoalProperties.count,
            "Mismatch in number of properties"
        )

        // Check if each property in Goal exists in CodableGoal
        for property in goalProperties {
            XCTAssertTrue(
                codableGoalProperties.contains(property),
                "Property \(property) does not exist in CodableGoal"
            )
        }
    }
}
