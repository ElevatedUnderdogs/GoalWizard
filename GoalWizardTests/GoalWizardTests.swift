//
//  GoalWizardTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest

final class GoalWizardTests: XCTestCase {

    override func setUpWithError() throws {
#if os(iOS)
    #if !targetEnvironment(simulator)
fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
}
