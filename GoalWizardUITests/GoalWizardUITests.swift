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

#if canImport(UIKit)
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
#endif
        clearAllCells()
    }

    override func tearDownWithError() throws {
        clearAllCells()
        app = nil
    }

    override func tearDown() {
        super.tearDown()
        clearAllCells()
        app = nil
    }

    var swipeableTexts: [String] {
        app?.staticTexts
            .allElementsBoundByIndex
            .map(\.label)
        // For some reason swipe doesn't work on shorter texts.
            .filter { $0.count > 5 } ?? []
    }

    private func clearAllCells() {
        let buffer = swipeableTexts
        for text in buffer {
            deleteCellWith(title: text)
        }
    }

    private func deleteCellWith(title: String) {
        if app.staticTexts[title].exists &&
            app.staticTexts[title].isHittable &&
            app.staticTexts.matching(identifier: title).count <= 1 {
            app.staticTexts[title].swipeLeft(velocity: .slow)
        } else {
            print(
                """
                Couldn't delete \(title)
                exists: \(app.staticTexts[title].exists)
                hittable: \(app.staticTexts[title].isHittable)
                count 1?: \(app.staticTexts.matching(identifier: title).count)
                """
            )
        }
        let deleteButton = XCUIApplication().collectionViews["Goal List"].buttons["Delete"]
        if deleteButton.exists {
            deleteButton.tap()
        }
    }

    func testCancelButton() {
        app.buttons["Add"].tap()
        app.navigationBars["Add Goal"].buttons["Cancel"].tap()
    }

    let alphabet: String = "abcdefghijklmnopqrstuvwxys"
    var random4Char: [String] {
        [
            // The Strings need to be long for the
            // swipe to delete to work sadly
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!),
            String(alphabet.randomElement()!)
        ]
    }

    func testEditTitleDays() {
        let longString = random4Char.joined()
        returnAfterAdd(new: longString)

        let goalListCollectionView = app.collectionViews["Goal List"]
        goalListCollectionView.staticTexts[longString].tap()
        app.buttons["Edit"].tap()

        let editTextField = app.textViews["EditGoalTextField"]

        editTextField.tap()

        let longString2 = random4Char.joined()
        editTextField.typeText(longString2)

        app.buttons["Edit Close Button"].tap()

        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
        let swipableTexts = swipeableTexts
        XCTAssertTrue(
            swipableTexts.contains(where: { $0.contains(longString2) }),
            "longString: " + longString2 + swipableTexts.joined(separator: ",")
        )
        XCTAssertFalse(
            swipableTexts.contains(longString),
            "longString: " + longString + swipableTexts.joined(separator: ",")
        )
    }

    func testEditEstimatedDays() {
        let longString = random4Char.joined()
        returnAfterAdd(new: longString)

        let firstEstimates = swipeableTexts.filter { $0.contains("Est") }
        XCTAssertGreaterThan(
            firstEstimates.count, 0,
            "There should be one that we added.")
        let goalListCollectionView = app.collectionViews["Goal List"]
        goalListCollectionView.staticTexts[longString].tap()
        app.buttons["Edit"].tap()
        let daysEstimateTextField = app.textFields["DaysEstimateTextField"]
        daysEstimateTextField.tap()
        daysEstimateTextField.typeText("20")
        app.navigationBars["Edit goal"].buttons["DoneButton"].tap()
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
        let newEstimates = swipeableTexts.filter { $0.contains("Est") }
        XCTAssertNotEqual(firstEstimates, newEstimates)
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
            app.textViews["EditGoalTextField"].tap()
            let rand2: String = random4Char.joined()
            app.textViews["EditGoalTextField"].typeText(rand2)

            app.buttons["Edit Close Button"].tap()
            app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
            let swipableTexts = swipeableTexts
            XCTAssertTrue(
                swipableTexts.contains(where: { $0.contains(rand2) }),
                "longString: " + rand2 + swipableTexts.joined(separator: ",")
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

    func testGpTCall() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let eatMoreVegetables: String = "Eat more vegetables"
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(eatMoreVegetables)
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[eatMoreVegetables].tap()
            app.buttons["goalWizardGenicon"].tap()
            goalListCollectionView/*@START_MENU_TOKEN@*/.staticTexts["Research vegetable options"]/*[[".cells.staticTexts[\"Research vegetable options\"]",".staticTexts[\"Research vegetable options\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            goalListCollectionView.staticTexts["Look up different types of vegetables"].tap()
        }
    }

    func testHome() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 10 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let random: String = random4Char.joined()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(random)
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.staticTexts[random].tap()
            app/*@START_MENU_TOKEN@*/.buttons["Home Button"]/*[[".buttons[\"Home\"]",".buttons[\"Home Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            XCTAssert(app.staticTexts["All Goals"].exists)
        }
    }

    func testSearch() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 10 {
            let first = random4Char.joined()
            returnAfterAdd(new: first)
            let second = random4Char.joined()
            returnAfterAdd(new: second)
            let third = random4Char.joined()
            returnAfterAdd(new: third)
            XCTAssertTrue(app.staticTexts[first].exists)
            XCTAssertTrue(app.staticTexts[second].exists)
            XCTAssertTrue(app.staticTexts[third].exists)

            app/*@START_MENU_TOKEN@*/.buttons["Search Button"]/*[[".buttons[\"Search\"]",".buttons[\"Search Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app/*@START_MENU_TOKEN@*/.textFields["Search TextField"]/*[[".textFields[\"Search\"]",".textFields[\"Search TextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app/*@START_MENU_TOKEN@*/.textFields["Search TextField"]/*[[".textFields[\"Search\"]",".textFields[\"Search TextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(first)
            XCTAssertTrue(app.staticTexts[first].exists)
            XCTAssertFalse(app.staticTexts[second].exists)
            XCTAssertFalse(app.staticTexts[third].exists)
        }
    }

    func returnAfterAdd(new: String) {
        app.buttons["Add"].tap()
        app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(new)
        app.buttons["AddGoalButton"].tap()
    }

    func testAddComplete3X() {
        let goalList = app.collectionViews["Goal List"]

        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let rand4: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(rand4.joined())
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[rand4.joined()].tap()
            let circleImage = app.images["circle"]
            circleImage.tap()
            app.images["largecircle.fill.circle"].tap()
            circleImage.tap()
            app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
            XCTAssertTrue(goalListCollectionView.staticTexts["100%"].exists)
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

    func testAddAddCutPaste() {
        let goalList = app.collectionViews["Goal List"]

        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let rand4: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(rand4.joined())
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[rand4.joined()].tap()
            app/*@START_MENU_TOKEN@*/.buttons["Add Button"]/*[[".buttons[\"Add\"]",".buttons[\"Add Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

            let rand42: [String] = random4Char
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app/*@START_MENU_TOKEN@*/.textViews["TitleTextEditor"]/*[[".otherElements[\"Add Goal View\"].textViews[\"TitleTextEditor\"]",".textViews[\"TitleTextEditor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText(rand42.joined())
            app/*@START_MENU_TOKEN@*/.buttons["AddGoalButton"]/*[[".otherElements[\"Add Goal View\"]",".buttons[\"Add Goal\"]",".buttons[\"AddGoalButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            goalListCollectionView.staticTexts[rand42.joined()].tap()
            app/*@START_MENU_TOKEN@*/.buttons["cut Button"]/*[[".buttons[\"scissors.circle.fill\"]",".buttons[\"cut Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
            app/*@START_MENU_TOKEN@*/.buttons["paste Button"]/*[[".buttons[\"Paste, Asfd...\"]",".buttons[\"paste Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            XCTAssertTrue(goalListCollectionView.staticTexts[rand42.joined()].exists)
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
}
// swiftlint: enable line_length
