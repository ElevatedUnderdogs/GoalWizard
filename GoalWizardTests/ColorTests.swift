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
    
    func toCGColor() -> CGColor? {
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
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

class ColorTests: XCTestCase {
    func testSystemGray6() {
        let color = Color.systemGray6
        XCTAssertEqual(color.toCGColor()?.hexString, "#000000")
    }

    func testSystemCompatibleTeal() {
        let color = Color.systemCompatibleTeal
        XCTAssertEqual(color.toCGColor()?.hexString, "#2FB0C7")
    }

    func testSystemCompatibleBlue() {
        let color = Color.systemCompatibleBlue
        XCTAssertEqual(color.toCGColor()?.hexString, "#007AFE")
    }

    func testGoalGreen() {
        let color = Color.goalGreen
        XCTAssertEqual(color.toCGColor()?.hexString, "#33C758")
    }
}
