//
//  String.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/5/23.
//

import Foundation

extension String {

    static func goalTreeFrom(goal: String) -> String {
        """
        Example prompt:
        Return all the necessary sub tasks for the following goal: “become a lawyer in Ireland.” For each of this sub tasks return a list of sub tasks.  Keep on going, until a task tree is created, where each leaf is an easy task.  Return the task tree exclusively as a logically structured json object.  Omit anything else.

        Example response:
        {
          "title": "Become a Lawyer in Ireland",
          "daysEstimate": 180,
          "steps": [
            {
              "title": "Research law schools in Ireland",
              "daysEstimate": 3,
              "steps": [
                {
                  "title": "Look up law schools in Ireland online",
                  "daysEstimate": 1,
                  "steps": []
                },
                {
                  "title": "Research admission requirements for each school",
                  "daysEstimate": 2,
                  "steps": []
                },
                {
                  "title": "Make a list of top law schools in Ireland",
                  "daysEstimate": 1,
                  "steps": []
                }
              ]
            },
            {
              "title": "Study for LSAT",
              "daysEstimate": 30,
              "steps": [
                {
                  "title": "Purchase LSAT study materials",
                  "daysEstimate": 2,
                  "steps": []
                },
                {
                  "title": "Create study plan for LSAT",
                  "daysEstimate": 3,
                  "steps": []
                },
                {
                  "title": "Study for LSAT",
                  "daysEstimate": 25,
                  "steps": []
                }
              ]
            },
            {
              "title": "Apply to law schools in Ireland",
              "daysEstimate": 120,
              "steps": [
                {
                  "title": "Gather necessary application materials",
                  "daysEstimate": 5,
                  "steps": []
                },
                {
                  "title": "Fill out and submit applications",
                  "daysEstimate": 115,
                  "steps": []
                }
              ]
            },
            {
              "title": "Prepare for move to Ireland",
              "daysEstimate": 27,
              "steps": [
                {
                  "title": "Research living arrangements in Ireland",
                  "daysEstimate": 2,
                  "steps": []
                },
                {
                  "title": "Apply for necessary visas",
                  "daysEstimate": 15,
                  "steps": []
                },
                {
                  "title": "Pack and prepare for move",
                  "daysEstimate": 10,
                  "steps": []
                }
              ]
            }
          ]
        }

        Current prompt:
        Return all the necessary sub tasks for the following goal: “\(goal)” For each of the sub tasks return a list of sub tasks.  Keep on going, until a task tree is created, where each leaf is an easy task.  Return the task tree exclusively as a logically structured json object.  Omit anything else, JSON ONLY!.
        """
    }
}


class MyDecoder {
    var parsedObjects: [String: Any] = [:]

    func decode(json: Data) throws -> Any? {
        let jsonObject = try JSONSerialization.jsonObject(with: json, options: [])

        return try decodeValue(jsonObject)
    }

    private func decodeValue(_ value: Any) throws -> Any? {
        switch value {
        case let dict as [String: Any]:
            if let refId = dict["__ref"] as? String {
                return parsedObjects[refId]
            }
            let newObject = MyObject()
            parsedObjects[ObjectIdentifier(newObject).debugDescription] = newObject

            for (key, subValue) in dict {
                newObject[key] = try decodeValue(subValue)
            }
            return newObject
        case let array as [Any]:
            return try array.map { try decodeValue($0) }
        default:
            return value
        }
    }
}

/*
 let options = PropertyListSerialization.WriteOptions(0)
 if PropertyListSerialization.propertyList(anyObject, isValidFor: .binary),
    let data: Data = try? PropertyListSerialization.data(fromPropertyList: anyObject, format: .binary, options: 0) {
     let goal = try? JSONDecoder().decode(GoalStruct.self, from: data)
     print("succeeded? \(goal?.steps.map(\.title) as Any)")
 }

 if PropertyListSerialization.propertyList(anyObject, isValidFor: .openStep),
    let data: Data = try? PropertyListSerialization.data(fromPropertyList: anyObject, format: .openStep, options: 0) {
     let goal = try? JSONDecoder().decode(GoalStruct.self, from: data)
     print("succeeded? \(goal?.steps.map(\.title) as Any)")
 }

 if PropertyListSerialization.propertyList(anyObject, isValidFor: .xml),
    let data: Data = try? PropertyListSerialization.data(fromPropertyList: anyObject, format: .xml, options: 0) {
     let goal = try? JSONDecoder().decode(GoalStruct.self, from: data)
     print("succeeded? \(goal?.steps.map(\.title) as Any)")
 }

 print(valueJSON["content"] as? [AnyHashable: Any])
 print(valueJSON["content"] as? String)
 print((valueJSON["content"] as? String)?.json)

 print(try? JSONSerialization.isValidJSONObject(valueJSON["content"]))

 guard let data = try? JSONSerialization.data(withJSONObject: valueJSON["content"] ?? [:]),
       let jsonString = String(data: data, encoding: .utf8),
       let json = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as? [String: Any] else {
     print("Failed to cast valueJSON to dictionary")
     return
 }

 print(json)
 guard let content: [String: Any] = valueJSON["content"] as? [String: Any] else {
     return
 }
 let gptGoal: Goal? = .fromJsonIterative(json: content)
 print(goal.title)
 print(gptGoal?.title)
 print(gptGoal?.steps.goals.map(\.title))
 */
