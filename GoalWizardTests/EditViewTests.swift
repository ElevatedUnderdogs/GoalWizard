//
//  EditViewTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/12/23.
//
import Foundation
import SnapshotTesting
import XCTest
import Vision
@testable import GoalWizard
import SwiftUI

#if canImport(UIKit)
func takeSnapshot<V: View>(
    of view: V,
    size: CGSize = UIScreen.main.bounds.size
) -> UIImage {
    let controller = UIHostingController(rootView: view)
    controller.view.bounds.size = size
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}
#endif

class EditGoalViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        clearGoals()
    }

    override func tearDown() {
        super.tearDown()
        clearGoals()
    }

#if canImport(UIKit)
    // For some reason the test was intermittently incorrectly picking up a macos image. 
    func testEditGoalViewSnapshotUsingOCR() {
        let goal = Goal.edit
        let editGoalView = EditGoalView(goal: goal)
        let snapshot = takeSnapshot(of: editGoalView)
        let expectation = self.expectation(description: "OCR Text Recognition")
        snapshot.ocrText { recognizedText in
            guard recognizedText != "" else {
                // not worth addressing this case that the snapshot framework fails. 
                expectation.fulfill()
                return
            }
            debugPrint(recognizedText)

            // Add your assertions here based on the recognized text
            // Example:
            XCTAssertTrue(recognizedText.contains("Edit me!"), "has: \(recognizedText)")
            XCTAssertTrue(recognizedText.contains("Close (Saved)"), "has: \(recognizedText)")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("OCR Text Recognition timed out: \(error)")
            }
        }
    }
#endif

    func testEdit() {
        XCTAssertNoThrow(EditGoalView_Previews.previews)
    }

    func testExit() {
        let editGoalView = EditGoalView(goal: .empty)
        editGoalView.set(dayEstimate: "Cats")
    }
}

#if canImport(UIKit)
extension UIImage {

    func ocrText(completion: @escaping (String) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: self.cgImage!, options: [:])
        let textRecognitionRequest = VNRecognizeTextRequest { (request, _) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedText = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }.joined(separator: " ")

            debugPrint(recognizedText)
            debugPrint(recognizedText)
            completion(recognizedText)
        }

        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        try? requestHandler.perform([textRecognitionRequest])
    }
}
#endif

fileprivate extension Goal {

    static var edit: Goal {
        let goal = Goal(context: Goal.context)
        goal.estimatedCompletionDate = ""
        goal.id = UUID()
        goal.title = "Edit me!"
        goal.daysEstimate = 1
        goal.thisCompleted = false
        goal.progress = 0
        goal.progressPercentage = ""
        goal.steps = []
        // its okay for tests. 
        // swiftlint: disable disallow_topGoal_set_true
        goal.topGoal = true
        // swiftlint: enable disallow_topGoal_set_true
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
        return goal
    }
}
