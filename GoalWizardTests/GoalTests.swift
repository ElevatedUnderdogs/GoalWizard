//
//  GoalTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 3/31/23.
//

import XCTest
@testable import GoalWizard
import CoreData
import SwiftUI

extension Goal {

    func findChildGoal(withTitle title: String) -> Goal? {
        var queue: [Goal] = [self]
        while !queue.isEmpty {
            let currentGoal = queue.removeFirst()
            if currentGoal.title == title {
                return currentGoal
            } else {
                queue.append(contentsOf: currentGoal.subGoals)
            }
        }
        return nil
    }
}

class GoalTestsGptapi: XCTestCase {
    var goal: Goal!

    override func setUp() {
        super.setUp()
#if os(iOS)
    #if !targetEnvironment(simulator)
fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
        clearGoals()
        goal = Goal.empty
        goal.title = "Test Goal"
        goal.daysEstimate = 10

    }

    override func tearDown() {
        goal = nil
        clearGoals()
        super.tearDown()
    }

    func testGptAddSubGoalsSuccess() {
        let initialGoalCount = Goal.context.goals.count
        goal.gptAddSubGoals(
            request: { _ in SubGoalMock() },
            hasAsync: RightNow(),
            completion: { error in
                XCTAssertNil(error)
                XCTAssertTrue(self.goal.subGoals.count > 0)
            }
        )
        let savedGoals = Goal.context.goals
        // Check that the goal count has not changed
        XCTAssertNotEqual(savedGoals.count, initialGoalCount)

        // Check that none of the goals from the example JSON were saved
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Step 1" }))
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Step 2" }))
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Substep 1.1" }))
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Substep 1.2" }))
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Substep 2.1" }))
        XCTAssertTrue(savedGoals.contains(where: { $0.title == "Substep 2.2" }))
    }

    func testGptAddSubGoalsFailure() {
        let initialGoalCount = Goal.context.goals.count
        goal.gptAddSubGoals(
            request: { _ in ErrorSubGoalMock() },
            hasAsync: RightNow(),
            completion: { _ in
                XCTAssertEqual(self.goal.subGoals.count, 0)
            }
        )
        let savedGoals = Goal.context.goals

        // Check that the goal count has not changed
        XCTAssertEqual(savedGoals.count, initialGoalCount)

        // Check that none of the goals from the example JSON were saved
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Step 1" }))
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Step 2" }))
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Substep 1.1" }))
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Substep 1.2" }))
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Substep 2.1" }))
        XCTAssertFalse(savedGoals.contains(where: { $0.title == "Substep 2.2" }))
    }
}

extension XCTestCase {

    func clearGoals() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Goal")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        Goal.context.goals.forEach { Goal.context.delete($0) }
        do {
            try NSPersistentCloudKitContainer.goalTable.viewContext.execute(deleteRequest)
            try NSPersistentCloudKitContainer.goalTable.viewContext.save()
        } catch {
            print("Error deleting all goals: \(error.localizedDescription)")
        }
        XCTAssertEqual(0, Goal.context.goals.count, "ERROR MESSAGE: " + Goal.context.goals.first!.title! + "<")
    }
}

// swiftlint: disable type_body_length
final class GoalTests: XCTestCase {

    override class func setUp() {
        super.setUp()
#if os(iOS)
    #if !targetEnvironment(simulator)
fatalError("These tests should only run on a simulator, not on a physical device.")
#endif
#endif
    }

    override func tearDown() {
        super.tearDown()
        self.clearGoals()
    }

    func testThisFirst() {
        clearGoals()
    }

    func testGoalAncestors() {
        let first: Goal = .start
        first.title = "first"
        let second: Goal = .empty
        second.title = "second"
        let third: Goal = .empty
        third.title = "third"
        first.add(sub: second)
        second.add(sub: third)
        XCTAssertEqual(
            third.ancestors,
            [first, second],
            "third.ancestors.titles: \(third.ancestors.map(\.notOptionalTitle))"
        )
    }

