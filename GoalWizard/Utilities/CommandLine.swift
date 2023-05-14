//
//  CommandLine.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/14/23.
//

import Foundation

struct MockGPTBuilder: HasCallCodable {

//    var content: String

    func callCodable<T: Codable>(expressive: Bool, _ action: @escaping (T?) -> Void) {
        // Create the mocked response
        let step = Step(subtitle: "Step subtitle", subdaysEstimate: 7)
        let thisStep = ThisStep(title: "Look up different types of vegetables", daysEstimate: 7, steps: [step])
        let choices = Choices(thisSteps: [thisStep])

        // Convert the choices object to JSON string
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let choicesData = try? encoder.encode(choices),
              let choicesJsonString = String(data: choicesData, encoding: .utf8) else {
            return
        }

        let message = Message<Choices>(content: choicesJsonString, role: "system")
        let choice = Choice<Choices>(message: message, finishReason: "stop", index: 0)
        let usage = Usage(totalTokens: 0, completionTokens: 0, promptTokens: 0)
        let response = OpenAIResponse<Choices>(
            choices: [choice],
            id: "mocked_id",
            model: "text-davinci-002",
            usage:
                usage, object: "text.completion",
            created: 0.0
        )

        // Call the completion handler with the mocked response
        action(response as? T)
    }
}

// Provided for UITesting purposes.
extension CommandLine {
    typealias TextToHasCancellable = (_ text: String) -> HasCallCodable
    static var gptBuilder: TextToHasCancellable? {
        arguments.contains("gptBuilder") ? { _ in MockGPTBuilder() } : nil
    }
}
