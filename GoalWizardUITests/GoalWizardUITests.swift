//
//  GoalWizardUITests.swift
//  GoalWizardUITests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest

// swiftlint: disable file_length
// swiftlint: disable type_body_length
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
        if title.lowercased() == "Flatten".lowercased() { return }
        if app.staticTexts[title].exists &&
            app.staticTexts[title].isHittable &&
            app.staticTexts.matching(identifier: title).count <= 1 {
            app.staticTexts[title].swipeLeft(velocity: .slow)
        } else if app.collectionViews["Goal List"].otherElements["goal_cell_0"].exists &&
            app.collectionViews["Goal List"].otherElements["goal_cell_0"].isHittable {
                app.collectionViews["Goal List"].otherElements["goal_cell_0"].swipeLeft(velocity: .slow)
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
        add(new: longString)

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
        add(new: longString)

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

    func testEditImportance() {
        let longString = random4Char.joined()
        add(new: longString)

        let firstEstimates = swipeableTexts.filter { $0.contains("Est") }
        XCTAssertGreaterThan(
            firstEstimates.count, 0,
            "There should be one that we added.")
        let goalListCollectionView = app.collectionViews["Goal List"]
        goalListCollectionView.staticTexts[longString].tap()
        app.buttons["Edit"].tap()

        let importanceTextField = app.textFields["ImportanceTextField"]
        importanceTextField.tap()
        importanceTextField.typeText("7")
        app.navigationBars["Edit goal"].buttons["DoneButton"].tap()
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
        let seven = swipeableTexts.filter { $0.contains("7") }
        XCTAssertNotEqual(firstEstimates, seven)
    }

    // if there are no cells, then add one, if there are any, change the first.
    func testAddEditGoal() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app.textViews["TitleTextEditor"].tap()
            let rand4: [String] = random4Char
            app.textViews["TitleTextEditor"].typeText(rand4.joined())
            app.buttons["AddGoalButton"].tap()

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
            app.textViews["TitleTextEditor"].tap()
            let rand4: [String] = random4Char
            app.textViews["TitleTextEditor"].typeText(rand4.joined())
            app.buttons["AddGoalButton"].tap()
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
            app.textViews["TitleTextEditor"].tap()
            let eatMoreVegetables: String = "Eat more vegetables"
            app.textViews["TitleTextEditor"].typeText(eatMoreVegetables)
            app.buttons["AddGoalButton"].tap()
            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[eatMoreVegetables].tap()
           // save your api calls!
            // app.buttons["goalWizardGenicon"].tap()
            goalListCollectionView.staticTexts["Research vegetable options"].tap()
            goalListCollectionView.staticTexts["Look up different types of vegetables"].tap()
        }
    }

    func testHome() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 10 {
            app.buttons["Add"].tap()
            app.textViews["TitleTextEditor"].tap()
            let random: String = random4Char.joined()
            app.textViews["TitleTextEditor"].typeText(random)
            app.buttons["AddGoalButton"].tap()
            app.staticTexts[random].tap()
            app.buttons["Home Button"].tap()
            XCTAssert(app.staticTexts["All Goals"].exists)
        }
    }

    func testSearch() {
        let goalList = app.collectionViews["Goal List"]
        if goalList.staticTexts.count < 10 {
            let first = random4Char.joined()
            add(new: first)
            let second = random4Char.joined()
            add(new: second)
            let third = random4Char.joined()
            add(new: third)
            XCTAssertTrue(app.staticTexts[first].exists)
            XCTAssertTrue(app.staticTexts[second].exists)
            XCTAssertTrue(app.staticTexts[third].exists)

            app.buttons["Search Button"].tap()
            app.textFields["Search TextField"].tap()
            app.textFields["Search TextField"].typeText(first)
            XCTAssertTrue(app.staticTexts[first].exists)
            XCTAssertFalse(app.staticTexts[second].exists)
            XCTAssertFalse(app.staticTexts[third].exists)
        }
    }

    func add(new: String, returnAfter: Bool = true) {
        app.buttons["Add"].tap()
        app.textViews["TitleTextEditor"].tap()
        app.textViews["TitleTextEditor"].typeText(new)
        if returnAfter {
            app.buttons["AddGoalButton"].tap()
        }
    }

    func testImportanceRating() {
        let app = XCUIApplication()
        let addButtonButton = app.buttons["Add Button"]
        addButtonButton.tap()
        let titletexteditorTextView = app.textViews["TitleTextEditor"]
        titletexteditorTextView.tap()
        let addgoalbuttonButton = app.buttons["AddGoalButton"]
        addgoalbuttonButton.tap()
        addButtonButton.tap()
        titletexteditorTextView.tap()
        titletexteditorTextView.tap()
        let importancetextfieldTextField = app.textFields["ImportanceTextField"]
        importancetextfieldTextField.tap()
        importancetextfieldTextField.tap()
        addgoalbuttonButton.tap()
    }

    /// When I fix the cell tap always navigating error, then this will need to be fixed. 
    func testTreeFlattenPathLong() {
        let goalList = app.collectionViews["Goal List"]

        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app.textViews["TitleTextEditor"].tap()
            let rand4: [String] = random4Char
            app.textViews["TitleTextEditor"].typeText(rand4.joined())
            app.buttons["AddGoalButton"].tap()
            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[rand4.joined()].tap()
            let app = XCUIApplication()

            for newGoal in ["Second", "Third"] {
                app.buttons["Add Button"].tap()
                let textEditor = app.textViews["TitleTextEditor"]
                textEditor.tap()
                textEditor.typeText(newGoal)
                app.buttons["AddGoalButton"].tap()
                app.collectionViews["Goal List"].staticTexts[newGoal].tap()
            }
            let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
            backButton.tap()
            backButton.tap()
            backButton.tap()
            if app.buttons["Flattened button"].exists {
                app.buttons["Flattened button"].tap()
            }
            goalList.children(matching: .cell).element(boundBy: 1).buttons["All Goals...Second"].tap()
            backButton.tap()
            XCTAssertTrue(goalList.buttons["All Goals->\n\(rand4.joined())->\nSecond"].exists)
            goalList.buttons["All Goals->\n\(rand4.joined())->\nSecond"].tap()
            backButton.tap()
            XCTAssertTrue(goalList.buttons["All Goals...Second"].exists)
        } else {
            XCTFail("you might not be clearing cells properly")
        }
    }

    func tapBackButton() {
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
    }

    /// Goes to new goal
    func addGoalDepth(text: String) {
        add(new: text)
        app.staticTexts[text].tap()
    }

    func testEditMiddleGoal() {
        let first = random4Char.joined()
        let second = random4Char.joined()
        let third = random4Char.joined()

        addGoalDepth(text: first)
        addGoalDepth(text: second)
        addGoalDepth(text: third)
        tapBackButton()
        app.buttons["Edit"].tap()
        XCTAssertTrue(swipeableTexts.contains(where: { $0.contains(second) }))
    }

    func testTapExpandFlattenCompleted() {
        let first = random4Char.joined()
        add(new: first)
        let second = random4Char.joined()
        add(new: second)
        app.staticTexts[second].tap()
        let third = random4Char.joined()
        add(new: third)
        app.collectionViews["Goal List"].staticTexts[third].tap()
        app.images["circle"].tap()

        tapBackButton()
        tapBackButton()

        app.buttons["Flattened button"].tap()

        let goalListCollectionView = app.collectionViews["Goal List"]
        goalListCollectionView.buttons["All Goals...\(second)"].tap()
        tapBackButton()
        XCTAssertTrue(goalListCollectionView.buttons["All Goals->\n\(second)"].exists)
        app.buttons["Expand to tree"].tap()
        XCTAssertTrue(app.collectionViews["Goal List"].staticTexts[second].exists)
    }

    func testAddComplete3X() {
        let goalList = app.collectionViews["Goal List"]

        if goalList.staticTexts.count < 8 {
            app.buttons["Add"].tap()
            app.textViews["TitleTextEditor"].tap()
            let rand4: [String] = random4Char
            app.textViews["TitleTextEditor"].typeText(rand4.joined())
            app.buttons["AddGoalButton"].tap()
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
            app.textViews["TitleTextEditor"].tap()
            let rand4: [String] = random4Char
            app.textViews["TitleTextEditor"].typeText(rand4.joined())
            app.buttons["AddGoalButton"].tap()

            let goalListCollectionView = app.collectionViews["Goal List"]
            goalListCollectionView.staticTexts[rand4.joined()].tap()
            app.buttons["Add Button"].tap()

            let rand42: [String] = random4Char
            app.textViews["TitleTextEditor"].tap()
            app.textViews["TitleTextEditor"].typeText(rand42.joined())
            app.buttons["AddGoalButton"].tap()
            goalListCollectionView.staticTexts[rand42.joined()].tap()
            app.buttons["cut Button"].tap()
            app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
            app.buttons["paste Button"].tap()
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
// swiftlint: enable type_body_length
// swiftlint: enable file_length
