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

func takeSnapshot<V: View>(of view: V, size: CGSize = UIScreen.main.bounds.size) -> UIImage {
     let controller = UIHostingController(rootView: view)
     controller.view.bounds.size = size
     UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
     controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
     let image = UIGraphicsGetImageFromCurrentImageContext()!
     UIGraphicsEndImageContext()
     return image
 }

class EditGoalViewTests: XCTestCase {

    // For some reason the test was intermittently incorrectly picking up a macos image. 
    func testEditGoalViewSnapshotUsingOCR() {


        let goal = Goal.edit
        let editGoalView = EditGoalView(goal: goal)
        let snapshot = takeSnapshot(of: editGoalView)
        let expectation = self.expectation(description: "OCR Text Recognition")
        snapshot.ocrText { recognizedText in
            print(recognizedText)

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


}

extension UIImage {

    func ocrText(completion: @escaping (String) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: self.cgImage!, options: [:])
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedText = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }.joined(separator: " ")

            print(recognizedText)
            print(recognizedText)
            completion(recognizedText)
        }

        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        try? requestHandler.perform([textRecognitionRequest])
    }
}

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
        goal.topGoal = true
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
        return goal
    }
}
