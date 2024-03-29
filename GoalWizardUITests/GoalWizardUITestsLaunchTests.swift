//
//  GoalWizardUITestsLaunchTests.swift
//  GoalWizardUITests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest

final class GoalWizardUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
#if os(iOS)
#if !targetEnvironment(simulator)
        fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
