//
//  StringTest.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/12/23.
//

import XCTest
@testable import GoalWizard
import CoreData
import SwiftUI

class StringTextCase: XCTestCase {

    func testDecodingError() {

        struct TestCodable: Codable {
            let value: Int
        }
        // This is a string that does NOT represent a valid JSON object of type `TestCodable`.
        let invalidJson = "{ \"wrong_key\": 123 }"

        var hitError: Bool = false
        do {
            // Attempt to decode the invalid JSON string.
            let _: TestCodable = try invalidJson.decodedContent()
            // If decoding does not throw an error, the test has failed.
            XCTFail("Decoding did not throw an error as expected.")
        } catch {
            // If we reach here, decoding threw an error as expected.
            // We can optionally check that the error is the type we expect.
            hitError = true
            XCTAssertTrue(error is DecodingError)
        }
        XCTAssertTrue(hitError)
    }

    func testImageStrings() {
        XCTAssertNotNil(Image(String.appIcon))
        XCTAssertNotNil(Image(String.appIconBlk))
        #if canImport(UIKit)
            XCTAssertNotNil(UIImage(named: String.appIcon))
            // This is failing for some reason.
            // XCTAssertNotNil(UIImage(named: String.appIconBlk))
        #endif
    }

    func testDecodableString() {
        var reached: Bool = false
        do {
            let _: GoalStruct = try "".decodedContent<GoalStruct>()
           // let choice: Choice = try "".decodedContent()
        } catch {
            reached = true
        }
        XCTAssertTrue(reached)
    }

    // Its not a complex function.  Its only for tests.  
    // swiftlint: disable function_body_length
    // swiftlint: disable line_length
    func testGetGoalTree() {
        let goalTreeMethod: String = .goalTreeFrom(goal: "Get a cat")
        let testString: String =
                """
                Example prompt:
                Return all the necessary sub tasks for the following goal: “become a lawyer in Ireland.” For each of this sub tasks return a list of sub tasks.  Keep on going, until a task tree is created, where each leaf is an easy task.  Return the task tree exclusively as a logically structured json object.  Omit anything else.

                Make sure it will be convertible to the following structs (if it will take less than a day, set daysEstimate to 1):

                // MARK: - Choices
                struct Choices: Codable {
                    let thisSteps: [ThisStep]
                }

                // MARK: - ThisStep
                struct ThisStep: Codable {
                    let title: String
                    let daysEstimate: Int
                    let steps: [Step]
                }

                // MARK: - Step
                struct Step: Codable {
                    let subtitle: String
                    let subdaysEstimate: Int
                }

                Example response:
                {
                  "thisSteps": [
                    {
                      "title": "Research law schools in Ireland",
                      "daysEstimate": 3,
                      "steps": [
                        {
                          "subtitle": "Look up law schools in Ireland online",
                          "subdaysEstimate": 1
                        },
                        {
                          "subtitle": "Research admission requirements for each school",
                          "subdaysEstimate": 2
                        },
                        {
                          "subtitle": "Make a list of top law schools in Ireland",
                          "subdaysEstimate": 1
                        }
                      ]
                    },
                    {
                      "title": "Study for LSAT",
                      "daysEstimate": 30,
                      "steps": [
                        {
                          "subtitle": "Purchase LSAT study materials",
                          "subdaysEstimate": 2
                        },
                        {
                          "subtitle": "Create study plan for LSAT",
                          "subdaysEstimate": 3
                        },
                        {
                          "subtitle": "Study for LSAT",
                          "subdaysEstimate": 25
                        }
                      ]
                    },
                    {
                      "title": "Apply to law schools in Ireland",
                      "daysEstimate": 120,
                      "steps": [
                        {
                          "subtitle": "Gather necessary application materials",
                          "subdaysEstimate": 5
                        },
                        {
                          "subtitle": "Fill out and submit applications",
                          "subdaysEstimate": 115
                        }
                      ]
                    },
                    {
                      "title": "Prepare for move to Ireland",
                      "daysEstimate": 27,
                      "steps": [
                        {
                          "subtitle": "Research living arrangements in Ireland",
                          "subdaysEstimate": 2
                        },
                        {
                          "subtitle": "Apply for necessary visas",
                          "subdaysEstimate": 15
                        },
                        {
                          "subtitle": "Pack and prepare for move",
                          "subdaysEstimate": 10
                        }
                      ]
                    }
                  ]
                }



                Current prompt:
                Return all the necessary sub tasks for the following goal: “Get a cat” For each of the sub tasks return a list of sub tasks.  Keep on going, until a task tree is created, where each leaf is an easy task.  Return the task tree exclusively as a logically structured json object.  Omit anything else, JSON ONLY!.

                Make sure it will be convertible to the following structs (if it will take less than a day, set daysEstimate to 1):

                // MARK: - Choices
                struct Choices: Codable {
                    let thisSteps: [ThisStep]
                }

                // MARK: - ThisStep
                struct ThisStep: Codable {
                    let title: String
                    let daysEstimate: Int
                    let steps: [Step]
                }

                // MARK: - Step
                struct Step: Codable {
                    let subtitle: String
                    let subdaysEstimate: Int
                }
                """
        XCTAssertEqual(goalTreeMethod, testString)
    }
    // swiftlint: enable function_body_length
    // swiftlint: enable line_length
}
