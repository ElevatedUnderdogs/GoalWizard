//
//  URLRequest.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/5/23.
//

import Foundation

extension URL {
    static var davinci: URL {
        URL(string: "https://api.openai.com/v1/engines/davinci/completions")!
    }

    static var gpt35Turbo: URL {
         URL(string: "https://api.openai.com/v1/chat/completions")!
     }

    static var models: URL {
        URL(string: "https://api.openai.com/v1/models")!
    }
}
// URLRequest extension to create an OpenAI API request
extension URLRequest {

    static var models: URLRequest {
        // Set your API key here
        // file not tracked by git, saved also in keychain.
        let apiKey = Secrets.openAIKey
        var request = URLRequest(url: .models)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }


    static func openAIRequest(
        url: URL = .davinci,
        prompt: String
    ) -> URLRequest {
        // Set your API key here
        // file not tracked by git, saved also in keychain. 
        let apiKey = Secrets.openAIKey

        // Configure the API request

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set the parameters for the API call
        let parameters: [String: Any] = [
            "prompt": prompt, // The text prompt to send to the API
            "max_tokens": 50,  // The maximum number of tokens (words or word pieces) to generate
            "n": 1,            // The number of generated responses to return
            "stop": ["\n"]     // The sequence(s) where the API should stop generating tokens
        ]

        // Encode the parameters as JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        return request
    }

    /**
         Creates a URLRequest for the GPT-3.5 Turbo chat model.

         - Parameters:
           - messages: An array of dictionaries with a `role` and `content` key.
                       Each dictionary represents a message in the conversation.
                       The `role` can be either "user" or "assistant", and `content`
                       contains the text of the message.
           - temperature: A double value that adjusts the randomness of the generated
                          response. Higher values (e.g., 1.0) make the output more random,
                          while lower values (e.g., 0.1) make it more deterministic.
                          The default value is 0.7.
           - url: The API endpoint URL. The default value is the GPT-3.5 Turbo URL.

         - Returns: A URLRequest configured for the GPT-3.5 Turbo chat model.
         */
        static func gpt35TurboChatRequest(
            messages: [[String: String]],
            temperature: Double = 0.7,
            url: URL = .gpt35Turbo
        ) -> URLRequest {
            // Set your API key here
            // file not tracked by git, saved also in keychain.
            let apiKey = Secrets.openAIKey

            // Configure the API request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Set the parameters for the API call
            let parameters: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": messages,
                "temperature": temperature
            ]

            // Encode the parameters as JSON
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

            return request
        }
}


// Extension to create messages for GPT-3.5 Turbo chat requests
extension Array where Element == [String: String] {
    static func buildUserMessage(content: String) -> [[String: String]] {
        let message = ["role": "user", "content": content]
        return [message]
    }

    static func buildAssistantMessage(content: String) -> [[String: String]] {
        let message = ["role": "assistant", "content": content]
        return [message]
    }
}
