//
//  Array.Goal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import Foundation

extension [Goal] {

    var totalDays: Int {
        reduce(0) { $0 + $1.totalDays }
    }

    var daysLeft: Int {
        reduce(0) { $0 + $1.daysLeft }
    }

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(totalDays - daysLeft) / Double(totalDays)
    }
}
