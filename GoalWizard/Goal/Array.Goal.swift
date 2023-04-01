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

    var progress: Decimal {
        Decimal(daysLeft) / Decimal(totalDays)
    }
}
