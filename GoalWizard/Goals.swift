//
//  Goals.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/14/23.
//

import Foundation

extension [Goal] {

    var totalDays: Int64 {
        reduce(0) { $0 + $1.totalDays }
    }

    var daysLeft: Int64 {
        reduce(0) { $0 + $1.daysLeft }
    }

    var progress: Double {
        // Set the total days to steps as 0, just 1 step
        // with 0 estimatedDays force assign it, then read the progress from the list.
        guard totalDays > 0 else { return 0 }
        return Double(totalDays - daysLeft) / Double(totalDays)
    }

    func filteredSteps(with searchText: String) -> (incomplete: [Goal], completed: [Goal]) {
        let filteredGoals: [Goal] = searchText.isEmpty ? [] : filter { goal in
            goal.title?.lowercased().contains(searchText.lowercased()) == true
        }
        return (
            incomplete: filteredGoals
                .filter { $0.progress < 1 }
                .sorted {
                    $0.progress == $1.progress ? $0.daysLeft < $1.daysLeft :
                    $0.progress > $1.progress
                },
            completed: filteredGoals.filter { $0.progress == 1 }
        )
    }
}
