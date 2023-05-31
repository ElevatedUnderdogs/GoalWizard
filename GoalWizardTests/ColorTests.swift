//
//  ColorTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//
import XCTest
import SwiftUI
import SnapshotTesting
@testable import GoalWizard

extension Color {
    var cgColor: CGColor? {
        #if canImport(UIKit)
        return UIColor(self).cgColor
        #elseif canImport(AppKit)
        return NSColor(self).cgColor
        #else
        return nil
        #endif
    }
}

extension CGColor {
    var hexString: String? {
        guard let components = components, components.count >= 3 else {
            return nil
        }
        return String(
            format: "#%02X%02X%02X",
            Int(components[0] * 255),
            Int(components[1] * 255),
            Int(components[2] * 255)
        )
    }
}

class ColorTests: XCTestCase {
    func testSystemGray6() {
        XCTAssertEqual(Color.systemGray6.cgColor?.hexString, "#000000")
    }

    func testSystemCompatibleTeal() {
        XCTAssertEqual(Color.systemCompatibleTeal.cgColor?.hexString, "#2FB0C7")
    }

    func testSystemCompatibleBlue() {
        XCTAssertEqual(Color.systemCompatibleBlue.cgColor?.hexString, "#007AFE")
    }

    func testGoalGreen() {
        XCTAssertEqual(Color.goalGreen.cgColor?.hexString, "#33C758")
    }

    func testHierarchyPink() {
        XCTAssertEqual(Color.hierarchyPink.cgColor?.hexString, "#FE989E")
    }
}
