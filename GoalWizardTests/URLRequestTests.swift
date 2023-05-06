//
//  URLRequestTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/12/23.
//

import Foundation
import XCTest
@testable import GoalWizard

class YourAppModuleTests: XCTestCase {

    func testURLExtensions() {
        XCTAssertEqual(URL.davinci, URL(string: "https://api.openai.com/v1/engines/davinci/completions")!)
        XCTAssertEqual(URL.gpt35Turbo, URL(string: "https://api.openai.com/v1/chat/completions")!)
        XCTAssertEqual(URL.models, URL(string: "https://api.openai.com/v1/models")!)
    }

    func testURLRequestModels() {
        let request = URLRequest.models
        XCTAssertEqual(request.url, URL.models)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testOpenAIRequest() {
        let prompt = "Test prompt"
        let request = URLRequest.openAIRequest(prompt: prompt)

        XCTAssertEqual(request.url, URL.davinci)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let httpBody = try? JSONSerialization.jsonObject(with: request.httpBody!, options: []) as? [String: Any]
        XCTAssertEqual(httpBody?["prompt"] as? String, prompt)
        XCTAssertEqual(httpBody?["max_tokens"] as? Int, 50)
        XCTAssertEqual(httpBody?["n"] as? Int, 1)
        XCTAssertEqual(httpBody?["stop"] as? [String], ["\n"])
    }

    func testGpt35TurboChatRequest() {
        let messages = [["role": "user", "content": "Hello"]]
        let temperature = 0.7
        let request = URLRequest.gpt35TurboChatRequest(messages: messages, temperature: temperature)

        XCTAssertEqual(request.url, URL.gpt35Turbo)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let httpBody = try? JSONSerialization.jsonObject(with: request.httpBody!, options: []) as? [String: Any]
        XCTAssertEqual(httpBody?["model"] as? String, "gpt-3.5-turbo")
        XCTAssertEqual(httpBody?["messages"] as? [[String: String]], messages)
        XCTAssertEqual(httpBody?["temperature"] as? Double, temperature)
    }

    func testMessageExtensions() {
        let userMessageContent = "Hello, Assistant!"
        let assistantMessageContent = "Hello, User!"

        let userMessage = [["role": "user", "content": userMessageContent]]
        let assistantMessage = [["role": "assistant", "content": assistantMessageContent]]

        XCTAssertEqual([[String: String]].buildUserMessage(content: userMessageContent), userMessage)
        XCTAssertEqual([[String: String]].buildAssistantMessage(content: assistantMessageContent), assistantMessage)
    }
}
