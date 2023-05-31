//
//  SubGoalMock.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/10/23.
//

import XCTest
@testable import GoalWizard
import CoreData

// Additional mock class for simulating error in JSON decoding
struct ErrorSubGoalMock: HasCallCodable {
    func callCodable<T>(
        expressive: Bool,
        _ action: @escaping (T?) -> Void
    ) where T: Decodable, T: Encodable {
        let invalidContent = "{\"invalid_key\": \"invalid_value\"}"
        let invalidMessage = Message<T>(content: invalidContent, role: "user")

        do {
            _ = try invalidMessage.content.decodedContent() as T
            action(nil)
        } catch {
            print("Error decoding content:", error.localizedDescription)
            action(nil)
        }
    }
}

struct SubGoalMock: HasCallCodable {

    func callCodable<T>(
        expressive: Bool,
        _ action: @escaping (T?) -> Void
    ) where T: Decodable, T: Encodable {
        // JSON string containing sample data for OpenAIResponse<Choices>
        // swiftlint: disable line_length
        let jsonString = """
        {
            "choices": [
                {
                    "message": {
                        "content": "{\\"thisSteps\\":[{\\"title\\":\\"Step 1\\",\\"daysEstimate\\":3,\\"steps\\":[{\\"subtitle\\":\\"Substep 1.1\\",\\"subdaysEstimate\\":1},{\\"subtitle\\":\\"Substep 1.2\\",\\"subdaysEstimate\\":2}]},{\\"title\\":\\"Step 2\\",\\"daysEstimate\\":5,\\"steps\\":[{\\"subtitle\\":\\"Substep 2.1\\",\\"subdaysEstimate\\":2},{\\"subtitle\\":\\"Substep 2.2\\",\\"subdaysEstimate\\":3}]}]}",
                        "role": "ai"
                    },
                    "finishReason": "stop",
                    "index": 0
                }
            ],
            "id": "example-id",
            "model": "text-davinci-002",
            "usage": {
                "total_tokens": 50,
                "completion_tokens": 25,
                "prompt_tokens": 25
            },
            "object": "list",
            "created": 1677649420.123456
        }
        """
        // swiftlint: enable line_length

        // Convert the JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            action(nil)
            return
        }

        // Decode the JSON data into an object of the required type
        let decoder = JSONDecoder()
        do {
            let responseObject = try decoder.decode(T.self, from: jsonData)
            action(responseObject)
        } catch {
            print("Error decoding JSON: \(error)")
            action(nil)
        }
    }
}
