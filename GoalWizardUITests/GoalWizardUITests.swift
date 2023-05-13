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

#if os(iOS)
    #if !targetEnvironment(simulator)
fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        let element = app.otherElements["Add"]

        let timeout: TimeInterval = 1
        let expectation = expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: element, handler: nil)

        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
    }

    override func tearDownWithError() throws {
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCancelButton() {
        app.buttons["Add"].tap()
        app.navigationBars["Add Goal"].buttons["Cancel"].tap()
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

    // swiftlint: disable line_length
    // if there are no cells, then add one, if there are any, change the first.
    func testAddEditGoal() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 4 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let rand4: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(rand4.joined())
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

          //  XCUIApplication().collectionViews["Goal List"].tap()
            goalList.staticTexts[rand4.joined()].tap()
            app.buttons["Edit"].tap()
            app/*@START_MENU_TOKEN@*/.textFields["EditGoalTextField"]/*[[".otherElements[\"Edit Goal View\"]",".textFields[\"Edit goal\"]",".textFields[\"EditGoalTextField\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            let rand2: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textFields["EditGoalTextField"]/*[[".otherElements[\"Edit Goal View\"]",".textFields[\"Edit goal\"]",".textFields[\"EditGoalTextField\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.typeText(rand2.joined())

            app.buttons["Edit Goal Button"].tap()
            app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
            let bigger: String = [rand4[0], rand4[1], rand4[2]].joined() + rand2.joined()
            XCTAssertTrue(
                goalList.staticTexts[bigger].exists ||
                goalList.staticTexts[rand2.joined()].exists, "expected \(bigger), or \(rand2)"
            )
            XCTAssertFalse(goalList.staticTexts[rand4.joined()].exists)
        } else {
            // not worth it case. 
            /*
             // Provided exclusively for ui tests :(
             Button(action: {
                 Goal.context.goals.forEach {
                     Goal.context.deleteGoal(goal: $0)
                 }
              }) {
                  Text("Hidden Button")
              }
              .opacity(0)
              .accessibilityIdentifier("hiddenButton")

             */
            // app.buttons["hiddenButton"].tap()
            // testAddEditGoal()           u
        }
    }

    // if there are no cells, then add one, if there are any, change the first.
    func testProgress() {
        XCUIDevice.shared.orientation = .portrait
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 50 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let rand4: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(rand4.joined())
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            XCTAssertTrue(app.staticTexts["0%"].exists)
            goalList.staticTexts[rand4.joined()].tap()

            app.images["circle"].tap()
            let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
            backButton.tap()

            XCTAssertTrue(app.staticTexts["100%"].exists)
        } else {
            // Addressing this case is "not worth it" NWI
            /*
             // Provided exclusively for ui tests :(
             Button(action: {
                 Goal.context.goals.forEach {
                     Goal.context.deleteGoal(goal: $0)
                 }
              }) {
                  Text("Hidden Button")
              }
              .opacity(0)
              .accessibilityIdentifier("hiddenButton")

             */
            // app.buttons["hiddenButton"].tap()
            // testAddEditGoal()
        }
    }
    // swiftlint: enable line_length

    func testWhenNoCells() {

    }

    func testWhenHasCells() {

    }
}

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.isHittable {
            let startPoint = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
            let endPoint = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            startPoint.press(forDuration: 0.01, thenDragTo: endPoint)
        }
    }
}
