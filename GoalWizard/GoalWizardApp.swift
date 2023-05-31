//
//  GoalWizardApp.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import SwiftUI

class GoalPasteBoard: ObservableObject {
    @Published var cutGoal: Goal?
}

@main
struct GoalWizardApp: App {

   var pasteBoard = GoalPasteBoard()

    var body: some Scene {
        WindowGroup {
            GoalView(goal: .start, pasteBoard: pasteBoard)
        }
    }
}
