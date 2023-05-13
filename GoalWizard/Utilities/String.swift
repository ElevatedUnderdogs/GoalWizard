//
//  String.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/5/23.
//

import Foundation

extension String {

    static var appIcon: String {
        "AppIcon"
    }

    static var appIconBlk: String {
        "AppIconBlk"
    }

    // swiftlint: disable function_body_length
    // swiftlint: disable line_length
    static func goalTreeFrom(goal: String) -> String {
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
        Return all the necessary sub tasks for the following goal: “\(goal)” For each of the sub tasks return a list of sub tasks.  Keep on going, until a task tree is created, where each leaf is an easy task.  Return the task tree exclusively as a logically structured json object.  Omit anything else, JSON ONLY!.

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
    }
    // swiftlint: enable function_body_length
    // swiftlint: enable line_length
}
