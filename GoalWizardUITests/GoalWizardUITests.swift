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

    fileprivate func type(_ rand4: [String]) {
        for str in rand4 {
            app.keys[str].tap()
        }
    }
    let alphabet: String = "abcdefghijklmnopqrstuvwxys"
    var random4Char: [String] {
        [
        String(alphabet.randomElement()!),
        String(alphabet.randomElement()!),
        String(alphabet.randomElement()!),
        String(alphabet.randomElement()!)
        ]
    }

    func testAddEditGoal() {
        app.buttons["Add"].tap()
        app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let rand4: [String] = random4Char
        checkKeyBoardShowing()
        setToLowerCaseKeyboard()
        type(rand4)
        app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews["Goal List"].staticTexts[rand4.joined()].tap()
        app.buttons["Edit"].tap()
        app/*@START_MENU_TOKEN@*/.textFields["EditGoalTextField"]/*[[".otherElements[\"Edit Goal View\"]",".textFields[\"Edit goal\"]",".textFields[\"EditGoalTextField\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        checkKeyBoardShowing()
        setToLowerCaseKeyboard()
        app/*@START_MENU_TOKEN@*/.keys["delete"]/*[[".keyboards.keys[\"delete\"]",".keys[\"delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let rand2: [String] = random4Char
        checkKeyBoardShowing()
        setToLowerCaseKeyboard()
        type(rand2)
        app/*@START_MENU_TOKEN@*/.buttons["CloseSavedButton"]/*[[".otherElements[\"Edit Goal View\"]",".buttons[\"Close (Saved)\"]",".buttons[\"CloseSavedButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()

        let bigger: String = [rand4[0], rand4[1], rand4[2]].joined() + rand2.joined()
        XCTAssertTrue(
            app.collectionViews["Goal List"].staticTexts[bigger].exists ||
            app.collectionViews["Goal List"].staticTexts[rand2.joined()].exists
        )
        XCTAssertFalse(app.collectionViews["Goal List"].staticTexts[rand4.joined()].exists)

    }

    /**
     Check if hardware keyboard is connected: In the iOS Simulator, go to I/O > Keyboard and make sure "Connect Hardware Keyboard" is unchecked. If a hardware keyboard is connected, the software keyboard might not show up in the simulator.
     Reset the simulator: If none of the above steps work, try resetting the simulator by going to Device > Erase All Content and Settings. This will reset the simulator to its default state, which might resolve any issues with the keyboard not appearing.
     Update Xcode and the simulator: Make sure you are using the latest version of Xcode and the iOS simulator. Updates may contain bug fixes that can resolve issues with the keyboard not appearing in UI tests.
     */
    func checkKeyBoardShowing() {
        while !app/*@START_MENU_TOKEN@*/.keyboards.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.exists {
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
    }

    func setToLowerCaseKeyboard() {
        while !app.keys["a"].exists {
            app/*@START_MENU_TOKEN@*/.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
    }
}