    func testAncestorStringOneElement() {
        let first = Goal.start
        first.title = "first"
        var second = Goal.empty
        second.title = "second"
        first.add(sub: second)
        XCTAssertEqual(second.fullAncestorPath, "first")
        XCTAssertEqual(second.shortenedAncesterPath, "first")
    }

    func testGoalsFilter() {
        let first: Goal = .empty
        first.title = "first"
        let second: Goal = .empty
        second.title = "second"
        let second2: Goal = .empty
        second2.title = "second2"
        second2.importance = "5"
        let third: Goal = .empty
        third.title = "third"
        first.add(sub: second)
        first.add(sub: third)
        first.add(sub: second2)
        let (incomplete, complete) = first.subGoals.filteredSteps(with: "second", flatten: true)
        XCTAssertEqual(incomplete.map(\.notOptionalTitle), ["second2", "second"])
        XCTAssertEqual(complete.map(\.notOptionalTitle), [])
    }

    func testGoalsFilternil() {
        let first: Goal = .empty
        first.title = "first"
        let second: Goal = .empty
        second.title = "second"
        second.importance = "5"
        let second2: Goal = .empty
        second2.title = "second2"
        second2.importance = nil
        let third: Goal = .empty
        third.title = "third"
        first.add(sub: second)
        first.add(sub: third)
        first.add(sub: second2)
        let (incomplete, complete) = first.subGoals.filteredSteps(with: "second", flatten: true)
        XCTAssertEqual(incomplete.map(\.notOptionalTitle), ["second", "second2"])
        XCTAssertEqual(complete.map(\.notOptionalTitle), [])
    }

    func testGoalsFilternil2() {
        let first: Goal = .empty
        first.title = "first"
        let second: Goal = .empty
        second.title = "second"
        second.importance = nil
        let second2: Goal = .empty
        second2.title = "second2"
        second2.importance = "5"
        let third: Goal = .empty
        third.title = "third"
        first.add(sub: second)
        first.add(sub: third)
        first.add(sub: second2)
        let (incomplete, complete) = first.subGoals.filteredSteps(with: "second", flatten: true)
        XCTAssertEqual(incomplete.map(\.notOptionalTitle), ["second2", "second"])
        XCTAssertEqual(complete.map(\.notOptionalTitle), [])
    }

    func testAncestorStringEmpty() {
        let first = Goal.start
        XCTAssertEqual(first.fullAncestorPath, "")
        XCTAssertEqual(first.shortenedAncesterPath, "")
    }

    func testClosedDates() {
        let testDates = [Date(), Date().addingTimeInterval(3600), Date().addingTimeInterval(7200)]
        let goal: Goal = .start
        goal.closedDates = testDates
        XCTAssertEqual(goal.closedDates, testDates, "Closed dates should match what was set")
    }

    func testCompletedDates() {
        let testDates = [Date(), Date().addingTimeInterval(3600), Date().addingTimeInterval(7200)]
        let goal: Goal = .start
        goal.completedDates = testDates
        XCTAssertEqual(goal.completedDates, testDates, "Completed dates should match what was set")
    }

    func testEmptyDates() {
        let goal = Goal.empty
        goal.completedDatesObject = nil
        goal.closedDatesObject = nil
        XCTAssertEqual(goal.closedDates, [])
        XCTAssertEqual(goal.completedDates, [])
    }

    func testNotOptionalEstimatedCompletionDate() {
        let goal = Goal.empty
         goal.estimatedCompletionDate = nil
         XCTAssertEqual(goal.notOptionalEstimatedCompletionDate, "-")
     }

     func testNotOptionalProgressPercentage() {
         let goal = Goal.empty
         goal.progressPercentage = nil
         XCTAssertEqual(goal.notOptionalProgressPercentage, "-")
     }

     func testAddSubGoalWithEmptyTitle() {
         let goal = Goal.empty
         let subGoal = Goal.empty
         subGoal.title = ""
         goal.add(sub: subGoal)
         XCTAssertEqual(goal.stepCount, 0)
     }

