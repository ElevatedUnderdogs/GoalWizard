//
//  DateFormatterTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//

import Foundation

import XCTest
@testable import GoalWizard

class DateFormatterTests: XCTestCase {

    func testMonthDayYearString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let testDate1 = dateFormatter.date(from: "2023-02-21")!
        let testDate2 = dateFormatter.date(from: "2022-12-31")!
        let testDate3 = dateFormatter.date(from: "2021-01-01")!

        let expectedOutput1 = "2/21/23"
        let expectedOutput2 = "12/31/22"
        let expectedOutput3 = "1/1/21"

        XCTAssertEqual(
            DateFormatter.monthDayYearString(from: testDate1),
            expectedOutput1, "Formatted date string should match expected output for testDate1"
        )
        XCTAssertEqual(
            DateFormatter.monthDayYearString(from: testDate2),
            expectedOutput2, "Formatted date string should match expected output for testDate2"
        )
        XCTAssertEqual(
            DateFormatter.monthDayYearString(from: testDate3),
            expectedOutput3, "Formatted date string should match expected output for testDate3"
        )
    }
}
