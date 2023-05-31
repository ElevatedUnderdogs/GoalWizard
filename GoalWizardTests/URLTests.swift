//
//  URLTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/12/23.
//
import XCTest
@testable import GoalWizard

class URLTests: XCTestCase {

    func testStaticURLs() {
        XCTAssertEqual(URL.davinci, URL(string: "https://api.openai.com/v1/engines/davinci/completions")!)
        XCTAssertEqual(URL.gpt35Turbo, URL(string: "https://api.openai.com/v1/chat/completions")!)
        XCTAssertEqual(URL.models, URL(string: "https://api.openai.com/v1/models")!)
    }

    func testModelsRequest() {
        let request = URLRequest.models
        XCTAssertEqual(request.url, URL.models)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertTrue(request.value(forHTTPHeaderField: "Authorization")?.starts(with: "Bearer ") ?? false)
    }

    func testOpenAIRequest() {
        let prompt = "Example prompt"
        let request = URLRequest.openAIRequest(prompt: prompt)

        XCTAssertEqual(request.url, URL.davinci)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertTrue(request.value(forHTTPHeaderField: "Authorization")?.starts(with: "Bearer ") ?? false)

        if let httpBody = request.httpBody {
            let decoded = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any]
            XCTAssertEqual(decoded?["prompt"] as? String, prompt)
            XCTAssertEqual(decoded?["max_tokens"] as? Int, 50)
            XCTAssertEqual(decoded?["n"] as? Int, 1)
            XCTAssertEqual(decoded?["stop"] as? [String], ["\n"])
        } else {
            XCTFail("Request body not found")
        }
    }

    func testGpt35TurboChatRequest() {
        let messages: [[String: String]] = [["role": "user", "content": "Hello"]]
        let temperature = 0.7
        let request = URLRequest.gpt35TurboChatRequest(messages: messages, temperature: temperature)

        XCTAssertEqual(request.url, URL.gpt35Turbo)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertTrue(request.value(forHTTPHeaderField: "Authorization")?.starts(with: "Bearer ") ?? false)

        if let httpBody = request.httpBody {
            let decoded = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any]
            XCTAssertEqual(decoded?["model"] as? String, "gpt-3.5-turbo")
            XCTAssertEqual(decoded?["messages"] as? [[String: String]], messages)
            XCTAssertEqual(decoded?["temperature"] as? Double, temperature)
        } else {
            XCTFail("Request body not found")
        }
    }

    func testBuildUserMessage() {
        let content = "Hello"
        let userMessage = [[String: String]].buildUserMessage(content: content)
        XCTAssertEqual(userMessage, [["role": "user", "content": content]])
    }

    func testBuildAssistantMessage() {
        let content = "Hello"
        let assistantMessage = [[String: String]].buildAssistantMessage(content: content)
        XCTAssertEqual(assistantMessage, [["role": "assistant", "content": content]])
    }
}
