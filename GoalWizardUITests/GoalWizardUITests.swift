//
//  GoalWizardUITests.swift
//  GoalWizardUITests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest

final class GoalWizardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {

#if !targetEnvironment(simulator)
fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        let element = app.otherElements["Add"]

        // Set a timeout (in seconds) for how long the test should wait for the element to appear
        let timeout: TimeInterval = 1
        let expectation = expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: element, handler: nil)

        // Wait for the element to appear
        let _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        //XCTAssertEqual(result, .completed, "App did not finish launching within the given timeout")
        // Replace "elementIdentifier" with the accessibility identifier of the view you expect to appear

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCancelButton() {
        app.buttons["Add"].tap()
        app.navigationBars["Add Goal"].buttons["Cancel"].tap()
    }

    func testAddEditGoal() {
        app.buttons["Add"].tap()
        app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        let alphabet: String = "abcdefghijklmnopqrstuvwxys"
        let rand4: [String] = [
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!)
        ]
        setToLowerCaseKeyboard()
        for str in rand4 {
            app.keys[str].tap()
        }
        app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews["Goal List"].staticTexts[rand4.joined()].tap()
        app.buttons["Edit"].tap()

    }

    func setToLowerCaseKeyboard() {
        while !app.keys["a"].exists {
            app/*@START_MENU_TOKEN@*/.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
    }
}
