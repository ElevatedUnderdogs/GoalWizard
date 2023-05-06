//
//  DateFormatter.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/2/23.
//

import Foundation

extension DateFormatter {

    /// "EEE", for example: Mon'
    static func dayOfWeekString(from date: Date) -> String {
        DateFormatter.dayOfWeek.string(from: date)
    }

    /// "EEE", for example: Mon'
    /// Private to ensure no write operations are executed and the DateFormatter is not shared for the same risk.
    private static let dayOfWeek: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()

    /// "M/d EEE", for example: 3/14 Tue
    static func monthDayDayOfWeekString(from date: Date) -> String {
        DateFormatter.monthDayDayOfWeek.string(from: date)
    }

    /// "M/d EEE", for example: 3/14 Tue
    /// Private to ensure no write operations are executed and the DateFormatter is not shared for the same risk.
    private static let monthDayDayOfWeek: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d EEE"
        return dateFormatter
    }()

    /// "M/d/yy", for example: 2/21/23
    static func monthDayYearString(from date: Date) -> String {
        DateFormatter.monthDayYear.string(from: date)
    }

    /// "M/d/yy", for example: 2/21/23
    /// Private to ensure no write operations are executed and the DateFormatter is not shared for the same risk.
    private static let monthDayYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        return dateFormatter
    }()
}
