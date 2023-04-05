//
//  GoalWizardApp.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import SwiftUI

@main
struct GoalWizardApp: App {
    var body: some Scene {
        WindowGroup {
            GoalView(goal: .start)
        }
    }
}