     func testAddSubGoalWithNilSteps() {
         let goal = Goal.empty
         let subGoal = Goal.empty
         subGoal.title = "Sub Goal"
         goal.steps = nil
         goal.add(sub: subGoal)
         XCTAssertEqual(goal.stepCount, 1)
     }

     func testProgressWithZeroTotalDays() {
         let goals = [Goal]()
         XCTAssertEqual(goals.progress, 0)
     }

    func testCutOut() {
        let parentGoal = Goal.start
        let originalSubGoalCount = parentGoal.subGoalCount
        let goal: Goal = .empty
        goal.parent = parentGoal

        XCTAssertEqual(parentGoal.subGoalCount, originalSubGoalCount + 1)
        XCTAssertNotNil(goal.parent, "Parent goal should not be nil")
        XCTAssertNoThrow(goal.cutOut(), "Cut out should not throw an error")

        XCTAssertTrue(goal.isUserMarkedForDeletion, "Goal should be marked for deletion")
        XCTAssertNil(goal.parent, "Parent goal should be nil")
        XCTAssertEqual(parentGoal.subGoalCount, originalSubGoalCount)
    }

    func testAddEmpty() {
        let goal: Goal = .empty
        goal.title = "Test123"
        let goal2: Goal = .empty
        let text2 = ""
        goal2.title = text2
        goal.add(sub: goal2)
        XCTAssertEqual(goal.subGoalCount, 0, goal.subGoals.first?.title ?? "nil")
    }

    func testPreview() {
        _ = ContentView_Previews.previews

    }

    func testIsCompleted() {
        let goal: Goal = .empty
        let text1 = "Become attorney"
        goal.title = text1
        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2
        goal.add(sub: goal2)
        goal2.thisCompleted = true
        XCTAssertTrue(goal.isCompleted)
    }

    func testGoalParents() {
        let goal: Goal = .empty
        let text1 = "Become attorney"
        goal.title = text1
        let goal2: Goal = .empty
        let text2 = "Go to law school"
        goal2.title = text2
        let goal3: Goal = .empty
        let text3 = "Research law schools"
        goal3.title = text3
        goal.add(sub: goal2)
        goal2.add(sub: goal3)
        let aSubGoalOf = ", a subgoal of: "
        XCTAssertEqual(goal3.goalForRequest, text3 + aSubGoalOf + text2 + aSubGoalOf + text1)
        clearGoals()
    }

    func testAddGoalViewHasCancel() {
        let first = Goal.start
        _ = AddGoalView(parentGoal: first)
        clearGoals()
    }

    func testSetTitle() {
        let first = Goal.start
        first.notOptionalTitle = "Cows"
        XCTAssertEqual(first.title, "Cows")
        first.notOptionalTitle = "Not"
        XCTAssertEqual(first.title, "Not")
        clearGoals()
    }

    func testAddSubGoal() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.notOptionalTitle = buffer1
        let buffer2 = String(describing: UUID())
        let second = Goal.empty
        second.notOptionalTitle = buffer2
        first.add(sub: second)
        XCTAssertEqual(first.subGoals.first?.title, buffer2)
        clearGoals()
    }

    func testAddToNilSteps() {
        let first = Goal.empty
        first.steps = nil
        let buffer = String(describing: UUID())
        let second = Goal.empty
        second.title = buffer
        first.add(sub: second)
        XCTAssertEqual(first.subGoals.first?.title, second.title)
        clearGoals()
    }

    func testAddSubGoals() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.notOptionalTitle = buffer1
        let buffer2 = String(describing: UUID())
        let second = Goal.empty
        second.notOptionalTitle = buffer2
        let buffer3 = String(describing: UUID())
        let third = Goal.empty
        third.notOptionalTitle = buffer3
        first.add(subGoals: [second, third])
        let titlesFromContext = Goal.context.goals.map(\.notOptionalTitle)
        [buffer2, buffer3].forEach { bufffer in
            XCTAssertTrue(titlesFromContext.contains(bufffer))
        }
        let firstFromContext = Goal.context.goals.first { goal in
            goal.title == buffer1
        }
        let bufferSet: Set<String> = [buffer2, buffer3]
        let subGoalTitles: Set<String> = Set(firstFromContext?.subGoals.map(\.notOptionalTitle) ?? [])
        XCTAssertEqual(bufferSet, subGoalTitles)
        clearGoals()
    }

    func testAddSubGoalTitle() {
        let first = Goal.empty
        let buffer1 = String(describing: UUID())
        first.addSuBGoal(title: buffer1, estimatedTime: 3, importance: "1")
        XCTAssertEqual(first.subGoals.first?.title, buffer1)
        XCTAssertEqual(first.subGoals.first?.daysEstimate, 3)
        clearGoals()
    }

    func testNonOptionalGetter() {
        let first = Goal.empty
        first.title = nil
        XCTAssertEqual(first.notOptionalTitle, "")
        first.title = ""
        clearGoals()
    }

    func testStartGoal() {
        let first = Goal.start
        XCTAssertEqual(first.title, "All Goals")
        XCTAssertTrue(first.topGoal)
        let idBuffer = first.id
        let next = Goal.start
        XCTAssertEqual(next.id, idBuffer)
        clearGoals()
    }

    func testUnitTestFunction() {
        // on app start there is 1 goal inserted, so this will always be 1 or
        // so I thought, turns out there was a goal that was not deleted by batch
        // delete, and specifically deleting was the only way.
        // XCTAssertEqual(Goal.context.goals.count, 1)
        clearGoals()
        XCTAssertEqual(Goal.context.goals.count, 0)
    }

    class MockHasCallCodable: HasCallCodable {
        var result: Result<Choices, Error>?

        func callCodable<T: Codable>(
            expressive: Bool,
            _ action: @escaping (T?) -> Void
        ) {
            switch result {
            case .success(let choices):
                action(choices as? T)
            case .failure(let error):
                action(nil)
                print(error.localizedDescription)
            case .none:
                action(nil)
            }
        }
    }

    class MockHasAsync: HasAsync {
        func async(execute work: @escaping @convention(block) () -> Void) {
            work()
        }
    }

    func testGptAddSubGoalsSuccess() {
        let goal = Goal.empty
        goal.title = "Sample Goal"

        let mockCallCodable = MockHasCallCodable()
        let choices = Choices(thisSteps: [])
        mockCallCodable.result = .success(choices)

        let expectation = XCTestExpectation(description: "Completion is called without error")

        goal.gptAddSubGoals(
            request: { _ in mockCallCodable },
            hasAsync: MockHasAsync(),
            completion: { error in
                XCTAssertNil(error, "Error should be nil when the request is successful")
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)
    }

    func testGptAddSubGoalsNoResponse() {
        let goal = Goal.empty
        goal.title = "Sample Goal"

        let mockCallCodable = MockHasCallCodable()
        mockCallCodable.result = nil

        let expectation = XCTestExpectation(description: "Completion is called without error")

        goal.gptAddSubGoals(
            request: { _ in mockCallCodable },
            hasAsync: MockHasAsync(),
            completion: { error in
                XCTAssertNil(error, "Error should be nil when there is no response")
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)
    }
}
// swiftlint: enable type_body_length
// swiftlint: disable file_length
class GptBuilderTests: XCTestCase {

    func testGptBuilder() {
        let goalTitle = "Sample Goal"
        let request = URLRequest.gptBuilder(goalTitle)

        XCTAssertEqual(request.url, URL.gpt35Turbo)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer \(Secrets.openAIKey)")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")

        let parameters = try? JSONSerialization.jsonObject(with: request.httpBody!, options: []) as? [String: Any]
        XCTAssertNotNil(parameters)
        XCTAssertEqual(parameters?["model"] as? String, "gpt-3.5-turbo")
        XCTAssertEqual(parameters?["temperature"] as? Double, 0.7)

        let messages = parameters?["messages"] as? [[String: String]]
        XCTAssertNotNil(messages)
        XCTAssertEqual(messages?.count, 1)

        let message = messages?.first
        XCTAssertNotNil(message)
    }
}
// swiftlint: enable file_length
